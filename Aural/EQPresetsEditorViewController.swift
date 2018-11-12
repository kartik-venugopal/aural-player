import Cocoa

class EQPresetsEditorViewController: FXPresetsEditorGenericViewController {
    
    @IBOutlet weak var eqView: EQView!
    
    override var nibName: String? {return "EQPresetsEditor"}
    
    var eqUnit: EQUnitDelegate {return graph.eqUnit}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .eq
        fxUnit = eqUnit
        presetsWrapper = PresetsWrapper<EQPreset, EQPresets>(eqUnit.presets)
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        eqView.initialize(nil, nil, {() -> EffectsUnitState in return .active})
        eqView.chooseType(.tenBand)
    }
    
    @IBAction func chooseEQTypeAction(_ sender: AnyObject) {
        
        let selection = getSelectedPresetNames()
        let preset = eqUnit.presets.presetByName(selection[0])!
        eqView.typeChanged(preset.bands, preset.globalGain)
    }
    
    override func renderPreview(_ presetName: String) {
        renderPreview(eqUnit.presets.presetByName(presetName)!)
    }
    
    private func renderPreview(_ preset: EQPreset) {
        eqView.applyPreset(preset)
    }
}
