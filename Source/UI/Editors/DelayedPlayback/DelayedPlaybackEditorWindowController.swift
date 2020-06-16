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
        WindowManager.registerModalComponent(self)
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
    
    func resetFields() {
        
        // Initial values will depend on whether the dialog is in "create" mode or "edit" mode
        btnDelay.on()
        radioButtonAction(self)
        
        let now = Date()
        delayPicker.maxInterval = 86400
        delayPicker.reset()
        delayPickerAction(self)
        
        // Max = 24 hours from now
        // TODO: Put this constant value in a constants file
        timePicker.minDate = now
        timePicker.maxDate = now + 86400
        timePickerAction(self)
    }
    
    @IBAction func radioButtonAction(_ sender: Any) {
        
        delayPicker.enableIf(btnDelay.isOn)
        timePicker.enableIf(!delayPicker.isEnabled)
    }
    
    @IBAction func delayPickerAction(_ sender: Any) {
        lblDelay.interval = delayPicker.interval
    }
    
    @IBAction func timePickerAction(_ sender: Any) {
        lblTime.stringValue = dateFormatter.string(from: timePicker.dateValue)
    }
    
    @IBAction func okAction(_ sender: Any) {
        
        var delay: Double = 0
        
        if btnTime.isOn {
            
            let chosenTime = timePicker.dateValue
            delay = DateUtils.timeUntil(chosenTime)
            
        } else {
            
            delay = delayPicker.interval
        }
        
        if delay < 0 {delay = 0}
        
        Messenger.publish(DelayedPlaybackCommandNotification(delay: delay,
                                                             viewSelector: PlaylistViewSelector.forView(PlaylistViewState.current)))
        
        modalDialogResponse = .ok
        UIUtils.dismissDialog(self.window!)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        modalDialogResponse = .cancel
        UIUtils.dismissDialog(self.window!)
    }
}
