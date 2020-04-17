import Cocoa

class GapsEditorWindowController: NSWindowController, ModalDialogDelegate {
    
    @IBOutlet weak var btnGapBeforeTrack: NSButton!
    
    @IBOutlet weak var btnGapType_oneTime_1: NSButton!
    @IBOutlet weak var btnGapType_tillAppExits_1: NSButton!
    @IBOutlet weak var btnGapType_persistent_1: NSButton!
    
    @IBOutlet weak var timePicker_1: IntervalPicker!
    @IBOutlet weak var lblDuration_1: FormattedIntervalLabel!
    
    @IBOutlet weak var btnGapAfterTrack: NSButton!
    
    @IBOutlet weak var btnGapType_oneTime_2: NSButton!
    @IBOutlet weak var btnGapType_tillAppExits_2: NSButton!
    @IBOutlet weak var btnGapType_persistent_2: NSButton!
    
    @IBOutlet weak var timePicker_2: IntervalPicker!
    @IBOutlet weak var lblDuration_2: FormattedIntervalLabel!
    
    private var gaps: (hasGaps: Bool, beforeTrack: PlaybackGap?, afterTrack: PlaybackGap?)?
    
    // Delegate that relays CRUD actions to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
    override var windowNibName: String? {return "GapsEditorDialog"}
    
    override func windowDidLoad() {
        ObjectGraph.layoutManager.registerModalComponent(self)
    }
    
    var isModal: Bool {
        return self.window?.isVisible ?? false
    }
    
    func showDialog() -> ModalDialogResponse {
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if (!self.isWindowLoaded) {
            _ = self.window!
        }
        
        resetFields()
        
        UIUtils.showDialog(self.window!)
        return modalDialogResponse
    }
    
    func setDataForKey(_ key: String, _ value: Any?) {
        
        if key == "gaps" {
            
            if let val = value as? (hasGaps: Bool, beforeTrack: PlaybackGap?, afterTrack: PlaybackGap?)? {
                self.gaps = val
            }
        }
    }
    
    func resetFields() {
        
        // Initial values will depend on whether the dialog is in "create" mode or "edit" mode
        
        if let gapB = gaps?.beforeTrack {
        
            btnGapBeforeTrack.on()
            timePicker_1.setInterval(gapB.duration)
            
            switch gapB.type {
                
            case .oneTime:
                
                btnGapType_oneTime_1.on()
                
            case .tillAppExits:
                
                btnGapType_tillAppExits_1.on()
                
            case .persistent:
                
                btnGapType_persistent_1.on()
                
            default: NSLog("Gap type (before track) is implicit. This should be impossible !")
                
            }
            
        } else {
            
            btnGapBeforeTrack.off()
            timePicker_1.setInterval(5)
            btnGapType_persistent_1.on()
        }
        
        if let gapA = gaps?.afterTrack {
            
            btnGapAfterTrack.on()
            timePicker_2.setInterval(gapA.duration)
            
            switch gapA.type {
                
            case .oneTime:
                
                btnGapType_oneTime_2.on()
                
            case .tillAppExits:
                
                btnGapType_tillAppExits_2.on()
                
            case .persistent:
                
                btnGapType_persistent_2.on()
                
            default: NSLog("Gap type (after track) is implicit. This should be impossible !")
                
            }
            
        } else {
            
            btnGapAfterTrack.off()
            timePicker_2.setInterval(5)
            btnGapType_persistent_2.on()
        }
        
        timePickerAction_1(self)
        timePickerAction_2(self)
        gapBeforeTrackAction(self)
        gapAfterTrackAction(self)
    }
    
    @IBAction func gapBeforeTrackAction(_ sender: Any) {
        
        [timePicker_1, btnGapType_oneTime_1, btnGapType_persistent_1, btnGapType_tillAppExits_1].forEach({$0?.enableIf(btnGapBeforeTrack.isOn)})
    }
    
    @IBAction func gapTypeAction_1(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func timePickerAction_1(_ sender: Any) {
        lblDuration_1.interval = timePicker_1.interval
    }
    
    @IBAction func gapAfterTrackAction(_ sender: Any) {
        
        [timePicker_2, btnGapType_oneTime_2, btnGapType_persistent_2, btnGapType_tillAppExits_2].forEach({$0?.enableIf(btnGapAfterTrack.isOn)})
    }
    
    @IBAction func gapTypeAction_2(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func timePickerAction_2(_ sender: Any) {
        lblDuration_2.interval = timePicker_2.interval
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
        var gapBeforeTrack: PlaybackGap? = nil
        var gapAfterTrack: PlaybackGap? = nil
        
        if btnGapBeforeTrack.isOn {
        
            let duration1 = timePicker_1.interval
            var type1: PlaybackGapType = .tillAppExits
            
            if btnGapType_oneTime_1.isOn {
                type1 = .oneTime
            } else if btnGapType_persistent_1.isOn {
                type1 = .persistent
            }
            
            gapBeforeTrack = PlaybackGap(duration1, .beforeTrack, type1)
        }
        
        if btnGapAfterTrack.isOn {
            
            let duration2 = timePicker_2.interval
            var type2: PlaybackGapType = .tillAppExits
            
            if btnGapType_oneTime_2.isOn {
                type2 = .oneTime
            } else if btnGapType_persistent_2.isOn {
                type2 = .persistent
            }
            
            gapAfterTrack = PlaybackGap(duration2, .afterTrack, type2)
        }
        
        SyncMessenger.publishActionMessage(InsertPlaybackGapsActionMessage(gapBeforeTrack, gapAfterTrack, PlaylistViewState.current))
        
        modalDialogResponse = .ok
        UIUtils.dismissDialog(self.window!)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        modalDialogResponse = .cancel
        UIUtils.dismissDialog(self.window!)
    }
}
