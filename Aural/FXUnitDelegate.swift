import Foundation

class FXUnitDelegate<T: FXUnit> {
    
    var unit: T
    
    init(_ unit: T) {
        self.unit = unit
    }
    
    var state: EffectsUnitState {
        return unit.state
    }
    
    func toggleState() -> EffectsUnitState {
        return unit.toggleState()
    }
}
