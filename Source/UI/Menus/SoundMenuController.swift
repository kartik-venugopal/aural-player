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
    
    let soundPreferences: SoundPreferences = preferences.soundPreferences
    
    lazy var effectsPresetsManager: EffectsPresetsManagerWindowController = .instance
    
    lazy var messenger = Messenger(for: self)
    
    // One-time setup.
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // Associate each of the menu items with a specific pitch shift or playback rate value, so that when the item is clicked later, that value can be readily retrieved and used in performing the action.
        
        setUpPitchShiftMenu()
        setUpTimeStretchMenu()
    }
    
    // When the menu is about to open, update the menu item states
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        let isReceivingTextInput: Bool = NSApp.isReceivingTextInput
        [panLeftMenuItem, panRightMenuItem].forEach {$0?.enableIf(!isReceivingTextInput)}
        rememberSettingsMenuItem.enableIf(player.playingTrack != nil)
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        
        // Audio output devices menu
//        if menu == devicesMenu {
//            
//            // Recreate the menu each time
//            
//            devicesMenu.removeAllItems()
//            
//            let outputDeviceName: String = soundOrch.outputDevice.name
//            
//            // Add menu items for each available device
//            for device in soundOrch.availableDevices {
//                
//                let newItem = devicesMenu.addItem(withTitle: device.name,
//                                                  action: #selector(self.outputDeviceAction(_:)),
//                                                  target: self,
//                                                  image: device.icon.image,
//                                                  representedObject: device)
//            
//                // Select this item if it represents the current output device
//                newItem.onIf(outputDeviceName == newItem.title)
//            }
//            
//        } else {
//            
//            masterBypassMenuItem.onIf(masterUnit.isActive)
//            
//            rememberSettingsMenuItem.showIf(!soundPreferences.rememberEffectsSettingsForAllTracks)
//            
//            if let playingTrack = player.playingTrack {
//                rememberSettingsMenuItem.onIf(soundProfiles.hasFor(playingTrack))
//            }
//        }
    }
    
    @IBAction func outputDeviceAction(_ sender: NSMenuItem) {
        
        if let outputDevice = sender.representedObject as? AudioDevice {
//            soundOrch.outputDevice = outputDevice
        }
    }
    
    // MARK: Volume ---------------------------------------------------------------------------
    
    // Mutes or unmutes the player
    @IBAction func muteOrUnmuteAction(_ sender: AnyObject) {
        soundOrch.toggleMuted()
    }
    
    // Decreases the volume by a certain preset decrement
    @IBAction func decreaseVolumeAction(_ sender: Any) {
        soundOrch.decreaseVolume()
    }
    
    // Increases the volume by a certain preset increment
    @IBAction func increaseVolumeAction(_ sender: Any) {
        soundOrch.increaseVolume()
    }
    
    // MARK: Pan ---------------------------------------------------------------------------
    
    // Pans the sound towards the left channel, by a certain preset value
    @IBAction func panLeftAction(_ sender: Any) {
        soundOrch.panLeft()
    }
    
    // Pans the sound towards the right channel, by a certain preset value
    @IBAction func panRightAction(_ sender: Any) {
        soundOrch.panRight()
    }
    
    // MARK: Master Unit ---------------------------------------------------------------------------
    
    // Toggles the master bypass switch
    @IBAction func masterBypassAction(_ sender: Any) {
        
//        masterUnit.toggleState()
        messenger.publish(.Effects.MasterUnit.allEffectsToggled)
    }
    
    @IBAction func managePresetsAction(_ sender: Any) {
        effectsPresetsManager.showWindow(self)
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
