import Cocoa

class FilterBandSlider: RangeSlider {
    
    var filterType: FilterBandType = .bandStop {
        
        didSet {
            redraw()
        }
    }
    
    override var barFillColor: NSColor {
        
        switch unitState {
            
        case .active:   return filterType == .bandPass ? Colors.Effects.activeUnitStateColor : Colors.Effects.bypassedUnitStateColor
            
        case .bypassed: return Colors.Effects.bypassedUnitStateColor
            
        case .suppressed:   return Colors.Effects.suppressedUnitStateColor
            
        }
    }
    
    override var knobColor: NSColor {
        return ColorSchemes.systemScheme.effects.sliderKnobColorSameAsForeground ? barFillColor : ColorSchemes.systemScheme.effects.sliderKnobColor
    }
    
    override var barBackgroundColor: NSColor {
        return Colors.Effects.sliderBackgroundColor
    }
    
    var startFrequency: Float {
        return Float(20 * pow(10, (start - 20) / 6660))
    }
    
    var endFrequency: Float {
        return Float(20 * pow(10, (end - 20) / 6660))
    }
    
    func setFrequencyRange(_ min: Float, _ max: Float) {
        
        let temp = shouldTriggerHandler
        shouldTriggerHandler = false
        
        start = Double(6660 * log10(min/20) + 20)
        end = Double(6660 * log10(max/20) + 20)
        
        shouldTriggerHandler = temp
    }
}
