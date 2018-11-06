import Cocoa

class CutoffFrequencySlider: NSSlider {
    
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
        
        switch self.filterType {
            
        case .lowPass:   return Colors.bandStopGradient
            
        case .highPass:   return Colors.activeSliderBarColoredGradient
            
        // IMPOSSIBLE
        default:    return Colors.neutralSliderBarColoredGradient
            
        }
    }
    
    override var barColoredGradient: NSGradient {
        
        switch self.filterType {
            
        case .lowPass:   return Colors.activeSliderBarColoredGradient
            
        case .highPass:   return Colors.bandStopGradient
            
            // IMPOSSIBLE
        default:    return Colors.neutralSliderBarColoredGradient
            
        }
    }
}
