import Cocoa

class JumpToTimeEditorWindowController: NSWindowController, AsyncMessageSubscriber, ModalDialogDelegate {
    
    override var windowNibName: String? {return "JumpToTimeEditorDialog"}
    
    @IBOutlet weak var lblTrackName: NSTextField!
    @IBOutlet weak var lblTrackDuration: NSTextField!
    
    @IBOutlet weak var btnHMS: NSButton!
    @IBOutlet weak var btnSeconds: NSButton!
    @IBOutlet weak var btnPercentage: NSButton!
    
    @IBOutlet weak var timePicker: IntervalPicker!
    
    @IBOutlet weak var secondsFormatter: JumpToTimeValueFormatter!
    
    @IBOutlet weak var percentageFormatter: JumpToTimeValueFormatter!
    
    @IBOutlet weak var txtSeconds: NSTextField!
    @IBOutlet weak var secondsStepper: NSStepper!
    
    @IBOutlet weak var txtPercentage: NSTextField!
    @IBOutlet weak var percentageStepper: NSStepper!
    
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
    override func windowDidLoad() {
        
        secondsFormatter.valueFunction = {
            () -> String in
            
            return String(describing: self.secondsStepper.doubleValue)
        }
        
        secondsFormatter.updateFunction = {
            (_ value: Double) in
            
            self.secondsStepper.doubleValue = value
        }
        
        percentageFormatter.valueFunction = {
            () -> String in
            
            return String(describing: self.percentageStepper.doubleValue)
        }
        
        percentageFormatter.updateFunction = {
            (_ value: Double) in
            
            self.percentageStepper.doubleValue = value
        }
        
        percentageFormatter.maxValue = 100
        
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
            
            btnHMS.on()
            radioButtonAction(self)
            
            btnHMS.title = String(format: "Specify as hh : mm : ss (00:00:00 to %@)", formattedDuration)
            btnSeconds.title = String(format: "Specify as seconds (0 to %d)", durationInt)
            
            // Reset to 00:00:00
            timePicker.maxInterval = roundedDuration
            timePicker.reset()
            
            secondsFormatter.maxValue = roundedDuration
            secondsStepper.maxValue = roundedDuration
            secondsStepper.doubleValue = 0
            secondsStepperAction(self)
            
            percentageStepper.doubleValue = 0
            percentageStepperAction(self)
            
        } else {
            
            // No track playing
            cancelAction(self)
        }
    }
    
    @IBAction func radioButtonAction(_ sender: Any) {
        
        timePicker.enableIf(btnHMS.isOn())
        [txtSeconds, secondsStepper].forEach({$0?.enableIf(btnSeconds.isOn())})
        
        if (txtSeconds.isEnabled) {
            self.window?.makeFirstResponder(txtSeconds)
        }
        
        [txtPercentage, percentageStepper].forEach({$0?.enableIf(btnPercentage.isOn())})
        
        if (txtPercentage.isEnabled) {
            self.window?.makeFirstResponder(txtPercentage)
        }
    }
    
    @IBAction func secondsStepperAction(_ sender: Any) {
        txtSeconds.stringValue = String(describing: secondsStepper.doubleValue)
    }
    
    @IBAction func percentageStepperAction(_ sender: Any) {
        txtPercentage.stringValue = String(describing: percentageStepper.doubleValue)
    }
    
    @IBAction func okAction(_ sender: Any) {
        
        var jumpToTime: Double = 0
        
        if btnHMS.isOn() {
            
            // HH : MM : SS
            jumpToTime = timePicker.interval
            
        } else if btnSeconds.isOn() {
            
            // Seconds
            jumpToTime = secondsStepper.doubleValue
            
        } else {
            
            // Percentage
            // NOTE - secondsStepper.maxValue = track duration
            jumpToTime = percentageStepper.doubleValue * secondsStepper.maxValue / 100
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
