import Cocoa

class PitchPresetsEditorViewController: FXPresetsEditorGenericViewController {
    
    @IBOutlet weak var pitchView: PitchView!
    
    override var nibName: String? {"PitchPresetsEditor"}
    
    var pitchUnit: PitchUnitDelegateProtocol = ObjectGraph.audioGraphDelegate.pitchUnit
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .pitch
        fxUnit = pitchUnit
        presetsWrapper = PresetsWrapper<PitchPreset, PitchPresets>(pitchUnit.presets)
    }
    
    override func viewDidLoad() {

        super.viewDidLoad()
        pitchView.initialize({() -> EffectsUnitState in .active})
    }
    
    override func renderPreview(_ presetName: String) {
        
        if let preset = pitchUnit.presets.presetByName(presetName) {
            renderPreview(preset)
        }
    }
   
    private func renderPreview(_ preset: PitchPreset) {
        pitchView.applyPreset(preset)
    }
}
