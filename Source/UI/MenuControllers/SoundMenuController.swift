//
//  SoundMenuController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Provides actions for the Sound menu that alter the sound output.
 
    NOTE - No actions are directly handled by this class. Command notifications are published to another app component that is responsible for these functions.
 */
class SoundMenuController: NSObject, NSMenuDelegate {
    
    @IBOutlet weak var devicesMenu: NSMenu!
    
    // Menu items that are not always accessible
    @IBOutlet weak var panLeftMenuItem: NSMenuItem!
    @IBOutlet weak var panRightMenuItem: NSMenuItem!
    
    @IBOutlet weak var masterBypassMenuItem: ToggleMenuItem!
    
    @IBOutlet weak var eqMenu: NSMenuItem!
    @IBOutlet weak var pitchMenu: NSMenuItem!
    @IBOutlet weak var timeMenu: NSMenuItem!
    
    // Menu items that hold specific associated values
    
    // Pitch shift menu items (with specific pitch shift values)
    @IBOutlet weak var twoOctavesBelowMenuItem: SoundParameterMenuItem!
    @IBOutlet weak var oneOctaveBelowMenuItem: SoundParameterMenuItem!
    @IBOutlet weak var oneOctaveAboveMenuItem: SoundParameterMenuItem!
    @IBOutlet weak var twoOctavesAboveMenuItem: SoundParameterMenuItem!
    
    // Playback rate (Time) menu items (with specific playback rate values)
    @IBOutlet weak var rate0_25MenuItem: SoundParameterMenuItem!
    @IBOutlet weak var rate0_5MenuItem: SoundParameterMenuItem!
    @IBOutlet weak var rate0_75MenuItem: SoundParameterMenuItem!
    @IBOutlet weak var rate1_25MenuItem: SoundParameterMenuItem!
    @IBOutlet weak var rate1_5MenuItem: SoundParameterMenuItem!
    @IBOutlet weak var rate2MenuItem: SoundParameterMenuItem!
    @IBOutlet weak var rate3MenuItem: SoundParameterMenuItem!
    @IBOutlet weak var rate4MenuItem: SoundParameterMenuItem!
    
    @IBOutlet weak var rememberSettingsMenuItem: ToggleMenuItem!
    
    // Delegate that alters the audio graph
    private lazy var graph: AudioGraphDelegateProtocol = audioGraphDelegate
    private let soundProfiles: SoundProfiles = audioGraphDelegate.soundProfiles
    
    private lazy var masterUnit: MasterUnitDelegateProtocol = graph.masterUnit
    private lazy var eqUnit: EQUnitDelegateProtocol = graph.eqUnit
    private lazy var pitchShiftUnit: PitchShiftUnitDelegateProtocol = graph.pitchShiftUnit
    private lazy var timeStretchUnit: TimeStretchUnitDelegateProtocol = graph.timeStretchUnit
    
    private let soundPreferences: SoundPreferences = preferences.soundPreferences
    
    lazy var effectsPresetsManager: EffectsPresetsManagerWindowController = .instance
    
    private lazy var messenger = Messenger(for: self)
    
    // One-time setup.
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // Associate each of the menu items with a specific pitch shift or playback rate value, so that when the item is clicked later, that value can be readily retrieved and used in performing the action.
        
        // Pitch shift menu items
        twoOctavesBelowMenuItem.paramValue = -2
        oneOctaveBelowMenuItem.paramValue = -1
        oneOctaveAboveMenuItem.paramValue = 1
        twoOctavesAboveMenuItem.paramValue = 2
        
