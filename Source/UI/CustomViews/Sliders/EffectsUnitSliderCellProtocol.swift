import Cocoa

protocol EffectsUnitSliderProtocol {
    
    var unitState: EffectsUnitState {get set}
    var stateFunction: (() -> EffectsUnitState)? {get set}
    
    func updateState()
}

protocol EffectsUnitSliderCellProtocol {
    
    var unitState: EffectsUnitState {get set}
}

class EffectsUnitSlider: NSSlider, EffectsUnitSliderProtocol {
    
    var unitState: EffectsUnitState = .bypassed
    var stateFunction: (() -> EffectsUnitState)?
    
    func updateState() {
        
        if let function = stateFunction {
            
            unitState = function()
            
            if var cell = self.cell as? EffectsUnitSliderCellProtocol {
                cell.unitState = unitState
            }
            
            redraw()
        }
    }
    
    func setUnitState(_ state: EffectsUnitState) {
        
        self.unitState = state
        
        if var cell = self.cell as? EffectsUnitSliderCellProtocol {
            cell.unitState = unitState
        }
        
        redraw()
    }
}
