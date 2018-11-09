import Cocoa

/*
    View controller for the Pitch effects unit
 */
class PitchViewController: FXUnitViewController, MessageSubscriber, ActionMessageSubscriber {
    
    @IBOutlet weak var pitchView: PitchView!
    @IBOutlet weak var box: NSBox!
    
    override var nibName: String? {return "Pitch"}
    
    var pitchUnit: PitchUnitDelegate {return graph.pitchUnit}
 
    override func awakeFromNib() {
        
        // TODO: Could some of this move to AudioGraphDelegate ??? e.g. graph.getUnit(self.unitType) OR graph.getStateFunction(self.unitTyp
        fxUnit = graph.pitchUnit
        unitStateFunction = pitchStateFunction
        presetsWrapper = PresetsWrapper<PitchPreset, PitchPresets>(pitchUnit.presets)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        initSubscriptions()
    }
    
    private func initSubscriptions() {
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(messageTypes: [.effectsUnitStateChangedNotification], subscriber: self)
        SyncMessenger.subscribe(actionTypes: [.increasePitch, .decreasePitch, .setPitch, .updateEffectsView], subscriber: self)
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        // TODO: Move this to generic view
        pitchView.initialize(unitStateFunction)
    }
    
    override func initControls() {
        
        super.initControls()
        
        pitchView.stateChanged()
        pitchView.setState(pitchUnit.pitch, pitchUnit.formattedPitch, pitchUnit.overlap, pitchUnit.formattedOverlap)
    }
    
    // Activates/deactivates the Pitch effects unit
    @IBAction override func bypassAction(_ sender: AnyObject) {
        super.bypassAction(sender)
        
        // TODO: Move to generic view
        pitchView.stateChanged()
    }
    
    // Updates the pitch
    @IBAction func pitchAction(_ sender: AnyObject) {
        
        pitchUnit.pitch = pitchView.pitch
        pitchView.setPitch(pitchUnit.pitch, pitchUnit.formattedPitch)
    }
    
    // TODO: Move to parent VC
    private func showPitchTab() {
        SyncMessenger.publishActionMessage(EffectsViewActionMessage(.showEffectsUnitTab, .pitch))
    }
    
    // Sets the pitch to a specific value
    private func setPitch(_ pitch: Float) {
        
        // TODO: Ensure unit active
        pitchUnit.pitch = pitch
        pitchView.setPitch(pitch, pitchUnit.formattedPitch)
        
        btnBypass.updateState()
        pitchView.stateChanged()
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
        
        // Show the Pitch tab
        showPitchTab()
    }
    
    // Updates the Overlap parameter of the Pitch shift effects unit
    @IBAction func pitchOverlapAction(_ sender: AnyObject) {

        pitchUnit.overlap = pitchView.overlap
        pitchView.setPitchOverlap(pitchUnit.overlap, pitchUnit.formattedOverlap)
    }
    
    // Increases the overall pitch by a certain preset increment
    private func increasePitch() {
        
        let newPitch = pitchUnit.increasePitch()
        pitchChange(newPitch.pitch, newPitch.pitchString)
    }
    
    // Decreases the overall pitch by a certain preset decrement
    private func decreasePitch() {
        
        let newPitch = pitchUnit.decreasePitch()
        pitchChange(newPitch.pitch, newPitch.pitchString)
    }
    
    // Changes the pitch to a specified value
    private func pitchChange(_ pitch: Float, _ pitchString: String) {
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
        
        pitchView.setPitch(pitch, pitchString)
        pitchView.stateChanged()
        
        // Show the Pitch tab if the Effects panel is shown
        showPitchTab()
    }
    
    // MARK: Message handling
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if notification is EffectsUnitStateChangedNotification {
            pitchView.stateChanged()
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if let message = message as? AudioGraphActionMessage {
        
            switch message.actionType {
                
            case .increasePitch: increasePitch()
                
            case .decreasePitch: decreasePitch()
                
            case .setPitch: setPitch(message.value!)
                
            default: return
                
            }
            
        } else if message.actionType == .updateEffectsView {
            
            let msg = message as! EffectsViewActionMessage
            if msg.effectsUnit == .master || msg.effectsUnit == .pitch {
                initControls()
            }
        }
    }
}
