import Cocoa

class ReverbPresetsEditorViewController: FXPresetsEditorGenericViewController {
    
    @IBOutlet weak var reverbView: ReverbView!
    
    override var nibName: String? {return "ReverbPresetsEditor"}
    
    var reverbUnit: ReverbUnitDelegateProtocol {return graph.reverbUnit}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .reverb
        fxUnit = reverbUnit
        presetsWrapper = PresetsWrapper<ReverbPreset, ReverbPresets>(reverbUnit.presets)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        reverbView.initialize({() -> EffectsUnitState in return .active})
    }
    
    override func renderPreview(_ presetName: String) {
        renderPreview(reverbUnit.presets.presetByName(presetName)!)
    }
    
    private func renderPreview(_ preset: ReverbPreset) {
        reverbView.applyPreset(preset)
    }
}
