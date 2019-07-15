import Cocoa

class MasterView: NSView {
    
    @IBOutlet weak var btnEQBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnPitchBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnTimeBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnReverbBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnDelayBypass: EffectsUnitTriStateBypassButton!
    @IBOutlet weak var btnFilterBypass: EffectsUnitTriStateBypassButton!
    
    private var buttons: [EffectsUnitTriStateBypassButton] = []
    
    override func awakeFromNib() {
        buttons = [btnEQBypass, btnPitchBypass, btnTimeBypass, btnReverbBypass, btnDelayBypass, btnFilterBypass]
    }
    
    func initialize(_ eqStateFunction: @escaping EffectsUnitStateFunction, _ pitchStateFunction: @escaping EffectsUnitStateFunction, _ timeStateFunction: @escaping EffectsUnitStateFunction, _ reverbStateFunction: @escaping EffectsUnitStateFunction, _ delayStateFunction: @escaping EffectsUnitStateFunction, _ filterStateFunction: @escaping EffectsUnitStateFunction) {
        
        btnEQBypass.stateFunction = eqStateFunction
        btnPitchBypass.stateFunction = pitchStateFunction
        btnTimeBypass.stateFunction = timeStateFunction
        btnReverbBypass.stateFunction = reverbStateFunction
        btnDelayBypass.stateFunction = delayStateFunction
        btnFilterBypass.stateFunction = filterStateFunction
        
        buttons.forEach({$0.updateState()})
    }
    
    func stateChanged() {
        buttons.forEach({$0.updateState()})
    }
    
    func applyPreset(_ preset: MasterPreset) {
        
        btnEQBypass.onIf(preset.eq.state == .active)
        btnPitchBypass.onIf(preset.pitch.state == .active)
        btnTimeBypass.onIf(preset.time.state == .active)
        btnReverbBypass.onIf(preset.reverb.state == .active)
        btnDelayBypass.onIf(preset.delay.state == .active)
        btnFilterBypass.onIf(preset.filter.state == .active)
    }
}
