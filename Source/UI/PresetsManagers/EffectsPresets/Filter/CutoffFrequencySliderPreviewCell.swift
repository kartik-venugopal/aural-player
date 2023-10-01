//
//  CutoffFrequencySliderPreviewCell.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

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
