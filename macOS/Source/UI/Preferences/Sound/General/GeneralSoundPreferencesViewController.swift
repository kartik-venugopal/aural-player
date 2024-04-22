//
//  GeneralSoundPreferencesViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class GeneralSoundPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var btnSystemDeviceOnStartup: NSButton!
    @IBOutlet weak var btnRememberDeviceOnStartup: NSButton!
    @IBOutlet weak var btnPreferredDeviceOnStartup: NSButton!
    @IBOutlet weak var preferredDevicesMenu: NSPopUpButton!
    
    @IBOutlet weak var btnRememberVolume: NSButton!
    @IBOutlet weak var btnSpecifyVolume: NSButton!
    
    @IBOutlet weak var startupVolumeSlider: NSSlider!
    @IBOutlet weak var lblStartupVolume: NSTextField!
    
    @IBOutlet weak var btnRememberEffectsOnStartup: NSButton!
    @IBOutlet weak var btnApplyPresetOnStartup: NSButton!
    @IBOutlet weak var masterPresetsMenu: NSPopUpButton!
    
    @IBOutlet weak var btnRememberSettings_allTracks: NSButton!
    @IBOutlet weak var btnRememberSettings_individualTracks: NSButton!
    
    private let masterPresets: MasterPresets = audioGraphDelegate.masterUnit.presets
    private let soundProfiles: SoundProfiles = audioGraphDelegate.soundProfiles
    
    override var nibName: String? {"GeneralSoundPreferences"}
    
    var preferencesView: NSView {
        self.view
    }
    
    func resetFields() {
        
        let soundPrefs = preferences.soundPreferences
        
        switch soundPrefs.outputDeviceOnStartup.option {
            
        case .system:                       btnSystemDeviceOnStartup.on()
                                            break
            
        case .rememberFromLastAppLaunch:    btnRememberDeviceOnStartup.on()
                                            break
            
        case .specific:                     btnPreferredDeviceOnStartup.on()
                                            break
        }
        
        updatePreferredDevicesMenu(soundPrefs)
        preferredDevicesMenu.enableIf(btnPreferredDeviceOnStartup.isOn)
        
        btnRememberVolume.onIf(soundPrefs.volumeOnStartupOption == .rememberFromLastAppLaunch)
        
        btnSpecifyVolume.onIf(soundPrefs.volumeOnStartupOption == .specific)
        
        startupVolumeSlider.enableIf(btnSpecifyVolume.isOn)
        startupVolumeSlider.integerValue = (soundPrefs.startupVolumeValue * ValueConversions.volume_audioGraphToUI).roundedInt
        
        lblStartupVolume.enableIf(btnSpecifyVolume.isOn)
        lblStartupVolume.stringValue = String(format: "%d%%", startupVolumeSlider.integerValue)
        
        // Effects settings on startup
        
        if soundPrefs.effectsSettingsOnStartupOption == .rememberFromLastAppLaunch {
            btnRememberEffectsOnStartup.on()
        } else {
            btnApplyPresetOnStartup.on()
        }
        
        masterPresetsMenu.enableIf(btnApplyPresetOnStartup.isOn)
        
        updateMasterPresetsMenu()
        
        if let masterPresetName = soundPrefs.masterPresetOnStartup_name {
            masterPresetsMenu.selectItem(withTitle: masterPresetName)
        }
        
        // Per-track effects settings memory
        
        if soundPrefs.rememberEffectsSettingsOption == .individualTracks {
            btnRememberSettings_individualTracks.on()
        } else {
            btnRememberSettings_allTracks.on()
        }
    }
    
    private func updatePreferredDevicesMenu(_ prefs: SoundPreferences) {
        
        preferredDevicesMenu.removeAllItems()
        
        let prefDeviceName: String = prefs.outputDeviceOnStartup.preferredDeviceName ?? ""
        let prefDeviceUID: String = prefs.outputDeviceOnStartup.preferredDeviceUID ?? ""
        
        var prefDevice: PreferredDevice?
        
        var selItem: NSMenuItem?
        
        for device in audioGraph.availableDevices {

            preferredDevicesMenu.insertItem(withTitle: device.name, at: 0)
            
            let repObject = PreferredDevice(device.name, device.uid)
            preferredDevicesMenu.item(at: 0)!.representedObject = repObject
            
            // If this device matches the preferred device, make note of it
            if (device.uid == prefDeviceUID) {
                prefDevice = repObject
                selItem = preferredDevicesMenu.item(at: 0)!
            }
        }
        
        // If the preferred device is not any of the available devices, add it to the menu
        if prefDevice == nil && prefDeviceUID != "" {
            
            preferredDevicesMenu.insertItem(withTitle: prefDeviceName + " (unavailable)", at: 0)
            preferredDevicesMenu.item(at: 0)!.representedObject = PreferredDevice(prefDeviceName, prefDeviceUID)
            selItem = preferredDevicesMenu.item(at: 0)!
        }
        
        preferredDevicesMenu.select(selItem)
    }
    
    private func updateMasterPresetsMenu() {
        
        masterPresetsMenu.removeAllItems()
        
        // Initialize the menu with user-defined presets
        masterPresets.userDefinedObjects.forEach {masterPresetsMenu.insertItem(withTitle: $0.name, at: 0)}
    }
    
    @IBAction func outputDeviceRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
        preferredDevicesMenu.enableIf(btnPreferredDeviceOnStartup.isOn)
    }
    
    @IBAction func startupVolumeButtonAction(_ sender: Any) {
        [startupVolumeSlider, lblStartupVolume].forEach {$0.enableIf(btnSpecifyVolume.isOn)}
    }
    
    @IBAction func startupVolumeSliderAction(_ sender: Any) {
        lblStartupVolume.stringValue = String(format: "%d%%", startupVolumeSlider.integerValue)
    }
    
    @IBAction func effectsSettingsOnStartupRadioButtonAction(_ sender: Any) {
        masterPresetsMenu.enableIf(btnApplyPresetOnStartup.isOn)
    }
    
    @IBAction func rememberSettingsRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    func save() throws {
        
//        let soundPrefs = preferences.soundPreferences
//
//        if btnSystemDeviceOnStartup.isOn {
//            soundPrefs.outputDeviceOnStartup.option = .system
//            
//        } else if btnRememberDeviceOnStartup.isOn {
//            soundPrefs.outputDeviceOnStartup.option = .rememberFromLastAppLaunch
//            
//        } else {
//            soundPrefs.outputDeviceOnStartup.option = .specific
//        }
//
//        if let prefDevice: PreferredDevice = preferredDevicesMenu.selectedItem?.representedObject as? PreferredDevice {
//            soundPrefs.outputDeviceOnStartup.preferredDeviceName = prefDevice.name
//            soundPrefs.outputDeviceOnStartup.preferredDeviceUID = prefDevice.uid
//        }
//
//        soundPrefs.volumeOnStartupOption = btnRememberVolume.isOn ? .rememberFromLastAppLaunch : .specific
//        soundPrefs.startupVolumeValue = Float(startupVolumeSlider.integerValue) * ValueConversions.volume_UIToAudioGraph
//
//        soundPrefs.effectsSettingsOnStartupOption = btnRememberEffectsOnStartup.isOn ? .rememberFromLastAppLaunch : .applyMasterPreset
//
//        soundPrefs.masterPresetOnStartup_name = masterPresetsMenu.titleOfSelectedItem ?? ""
//
//        let wasAllTracks: Bool = soundPrefs.rememberEffectsSettingsOption == .allTracks
//
//        soundPrefs.rememberEffectsSettingsOption = btnRememberSettings_individualTracks.isOn ? .individualTracks : .allTracks
//
//        let isNowIndividualTracks: Bool = soundPrefs.rememberEffectsSettingsOption == .individualTracks
//
//        if wasAllTracks && isNowIndividualTracks {
//            soundProfiles.removeAll()
//        }
    }
}

// Encapsulates a user-preferred audio output device
public class PreferredDevice {
    
    var name: String
    var uid: String
    
    init(_ name: String, _ uid: String) {
        self.name = name
        self.uid = uid
    }
}

