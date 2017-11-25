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
        
        btnAllowVolumeControl.state = controlsPrefs.allowVolumeControl ? 1 : 0
        volumeControlSensitivityMenu.isEnabled = btnAllowVolumeControl.state == 1
        volumeControlSensitivityMenu.selectItem(withTitle: controlsPrefs.volumeControlSensitivity.rawValue.capitalized)
        
        btnAllowSeeking.state = controlsPrefs.allowSeeking ? 1 : 0
        seekSensitivityMenu.isEnabled = btnAllowSeeking.state == 1
        seekSensitivityMenu.selectItem(withTitle: controlsPrefs.seekSensitivity.rawValue.capitalized)
        
        btnAllowTrackChange.state = controlsPrefs.allowTrackChange ? 1 : 0
        
        btnAllowPlaylistNavigation.state = controlsPrefs.allowPlaylistNavigation ? 1 : 0
        btnAllowPlaylistTabToggle.state = controlsPrefs.allowPlaylistTabToggle ? 1 : 0
    }
    
    @IBAction func allowVolumeControlAction(_ sender: Any) {
        volumeControlSensitivityMenu.isEnabled = Bool(btnAllowVolumeControl.state)
    }
    
    @IBAction func allowSeekingAction(_ sender: Any) {
        seekSensitivityMenu.isEnabled = Bool(btnAllowSeeking.state)
    }
    
    @IBAction func enableAllGesturesAction(_ sender: Any) {
        gestureButtons.forEach({$0.state = 1})
        [volumeControlSensitivityMenu, seekSensitivityMenu].forEach({$0.isEnabled = true})
    }
    
    @IBAction func disableAllGesturesAction(_ sender: Any) {
        gestureButtons.forEach({$0.state = 0})
        [volumeControlSensitivityMenu, seekSensitivityMenu].forEach({$0.isEnabled = false})
    }
    
    func save(_ preferences: Preferences) {
        
        let controlsPrefs = preferences.controlsPreferences
        
        controlsPrefs.allowVolumeControl = Bool(btnAllowVolumeControl.state)
        controlsPrefs.volumeControlSensitivity = ScrollSensitivity(rawValue: volumeControlSensitivityMenu.titleOfSelectedItem!.lowercased())!
        
        controlsPrefs.allowSeeking = Bool(btnAllowSeeking.state)
        controlsPrefs.seekSensitivity = ScrollSensitivity(rawValue: seekSensitivityMenu.titleOfSelectedItem!.lowercased())!
        
        controlsPrefs.allowTrackChange = Bool(btnAllowTrackChange.state)
        
        controlsPrefs.allowPlaylistNavigation = Bool(btnAllowPlaylistNavigation.state)
        controlsPrefs.allowPlaylistTabToggle = Bool(btnAllowPlaylistTabToggle.state)
    }
}
