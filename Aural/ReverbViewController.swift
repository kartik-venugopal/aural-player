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
        unitStateFunction = reverbStateFunction
        presetsWrapper = PresetsWrapper<ReverbPreset, ReverbPresets>(reverbUnit.presets)
    }
    
    override func oneTimeSetup() {
        
        super.oneTimeSetup()
        reverbView.initialize(reverbStateFunction)
    }
    
    override func initSubscriptions() {
        
        super.initSubscriptions()
        SyncMessenger.subscribe(actionTypes: [.changeEffectsSliderBackgroundColor], subscriber: self)
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
    
    override func changeTextSize() {
        super.changeTextSize()
        reverbView.changeTextSize()
    }
    
    func changeSliderBackgroundColor() {
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
    
    override func changeFunctionButtonColor() {
        
        super.changeFunctionButtonColor()
        reverbView.redrawButtons()
    }
    
    override func changeFunctionButtonTextColor() {
        
        super.changeFunctionButtonTextColor()
        reverbView.redrawButtons()
    }
    
    // MARK: Message handling
    
    override func consumeMessage(_ message: ActionMessage) {
        
        super.consumeMessage(message)
        
        if message.actionType == .changeEffectsTextSize {
            
            changeTextSize()
            return
        }
        
        if let colorChangeMsg = message as? ColorSchemeActionMessage {
            
            switch colorChangeMsg.actionType {
                
            case .changeEffectsSliderBackgroundColor:
                
                changeSliderBackgroundColor()
                
            default: return
                
            }
            
            return
        }
    }
}
