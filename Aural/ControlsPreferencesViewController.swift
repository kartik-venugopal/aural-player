import Cocoa

class ControlsPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
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
    
    override var nibName: String? {return "ControlsPreferences"}
    
    override func viewDidLoad() {
        
        gestureButtons = [btnAllowVolumeControl, btnAllowSeeking, btnAllowTrackChange, btnAllowPlaylistNavigation, btnAllowPlaylistTabToggle]
    }
    
    func getView() -> NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let controlsPrefs = preferences.controlsPreferences
        
        btnAllowVolumeControl.onIf(controlsPrefs.allowVolumeControl)
        volumeControlSensitivityMenu.isEnabled = btnAllowVolumeControl.isOn()
        volumeControlSensitivityMenu.selectItem(withTitle: controlsPrefs.volumeControlSensitivity.rawValue.capitalized)
        
        btnAllowSeeking.onIf(controlsPrefs.allowSeeking)
        seekSensitivityMenu.isEnabled = btnAllowSeeking.isOn()
        seekSensitivityMenu.selectItem(withTitle: controlsPrefs.seekSensitivity.rawValue.capitalized)
        
        btnAllowTrackChange.onIf(controlsPrefs.allowTrackChange)
        
        btnAllowPlaylistNavigation.onIf(controlsPrefs.allowPlaylistNavigation)
        btnAllowPlaylistTabToggle.onIf(controlsPrefs.allowPlaylistTabToggle)
    }
    
    @IBAction func allowVolumeControlAction(_ sender: Any) {
        volumeControlSensitivityMenu.isEnabled = btnAllowVolumeControl.isOn()
    }
    
    @IBAction func allowSeekingAction(_ sender: Any) {
        seekSensitivityMenu.isEnabled = btnAllowSeeking.isOn()
    }
    
    @IBAction func enableAllGesturesAction(_ sender: Any) {
        gestureButtons.forEach({$0.on()})
        [volumeControlSensitivityMenu, seekSensitivityMenu].forEach({$0.isEnabled = true})
    }
    
    @IBAction func disableAllGesturesAction(_ sender: Any) {
        gestureButtons.forEach({$0.off()})
        [volumeControlSensitivityMenu, seekSensitivityMenu].forEach({$0.isEnabled = false})
    }
    
    func save(_ preferences: Preferences) throws {
        
        let controlsPrefs = preferences.controlsPreferences
        
        controlsPrefs.allowVolumeControl = btnAllowVolumeControl.isOn()
        controlsPrefs.volumeControlSensitivity = ScrollSensitivity(rawValue: volumeControlSensitivityMenu.titleOfSelectedItem!.lowercased())!
        
        controlsPrefs.allowSeeking = btnAllowSeeking.isOn()
        controlsPrefs.seekSensitivity = ScrollSensitivity(rawValue: seekSensitivityMenu.titleOfSelectedItem!.lowercased())!
        
        controlsPrefs.allowTrackChange = btnAllowTrackChange.isOn()
        
        controlsPrefs.allowPlaylistNavigation = btnAllowPlaylistNavigation.isOn()
        controlsPrefs.allowPlaylistTabToggle = btnAllowPlaylistTabToggle.isOn()
    }
}
