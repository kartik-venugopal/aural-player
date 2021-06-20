import Cocoa

class EffectsSliderPreviewCell: EffectsSliderCell {
    
    override var knobColor: NSColor {
        
        switch self.unitState {
            
        case .active:   return Colors.Effects.defaultActiveUnitColor
            
        case .bypassed: return Colors.Effects.defaultBypassedUnitColor
            
        case .suppressed:   return Colors.Effects.defaultSuppressedUnitColor
            
        }
    }
    
    override var tickColor: NSColor {Colors.Effects.defaultTickColor}
    
    override var backgroundGradient: NSGradient {
        return Colors.Effects.defaultSliderBackgroundGradient
    }
    
    override var foregroundGradient: NSGradient {
        
        switch self.unitState {
            
        case .active:   return Colors.Effects.defaultActiveSliderGradient
            
        case .bypassed: return Colors.Effects.defaultBypassedSliderGradient
            
        case .suppressed:   return Colors.Effects.defaultSuppressedSliderGradient
            
        }
    }
}
