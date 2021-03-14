import Foundation

class ReverbUnitDelegate: FXUnitDelegate<ReverbUnit>, ReverbUnitDelegateProtocol {
    
    var presets: ReverbPresets {return unit.presets}
    
    var space: ReverbSpaces {
        
        get {return unit.space}
        set(newValue) {unit.space = newValue}
    }
    
    var amount: Float {
        
        get {return unit.amount}
        set(newValue) {unit.amount = newValue}
    }
    
    var formattedAmount: String {
        return ValueFormatter.formatReverbAmount(amount)
    }
}
