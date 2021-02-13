import Cocoa

class JumpToTimeEditorWindowController: NSWindowController, NotificationSubscriber, ModalDialogDelegate {
    
    override var windowNibName: String? {return "JumpToTimeEditorDialog"}
    
    @IBOutlet weak var lblTrackName: NSTextField!
    @IBOutlet weak var lblTrackDuration: NSTextField!
    
    @IBOutlet weak var btnHMS: DialogCheckRadioButton!
    @IBOutlet weak var btnSeconds: DialogCheckRadioButton!
    @IBOutlet weak var btnPercentage: DialogCheckRadioButton!
    
    @IBOutlet weak var timePicker: IntervalPicker!
    
    @IBOutlet weak var secondsFormatter: DoubleValueFormatter!
    
    @IBOutlet weak var percentageFormatter: DoubleValueFormatter!
    
    @IBOutlet weak var txtSeconds: NSTextField!
    @IBOutlet weak var secondsStepper: NSStepper!
    
    @IBOutlet weak var txtPercentage: NSTextField!
    @IBOutlet weak var percentageStepper: NSStepper!
    
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
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
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:),
                                 filter: {msg in self.window?.isVisible ?? false},
                                 queue: .main)
        WindowManager.registerModalComponent(self)
    }
    
    var isModal: Bool {
        return self.window?.isVisible ?? false
    }
    
    func showDialog() -> ModalDialogResponse {
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if !self.isWindowLoaded {
            _ = self.window!
        }
        
        guard let playingTrack = playbackInfo.playingTrack else {
            
            // Should never happen
            cancelAction(self)
            return modalDialogResponse
        }
            
        resetFields(playingTrack)
        UIUtils.showDialog(self.window!)
        modalDialogResponse = .ok
        
        return modalDialogResponse
    }
    
    func resetFields(_ playingTrack: Track) {
    
        let roundedDuration = round(playingTrack.duration)
        let formattedDuration = ValueFormatter.formatSecondsToHMS(roundedDuration)
        let durationInt = Int(roundedDuration)
        
        lblTrackName.stringValue = String(format: "Track:   %@", playingTrack.conciseDisplayName)
        lblTrackDuration.stringValue = String(format: "Duration:   %@", formattedDuration)
        
        btnHMS.on()
        radioButtonAction(self)
        
        btnHMS.title = String(format: "Specify as hh : mm : ss (00:00:00 to %@)", formattedDuration)
        btnHMS.titleUpdated()
        
        btnSeconds.title = String(format: "Specify as seconds (0 to %d)", durationInt)
        btnSeconds.titleUpdated()
        
        // Reset to 00:00:00
        timePicker.maxInterval = roundedDuration
        timePicker.reset()
        
        secondsFormatter.maxValue = roundedDuration
        secondsStepper.maxValue = roundedDuration
        secondsStepper.doubleValue = 0
        secondsStepperAction(self)
        
        percentageStepper.doubleValue = 0
        percentageStepperAction(self)
    }
    
    @IBAction func radioButtonAction(_ sender: Any) {
        
        timePicker.enableIf(btnHMS.isOn)
        [txtSeconds, secondsStepper].forEach({$0?.enableIf(btnSeconds.isOn)})
        
        if txtSeconds.isEnabled {
            self.window?.makeFirstResponder(txtSeconds)
        }
        
        [txtPercentage, percentageStepper].forEach({$0?.enableIf(btnPercentage.isOn)})
        
        if txtPercentage.isEnabled {
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
        
        if btnHMS.isOn {
            
            // HH : MM : SS
            jumpToTime = timePicker.interval
            
        } else if btnSeconds.isOn {
            
            // Seconds
            jumpToTime = secondsStepper.doubleValue
            
        } else {
            
            // Percentage
            // NOTE - secondsStepper.maxValue = track duration
            jumpToTime = percentageStepper.doubleValue * secondsStepper.maxValue / 100
        }
        
        Messenger.publish(.player_jumpToTime, payload: jumpToTime)
        
        modalDialogResponse = .ok
        UIUtils.dismissDialog(self.window!)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        
        modalDialogResponse = .cancel
        UIUtils.dismissDialog(self.window!)
    }
    
    func trackTransitioned(_ msg: TrackTransitionNotification) {
        
        if msg.playbackStarted, let playingTrack = msg.endTrack {
            resetFields(playingTrack)
            
        } else {
            cancelAction(self)
        }
    }
}
