import Cocoa

class GesturesPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    // Gestures
    @IBOutlet weak var btnAllowVolumeControl: NSButton!
    @IBOutlet weak var btnAllowSeeking: NSButton!
    @IBOutlet weak var btnAllowTrackChange: NSButton!
    
    @IBOutlet weak var btnAllowPlaylistNavigation: NSButton!
    @IBOutlet weak var btnAllowPlaylistTabToggle: NSButton!
    
    private var gestureButtons: [NSButton] = []
    
    // Sensitivity
    @IBOutlet weak var volumeControlSensitivityMenu: NSPopUpButton!
    @IBOutlet weak var seekSensitivityMenu: NSPopUpButton!
    
    override var nibName: String? {"GesturesPreferences"}
    
    override func viewDidLoad() {
        
        gestureButtons = [btnAllowVolumeControl, btnAllowSeeking, btnAllowTrackChange, btnAllowPlaylistNavigation, btnAllowPlaylistTabToggle]
    }
    
    var preferencesView: NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let controlsPrefs = preferences.controlsPreferences.gestures
        
        btnAllowVolumeControl.onIf(controlsPrefs.allowVolumeControl)
        volumeControlSensitivityMenu.enableIf(btnAllowVolumeControl.isOn)
        volumeControlSensitivityMenu.selectItem(withTitle: controlsPrefs.volumeControlSensitivity.rawValue.capitalized)
        
        btnAllowSeeking.onIf(controlsPrefs.allowSeeking)
        seekSensitivityMenu.enableIf(btnAllowSeeking.isOn)
        seekSensitivityMenu.selectItem(withTitle: controlsPrefs.seekSensitivity.rawValue.capitalized)
        
        btnAllowTrackChange.onIf(controlsPrefs.allowTrackChange)
        
        btnAllowPlaylistNavigation.onIf(controlsPrefs.allowPlaylistNavigation)
        btnAllowPlaylistTabToggle.onIf(controlsPrefs.allowPlaylistTabToggle)
    }

    @IBAction func allowVolumeControlAction(_ sender: Any) {
        volumeControlSensitivityMenu.enableIf(btnAllowVolumeControl.isOn)
    }
    
    @IBAction func allowSeekingAction(_ sender: Any) {
        seekSensitivityMenu.enableIf(btnAllowSeeking.isOn)
    }
    
    @IBAction func enableAllGesturesAction(_ sender: Any) {
        gestureButtons.forEach({$0.on()})
        [volumeControlSensitivityMenu, seekSensitivityMenu].forEach({$0.enable()})
    }
    
    @IBAction func disableAllGesturesAction(_ sender: Any) {
        gestureButtons.forEach({$0.off()})
        [volumeControlSensitivityMenu, seekSensitivityMenu].forEach({$0.disable()})
    }
    
    func save(_ preferences: Preferences) throws {
        
        let controlsPrefs = preferences.controlsPreferences.gestures
        
        controlsPrefs.allowVolumeControl = btnAllowVolumeControl.isOn
        controlsPrefs.volumeControlSensitivity = ScrollSensitivity(rawValue: volumeControlSensitivityMenu.titleOfSelectedItem!.lowercased())!
        
        controlsPrefs.allowSeeking = btnAllowSeeking.isOn
        controlsPrefs.seekSensitivity = ScrollSensitivity(rawValue: seekSensitivityMenu.titleOfSelectedItem!.lowercased())!
        
        controlsPrefs.allowTrackChange = btnAllowTrackChange.isOn
        
        controlsPrefs.allowPlaylistNavigation = btnAllowPlaylistNavigation.isOn
        controlsPrefs.allowPlaylistTabToggle = btnAllowPlaylistTabToggle.isOn
    }
}
