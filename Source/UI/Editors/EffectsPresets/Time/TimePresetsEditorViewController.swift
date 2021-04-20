import Cocoa

class TimePresetsEditorViewController: FXPresetsEditorGenericViewController {
    
    @IBOutlet weak var timeView: TimeView!
    
    override var nibName: String? {"TimePresetsEditor"}
    
    var timeUnit: TimeUnitDelegateProtocol = ObjectGraph.audioGraphDelegate.timeUnit
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        unitType = .time
        fxUnit = timeUnit
        presetsWrapper = PresetsWrapper<TimePreset, TimePresets>(timeUnit.presets)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        timeView.initialize({() -> EffectsUnitState in .active})
    }
    
    override func renderPreview(_ presetName: String) {

        if let preset = timeUnit.presets.presetByName(presetName) {
            renderPreview(preset)
        }
    }
    
    private func renderPreview(_ preset: TimePreset) {
        timeView.applyPreset(preset)
    }
}
