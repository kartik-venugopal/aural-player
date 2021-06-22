import Cocoa

class DelayPresetsEditorViewController: FXPresetsEditorGenericViewController {
    
    @IBOutlet weak var delayView: DelayView!
    
    override var nibName: String? {"DelayPresetsEditor"}
    
    var delayUnit: DelayUnitDelegateProtocol = ObjectGraph.audioGraphDelegate.delayUnit
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .delay
        fxUnit = delayUnit
        presetsWrapper = PresetsWrapper<DelayPreset, DelayPresets>(delayUnit.presets)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        delayView.initialize({() -> EffectsUnitState in .active})
    }
    
    override func renderPreview(_ presetName: String) {
        
        if let preset = delayUnit.presets.preset(named: presetName) {
            renderPreview(preset)
        }
    }
    
    private func renderPreview(_ preset: DelayPreset) {
        delayView.applyPreset(preset)
    }
}
