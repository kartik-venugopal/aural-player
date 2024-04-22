//
//  SoundPreferencesViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Cocoa

class SoundPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var tabView: NSTabView!
    
    private let generalPreferencesView: PreferencesViewProtocol = GeneralSoundPreferencesViewController()
    private let adjustmentPreferencesView: PreferencesViewProtocol = SoundAdjustmentPreferencesViewController()
    
    private var subViews: [PreferencesViewProtocol] = []
    
    override var nibName: String? {"SoundPreferences"}
    
    var preferencesView: NSView {
        return self.view
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        subViews = [generalPreferencesView, adjustmentPreferencesView]
        
        for (index, subView) in subViews.enumerated() {
            tabView.tabViewItems[index].view?.addSubview(subView.preferencesView)
        }
        
        // Select the Media Keys prefs tab
//        tabView.selectTabViewItem(at: 0)
    }
    
    func resetFields() {
        
        
    }
    
    func save() throws {
        
        try generalPreferencesView.save()
        try adjustmentPreferencesView.save()
        
//        let soundPrefs = preferences.soundPreferences
//        
//        if (btnSystemDeviceOnStartup.isOn) {
//            soundPrefs.outputDeviceOnStartup.option = .system
//        } else if (btnRememberDeviceOnStartup.isOn) {
//            soundPrefs.outputDeviceOnStartup.option = .rememberFromLastAppLaunch
//        } else {
//            soundPrefs.outputDeviceOnStartup.option = .specific
//        }
//        
//        if let prefDevice: PreferredDevice = preferredDevicesMenu.selectedItem?.representedObject as? PreferredDevice {
//            soundPrefs.outputDeviceOnStartup.preferredDeviceName = prefDevice.name
//            soundPrefs.outputDeviceOnStartup.preferredDeviceUID = prefDevice.uid
//        }
//        
//        soundPrefs.volumeDelta = volumeDeltaStepper.floatValue * ValueConversions.volume_UIToAudioGraph
//        
//        soundPrefs.volumeOnStartupOption = btnRememberVolume.isOn ? .rememberFromLastAppLaunch : .specific
//        soundPrefs.startupVolumeValue = Float(startupVolumeSlider.integerValue) * ValueConversions.volume_UIToAudioGraph
//        
//        soundPrefs.panDelta = panDeltaStepper.floatValue * ValueConversions.pan_UIToAudioGraph
//        
//        soundPrefs.eqDelta = eqDeltaStepper.floatValue
//        soundPrefs.pitchDelta = pitchDeltaStepper.integerValue
//        soundPrefs.timeDelta = timeDeltaStepper.floatValue
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
