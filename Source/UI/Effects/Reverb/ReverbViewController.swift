import Cocoa

/*
    View controller for the Reverb effects unit
 */
class ReverbViewController: FXUnitViewController {
    
    @IBOutlet weak var reverbView: ReverbView!
    
    override var nibName: String? {return "Reverb"}
    
    var reverbUnit: ReverbUnitDelegateProtocol = ObjectGraph.audioGraphDelegate.reverbUnit
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .reverb
        fxUnit = graph.reverbUnit
        presetsWrapper = PresetsWrapper<ReverbPreset, ReverbPresets>(reverbUnit.presets)
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        reverbView.initialize(self.unitStateFunction)
    }
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        SyncMessenger.subscribe(actionTypes: [.changeTextButtonMenuColor, .changeButtonMenuTextColor], subscriber: self)
    }
    
    override func initControls() {
        
        super.initControls()
        reverbView.setState(reverbUnit.space.description, reverbUnit.amount, reverbUnit.formattedAmount)
    }

    override func stateChanged() {
        
        super.stateChanged()
        reverbView.stateChanged()
    }

    // Updates the Reverb preset
    @IBAction func reverbSpaceAction(_ sender: AnyObject) {
        reverbUnit.space = ReverbSpaces.fromDescription(reverbView.spaceString)
    }

    // Updates the Reverb amount parameter
    @IBAction func reverbAmountAction(_ sender: AnyObject) {
        
        reverbUnit.amount = reverbView.amount
        reverbView.setAmount(reverbUnit.amount, reverbUnit.formattedAmount)
    }
    
    override func changeTextSize(_ textSize: TextSize) {
        
        super.changeTextSize(textSize)
        reverbView.changeTextSize()
    }
    
    override func applyColorScheme(_ scheme: ColorScheme) {
        
        super.applyColorScheme(scheme)
        
        changeSliderColors()
        reverbView.redrawMenu()
    }
    
    override func changeSliderColors() {
        reverbView.redrawSliders()
    }
    
    override func changeActiveUnitStateColor(_ color: NSColor) {
        
        super.changeActiveUnitStateColor(color)
        
        if reverbUnit.isActive {
            reverbView.redrawSliders()
        }
    }
    
    override func changeBypassedUnitStateColor(_ color: NSColor) {
        
        super.changeBypassedUnitStateColor(color)
        
        if reverbUnit.state == .bypassed {
            reverbView.redrawSliders()
        }
    }
    
    override func changeSuppressedUnitStateColor(_ color: NSColor) {
        
        super.changeSuppressedUnitStateColor(color)
        
        if reverbUnit.state == .suppressed {
            reverbView.redrawSliders()
        }
    }
    
    func changeTextButtonMenuColor() {
        reverbView.redrawMenu()
    }
    
    func changeButtonMenuTextColor() {
        reverbView.redrawMenu()
    }
    
    // MARK: Message handling
    
    override func consumeMessage(_ message: ActionMessage) {
        
        super.consumeMessage(message)
        
        if let colorChangeMsg = message as? ColorSchemeComponentActionMessage {
            
            switch colorChangeMsg.actionType {
                
            case .changeTextButtonMenuColor:
                
                changeTextButtonMenuColor()
                
            case .changeButtonMenuTextColor:
                
                changeButtonMenuTextColor()
                
            default: return
                
            }
            
            return
        }
    }
}
