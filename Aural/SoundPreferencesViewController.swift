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
    
    @IBOutlet weak var btnRememberSettings: NSButton!
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
        
        btnRememberVolume.state = NSControl.StateValue(rawValue: soundPrefs.volumeOnStartup == .rememberFromLastAppLaunch ? 1 : 0)
        
        btnSpecifyVolume.state = NSControl.StateValue(rawValue: soundPrefs.volumeOnStartup == .rememberFromLastAppLaunch ? 0 : 1)
        
        startupVolumeSlider.isEnabled = Bool(btnSpecifyVolume.state.rawValue)
        startupVolumeSlider.integerValue = Int(round(soundPrefs.startupVolumeValue * AppConstants.volumeConversion_audioGraphToUI))
        
        lblStartupVolume.isEnabled = Bool(btnSpecifyVolume.state.rawValue)
        lblStartupVolume.stringValue = String(format: "%d%%", startupVolumeSlider.integerValue)
        
        let panDelta = Int(round(soundPrefs.panDelta * AppConstants.panConversion_audioGraphToUI))
        panDeltaStepper.integerValue = panDelta
        lblPanDelta.stringValue = String(format: "%d%%", panDelta)
        
        btnRememberSettings.state = soundPrefs.rememberSettings ? UIConstants.buttonState_1 : UIConstants.buttonState_0
        [btnRememberSettings_allTracks, btnRememberSettings_individualTracks].forEach({$0?.isEnabled = soundPrefs.rememberSettings})
        
        if soundPrefs.rememberSettingsOption == .individualTracks {
            btnRememberSettings_individualTracks.state = UIConstants.buttonState_1
        } else {
            btnRememberSettings_allTracks.state = UIConstants.buttonState_1
        }
    }
    
    @IBAction func volumeDeltaAction(_ sender: Any) {
        volumeDeltaField.stringValue = String(format: "%d%%", volumeDeltaStepper.integerValue)
    }
    
    @IBAction func panDeltaAction(_ sender: Any) {
        lblPanDelta.stringValue = String(format: "%d%%", panDeltaStepper.integerValue)
    }

    @IBAction func startupVolumeButtonAction(_ sender: Any) {
        [startupVolumeSlider, lblStartupVolume].forEach({$0.isEnabled = Bool(btnSpecifyVolume.state.rawValue)})
    }
    
    @IBAction func startupVolumeSliderAction(_ sender: Any) {
        lblStartupVolume.stringValue = String(format: "%d%%", startupVolumeSlider.integerValue)
    }
    
    @IBAction func rememberSettingsAction(_ sender: Any) {
        [btnRememberSettings_allTracks, btnRememberSettings_individualTracks].forEach({$0?.isEnabled = btnRememberSettings.state == UIConstants.buttonState_1})
    }
    
    @IBAction func rememberSettingsRadioButtonAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    func save(_ preferences: Preferences) throws {
        
        let soundPrefs = preferences.soundPreferences
        
        soundPrefs.volumeDelta = volumeDeltaStepper.floatValue * AppConstants.volumeConversion_UIToAudioGraph
        
        soundPrefs.volumeOnStartup = btnRememberVolume.state.rawValue == 1 ? .rememberFromLastAppLaunch : .specific
        soundPrefs.startupVolumeValue = Float(startupVolumeSlider.integerValue) * AppConstants.volumeConversion_UIToAudioGraph
        
        soundPrefs.panDelta = panDeltaStepper.floatValue * AppConstants.panConversion_UIToAudioGraph
        
        soundPrefs.rememberSettings = Bool(btnRememberSettings.state.rawValue)
        
        let wasAllTracks: Bool = soundPrefs.rememberSettingsOption == .allTracks
        
        soundPrefs.rememberSettingsOption = btnRememberSettings_individualTracks.state == UIConstants.buttonState_1 ? .individualTracks : .allTracks
        
        let isNowIndividualTracks: Bool = soundPrefs.rememberSettingsOption == .individualTracks
        
        if !soundPrefs.rememberSettings || (wasAllTracks && isNowIndividualTracks) {
            SoundProfiles.removeAll()
        }
    }
}
