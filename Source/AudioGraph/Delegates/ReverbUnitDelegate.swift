import Foundation

class ReverbUnitDelegate: FXUnitDelegate<ReverbUnit>, ReverbUnitDelegateProtocol {
    
    var presets: ReverbPresets {return unit.presets}
    
    var space: ReverbSpaces {
        
        get {unit.space}
        set {unit.space = newValue}
    }
    
    var amount: Float {
        
        get {unit.amount}
        set {unit.amount = newValue}
    }
    
    var formattedAmount: String {
        return ValueFormatter.formatReverbAmount(amount)
    }
}
