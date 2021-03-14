import Cocoa

/*
    View controller for the EQ (Equalizer) effects unit
 */
class EQViewController: FXUnitViewController {
    
    @IBOutlet weak var eqView: EQView!
    
    private var eqUnit: EQUnitDelegateProtocol = ObjectGraph.audioGraphDelegate.eqUnit
    
    override var nibName: String? {return "EQ"}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        self.unitType = .eq
        self.fxUnit = graph.eqUnit
        self.unitStateFunction = eqStateFunction
        self.presetsWrapper = PresetsWrapper<EQPreset, EQPresets>(eqUnit.presets)
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        eqView.initialize(#selector(self.eqSliderAction(_:)), self, eqStateFunction)
    }
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        SyncMessenger.subscribe(actionTypes: [.increaseBass, .decreaseBass, .increaseMids, .decreaseMids, .increaseTreble, .decreaseTreble], subscriber: self)
    }
    
    override func initControls() {
        
        super.initControls()
        eqView.setState(eqUnit.type, eqUnit.bands, eqUnit.globalGain, eqUnit.sync)
    }
    
    @IBAction func chooseEQTypeAction(_ sender: AnyObject) {
        
        eqUnit.type = eqView.type
        eqView.typeChanged(eqUnit.bands, eqUnit.globalGain)
    }
    
    @IBAction func eqSyncAction(_ sender: AnyObject) {
        eqUnit.sync = eqView.sync
    }
    
    override func stateChanged() {
        
        super.stateChanged()
        eqView.stateChanged()
    }
    
    @IBAction func eqGlobalGainAction(_ sender: EffectsUnitSlider) {
        eqUnit.globalGain = sender.floatValue
    }
    
    // Updates the gain value of a single frequency band (specified by the slider parameter) of the Equalizer
    @IBAction func eqSliderAction(_ sender: EffectsUnitSlider) {
        eqUnit.setBand(sender.tag, gain: sender.floatValue)
    }
    
    // Provides a "bass boost". Increases each of the EQ bass bands by a certain preset increment.
    private func increaseBass() {
        bandsUpdated(eqUnit.increaseBass())
    }
    
    // Decreases each of the EQ bass bands by a certain preset decrement
    private func decreaseBass() {
        bandsUpdated(eqUnit.decreaseBass())
    }
    
    // Increases each of the EQ mid-frequency bands by a certain preset increment
    private func increaseMids() {
        bandsUpdated(eqUnit.increaseMids())
    }
    
    // Decreases each of the EQ mid-frequency bands by a certain preset decrement
    private func decreaseMids() {
        bandsUpdated(eqUnit.decreaseMids())
    }
    
    // Decreases each of the EQ treble bands by a certain preset increment
    private func increaseTreble() {
        bandsUpdated(eqUnit.increaseTreble())
    }
    
    // Decreases each of the EQ treble bands by a certain preset decrement
    private func decreaseTreble() {
        bandsUpdated(eqUnit.decreaseTreble())
    }
    
    private func bandsUpdated(_ bands: [Float]) {
        
        stateChanged()
        eqView.bandsUpdated(bands, eqUnit.globalGain)
        
        SyncMessenger.publishNotification(EffectsUnitStateChangedNotification.instance)
        showThisTab()
    }
    
    override func changeTextSize() {

        super.changeTextSize()
        
        // Resize selector button and sync button text
        eqView.changeTextSize()
    }
    
    override func changeColorScheme() {
        
        super.changeColorScheme()
        eqView.changeColorScheme()
    }
    
    // MARK: Message handling
    
    override func consumeMessage(_ message: ActionMessage) {
        
        super.consumeMessage(message)
        
        if let message = message as? AudioGraphActionMessage {
        
            switch message.actionType {
                
            case .increaseBass: increaseBass()
                
            case .decreaseBass: decreaseBass()
                
            case .increaseMids: increaseMids()
                
            case .decreaseMids: decreaseMids()
                
            case .increaseTreble: increaseTreble()
                
            case .decreaseTreble: decreaseTreble()
                
            default: return
                
            }
        }
    }
}
