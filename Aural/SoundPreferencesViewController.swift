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
    
    override var nibName: String? {return "SoundPreferences"}
    
    func getView() -> NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let soundPrefs = preferences.soundPreferences
        
        let volumeDelta = Int(round(soundPrefs.volumeDelta * AppConstants.volumeConversion_audioGraphToUI))
        volumeDeltaStepper.integerValue = volumeDelta
        volumeDeltaField.stringValue = String(format: "%d%%", volumeDelta)
        
        btnRememberVolume.state = soundPrefs.volumeOnStartup == .rememberFromLastAppLaunch ? 1 : 0
        
        btnSpecifyVolume.state = soundPrefs.volumeOnStartup == .rememberFromLastAppLaunch ? 0 : 1
        
        startupVolumeSlider.isEnabled = Bool(btnSpecifyVolume.state)
        startupVolumeSlider.integerValue = Int(round(soundPrefs.startupVolumeValue * AppConstants.volumeConversion_audioGraphToUI))
        
        lblStartupVolume.isEnabled = Bool(btnSpecifyVolume.state)
        lblStartupVolume.stringValue = String(format: "%d%%", startupVolumeSlider.integerValue)
        
        let panDelta = Int(round(soundPrefs.panDelta * AppConstants.panConversion_audioGraphToUI))
        panDeltaStepper.integerValue = panDelta
        lblPanDelta.stringValue = String(format: "%d%%", panDelta)
    }
    
    @IBAction func volumeDeltaAction(_ sender: Any) {
        volumeDeltaField.stringValue = String(format: "%d%%", volumeDeltaStepper.integerValue)
    }
    
    @IBAction func panDeltaAction(_ sender: Any) {
        lblPanDelta.stringValue = String(format: "%d%%", panDeltaStepper.integerValue)
    }

    @IBAction func startupVolumeButtonAction(_ sender: Any) {
        [startupVolumeSlider, lblStartupVolume].forEach({$0.isEnabled = Bool(btnSpecifyVolume.state)})
    }
    
    @IBAction func startupVolumeSliderAction(_ sender: Any) {
        lblStartupVolume.stringValue = String(format: "%d%%", startupVolumeSlider.integerValue)
    }
    
    func save(_ preferences: Preferences) {
        
        let soundPrefs = preferences.soundPreferences
        
        soundPrefs.volumeDelta = volumeDeltaStepper.floatValue * AppConstants.volumeConversion_UIToAudioGraph
        
        soundPrefs.volumeOnStartup = btnRememberVolume.state == 1 ? .rememberFromLastAppLaunch : .specific
        soundPrefs.startupVolumeValue = Float(startupVolumeSlider.integerValue) * AppConstants.volumeConversion_UIToAudioGraph
        
        soundPrefs.panDelta = panDeltaStepper.floatValue * AppConstants.panConversion_UIToAudioGraph
    }
}
