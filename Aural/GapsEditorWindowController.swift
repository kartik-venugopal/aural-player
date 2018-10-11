import Cocoa

class GapsEditorWindowController: NSWindowController, ModalDialogDelegate {
    
    @IBOutlet weak var btnGapType_oneTime: NSButton!
    @IBOutlet weak var btnGapType_tillAppExits: NSButton!
    @IBOutlet weak var btnGapType_persistent: NSButton!
    
    @IBOutlet weak var durationSlider: NSSlider!
    @IBOutlet weak var lblDuration: NSTextField!
    
    private var gapPosition: PlaybackGapPosition?
    
    // Delegate that relays CRUD actions to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    override var windowNibName: String? {return "GapsEditorDialog"}
    
    override func windowDidLoad() {
        
        self.window?.titlebarAppearsTransparent = true
        super.windowDidLoad()
    }
    
    func setDataForKey(_ key: String, _ value: Any?) {
        
        if key == "gapPosition" {
            
            if let posn = value as? PlaybackGapPosition {
                gapPosition = posn
            }
        }
    }
    
    func showDialog() {
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if (!self.isWindowLoaded) {
            _ = self.window!
        }
        
        resetFields()
        
        UIUtils.showModalDialog(self.window!)
    }
    
    func resetFields() {
        
        durationSlider.integerValue = 1
        lblDuration.stringValue = StringUtils.formatSecondsToHMS_hrMinSec(durationSlider.integerValue)
        btnGapType_tillAppExits.state = UIConstants.buttonState_1
    }
    
    @IBAction func gapTypeAction(_ sender: Any) {
        // Needed for radio button group
    }
    
    @IBAction func durationIncrementAction(_ sender: Any) {
        
        if (Double(durationSlider.integerValue) < durationSlider.maxValue) {
            durationSlider.integerValue += 1
            lblDuration.stringValue = StringUtils.formatSecondsToHMS_hrMinSec(durationSlider.integerValue)
        }
    }
    
    @IBAction func durationDecrementAction(_ sender: Any) {
        
        if (Double(durationSlider.integerValue) > durationSlider.minValue) {
            durationSlider.integerValue -= 1
            lblDuration.stringValue = StringUtils.formatSecondsToHMS_hrMinSec(durationSlider.integerValue)
        }
    }
    
    @IBAction func durationSliderAction(_ sender: Any) {
        lblDuration.stringValue = StringUtils.formatSecondsToHMS_hrMinSec(durationSlider.integerValue)
    }
    
    private func getClickedTrack() -> Track {
        
        let clickedItem = PlaylistViewContext.clickedItem
        return clickedItem.type == .index ? playlist.trackAtIndex(clickedItem.index!)!.track : clickedItem.track!
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
        let duration = Double(durationSlider.integerValue)
        var type: PlaybackGapType = .tillAppExits
        
        if btnGapType_oneTime.state == UIConstants.buttonState_1 {
            type = .oneTime
        } else if btnGapType_persistent.state == UIConstants.buttonState_1 {
            type = .persistent
        }
        
        let gap = PlaybackGap(duration, gapPosition!, type)
        SyncMessenger.publishActionMessage(InsertPlaybackGapActionMessage(getClickedTrack(), gap, PlaylistViewState.current))
        
        UIUtils.dismissModalDialog()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        UIUtils.dismissModalDialog()
    }
}
