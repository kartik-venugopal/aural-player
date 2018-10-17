import Cocoa

class DelayedPlaybackEditorWindowController: NSWindowController, ModalDialogDelegate {
    
    @IBOutlet weak var btnDelay: NSButton!
    @IBOutlet weak var btnTime: NSButton!
    
    @IBOutlet weak var delayPicker: IntervalPicker!
    @IBOutlet weak var lblDelay: FormattedIntervalLabel!
    
    @IBOutlet weak var timePicker: NSDatePicker!
    @IBOutlet weak var lblTime: NSTextField!
    
    @IBOutlet weak var delayFormatter: DateFormatter!
    @IBOutlet weak var dateFormatter: DateFormatter!
    
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
        
        let now = Date()
        delayPicker.maxInterval = 86400
        delayPicker.reset()
        delayPickerAction(self)
        
        // Max = 24 hours from now
        // TODO: Put this constant value in a constants file
        timePicker.minDate = now
        timePicker.maxDate = DateUtils.addToDate(now, 86400)
        timePickerAction(self)
    }
    
    @IBAction func radioButtonAction(_ sender: Any) {
        
        delayPicker.isEnabled = btnDelay.state == UIConstants.buttonState_1
        timePicker.isEnabled = !delayPicker.isEnabled
    }
    
    @IBAction func delayPickerAction(_ sender: Any) {
        lblDelay.interval = delayPicker.interval
    }
    
    @IBAction func timePickerAction(_ sender: Any) {
        lblTime.stringValue = dateFormatter.string(from: timePicker.dateValue)
    }
    
    @IBAction func okAction(_ sender: Any) {
        
        var delay: Double = 0
        
        if btnTime.state == UIConstants.buttonState_1 {
            
            let chosenTime = timePicker.dateValue
            delay = DateUtils.timeUntil(chosenTime)
            
        } else {
            
            delay = delayPicker.interval
        }
        
        if delay < 0 {delay = 0}
        
        SyncMessenger.publishActionMessage(DelayedPlaybackActionMessage(delay, PlaylistViewState.current))
        
        modalDialogResponse = .ok
        UIUtils.dismissModalDialog()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        modalDialogResponse = .cancel
        UIUtils.dismissModalDialog()
    }
}
