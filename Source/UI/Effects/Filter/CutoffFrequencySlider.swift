//
//  CutoffFrequencySlider.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class CutoffFrequencySlider: FXUnitSlider {
    
    var frequency: Float {
        return 20 * powf(10, (floatValue - 20) / 6660)
    }
    
    func setFrequency(_ freq: Float) {
        self.floatValue = 6660 * log10(freq/20) + 20
    }
}

class CutoffFrequencySliderCell: EffectsSliderCell {
    
    var filterType: FilterBandType = .lowPass
    
    override var backgroundGradient: NSGradient {
        
        if self.unitState == .active {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.sliderBackgroundGradient
                
            case .highPass:  return Colors.Effects.activeSliderGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.sliderBackgroundGradient
                
            }
            
        } else if self.unitState == .bypassed {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.sliderBackgroundGradient
                
            case .highPass:   return Colors.Effects.bypassedSliderGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.sliderBackgroundGradient
                
            }
            
        } else {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.sliderBackgroundGradient
                
            case .highPass:   return Colors.Effects.suppressedSliderGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.sliderBackgroundGradient
                
            }
        }
    }
    
    override var foregroundGradient: NSGradient {
        
        if self.unitState == .active {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.activeSliderGradient
                
            case .highPass:   return Colors.Effects.sliderBackgroundGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.sliderBackgroundGradient
                
            }
            
        } else if self.unitState == .bypassed {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.bypassedSliderGradient
                
            case .highPass:   return Colors.Effects.sliderBackgroundGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.sliderBackgroundGradient
                
            }
            
        } else {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.suppressedSliderGradient
                
            case .highPass:   return Colors.Effects.sliderBackgroundGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.sliderBackgroundGradient
                
            }
        }
    }
}

class FilterCutoffFrequencySliderCell: CutoffFrequencySliderCell {
}

class CutoffFrequencySliderPreviewCell: CutoffFrequencySliderCell {
    
    override var knobColor: NSColor {
        
        switch self.unitState {
            
        case .active:   return Colors.Effects.defaultActiveUnitColor
            
        case .bypassed: return Colors.Effects.defaultBypassedUnitColor
            
        case .suppressed:   return Colors.Effects.defaultSuppressedUnitColor
            
        }
    }
    
    override var backgroundGradient: NSGradient {
        
        if self.unitState == .active {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.defaultSliderBackgroundGradient
                
            case .highPass:  return Colors.Effects.defaultActiveSliderGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.defaultSliderBackgroundGradient
                
            }
            
        } else if self.unitState == .bypassed {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.defaultSliderBackgroundGradient
                
            case .highPass:   return Colors.Effects.defaultBypassedSliderGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.defaultSliderBackgroundGradient
                
            }
            
        } else {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.defaultSliderBackgroundGradient
                
            case .highPass:   return Colors.Effects.defaultSuppressedSliderGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.defaultSliderBackgroundGradient
                
            }
        }
    }
    
    override var foregroundGradient: NSGradient {
        
        if self.unitState == .active {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.defaultActiveSliderGradient
                
            case .highPass:   return Colors.Effects.defaultSliderBackgroundGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.defaultSliderBackgroundGradient
                
            }
            
        } else if self.unitState == .bypassed {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.defaultBypassedSliderGradient
                
            case .highPass:   return Colors.Effects.defaultSliderBackgroundGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.defaultSliderBackgroundGradient
                
            }
            
        } else {
            
            switch self.filterType {
                
            case .lowPass:   return Colors.Effects.defaultSuppressedSliderGradient
                
            case .highPass:   return Colors.Effects.defaultSliderBackgroundGradient.reversed()
                
            // IMPOSSIBLE
            default:    return Colors.Effects.defaultSliderBackgroundGradient
                
            }
        }
    }
}
