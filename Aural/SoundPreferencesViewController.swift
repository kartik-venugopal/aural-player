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
    
    @IBOutlet weak var lblEQDelta: NSTextField!
    @IBOutlet weak var eqDeltaStepper: NSStepper!
    
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
    
    private let masterPresets: MasterPresets = ObjectGraph.audioGraphDelegate.masterUnit.presets
    private let soundProfiles: SoundProfiles = ObjectGraph.audioGraphDelegate.soundProfiles
    
    override var nibName: String? {return "SoundPreferences"}
    
    func getView() -> NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let soundPrefs = preferences.soundPreferences
        
        let volumeDelta = Int(round(soundPrefs.volumeDelta * AppConstants.ValueConversions.volume_audioGraphToUI))
        volumeDeltaStepper.integerValue = volumeDelta
        volumeDeltaField.stringValue = String(format: "%d%%", volumeDelta)
        
        btnRememberVolume.onIf(soundPrefs.volumeOnStartupOption == .rememberFromLastAppLaunch)
        
        btnSpecifyVolume.onIf(soundPrefs.volumeOnStartupOption == .specific)
        
        startupVolumeSlider.enableIf(btnSpecifyVolume.isOn())
        startupVolumeSlider.integerValue = Int(round(soundPrefs.startupVolumeValue * AppConstants.ValueConversions.volume_audioGraphToUI))
        
        lblStartupVolume.enableIf(btnSpecifyVolume.isOn())
        lblStartupVolume.stringValue = String(format: "%d%%", startupVolumeSlider.integerValue)
        
        let panDelta = Int(round(soundPrefs.panDelta * AppConstants.ValueConversions.pan_audioGraphToUI))
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
        
        if soundPrefs.effectsSettingsOnStartupOption == .rememberFromLastAppLaunch {
            btnRememberEffectsOnStartup.on()
        } else {
            btnApplyPresetOnStartup.on()
        }
        
        masterPresetsMenu.enableIf(btnApplyPresetOnStartup.isOn())
        
        updateMasterPresetsMenu()
        
        if let masterPresetName = soundPrefs.masterPresetOnStartup_name {
            masterPresetsMenu.selectItem(withTitle: masterPresetName)
        }
        
        btnRememberSettingsForTrack.onIf(soundPrefs.rememberEffectsSettings)
        [btnRememberSettings_allTracks, btnRememberSettings_individualTracks].forEach({$0?.enableIf(soundPrefs.rememberEffectsSettings)})
        
        if soundPrefs.rememberEffectsSettingsOption == .individualTracks {
            btnRememberSettings_individualTracks.on()
        } else {
            btnRememberSettings_allTracks.on()
        }
    }
    
    private func updateMasterPresetsMenu() {
        
        masterPresetsMenu.removeAllItems()
        
        // Initialize the menu with user-defined presets
        masterPresets.userDefinedPresets.forEach({masterPresetsMenu.insertItem(withTitle: $0.name, at: 0)})
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
        [startupVolumeSlider, lblStartupVolume].forEach({$0.enableIf(btnSpecifyVolume.isOn())})
    }
    
    @IBAction func startupVolumeSliderAction(_ sender: Any) {
        lblStartupVolume.stringValue = String(format: "%d%%", startupVolumeSlider.integerValue)
    }
    
    @IBAction func effectsSettingsOnStartupRadioButtonAction(_ sender: Any) {
        masterPresetsMenu.enableIf(btnApplyPresetOnStartup.isOn())
    }
    
    @IBAction func rememberSettingsAction(_ sender: Any) {
        [btnRememberSettings_allTracks, btnRememberSettings_individualTracks].forEach({$0?.enableIf(btnRememberSettingsForTrack.isOn())})
    }
    
    @IBAction func rememberSettingsRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    func save(_ preferences: Preferences) throws {
        
        let soundPrefs = preferences.soundPreferences
        
        soundPrefs.volumeDelta = volumeDeltaStepper.floatValue * AppConstants.ValueConversions.volume_UIToAudioGraph
        
        soundPrefs.volumeOnStartupOption = btnRememberVolume.isOn() ? .rememberFromLastAppLaunch : .specific
        soundPrefs.startupVolumeValue = Float(startupVolumeSlider.integerValue) * AppConstants.ValueConversions.volume_UIToAudioGraph
        
        soundPrefs.panDelta = panDeltaStepper.floatValue * AppConstants.ValueConversions.pan_UIToAudioGraph
        
        soundPrefs.eqDelta = eqDeltaStepper.floatValue
        soundPrefs.pitchDelta = pitchDeltaStepper.integerValue
        soundPrefs.timeDelta = timeDeltaStepper.floatValue
        
        soundPrefs.effectsSettingsOnStartupOption = btnRememberEffectsOnStartup.isOn() ? .rememberFromLastAppLaunch : .applyMasterPreset
        
        soundPrefs.masterPresetOnStartup_name = masterPresetsMenu.titleOfSelectedItem ?? ""
        
        soundPrefs.rememberEffectsSettings = btnRememberSettingsForTrack.isOn()
        
        let wasAllTracks: Bool = soundPrefs.rememberEffectsSettingsOption == .allTracks
        
        soundPrefs.rememberEffectsSettingsOption = btnRememberSettings_individualTracks.isOn() ? .individualTracks : .allTracks
        
        let isNowIndividualTracks: Bool = soundPrefs.rememberEffectsSettingsOption == .individualTracks
        
        if !soundPrefs.rememberEffectsSettings || (wasAllTracks && isNowIndividualTracks) {
            soundProfiles.removeAll()
        }
    }
}
