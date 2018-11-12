import Cocoa

/*
    View controller for the Pitch effects unit
 */
class PitchViewController: FXUnitViewController {
    
    @IBOutlet weak var pitchView: PitchView!
    @IBOutlet weak var box: NSBox!
    
    override var nibName: String? {return "Pitch"}
    
    var pitchUnit: PitchUnitDelegate {return graph.pitchUnit}
 
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        // TODO: Could some of this move to AudioGraphDelegate ??? e.g. graph.getUnit(self.unitType) OR graph.getStateFunction(self.unitTyp
        unitType = .pitch
        fxUnit = pitchUnit
        unitStateFunction = pitchStateFunction
        presetsWrapper = PresetsWrapper<PitchPreset, PitchPresets>(pitchUnit.presets)
    }
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        SyncMessenger.subscribe(actionTypes: [.increasePitch, .decreasePitch, .setPitch], subscriber: self)
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
    
    // Sets the pitch to a specific value
    private func setPitch(_ pitch: Float) {
        
        pitchUnit.pitch = pitch
        pitchUnit.ensureActive()
        
        pitchView.setPitch(pitch, pitchUnit.formattedPitch)
        
        btnBypass.updateState()
        pitchView.stateChanged()
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
        
        // Show the Pitch tab
        showThisTab()
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
        showThisTab()
    }
    
    // MARK: Message handling
    
    override func consumeNotification(_ notification: NotificationMessage) {
        
        super.consumeNotification(notification)
        
        if notification is EffectsUnitStateChangedNotification {
            pitchView.stateChanged()
        }
    }
    
    override func consumeMessage(_ message: ActionMessage) {
        
        super.consumeMessage(message)
        
        if let message = message as? AudioGraphActionMessage {
        
            switch message.actionType {
                
            case .increasePitch: increasePitch()
                
            case .decreasePitch: decreasePitch()
                
            case .setPitch: setPitch(message.value!)
                
            default: return
                
            }
        }
    }
}
