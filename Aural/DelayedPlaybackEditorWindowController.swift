import Cocoa

class DelayedPlaybackEditorWindowController: NSWindowController, ModalDialogDelegate {
    
    @IBOutlet weak var btnDelay: NSButton!
    @IBOutlet weak var btnTime: NSButton!
    
    @IBOutlet weak var btnDelayDecrement: NSButton!
    @IBOutlet weak var btnDelayIncrement: NSButton!
    
    @IBOutlet weak var delaySlider: NSSlider!
    @IBOutlet weak var lblDelay: NSTextField!
    
    @IBOutlet weak var timePicker: NSDatePicker!
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
    override var windowNibName: String? {return "DelayedPlaybackEditorDialog"}
    
    override func windowDidLoad() {
        
        self.window?.titlebarAppearsTransparent = true
        super.windowDidLoad()
    }
    
    func showDialog() -> ModalDialogResponse {
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if (!self.isWindowLoaded) {
            _ = self.window!
        }
        
        resetFields()
        
        UIUtils.showModalDialog(self.window!)
        return modalDialogResponse
    }
    
    func resetFields() {
        
        // Initial values will depend on whether the dialog is in "create" mode or "edit" mode
        btnDelay.state = UIConstants.buttonState_1
        radioButtonAction(self)
        
        delaySlider.integerValue = 5
        delaySliderAction(self)
    }
    
    @IBAction func radioButtonAction(_ sender: Any) {
        
        [delaySlider, btnDelayDecrement, btnDelayIncrement].forEach({$0?.isEnabled = btnDelay.state == UIConstants.buttonState_1})
        timePicker.isEnabled = btnTime.state == UIConstants.buttonState_1
    }
    
    @IBAction func delayIncrementAction(_ sender: Any) {
        
        if (Double(delaySlider.integerValue) < delaySlider.maxValue) {
            delaySlider.integerValue += 1
            lblDelay.stringValue = StringUtils.formatSecondsToHMS_hrMinSec(delaySlider.integerValue)
        }
    }
    
    @IBAction func delayDecrementAction(_ sender: Any) {
        
        if (Double(delaySlider.integerValue) > delaySlider.minValue) {
            delaySlider.integerValue -= 1
            lblDelay.stringValue = StringUtils.formatSecondsToHMS_hrMinSec(delaySlider.integerValue)
        }
    }
    
    @IBAction func delaySliderAction(_ sender: Any) {
        lblDelay.stringValue = StringUtils.formatSecondsToHMS_hrMinSec(delaySlider.integerValue)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        
        SyncMessenger.publishActionMessage(DelayedPlaybackActionMessage(delaySlider.doubleValue, PlaylistViewState.current))
        
        modalDialogResponse = .ok
        UIUtils.dismissModalDialog()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        modalDialogResponse = .cancel
        UIUtils.dismissModalDialog()
    }
}
