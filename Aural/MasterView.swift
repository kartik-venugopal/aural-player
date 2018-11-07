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
        
        btnEQBypass.setUnitState(preset.eq.state)
        btnPitchBypass.setUnitState(preset.pitch.state)
        btnTimeBypass.setUnitState(preset.time.state)
        btnReverbBypass.setUnitState(preset.reverb.state)
        btnDelayBypass.setUnitState(preset.delay.state)
        btnFilterBypass.setUnitState(preset.filter.state)
    }
}
