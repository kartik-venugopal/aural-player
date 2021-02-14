import Cocoa

class ControlsPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    // Media keys response
    @IBOutlet weak var btnRespondToMediaKeys: NSButton!
    
    // SKip key behavior
    @IBOutlet weak var btnHybrid: NSButton!
    @IBOutlet weak var btnTrackChangesOnly: NSButton!
    @IBOutlet weak var btnSeekingOnly: NSButton!
    
    @IBOutlet weak var repeatSpeedMenu: NSPopUpButton!
    
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
    
    private lazy var mediaKeyHandler: MediaKeyHandler = ObjectGraph.mediaKeyHandler
    
    override var nibName: String? {return "ControlsPreferences"}
    
    override func viewDidLoad() {
        
        gestureButtons = [btnAllowVolumeControl, btnAllowSeeking, btnAllowTrackChange, btnAllowPlaylistNavigation, btnAllowPlaylistTabToggle]
    }
    
    var preferencesView: NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
        let controlsPrefs = preferences.controlsPreferences
        
        btnRespondToMediaKeys.onIf(controlsPrefs.respondToMediaKeys)
        mediaKeyResponseAction(self)
        
        [btnHybrid, btnTrackChangesOnly, btnSeekingOnly].forEach({$0?.off()})
        
        switch controlsPrefs.skipKeyBehavior {
            
        case .hybrid:   btnHybrid.on()
            
        case .trackChangesOnly:     btnTrackChangesOnly.on()
            
        case .seekingOnly:          btnSeekingOnly.on()
            
        }
        
        repeatSpeedMenu.selectItem(withTitle: controlsPrefs.repeatSpeed.rawValue.capitalized)
        
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
    
    @IBAction func mediaKeyResponseAction(_ sender: Any) {
    }
    
    @IBAction func skipKeyBehaviorAction(_ sender: Any) {
        // Needed for radio button group
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
        
        let controlsPrefs = preferences.controlsPreferences
        
        controlsPrefs.respondToMediaKeys = btnRespondToMediaKeys.isOn
        
        if btnHybrid.isOn {
            controlsPrefs.skipKeyBehavior = .hybrid
        } else if btnTrackChangesOnly.isOn {
            controlsPrefs.skipKeyBehavior = .trackChangesOnly
        } else {
            controlsPrefs.skipKeyBehavior = .seekingOnly
        }
        
        controlsPrefs.repeatSpeed = SkipKeyRepeatSpeed(rawValue: repeatSpeedMenu.titleOfSelectedItem!.lowercased())!
        
        controlsPrefs.allowVolumeControl = btnAllowVolumeControl.isOn
        controlsPrefs.volumeControlSensitivity = ScrollSensitivity(rawValue: volumeControlSensitivityMenu.titleOfSelectedItem!.lowercased())!
        
        controlsPrefs.allowSeeking = btnAllowSeeking.isOn
        controlsPrefs.seekSensitivity = ScrollSensitivity(rawValue: seekSensitivityMenu.titleOfSelectedItem!.lowercased())!
        
        controlsPrefs.allowTrackChange = btnAllowTrackChange.isOn
        
        controlsPrefs.allowPlaylistNavigation = btnAllowPlaylistNavigation.isOn
        controlsPrefs.allowPlaylistTabToggle = btnAllowPlaylistTabToggle.isOn
        
        controlsPrefs.respondToMediaKeys ? mediaKeyHandler.startMonitoring() : mediaKeyHandler.stopMonitoring()
    }
}
