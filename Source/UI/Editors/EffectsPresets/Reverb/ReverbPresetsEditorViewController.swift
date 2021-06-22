import Cocoa

class ReverbPresetsEditorViewController: FXPresetsEditorGenericViewController {
    
    @IBOutlet weak var reverbView: ReverbView!
    
    override var nibName: String? {"ReverbPresetsEditor"}
    
    var reverbUnit: ReverbUnitDelegateProtocol {graph.reverbUnit}
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .reverb
        fxUnit = reverbUnit
        presetsWrapper = PresetsWrapper<ReverbPreset, ReverbPresets>(reverbUnit.presets)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        reverbView.initialize({() -> EffectsUnitState in .active})
    }
    
    override func renderPreview(_ presetName: String) {
        
        if let preset = reverbUnit.presets.preset(named: presetName) {
            renderPreview(preset)
        }
    }
    
    private func renderPreview(_ preset: ReverbPreset) {
        reverbView.applyPreset(preset)
    }
}
