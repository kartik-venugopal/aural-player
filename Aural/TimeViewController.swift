import Cocoa

class TimeViewController: NSViewController, ActionMessageSubscriber {
    
    // Time controls
    @IBOutlet weak var btnTimeBypass: NSButton!
    @IBOutlet weak var timeSlider: NSSlider!
    @IBOutlet weak var timeOverlapSlider: NSSlider!
    @IBOutlet weak var lblTimeStretchRateValue: NSTextField!
    @IBOutlet weak var lblTimeOverlapValue: NSTextField!
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    convenience init() {
        self.init(nibName: "Time", bundle: Bundle.main)!
    }
    
    override func viewDidLoad() {
        
        initTime(ObjectGraph.getUIAppState())
        
        SyncMessenger.subscribe(actionTypes: [.increaseRate, .decreaseRate, .setRate], subscriber: self)
    }
    
    private func initTime(_ appState: UIAppState) {
        
        btnTimeBypass.image = appState.timeBypass ? Images.imgSwitchOff : Images.imgSwitchOn
        
        timeSlider.floatValue = appState.timeStretchRate
        lblTimeStretchRateValue.stringValue = appState.formattedTimeStretchRate
        
        timeOverlapSlider.floatValue = appState.timeOverlap
        lblTimeOverlapValue.stringValue = appState.formattedTimeOverlap
    }
    
    // Activates/deactivates the Time stretch effects unit
    @IBAction func timeBypassAction(_ sender: AnyObject) {
        
        let newBypassState = graph.toggleTimeBypass()
        
        btnTimeBypass.image = newBypassState ? Images.imgSwitchOff : Images.imgSwitchOn
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.time, !newBypassState))
        
        let newRate = newBypassState ? 1 : timeSlider.floatValue
        let playbackRateChangedMsg = PlaybackRateChangedNotification(newRate)
        SyncMessenger.publishNotification(playbackRateChangedMsg)
    }
    
    // Updates the playback rate value
    @IBAction func timeStretchAction(_ sender: AnyObject) {
        
        lblTimeStretchRateValue.stringValue = graph.setTimeStretchRate(timeSlider.floatValue)
        
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
            SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.time, true))
        }
        
        lblTimeStretchRateValue.stringValue = graph.setTimeStretchRate(rate)
        timeSlider.floatValue = rate
        btnTimeBypass.image = Images.imgSwitchOn
        
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
        btnTimeBypass.image = Images.imgSwitchOn
        
        showTimeTab()
        
        SyncMessenger.publishNotification(PlaybackRateChangedNotification(rateInfo.rate))
    }
    
    // Updates the Overlap parameter of the Time stretch effects unit
    @IBAction func timeOverlapAction(_ sender: Any) {
        lblTimeOverlapValue.stringValue = graph.setTimeOverlap(timeOverlapSlider.floatValue)
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
