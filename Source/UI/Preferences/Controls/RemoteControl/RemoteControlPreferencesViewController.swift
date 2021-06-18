import Cocoa

class RemoteControlPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var lblNotApplicable: NSTextField!
    @IBOutlet weak var controlsBox: NSBox!
    
    @IBOutlet weak var btnEnableRemoteControl: NSButton!
    
    @IBOutlet weak var btnAllowPlayPause: NSButton!
    @IBOutlet weak var btnAllowStop: NSButton!
    
    @IBOutlet weak var btnAllowTrackChangeOrSeeking: NSButton!
    @IBOutlet weak var btnShowTrackChangeControls: NSButton!
    @IBOutlet weak var btnShowSeekingControls: NSButton!
    
    @IBOutlet weak var btnAllowPlaybackPositionControl: NSButton!
    
//    private var controlsButtons: [NSButton] = []
    
    override var nibName: String? {"RemoteControlPreferences"}
    
    override func viewDidLoad() {
        
        if #available(OSX 10.12.2, *) {
            
//            controlsButtons = [btnAllowPlayPause, btnAllowStop, btnAllowTrackChangeOrSeeking, btnAllowPlaybackPositionControl]
            
            lblNotApplicable.hide()
            controlsBox.show()
            
        } else {

            controlsBox.hide()
            lblNotApplicable.show()
        }
    }
    
    var preferencesView: NSView {
        return self.view
    }
    
    func resetFields(_ preferences: Preferences) {
        
        if #available(OSX 10.12.2, *) {
            
            let controlsPrefs = preferences.controlsPreferences.remoteControl
            
            btnEnableRemoteControl.onIf(controlsPrefs.enabled)
            [btnShowTrackChangeControls, btnShowSeekingControls].forEach({$0?.enableIf(controlsPrefs.enabled)})
            
            btnShowTrackChangeControls.onIf(controlsPrefs.trackChangeOrSeekingOption == .trackChange)
            btnShowSeekingControls.onIf(controlsPrefs.trackChangeOrSeekingOption == .seeking)
            
//            btnAllowPlayPause.onIf(controlsPrefs.allowPlayPause)
//            btnAllowStop.onIf(controlsPrefs.allowStop)
//            btnAllowTrackChangeOrSeeking.onIf(controlsPrefs.allowTrackChangeOrSeeking)
//
//
//
//            btnAllowPlaybackPositionControl.onIf(controlsPrefs.allowPlaybackPositionControl)
        }
    }
    
    @IBAction func enableRemoteControlAction(_ sender: Any) {
        [btnShowTrackChangeControls, btnShowSeekingControls].forEach({$0?.enableIf(btnEnableRemoteControl.isOn)})
    }
    
//    @IBAction func allowTrackChangeOrSeekingAction(_ sender: Any) {
//        [btnShowTrackChangeControls, btnShowSeekingControls].forEach({$0?.enableIf(btnAllowTrackChangeOrSeeking.isOn)})
//    }
    
    @IBAction func trackChangeOrSeekingOptionsAction(_ sender: Any) {
        // Needed for radio button group.
    }

//    @IBAction func enableAllControlsAction(_ sender: Any) {
//
//        controlsButtons.forEach({$0.on()})
//        [btnShowTrackChangeControls, btnShowSeekingControls].forEach({$0.enable()})
//    }
//
//    @IBAction func disableAllControlsAction(_ sender: Any) {
//
//        controlsButtons.forEach({$0.off()})
//        [btnShowTrackChangeControls, btnShowSeekingControls].forEach({$0.disable()})
//    }
    
    func save(_ preferences: Preferences) throws {

        if #available(OSX 10.12.2, *) {
            
            let controlsPrefs = preferences.controlsPreferences.remoteControl
            
            controlsPrefs.enabled = btnEnableRemoteControl.isOn
            controlsPrefs.trackChangeOrSeekingOption = btnShowTrackChangeControls.isOn ? .trackChange : .seeking
            
            if controlsPrefs.enabled {
                ObjectGraph.remoteCommandManager.activateCommandHandlers()
            } else {
                ObjectGraph.remoteCommandManager.deactivateCommandHandlers()
            }
            
//            controlsPrefs.allowPlayPause = btnAllowPlayPause.isOn
//            controlsPrefs.allowStop = btnAllowStop.isOn
//            controlsPrefs.allowTrackChangeOrSeeking = btnAllowTrackChangeOrSeeking.isOn
//            controlsPrefs.allowPlaybackPositionControl = btnAllowPlaybackPositionControl.isOn
            
//            ObjectGraph.remoteCommandManager.activateOrDeactivateCommandHandlers()
        }
    }
}

