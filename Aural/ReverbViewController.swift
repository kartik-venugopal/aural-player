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
    
    override func changeColorScheme() {
        
        super.changeColorScheme()
        reverbView.changeColorScheme()
    }
}
