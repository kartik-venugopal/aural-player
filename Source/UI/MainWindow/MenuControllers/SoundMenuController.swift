//
//  SoundMenuController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
    @IBOutlet weak var halfOctaveBelowMenuItem: SoundParameterMenuItem!
    @IBOutlet weak var thirdOctaveBelowMenuItem: SoundParameterMenuItem!
    @IBOutlet weak var sixthOctaveBelowMenuItem: SoundParameterMenuItem!
    
    @IBOutlet weak var sixthOctaveAboveMenuItem: SoundParameterMenuItem!
    @IBOutlet weak var thirdOctaveAboveMenuItem: SoundParameterMenuItem!
    @IBOutlet weak var halfOctaveAboveMenuItem: SoundParameterMenuItem!
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
    private var graph: AudioGraphDelegateProtocol = objectGraph.audioGraphDelegate
    private let soundProfiles: SoundProfiles = objectGraph.audioGraphDelegate.soundProfiles
    
    private let player: PlaybackInfoDelegateProtocol = objectGraph.playbackInfoDelegate
    
    private let preferences: SoundPreferences = objectGraph.preferences.soundPreferences
    
    private lazy var presetsManager: PresetsManagerWindowController = PresetsManagerWindowController.instance
    
    private lazy var messenger = Messenger(for: self)
    
    private lazy var windowLayoutsManager: WindowLayoutsManager = objectGraph.windowLayoutsManager
    
    // One-time setup.
    override func awakeFromNib() {
        
        // Associate each of the menu items with a specific pitch shift or playback rate value, so that when the item is clicked later, that value can be readily retrieved and used in performing the action.
        
        // Pitch shift menu items
        twoOctavesBelowMenuItem.paramValue = -2
        oneOctaveBelowMenuItem.paramValue = -1
        halfOctaveBelowMenuItem.paramValue = -0.5
        thirdOctaveBelowMenuItem.paramValue = -1/3
        sixthOctaveBelowMenuItem.paramValue = -1/6
        
        sixthOctaveAboveMenuItem.paramValue = 1/6
        thirdOctaveAboveMenuItem.paramValue = 1/3
        halfOctaveAboveMenuItem.paramValue = 0.5
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
        
        [panLeftMenuItem, panRightMenuItem].forEach({$0?.enableIf(!windowLayoutsManager.isShowingModalComponent)})
        rememberSettingsMenuItem.enableIf(player.playingTrack != nil)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        // Audio output devices menu
        if (menu == devicesMenu) {
            
            // Recreate the menu each time
            
            devicesMenu.removeAllItems()
            
            let outputDeviceName: String = graph.outputDevice.name
            
            // Add menu items for each available device
            for device in graph.availableDevices.allDevices {
                
                let menuItem = NSMenuItem(title: device.name, action: #selector(self.outputDeviceAction(_:)))
                menuItem.representedObject = device
                menuItem.target = self
                
                self.devicesMenu.insertItem(menuItem, at: 0)
            
                // Select this item if it represents the current output device
                menuItem.onIf(outputDeviceName == menuItem.title)
            }
            
        } else {
            
            masterBypassMenuItem.onIf(!graph.masterUnit.isActive)
            rememberSettingsMenuItem.showIf(preferences.rememberEffectsSettingsOption == .individualTracks)
            
            if let playingTrack = player.playingTrack {
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
        messenger.publish(.player_muteOrUnmute)
    }
    
    // Decreases the volume by a certain preset decrement
    @IBAction func decreaseVolumeAction(_ sender: Any) {
        messenger.publish(.player_decreaseVolume, payload: UserInputMode.discrete)
    }
    
    // Increases the volume by a certain preset increment
    @IBAction func increaseVolumeAction(_ sender: Any) {
        messenger.publish(.player_increaseVolume, payload: UserInputMode.discrete)
    }
    
    // Pans the sound towards the left channel, by a certain preset value
    @IBAction func panLeftAction(_ sender: Any) {
        messenger.publish(.player_panLeft)
    }
    
    // Pans the sound towards the right channel, by a certain preset value
    @IBAction func panRightAction(_ sender: Any) {
        messenger.publish(.player_panRight)
    }
    
    // Whether or not the Effects window is loaded (and is able to receive commands).
    var effectsWindowLoaded: Bool {windowLayoutsManager.effectsWindowLoaded}
    
    // Toggles the master bypass switch
    @IBAction func masterBypassAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            messenger.publish(.masterEffectsUnit_toggleEffects)
        } else {
            _ = graph.masterUnit.toggleState()
        }
    }
    
    @IBAction func managePresetsAction(_ sender: Any) {
        presetsManager.showEffectsPresetsManager()
    }
    
    // Decreases each of the EQ bass bands by a certain preset decrement
    @IBAction func decreaseBassAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            messenger.publish(.eqEffectsUnit_decreaseBass)
        } else {
            _ = graph.eqUnit.decreaseBass()
        }
    }
    
    // Provides a "bass boost". Increases each of the EQ bass bands by a certain preset increment.
    @IBAction func increaseBassAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            messenger.publish(.eqEffectsUnit_increaseBass)
        } else {
            _ = graph.eqUnit.increaseBass()
        }
    }
    
    // Decreases each of the EQ mid-frequency bands by a certain preset decrement
    @IBAction func decreaseMidsAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            messenger.publish(.eqEffectsUnit_decreaseMids)
        } else {
            _ = graph.eqUnit.decreaseMids()
        }
    }
    
    // Increases each of the EQ mid-frequency bands by a certain preset increment
    @IBAction func increaseMidsAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            messenger.publish(.eqEffectsUnit_increaseMids)
        } else {
            _ = graph.eqUnit.increaseMids()
        }
    }
    
    // Decreases each of the EQ treble bands by a certain preset decrement
    @IBAction func decreaseTrebleAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            messenger.publish(.eqEffectsUnit_decreaseTreble)
        } else {
            _ = graph.eqUnit.decreaseTreble()
        }
    }
    
    // Decreases each of the EQ treble bands by a certain preset increment
    @IBAction func increaseTrebleAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            messenger.publish(.eqEffectsUnit_increaseTreble)
        } else {
            _ = graph.eqUnit.increaseTreble()
        }
    }
    
    // Decreases the pitch by a certain preset decrement
    @IBAction func decreasePitchAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            messenger.publish(.pitchEffectsUnit_decreasePitch)
        } else {
            _ = graph.pitchShiftUnit.decreasePitch()
        }
    }
    
    // Increases the pitch by a certain preset increment
    @IBAction func increasePitchAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            messenger.publish(.pitchEffectsUnit_increasePitch)
        } else {
            _ = graph.pitchShiftUnit.increasePitch()
        }
    }
    
    // Sets the pitch to a value specified by the menu item clicked
    @IBAction func setPitchAction(_ sender: SoundParameterMenuItem) {
        
        // Menu item's "paramValue" specifies the pitch shift value associated with the menu item (in octaves)
        let pitch = sender.paramValue
        
        if effectsWindowLoaded {
            messenger.publish(.pitchEffectsUnit_setPitch, payload: pitch)
            
        } else {
            
            graph.pitchShiftUnit.pitch = pitch
            graph.pitchShiftUnit.ensureActive()
        }
    }
    
    // Decreases the playback rate by a certain preset decrement
    @IBAction func decreaseRateAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            messenger.publish(.timeEffectsUnit_decreaseRate)
        } else {
            _ = graph.timeStretchUnit.decreaseRate()
        }
    }
    
    // Increases the playback rate by a certain preset increment
    @IBAction func increaseRateAction(_ sender: Any) {
        
        if effectsWindowLoaded {
            messenger.publish(.timeEffectsUnit_increaseRate)
        } else {
            _ = graph.timeStretchUnit.increaseRate()
        }
    }
    
    // Sets the playback rate to a value specified by the menu item clicked
    @IBAction func setRateAction(_ sender: SoundParameterMenuItem) {
        
        // Menu item's "paramValue" specifies the playback rate value associated with the menu item
        let rate = sender.paramValue
        
        if effectsWindowLoaded {
            messenger.publish(.timeEffectsUnit_setRate, payload: rate)
            
        } else {
            
            graph.timeStretchUnit.rate = rate
            graph.timeStretchUnit.ensureActive()
        }
    }
    
    @IBAction func rememberSettingsAction(_ sender: ToggleMenuItem) {
        messenger.publish(!rememberSettingsMenuItem.isOn ? .effects_saveSoundProfile : .effects_deleteSoundProfile)
    }
}

// An NSMenuItem subclass that contains extra fields to hold information (similar to tags) associated with the menu item
class SoundParameterMenuItem: NSMenuItem {
    
    // A generic numerical parameter value
    var paramValue: Float = 0
}
