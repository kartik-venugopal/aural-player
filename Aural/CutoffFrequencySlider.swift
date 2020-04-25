import Cocoa

class CutoffFrequencySlider: EffectsUnitSlider {
    
    var frequency: Float {
        return 20 * powf(10, (floatValue - 20) / 6660)
    }
    
    func setFrequency(_ freq: Float) {
        self.floatValue = 6660 * log10(freq/20) + 20
    }
}

class CutoffFrequencySliderCell: EffectsTickedSliderCell {
    
    var filterType: FilterBandType = .lowPass
    
    override var barPlainGradient: NSGradient {
        
        if self.unitState == .active {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.sliderBackgroundGradient
                
            case .highPass:  return Colors.Effects.activeSliderGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.neutralSliderColoredGradient
                
            }
            
        } else if self.unitState == .bypassed {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.sliderBackgroundGradient
                
            case .highPass:   return Colors.Effects.bypassedSliderGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.neutralSliderColoredGradient
                
            }
            
        } else {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.sliderBackgroundGradient
                
            case .highPass:   return Colors.Effects.suppressedSliderGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.neutralSliderColoredGradient
                
            }
        }
    }
    
    override var barColoredGradient: NSGradient {
        
        if self.unitState == .active {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.activeSliderGradient
                
            case .highPass:   return Colors.Effects.sliderBackgroundGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.neutralSliderColoredGradient
                
            }
            
        } else if self.unitState == .bypassed {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.bypassedSliderGradient
                
            case .highPass:   return Colors.Effects.sliderBackgroundGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.neutralSliderColoredGradient
                
            }
            
        } else {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.suppressedSliderGradient
                
            case .highPass:   return Colors.Effects.sliderBackgroundGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.neutralSliderColoredGradient
                
            }
        }
    }
}
