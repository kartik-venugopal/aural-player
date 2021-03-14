import Foundation

class DelayUnitDelegate: FXUnitDelegate<DelayUnit>, DelayUnitDelegateProtocol {
    
    var presets: DelayPresets {return unit.presets}
    
    var amount: Float {
        
        get {return unit.amount}
        set(newValue) {unit.amount = newValue}
    }
    
    var formattedAmount: String {return ValueFormatter.formatDelayAmount(amount)}
    
    var time: Double {
        
        get {return unit.time}
        set(newValue) {unit.time = newValue}
    }
    
    var formattedTime: String {return ValueFormatter.formatDelayTime(time)}
    
    var feedback: Float {
        
        get {return unit.feedback}
        set(newValue) {unit.feedback = newValue}
    }
    
    var formattedFeedback: String {return ValueFormatter.formatDelayFeedback(feedback)}
    
    var lowPassCutoff: Float {
        
        get {return unit.lowPassCutoff}
        set(newValue) {unit.lowPassCutoff = newValue}
    }
    
    var formattedLowPassCutoff: String {return ValueFormatter.formatDelayLowPassCutoff(lowPassCutoff)}
}

