import Cocoa

class JumpToTimeEditorWindowController: NSWindowController, AsyncMessageSubscriber, ModalDialogDelegate {
    
    override var windowNibName: String? {return "JumpToTimeEditorDialog"}
    
    @IBOutlet weak var lblTrackName: NSTextField!
    @IBOutlet weak var lblTrackDuration: NSTextField!
    
    @IBOutlet weak var btnHMS: NSButton!
    @IBOutlet weak var btnSeconds: NSButton!
    
    @IBOutlet weak var timePicker: NSDatePicker!
    @IBOutlet weak var secondsFormatter: JumpToTimeSecondsFormatter!
    
    @IBOutlet weak var txtSeconds: NSTextField!
    @IBOutlet weak var stepper: NSStepper!
    
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
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
        
        AsyncMessenger.subscribe([.trackChanged], subscriber: self, dispatchQueue: DispatchQueue.main)
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
        
        if let playingTrack = playbackInfo.getPlayingTrack() {
        
            let roundedDuration = round(playingTrack.track.duration)
            let formattedDuration = StringUtils.formatSecondsToHMS(roundedDuration)
            let durationInt = Int(roundedDuration)
            
            lblTrackName.stringValue = String(format: "Track:   %@", playingTrack.track.conciseDisplayName)
            lblTrackDuration.stringValue = String(format: "Duration:   %@", formattedDuration)
            
            btnHMS.state = UIConstants.buttonState_1
            radioButtonAction(self)
            
            btnHMS.title = String(format: "Specify as hh : mm : ss (00:00:00 to %@)", formattedDuration)
            btnSeconds.title = String(format: "Specify as seconds (0 to %d)", durationInt)
            
            // Reset to 00:00:00
            let startOfDay = Date().startOfDay
            timePicker.dateValue = startOfDay
            timePicker.maxDate = startOfDay.addingTimeInterval(roundedDuration)
            
            secondsFormatter.maxValue = durationInt
            stepper.maxValue = roundedDuration
            stepper.doubleValue = 0
            secondsStepperAction(self)
            
        } else {
            
            // No track playing
            cancelAction(self)
        }
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
    
    private func trackChanged(_ msg: TrackChangedAsyncMessage) {
        resetFields()
    }
    
    // MARK: Message handling
    
    func getID() -> String {
        return self.className
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .trackChanged:
            
            // Update the track duration
            trackChanged(message as! TrackChangedAsyncMessage)
            
        default:
            
            return
            
        }
    }
}

extension Date {
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
