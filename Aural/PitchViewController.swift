import Cocoa

/*
    View controller for the Pitch effects unit
 */
class PitchViewController: NSViewController, ActionMessageSubscriber {
    
    // Pitch controls
    @IBOutlet weak var btnPitchBypass: EffectsUnitBypassButton!
    @IBOutlet weak var pitchSlider: NSSlider!
    @IBOutlet weak var pitchOverlapSlider: NSSlider!
    @IBOutlet weak var lblPitchValue: NSTextField!
    @IBOutlet weak var lblPitchOverlapValue: NSTextField!
    
    // Delegate that alters the audio graph
    private let graph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    override var nibName: String? {return "Pitch"}
    
    override func viewDidLoad() {
        
        initControls(ObjectGraph.getUIAppState())
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(actionTypes: [.increasePitch, .decreasePitch, .setPitch], subscriber: self)
    }
    
    private func initControls(_ appState: UIAppState) {
        
        btnPitchBypass.setBypassState(appState.pitchBypass)
        
        pitchSlider.floatValue = appState.pitch
        lblPitchValue.stringValue = appState.formattedPitch
        
        pitchOverlapSlider.floatValue = appState.pitchOverlap
        lblPitchOverlapValue.stringValue = appState.formattedPitchOverlap
    }
    
    // Activates/deactivates the Pitch effects unit
    @IBAction func pitchBypassAction(_ sender: AnyObject) {
        btnPitchBypass.toggle()
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.pitch, !graph.togglePitchBypass()))
    }
    
    // Updates the pitch
    @IBAction func pitchAction(_ sender: AnyObject) {
        lblPitchValue.stringValue = graph.setPitch(pitchSlider.floatValue)
    }
    
    private func showPitchTab() {
        SyncMessenger.publishActionMessage(EffectsViewActionMessage(.showEffectsUnitTab, .pitch))
    }
    
    // Sets the pitch to a specific value
    private func setPitch(_ pitch: Float) {
        
        if graph.isPitchBypass() {
            _ = graph.togglePitchBypass()
            btnPitchBypass.on()
            SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.pitch, true))
        }
        
        lblPitchValue.stringValue = graph.setPitch(pitch)
        pitchSlider.floatValue = pitch
        
        // Show the Pitch tab
        showPitchTab()
    }
    
    // Updates the Overlap parameter of the Pitch shift effects unit
    @IBAction func pitchOverlapAction(_ sender: AnyObject) {
        lblPitchOverlapValue.stringValue = graph.setPitchOverlap(pitchOverlapSlider.floatValue)
    }
    
    // Increases the overall pitch by a certain preset increment
    private func increasePitch() {
        pitchChange(graph.increasePitch())
    }
    
    // Decreases the overall pitch by a certain preset decrement
    private func decreasePitch() {
        pitchChange(graph.decreasePitch())
    }
    
    // Changes the pitch to a specified value
    private func pitchChange(_ pitchInfo: (pitch: Float, pitchString: String)) {
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification(.pitch, true))
        
        pitchSlider.floatValue = pitchInfo.pitch
        lblPitchValue.stringValue = pitchInfo.pitchString
        btnPitchBypass.on()
        
        // Show the Pitch tab if the Effects panel is shown
        showPitchTab()
    }
    
    func getID() -> String {
        return self.className
    }
    
    // MARK: Message handling
    
    func consumeMessage(_ message: ActionMessage) {
        
        let message = message as! AudioGraphActionMessage
        
        switch message.actionType {
            
        case .increasePitch: increasePitch()
            
        case .decreasePitch: decreasePitch()
            
        case .setPitch: setPitch(message.value!)
            
        default: return
            
        }
    }
}
