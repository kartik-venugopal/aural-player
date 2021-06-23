import Cocoa

class EQPresetsEditorViewController: FXPresetsEditorGenericViewController {
    
    @IBOutlet weak var eqView: EQView!
    
    override var nibName: String? {"EQPresetsEditor"}
    
    var eqUnit: EQUnitDelegateProtocol {graph.eqUnit}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .eq
        fxUnit = eqUnit
        presetsWrapper = PresetsWrapper<EQPreset, EQPresets>(eqUnit.presets)
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        eqView.initialize(nil, nil, {() -> EffectsUnitState in .active})
        eqView.chooseType(.tenBand)
    }
    
    @IBAction func chooseEQTypeAction(_ sender: AnyObject) {
        
        if let preset = firstSelectedPreset as? EQPreset {
            eqView.typeChanged(preset.bands, preset.globalGain)
        }
    }
    
    override func renderPreview(_ presetName: String) {
        
        if let preset = eqUnit.presets.preset(named: presetName) {
            renderPreview(preset)
        }
    }
    
    private func renderPreview(_ preset: EQPreset) {
        eqView.applyPreset(preset)
    }
}
