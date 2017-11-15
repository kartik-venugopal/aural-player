import Cocoa

/*
    View controller for the Delay effects unit
 */
class DelayViewController: NSViewController {
    
    // Delay controls
    @IBOutlet weak var btnDelayBypass: EffectsUnitBypassButton!
    @IBOutlet weak var delayTimeSlider: NSSlider!
    @IBOutlet weak var delayAmountSlider: NSSlider!
    @IBOutlet weak var delayCutoffSlider: NSSlider!
    @IBOutlet weak var delayFeedbackSlider: NSSlider!
    
    @IBOutlet weak var lblDelayTimeValue: NSTextField!
    @IBOutlet weak var lblDelayAmountValue: NSTextField!
    @IBOutlet weak var lblDelayFeedbackValue: NSTextField!
    @IBOutlet weak var lblDelayLowPassCutoffValue: NSTextField!
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    convenience init() {
        self.init(nibName: "Delay", bundle: Bundle.main)!
    }
    
    override func viewDidLoad() {
        initControls(ObjectGraph.getUIAppState())
    }

    private func initControls(_ appState: UIAppState) {
        
        btnDelayBypass.setBypassState(appState.delayBypass)
        
        delayAmountSlider.floatValue = appState.delayAmount
        lblDelayAmountValue.stringValue = appState.formattedDelayAmount
        
        delayTimeSlider.doubleValue = appState.delayTime
        lblDelayTimeValue.stringValue = appState.formattedDelayTime
        
        delayFeedbackSlider.floatValue = appState.delayFeedback
        lblDelayFeedbackValue.stringValue = appState.formattedDelayFeedback
        
        delayCutoffSlider.floatValue = appState.delayLowPassCutoff
        lblDelayLowPassCutoffValue.stringValue = appState.formattedDelayLowPassCutoff
    }

    // Activates/deactivates the Delay effects unit
    @IBAction func delayBypassAction(_ sender: AnyObject) {
        btnDelayBypass.toggle()
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.delay, !graph.toggleDelayBypass()))
    }
    
    // Updates the Delay amount parameter
    @IBAction func delayAmountAction(_ sender: AnyObject) {
        lblDelayAmountValue.stringValue = graph.setDelayAmount(delayAmountSlider.floatValue)
    }
    
    // Updates the Delay time parameter
    @IBAction func delayTimeAction(_ sender: AnyObject) {
        lblDelayTimeValue.stringValue = graph.setDelayTime(delayTimeSlider.doubleValue)
    }
    
    // Updates the Delay feedback parameter
    @IBAction func delayFeedbackAction(_ sender: AnyObject) {
        lblDelayFeedbackValue.stringValue = graph.setDelayFeedback(delayFeedbackSlider.floatValue)
    }
    
    // Updates the Delay low pass cutoff parameter
    @IBAction func delayCutoffAction(_ sender: AnyObject) {
        lblDelayLowPassCutoffValue.stringValue = graph.setDelayLowPassCutoff(delayCutoffSlider.floatValue)
    }
}
