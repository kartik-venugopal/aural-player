import Cocoa

class EffectsUnitView: NSView {
    
    @IBOutlet weak var btnBypass: EffectsUnitTriStateBypassButton!
    
    func initialize(_ stateFunction: @escaping EffectsUnitStateFunction) {
        
        btnBypass.stateFunction = stateFunction
        stateChanged()
    }
    
    func stateChanged() {
        btnBypass.updateState()
    }
}
