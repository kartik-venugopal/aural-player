import Cocoa

class SoundPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var volumeDeltaField: NSTextField!
    @IBOutlet weak var volumeDeltaStepper: NSStepper!
    
    @IBOutlet weak var btnRememberVolume: NSButton!
    @IBOutlet weak var btnSpecifyVolume: NSButton!
    
    @IBOutlet weak var startupVolumeSlider: NSSlider!
    @IBOutlet weak var lblStartupVolume: NSTextField!
    
    @IBOutlet weak var lblPanDelta: NSTextField!
    @IBOutlet weak var panDeltaStepper: NSStepper!
    
    @IBOutlet weak var lblPitchDelta: NSTextField!
    @IBOutlet weak var pitchDeltaStepper: NSStepper!
    
    @IBOutlet weak var lblTimeDelta: NSTextField!
    @IBOutlet weak var timeDeltaStepper: NSStepper!
    
    @IBOutlet weak var btnRememberEffectsOnStartup: NSButton!
    @IBOutlet weak var btnApplyPresetOnStartup: NSButton!
    @IBOutlet weak var masterPresetsMenu: NSPopUpButton!
    
    @IBOutlet weak var btnRememberSettingsForTrack: NSButton!
    @IBOutlet weak var btnRememberSettings_allTracks: NSButton!
    @IBOutlet weak var btnRememberSettings_individualTracks: NSButton!
    
    override var nibName: String? {return "SoundPreferences"}
    
    func getView() -> NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let soundPrefs = preferences.soundPreferences
        
        let volumeDelta = Int(round(soundPrefs.volumeDelta * AppConstants.volumeConversion_audioGraphToUI))
        volumeDeltaStepper.integerValue = volumeDelta
        volumeDeltaField.stringValue = String(format: "%d%%", volumeDelta)
        
        btnRememberVolume.state = NSControl.StateValue(rawValue: soundPrefs.volumeOnStartupOption == .rememberFromLastAppLaunch ? 1 : 0)
        
        btnSpecifyVolume.state = NSControl.StateValue(rawValue: soundPrefs.volumeOnStartupOption == .rememberFromLastAppLaunch ? 0 : 1)
        
        startupVolumeSlider.isEnabled = Bool(btnSpecifyVolume.state.rawValue)
        startupVolumeSlider.integerValue = Int(round(soundPrefs.startupVolumeValue * AppConstants.volumeConversion_audioGraphToUI))
        
        lblStartupVolume.isEnabled = Bool(btnSpecifyVolume.state.rawValue)
        lblStartupVolume.stringValue = String(format: "%d%%", startupVolumeSlider.integerValue)
        
        let panDelta = Int(round(soundPrefs.panDelta * AppConstants.panConversion_audioGraphToUI))
        panDeltaStepper.integerValue = panDelta
        panDeltaAction(self)
        
        let pitchDelta = soundPrefs.pitchDelta
        pitchDeltaStepper.integerValue = pitchDelta
        pitchDeltaAction(self)
        
        let timeDelta = soundPrefs.timeDelta
        timeDeltaStepper.floatValue = timeDelta
        timeDeltaAction(self)
        
        if soundPrefs.effectsSettingsOnStartupOption == .rememberFromLastAppLaunch {
            btnRememberEffectsOnStartup.state = UIConstants.buttonState_1
        } else {
            btnApplyPresetOnStartup.state = UIConstants.buttonState_1
        }
        
        masterPresetsMenu.isEnabled = btnApplyPresetOnStartup.state.rawValue == 1
        
        updateMasterPresetsMenu()
        
        if let masterPresetName = soundPrefs.masterPresetOnStartup_name {
            masterPresetsMenu.selectItem(withTitle: masterPresetName)
        }
        
        btnRememberSettingsForTrack.state = soundPrefs.rememberEffectsSettings ? UIConstants.buttonState_1 : UIConstants.buttonState_0
        [btnRememberSettings_allTracks, btnRememberSettings_individualTracks].forEach({$0?.isEnabled = soundPrefs.rememberEffectsSettings})
        
        if soundPrefs.rememberEffectsSettingsOption == .individualTracks {
            btnRememberSettings_individualTracks.state = UIConstants.buttonState_1
        } else {
            btnRememberSettings_allTracks.state = UIConstants.buttonState_1
        }
    }
    
    private func updateMasterPresetsMenu() {
        
        masterPresetsMenu.removeAllItems()
        
        // Initialize the menu with user-defined presets
        MasterPresets.userDefinedPresets.forEach({masterPresetsMenu.insertItem(withTitle: $0.name, at: 0)})
    }
    
    @IBAction func volumeDeltaAction(_ sender: Any) {
        volumeDeltaField.stringValue = String(format: "%d%%", volumeDeltaStepper.integerValue)
    }
    
    @IBAction func panDeltaAction(_ sender: Any) {
        lblPanDelta.stringValue = String(format: "%d%%", panDeltaStepper.integerValue)
    }
    
    @IBAction func pitchDeltaAction(_ sender: Any) {
        lblPitchDelta.stringValue = String(format: "%d cents", pitchDeltaStepper.integerValue)
    }
    
    @IBAction func timeDeltaAction(_ sender: Any) {
        lblTimeDelta.stringValue = String(format: "%.2lfx", timeDeltaStepper.floatValue)
    }

    @IBAction func startupVolumeButtonAction(_ sender: Any) {
        [startupVolumeSlider, lblStartupVolume].forEach({$0.isEnabled = Bool(btnSpecifyVolume.state.rawValue)})
    }
    
    @IBAction func startupVolumeSliderAction(_ sender: Any) {
        lblStartupVolume.stringValue = String(format: "%d%%", startupVolumeSlider.integerValue)
    }
    
    @IBAction func effectsSettingsOnStartupRadioButtonAction(_ sender: Any) {
        masterPresetsMenu.isEnabled = btnApplyPresetOnStartup.state.rawValue == 1
    }
    
    @IBAction func rememberSettingsAction(_ sender: Any) {
        [btnRememberSettings_allTracks, btnRememberSettings_individualTracks].forEach({$0?.isEnabled = btnRememberSettingsForTrack.state == UIConstants.buttonState_1})
    }
    
    @IBAction func rememberSettingsRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    func save(_ preferences: Preferences) throws {
        
        let soundPrefs = preferences.soundPreferences
        
        soundPrefs.volumeDelta = volumeDeltaStepper.floatValue * AppConstants.volumeConversion_UIToAudioGraph
        
        soundPrefs.volumeOnStartupOption = btnRememberVolume.state.rawValue == 1 ? .rememberFromLastAppLaunch : .specific
        soundPrefs.startupVolumeValue = Float(startupVolumeSlider.integerValue) * AppConstants.volumeConversion_UIToAudioGraph
        
        soundPrefs.panDelta = panDeltaStepper.floatValue * AppConstants.panConversion_UIToAudioGraph
        soundPrefs.pitchDelta = pitchDeltaStepper.integerValue
        soundPrefs.timeDelta = timeDeltaStepper.floatValue
        
        soundPrefs.effectsSettingsOnStartupOption = btnRememberEffectsOnStartup.state == UIConstants.buttonState_1 ? .rememberFromLastAppLaunch : .applyMasterPreset
        
        soundPrefs.masterPresetOnStartup_name = masterPresetsMenu.titleOfSelectedItem ?? ""
        
        soundPrefs.rememberEffectsSettings = Bool(btnRememberSettingsForTrack.state.rawValue)
        
        let wasAllTracks: Bool = soundPrefs.rememberEffectsSettingsOption == .allTracks
        
        soundPrefs.rememberEffectsSettingsOption = btnRememberSettings_individualTracks.state == UIConstants.buttonState_1 ? .individualTracks : .allTracks
        
        let isNowIndividualTracks: Bool = soundPrefs.rememberEffectsSettingsOption == .individualTracks
        
        if !soundPrefs.rememberEffectsSettings || (wasAllTracks && isNowIndividualTracks) {
            SoundProfiles.removeAll()
        }
    }
}
