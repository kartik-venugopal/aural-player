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
        
        btnAllowVolumeControl.state = NSControl.StateValue(rawValue: controlsPrefs.allowVolumeControl ? 1 : 0)
        volumeControlSensitivityMenu.isEnabled = btnAllowVolumeControl.state.rawValue == 1
        volumeControlSensitivityMenu.selectItem(withTitle: controlsPrefs.volumeControlSensitivity.rawValue.capitalized)
        
        btnAllowSeeking.state = NSControl.StateValue(rawValue: controlsPrefs.allowSeeking ? 1 : 0)
        seekSensitivityMenu.isEnabled = btnAllowSeeking.state.rawValue == 1
        seekSensitivityMenu.selectItem(withTitle: controlsPrefs.seekSensitivity.rawValue.capitalized)
        
        btnAllowTrackChange.state = NSControl.StateValue(rawValue: controlsPrefs.allowTrackChange ? 1 : 0)
        
        btnAllowPlaylistNavigation.state = NSControl.StateValue(rawValue: controlsPrefs.allowPlaylistNavigation ? 1 : 0)
        btnAllowPlaylistTabToggle.state = NSControl.StateValue(rawValue: controlsPrefs.allowPlaylistTabToggle ? 1 : 0)
    }
    
    @IBAction func allowVolumeControlAction(_ sender: Any) {
        volumeControlSensitivityMenu.isEnabled = Bool(btnAllowVolumeControl.state.rawValue)
    }
    
    @IBAction func allowSeekingAction(_ sender: Any) {
        seekSensitivityMenu.isEnabled = Bool(btnAllowSeeking.state.rawValue)
    }
    
    @IBAction func enableAllGesturesAction(_ sender: Any) {
        gestureButtons.forEach({$0.state = convertToNSControlStateValue(1)})
        [volumeControlSensitivityMenu, seekSensitivityMenu].forEach({$0.isEnabled = true})
    }
    
    @IBAction func disableAllGesturesAction(_ sender: Any) {
        gestureButtons.forEach({$0.state = convertToNSControlStateValue(0)})
        [volumeControlSensitivityMenu, seekSensitivityMenu].forEach({$0.isEnabled = false})
    }
    
    func save(_ preferences: Preferences) throws {
        
        let controlsPrefs = preferences.controlsPreferences
        
        controlsPrefs.allowVolumeControl = Bool(btnAllowVolumeControl.state.rawValue)
        controlsPrefs.volumeControlSensitivity = ScrollSensitivity(rawValue: volumeControlSensitivityMenu.titleOfSelectedItem!.lowercased())!
        
        controlsPrefs.allowSeeking = Bool(btnAllowSeeking.state.rawValue)
        controlsPrefs.seekSensitivity = ScrollSensitivity(rawValue: seekSensitivityMenu.titleOfSelectedItem!.lowercased())!
        
        controlsPrefs.allowTrackChange = Bool(btnAllowTrackChange.state.rawValue)
        
        controlsPrefs.allowPlaylistNavigation = Bool(btnAllowPlaylistNavigation.state.rawValue)
        controlsPrefs.allowPlaylistTabToggle = Bool(btnAllowPlaylistTabToggle.state.rawValue)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSControlStateValue(_ input: Int) -> NSControl.StateValue {
	return NSControl.StateValue(rawValue: input)
}