        // Playback rate (Time) menu items
        rate0_25MenuItem.paramValue = 0.25
        rate0_5MenuItem.paramValue = 0.5
        rate0_75MenuItem.paramValue = 0.75
        rate1_25MenuItem.paramValue = 1.25
        rate1_5MenuItem.paramValue = 1.5
        rate2MenuItem.paramValue = 2
        rate3MenuItem.paramValue = 3
        rate4MenuItem.paramValue = 4
    }
    
    // When the menu is about to open, update the menu item states
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        [panLeftMenuItem, panRightMenuItem].forEach {$0?.enableIf(!windowLayoutsManager.isShowingModalComponent)}
        rememberSettingsMenuItem.enableIf(playbackInfoDelegate.playingTrack != nil)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        // Audio output devices menu
        if menu == devicesMenu {
            
            // Recreate the menu each time
            
            devicesMenu.removeAllItems()
            
            let outputDeviceName: String = graph.outputDevice.name
            
            // Add menu items for each available device
            for device in graph.availableDevices {
                
                let menuItem = NSMenuItem(title: device.name, action: #selector(self.outputDeviceAction(_:)))
                menuItem.image = device.icon.image
                
                menuItem.representedObject = device
                menuItem.target = self
                
                devicesMenu.addItem(menuItem)
            
                // Select this item if it represents the current output device
                menuItem.onIf(outputDeviceName == menuItem.title)
            }
            
        } else {
            
            masterBypassMenuItem.onIf(!masterUnit.isActive)
            rememberSettingsMenuItem.showIf(!soundPreferences.rememberEffectsSettingsForAllTracks.value)
            
            if let playingTrack = playbackInfoDelegate.playingTrack {
                rememberSettingsMenuItem.onIf(soundProfiles.hasFor(playingTrack))
            }
        }
    }
    
    @IBAction func outputDeviceAction(_ sender: NSMenuItem) {
        
        if let outputDevice = sender.representedObject as? AudioDevice {
            graph.outputDevice = outputDevice
        }
    }
    
    // Mutes or unmutes the player
    @IBAction func muteOrUnmuteAction(_ sender: AnyObject) {
        messenger.publish(.Player.muteOrUnmute)
    }
    
    // Decreases the volume by a certain preset decrement
    @IBAction func decreaseVolumeAction(_ sender: Any) {
        messenger.publish(.Player.decreaseVolume, payload: UserInputMode.discrete)
    }
    
    // Increases the volume by a certain preset increment
    @IBAction func increaseVolumeAction(_ sender: Any) {
        messenger.publish(.Player.increaseVolume, payload: UserInputMode.discrete)
    }
    
    // Pans the sound towards the left channel, by a certain preset value
    @IBAction func panLeftAction(_ sender: Any) {
        messenger.publish(.Player.panLeft)
    }
    
    // Pans the sound towards the right channel, by a certain preset value
    @IBAction func panRightAction(_ sender: Any) {
        messenger.publish(.Player.panRight)
    }
    
    // Whether or not the Effects window is loaded (and is able to receive commands).
    var effectsWindowLoaded: Bool {windowLayoutsManager.isWindowLoaded(withId: .effects)}
    
    // Toggles the master bypass switch
    @IBAction func masterBypassAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            messenger.publish(.Effects.MasterUnit.toggleEffects)
        } else {
            _ = masterUnit.toggleState()
        }
    }
    
    @IBAction func managePresetsAction(_ sender: Any) {
        effectsPresetsManager.showWindow(self)
    }
    
    // Decreases each of the EQ bass bands by a certain preset decrement
    @IBAction func decreaseBassAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            messenger.publish(.Effects.EQUnit.decreaseBass)
        } else {
            _ = eqUnit.decreaseBass()
        }
    }
    
    // Provides a "bass boost". Increases each of the EQ bass bands by a certain preset increment.
    @IBAction func increaseBassAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            messenger.publish(.Effects.EQUnit.increaseBass)
        } else {
            _ = eqUnit.increaseBass()
        }
    }
    
    // Decreases each of the EQ mid-frequency bands by a certain preset decrement
    @IBAction func decreaseMidsAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            messenger.publish(.Effects.EQUnit.decreaseMids)
        } else {
            _ = eqUnit.decreaseMids()
        }
    }
    
    // Increases each of the EQ mid-frequency bands by a certain preset increment
    @IBAction func increaseMidsAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            messenger.publish(.Effects.EQUnit.increaseMids)
        } else {
            _ = eqUnit.increaseMids()
        }
    }
    
    // Decreases each of the EQ treble bands by a certain preset decrement
    @IBAction func decreaseTrebleAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            messenger.publish(.Effects.EQUnit.decreaseTreble)
        } else {
            _ = eqUnit.decreaseTreble()
        }
    }
    
    // Decreases each of the EQ treble bands by a certain preset increment
    @IBAction func increaseTrebleAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            messenger.publish(.Effects.EQUnit.increaseTreble)
        } else {
            _ = eqUnit.increaseTreble()
        }
    }
    
    // Decreases the pitch by a certain preset decrement
    @IBAction func decreasePitchAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            messenger.publish(.Effects.PitchShiftUnit.decreasePitch)
        } else {
            _ = pitchShiftUnit.decreasePitch()
        }
    }
    
    // Increases the pitch by a certain preset increment
    @IBAction func increasePitchAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            messenger.publish(.Effects.PitchShiftUnit.increasePitch)
        } else {
            _ = pitchShiftUnit.increasePitch()
        }
    }
    
    // Sets the pitch to a value specified by the menu item clicked
    @IBAction func setPitchAction(_ sender: SoundParameterMenuItem) {
        
        // Menu item's "paramValue" specifies the pitch shift value associated with the menu item (in cents)
        let pitch = sender.paramValue
        
        if effectsWindowLoaded {
            messenger.publish(.Effects.PitchShiftUnit.setPitch, payload: pitch)
            
        } else {
            
            pitchShiftUnit.pitch = PitchShift(fromCents: pitch)
            pitchShiftUnit.ensureActive()
        }
    }
    
    // Decreases the playback rate by a certain preset decrement
    @IBAction func decreaseRateAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            messenger.publish(.Effects.TimeStretchUnit.decreaseRate)
        } else {
            _ = timeStretchUnit.decreaseRate()
        }
    }
    
    // Increases the playback rate by a certain preset increment
    @IBAction func increaseRateAction(_ sender: Any) {
        
        // TODO: This logic only works for modular mode.
        if effectsWindowLoaded {
            messenger.publish(.Effects.TimeStretchUnit.increaseRate)
        } else {
            _ = timeStretchUnit.increaseRate()
        }
    }
    
    // Sets the playback rate to a value specified by the menu item clicked
    @IBAction func setRateAction(_ sender: SoundParameterMenuItem) {
        
        // Menu item's "paramValue" specifies the playback rate value associated with the menu item
        let rate = sender.paramValue
        
        if effectsWindowLoaded {
            messenger.publish(.Effects.TimeStretchUnit.setRate, payload: rate)
            
        } else {
            
            timeStretchUnit.rate = rate
            timeStretchUnit.ensureActive()
        }
    }
    
    @IBAction func rememberSettingsAction(_ sender: ToggleMenuItem) {
        messenger.publish(rememberSettingsMenuItem.isOff ? .Effects.saveSoundProfile : .Effects.deleteSoundProfile)
    }
}

// An NSMenuItem subclass that contains extra fields to hold information (similar to tags) associated with the menu item
class SoundParameterMenuItem: NSMenuItem {
    
    // A generic numerical parameter value
    var paramValue: Float = 0
}
