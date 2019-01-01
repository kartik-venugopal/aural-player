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
                
            case .lowPass:   return Colors.bandStopGradient
                
            case .highPass:   return Colors.activeSliderBarColoredGradient
                
            // IMPOSSIBLE
            default:    return Colors.neutralSliderBarColoredGradient
                
            }
        } else if self.unitState == .bypassed {
            
            return Colors.sliderBarPlainGradient
            
        } else {
            
            return Colors.sliderBarPlainGradient
        }
    }
    
    override var barColoredGradient: NSGradient {
        
        if self.unitState == .active {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.activeSliderBarColoredGradient
                
            case .highPass:   return Colors.bandStopGradient
                
            // IMPOSSIBLE
            default:    return Colors.neutralSliderBarColoredGradient
                
            }
        } else if self.unitState == .bypassed {
            
            return Colors.neutralSliderBarColoredGradient
            
        } else {
            
            return Colors.suppressedSliderBarColoredGradient
        }
    }
}
