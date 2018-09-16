import Cocoa

/*
    View controller for the Time effects unit
 */
class TimeViewController: NSViewController, ActionMessageSubscriber {
    
    // Time controls
    @IBOutlet weak var btnTimeBypass: EffectsUnitBypassButton!
    @IBOutlet weak var btnShiftPitch: NSButton!
    @IBOutlet weak var timeSlider: NSSlider!
    @IBOutlet weak var timeOverlapSlider: NSSlider!
    
    @IBOutlet weak var lblTimeStretchRateValue: NSTextField!
    @IBOutlet weak var lblPitchShiftValue: NSTextField!
    @IBOutlet weak var lblTimeOverlapValue: NSTextField!
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    override var nibName: String? {return "Time"}
    
    override func viewDidLoad() {
        
        initControls(ObjectGraph.getUIAppState())
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(actionTypes: [.increaseRate, .decreaseRate, .setRate], subscriber: self)
    }
    
    private func initControls(_ appState: UIAppState) {
        
        btnTimeBypass.setBypassState(appState.timeBypass)
        btnShiftPitch.state = appState.timeShiftPitch ? 1 : 0
        updatePitchShift()
        
        timeSlider.floatValue = appState.timeStretchRate
        lblTimeStretchRateValue.stringValue = appState.formattedTimeStretchRate
        
        timeOverlapSlider.floatValue = appState.timeOverlap
        lblTimeOverlapValue.stringValue = appState.formattedTimeOverlap
    }
    
    // Activates/deactivates the Time stretch effects unit
    @IBAction func timeBypassAction(_ sender: AnyObject) {
        
        let newBypassState = graph.toggleTimeBypass()
        
        btnTimeBypass.toggle()
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.time, !newBypassState))
        
        let newRate = newBypassState ? 1 : timeSlider.floatValue
        let playbackRateChangedMsg = PlaybackRateChangedNotification(newRate)
        SyncMessenger.publishNotification(playbackRateChangedMsg)
    }
    
    // Toggles the "pitch shift" option of the Time stretch effects unit
    @IBAction func shiftPitchAction(_ sender: AnyObject) {
        _ = graph.toggleTimePitchShift()
        updatePitchShift()
    }
    
    // Updates the playback rate value
    @IBAction func timeStretchAction(_ sender: AnyObject) {
        
        lblTimeStretchRateValue.stringValue = graph.setTimeStretchRate(timeSlider.floatValue)
        updatePitchShift()
        
        // If the unit is active, publish a notification that the playback rate has changed. Other UI elements may need to be updated as a result.
        if (!graph.isTimeBypass()) {
            SyncMessenger.publishNotification(PlaybackRateChangedNotification(timeSlider.floatValue))
        }
    }
    
    private func showTimeTab() {
        SyncMessenger.publishActionMessage(EffectsViewActionMessage(.showEffectsUnitTab, .time))
    }
    
    // Sets the playback rate to a specific value
    private func setRate(_ rate: Float) {
        
        // Ensure unit is activated
        if graph.isTimeBypass() {
            _ = graph.toggleTimeBypass()
            btnTimeBypass.on()
            SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.time, true))
        }
        
        lblTimeStretchRateValue.stringValue = graph.setTimeStretchRate(rate)
        timeSlider.floatValue = rate
        updatePitchShift()
        
        showTimeTab()
        
        SyncMessenger.publishNotification(PlaybackRateChangedNotification(rate))
    }
    
    // Increases the playback rate by a certain preset increment
    private func increaseRate() {
        rateChange(graph.increaseRate())
    }
    
    // Decreases the playback rate by a certain preset decrement
    private func decreaseRate() {
        rateChange(graph.decreaseRate())
    }
    
    // Changes the playback rate to a specific value
    private func rateChange(_ rateInfo: (rate: Float, rateString: String)) {
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.time, true))
        
        timeSlider.floatValue = rateInfo.rate
        lblTimeStretchRateValue.stringValue = rateInfo.rateString
        updatePitchShift()
        btnTimeBypass.on()
        
        showTimeTab()
        
        SyncMessenger.publishNotification(PlaybackRateChangedNotification(rateInfo.rate))
    }
    
    // Updates the Overlap parameter of the Time stretch effects unit
    @IBAction func timeOverlapAction(_ sender: Any) {
        lblTimeOverlapValue.stringValue = graph.setTimeOverlap(timeOverlapSlider.floatValue)
    }
    
    // Updates the label that displays the pitch shift value
    private func updatePitchShift() {
        lblPitchShiftValue.stringValue = graph.getTimePitchShift()
    }
    
    func getID() -> String {
        return self.className
    }

    // MARK: Message handling
    
    func consumeMessage(_ message: ActionMessage) {
        
        let message = message as! AudioGraphActionMessage
        
        switch message.actionType {
            
        case .increaseRate: increaseRate()
            
        case .decreaseRate: decreaseRate()
            
        case .setRate: setRate(message.value!)
            
        default: return
            
        }
    }
}
