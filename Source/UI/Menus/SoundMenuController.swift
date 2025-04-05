//
//  SoundMenuController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
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
        
        let isReceivingTextInput: Bool = NSApp.isReceivingTextInput
        [panLeftMenuItem, panRightMenuItem].forEach {$0?.enableIf(!isReceivingTextInput)}
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
                
                let newItem = devicesMenu.addItem(withTitle: device.name,
                                                  action: #selector(self.outputDeviceAction(_:)),
                                                  target: self,
                                                  image: device.icon.image,
                                                  representedObject: device)
            
                // Select this item if it represents the current output device
                newItem.onIf(outputDeviceName == newItem.title)
            }
            
        } else {
            
            masterBypassMenuItem.onIf(masterUnit.isActive)
            
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
    
    // MARK: Volume ---------------------------------------------------------------------------
    
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
    
    // MARK: Pan ---------------------------------------------------------------------------
    
    // Pans the sound towards the left channel, by a certain preset value
    @IBAction func panLeftAction(_ sender: Any) {
        messenger.publish(.Player.panLeft)
    }
    
    // Pans the sound towards the right channel, by a certain preset value
    @IBAction func panRightAction(_ sender: Any) {
        messenger.publish(.Player.panRight)
    }
    
    // MARK: Master Unit ---------------------------------------------------------------------------
    
    // Toggles the master bypass switch
    @IBAction func masterBypassAction(_ sender: Any) {
        
        masterUnit.toggleState()
        messenger.publish(.Effects.MasterUnit.allEffectsToggled)
    }
    
    @IBAction func managePresetsAction(_ sender: Any) {
        effectsPresetsManager.showWindow(self)
    }
    
    // MARK: EQ ---------------------------------------------------------------------------
    
    // Decreases each of the EQ bass bands by a certain preset decrement
    @IBAction func decreaseBassAction(_ sender: Any) {
        
        eqUnit.decreaseBass()
        messenger.publish(.Effects.EQUnit.bandsUpdated)
    }
    
    // Provides a "bass boost". Increases each of the EQ bass bands by a certain preset increment.
    @IBAction func increaseBassAction(_ sender: Any) {
        
        eqUnit.increaseBass()
        messenger.publish(.Effects.EQUnit.bandsUpdated)
    }
    
    // Decreases each of the EQ mid-frequency bands by a certain preset decrement
    @IBAction func decreaseMidsAction(_ sender: Any) {
        
        eqUnit.decreaseMids()
        messenger.publish(.Effects.EQUnit.bandsUpdated)
    }
    
    // Increases each of the EQ mid-frequency bands by a certain preset increment
    @IBAction func increaseMidsAction(_ sender: Any) {
        
        eqUnit.increaseMids()
        messenger.publish(.Effects.EQUnit.bandsUpdated)
    }
    
    // Decreases each of the EQ treble bands by a certain preset decrement
    @IBAction func decreaseTrebleAction(_ sender: Any) {
        
        eqUnit.decreaseTreble()
        messenger.publish(.Effects.EQUnit.bandsUpdated)
    }
    
    // Decreases each of the EQ treble bands by a certain preset increment
    @IBAction func increaseTrebleAction(_ sender: Any) {
        
        eqUnit.increaseTreble()
        messenger.publish(.Effects.EQUnit.bandsUpdated)
    }
    
    // MARK: Pitch Shift ---------------------------------------------------------------------------
    
    // Decreases the pitch by a certain preset decrement
    @IBAction func decreasePitchAction(_ sender: Any) {
        
//        pitchShiftUnit.decreasePitch()
        messenger.publish(.Effects.PitchShiftUnit.pitchUpdated)
    }
    
    // Increases the pitch by a certain preset increment
    @IBAction func increasePitchAction(_ sender: Any) {
        
//        pitchShiftUnit.increasePitch()
        messenger.publish(.Effects.PitchShiftUnit.pitchUpdated)
    }
    
    // Sets the pitch to a value specified by the menu item clicked
    @IBAction func setPitchAction(_ sender: SoundParameterMenuItem) {
        
        // Menu item's "paramValue" specifies the pitch shift value associated with the menu item (in cents)
        let pitch = Int(sender.paramValue)
        
        pitchShiftUnit.pitch = PitchShift(octaves: pitch)
        pitchShiftUnit.ensureActive()
        messenger.publish(.Effects.PitchShiftUnit.pitchUpdated)
    }
    
    // MARK: Time Stretch ---------------------------------------------------------------------------
    
    // Decreases the playback rate by a certain preset decrement
    @IBAction func decreaseRateAction(_ sender: Any) {
        
        timeStretchUnit.decreaseRate()
        messenger.publish(.Effects.TimeStretchUnit.rateUpdated)
    }
    
    // Increases the playback rate by a certain preset increment
    @IBAction func increaseRateAction(_ sender: Any) {
        
        timeStretchUnit.increaseRate()
        messenger.publish(.Effects.TimeStretchUnit.rateUpdated)
    }
    
    // Sets the playback rate to a value specified by the menu item clicked
    @IBAction func setRateAction(_ sender: SoundParameterMenuItem) {
        
        // Menu item's "paramValue" specifies the playback rate value associated with the menu item
        let rate = sender.paramValue
        timeStretchUnit.rate = rate
        timeStretchUnit.ensureActive()
        messenger.publish(.Effects.TimeStretchUnit.rateUpdated)
    }
    
    // ------------------------------------------------------------------------------------------------------------
    
    @IBAction func rememberSettingsAction(_ sender: ToggleMenuItem) {
        messenger.publish(rememberSettingsMenuItem.isOff ? .Effects.saveSoundProfile : .Effects.deleteSoundProfile)
    }
}

// An NSMenuItem subclass that contains extra fields to hold information (similar to tags) associated with the menu item
class SoundParameterMenuItem: NSMenuItem {
    
    // A generic numerical parameter value
    var paramValue: Float = 0
}
