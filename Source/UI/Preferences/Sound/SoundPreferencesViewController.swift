//
//  SoundPreferencesViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class SoundPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var btnSystemDeviceOnStartup: NSButton!
    @IBOutlet weak var btnRememberDeviceOnStartup: NSButton!
    @IBOutlet weak var btnPreferredDeviceOnStartup: NSButton!
    @IBOutlet weak var preferredDevicesMenu: NSPopUpButton!
    
    @IBOutlet weak var volumeDeltaField: NSTextField!
    @IBOutlet weak var volumeDeltaStepper: NSStepper!
    
    @IBOutlet weak var btnRememberVolume: NSButton!
    @IBOutlet weak var btnSpecifyVolume: NSButton!
    
    @IBOutlet weak var startupVolumeSlider: NSSlider!
    @IBOutlet weak var lblStartupVolume: NSTextField!
    
    @IBOutlet weak var lblPanDelta: NSTextField!
    @IBOutlet weak var panDeltaStepper: NSStepper!
    
    @IBOutlet weak var lblEQDelta: NSTextField!
    @IBOutlet weak var eqDeltaStepper: NSStepper!
    
    @IBOutlet weak var lblPitchDelta: NSTextField!
    @IBOutlet weak var pitchDeltaStepper: NSStepper!
    
    @IBOutlet weak var lblTimeDelta: NSTextField!
    @IBOutlet weak var timeDeltaStepper: NSStepper!
    
    @IBOutlet weak var btnRememberEffectsOnStartup: NSButton!
    @IBOutlet weak var btnApplyPresetOnStartup: NSButton!
    @IBOutlet weak var masterPresetsMenu: NSPopUpButton!
    
    @IBOutlet weak var btnRememberSettings_allTracks: NSButton!
    @IBOutlet weak var btnRememberSettings_individualTracks: NSButton!
    
    private let audioGraph: AudioGraphDelegateProtocol = ObjectGraph.audioGraphDelegate
    private let masterPresets: MasterPresets = ObjectGraph.audioGraphDelegate.masterUnit.presets
    private let soundProfiles: SoundProfiles = ObjectGraph.audioGraphDelegate.soundProfiles
    
    override var nibName: String? {"SoundPreferences"}
    
    var preferencesView: NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
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
        
        // Volume increment / decrement
        
        let volumeDelta = (soundPrefs.volumeDelta * ValueConversions.volume_audioGraphToUI).roundedInt
        volumeDeltaStepper.integerValue = volumeDelta
        volumeDeltaField.stringValue = String(format: "%d%%", volumeDelta)
        
        btnRememberVolume.onIf(soundPrefs.volumeOnStartupOption == .rememberFromLastAppLaunch)
        
        btnSpecifyVolume.onIf(soundPrefs.volumeOnStartupOption == .specific)
        
        startupVolumeSlider.enableIf(btnSpecifyVolume.isOn)
        startupVolumeSlider.integerValue = (soundPrefs.startupVolumeValue * ValueConversions.volume_audioGraphToUI).roundedInt
        
        lblStartupVolume.enableIf(btnSpecifyVolume.isOn)
        lblStartupVolume.stringValue = String(format: "%d%%", startupVolumeSlider.integerValue)
        
        // Balance increment / decrement
        
        let panDelta = (soundPrefs.panDelta * ValueConversions.pan_audioGraphToUI).roundedInt
        panDeltaStepper.integerValue = panDelta
        panDeltaAction(self)
        
        let eqDelta = soundPrefs.eqDelta
        eqDeltaStepper.floatValue = eqDelta
        eqDeltaAction(self)
        
        let pitchDelta = soundPrefs.pitchDelta
        pitchDeltaStepper.integerValue = pitchDelta
        pitchDeltaAction(self)
        
        let timeDelta = soundPrefs.timeDelta
        timeDeltaStepper.floatValue = timeDelta
        timeDeltaAction(self)
        
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
        
        for device in audioGraph.availableDevices.allDevices {

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
        masterPresets.userDefinedPresets.forEach({masterPresetsMenu.insertItem(withTitle: $0.name, at: 0)})
    }
    
    @IBAction func outputDeviceRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
        preferredDevicesMenu.enableIf(btnPreferredDeviceOnStartup.isOn)
    }
    
    @IBAction func volumeDeltaAction(_ sender: Any) {
        volumeDeltaField.stringValue = String(format: "%d%%", volumeDeltaStepper.integerValue)
    }
    
    @IBAction func panDeltaAction(_ sender: Any) {
        lblPanDelta.stringValue = String(format: "%d%%", panDeltaStepper.integerValue)
    }
    
    @IBAction func eqDeltaAction(_ sender: Any) {
        lblEQDelta.stringValue = String(format: "%.1lf dB", eqDeltaStepper.floatValue)
    }
    
    @IBAction func pitchDeltaAction(_ sender: Any) {
        lblPitchDelta.stringValue = String(format: "%d cents", pitchDeltaStepper.integerValue)
    }
    
    @IBAction func timeDeltaAction(_ sender: Any) {
        lblTimeDelta.stringValue = String(format: "%.2lfx", timeDeltaStepper.floatValue)
    }

    @IBAction func startupVolumeButtonAction(_ sender: Any) {
        [startupVolumeSlider, lblStartupVolume].forEach({$0.enableIf(btnSpecifyVolume.isOn)})
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
    
    func save(_ preferences: Preferences) throws {
        
        let soundPrefs = preferences.soundPreferences
        
        if (btnSystemDeviceOnStartup.isOn) {
            soundPrefs.outputDeviceOnStartup.option = .system
        } else if (btnRememberDeviceOnStartup.isOn) {
            soundPrefs.outputDeviceOnStartup.option = .rememberFromLastAppLaunch
        } else {
            soundPrefs.outputDeviceOnStartup.option = .specific
        }
        
        if let prefDevice: PreferredDevice = preferredDevicesMenu.selectedItem?.representedObject as? PreferredDevice {
            soundPrefs.outputDeviceOnStartup.preferredDeviceName = prefDevice.name
            soundPrefs.outputDeviceOnStartup.preferredDeviceUID = prefDevice.uid
        }
        
        soundPrefs.volumeDelta = volumeDeltaStepper.floatValue * ValueConversions.volume_UIToAudioGraph
        
        soundPrefs.volumeOnStartupOption = btnRememberVolume.isOn ? .rememberFromLastAppLaunch : .specific
        soundPrefs.startupVolumeValue = Float(startupVolumeSlider.integerValue) * ValueConversions.volume_UIToAudioGraph
        
        soundPrefs.panDelta = panDeltaStepper.floatValue * ValueConversions.pan_UIToAudioGraph
        
        soundPrefs.eqDelta = eqDeltaStepper.floatValue
        soundPrefs.pitchDelta = pitchDeltaStepper.integerValue
        soundPrefs.timeDelta = timeDeltaStepper.floatValue
        
        soundPrefs.effectsSettingsOnStartupOption = btnRememberEffectsOnStartup.isOn ? .rememberFromLastAppLaunch : .applyMasterPreset
        
        soundPrefs.masterPresetOnStartup_name = masterPresetsMenu.titleOfSelectedItem ?? ""
        
        let wasAllTracks: Bool = soundPrefs.rememberEffectsSettingsOption == .allTracks
        
        soundPrefs.rememberEffectsSettingsOption = btnRememberSettings_individualTracks.isOn ? .individualTracks : .allTracks
        
        let isNowIndividualTracks: Bool = soundPrefs.rememberEffectsSettingsOption == .individualTracks
        
        if wasAllTracks && isNowIndividualTracks {
            soundProfiles.removeAll()
        }
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
