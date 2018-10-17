import Cocoa

class JumpToTimeEditorWindowController: NSWindowController, ModalDialogDelegate {
    
    override var windowNibName: String? {return "JumpToTimeEditorDialog"}
    
    @IBOutlet weak var btnHMS: NSButton!
    @IBOutlet weak var btnSeconds: NSButton!
    
    @IBOutlet weak var timePicker: NSDatePicker!
    @IBOutlet weak var secondsFormatter: JumpToTimeSecondsFormatter!
    
    @IBOutlet weak var txtSeconds: NSTextField!
    @IBOutlet weak var stepper: NSStepper!
    
    private var trackDuration: Double = 0
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
    func setDataForKey(_ key: String, _ value: Any?) {
        
        if key == "trackDuration" {
            
            if let val = value as? Double {
                self.trackDuration = val
            }
        }
    }
    
    override func windowDidLoad() {
        
        // 24 hour clock (don't want AM/PM)
        timePicker.locale = Locale(identifier: "en_GB")
        
        secondsFormatter.valueFunction = {
            () -> String in
            
            return String(describing: self.stepper.integerValue)
        }
        
        secondsFormatter.updateFunction = {
            (_ value: Int) in
            
            self.stepper.integerValue = value
        }
    }
    
    func showDialog() -> ModalDialogResponse {
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if (!self.isWindowLoaded) {
            _ = self.window!
        }
        
        resetFields()
        
        UIUtils.showModalDialog(self.window!)
        
        return .ok
    }
    
    func resetFields() {
        
        btnHMS.state = UIConstants.buttonState_1
        radioButtonAction(self)
        
        // Reset to 00:00:00
        let startOfDay = Date().startOfDay
        timePicker.dateValue = startOfDay
        timePicker.maxDate = startOfDay.addingTimeInterval(trackDuration)
        
        secondsFormatter.maxValue = Int(trackDuration)
        stepper.maxValue = trackDuration
        stepper.doubleValue = 0
        secondsStepperAction(self)
    }
    
    @IBAction func radioButtonAction(_ sender: Any) {
        
        timePicker.isEnabled = btnHMS.state == UIConstants.buttonState_1
        [txtSeconds, stepper].forEach({$0?.isEnabled = btnSeconds.state == UIConstants.buttonState_1})
        
        if (txtSeconds.isEnabled) {
            self.window?.makeFirstResponder(txtSeconds)
        }
    }
    
    @IBAction func secondsStepperAction(_ sender: Any) {
        txtSeconds.stringValue = String(describing: stepper.integerValue)
    }
    
    @IBAction func okAction(_ sender: Any) {
        
        var jumpToTime: Double = 0
        
        if btnHMS.state == UIConstants.buttonState_1 {
            
            // HH : MM : SS
            let chosenTime = timePicker.dateValue
            jumpToTime = chosenTime.timeIntervalSince(chosenTime.startOfDay)
            
        } else {
            
            // Seconds
            jumpToTime = stepper.doubleValue
        }
        
        SyncMessenger.publishActionMessage(JumpToTimeActionMessage(jumpToTime))
        
        modalDialogResponse = .ok
        UIUtils.dismissModalDialog()
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        modalDialogResponse = .cancel
        UIUtils.dismissModalDialog()
    }
}

extension Date {
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
