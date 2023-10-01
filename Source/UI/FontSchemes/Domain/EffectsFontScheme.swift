//
//  EffectsFontScheme.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class EffectsFontScheme {

    var unitCaptionFont: NSFont
    var unitFunctionFont: NSFont
    var masterUnitFunctionFont: NSFont
    var filterChartFont: NSFont
    var auRowTextYOffset: CGFloat
    
    init(_ persistentState: FontSchemePersistentState?) {
        
        self.unitCaptionFont = FontSchemePreset.standard.effectsUnitCaptionFont
        self.unitFunctionFont = FontSchemePreset.standard.effectsUnitFunctionFont
        self.masterUnitFunctionFont = FontSchemePreset.standard.effectsMasterUnitFunctionFont
        self.filterChartFont = FontSchemePreset.standard.effectsFilterChartFont
        self.auRowTextYOffset = FontSchemePreset.standard.effectsAURowTextYOffset
        
        guard let textFontName = persistentState?.textFontName, let headingFontName = persistentState?.headingFontName else {
            return
        }
        
        if let unitCaptionSize = persistentState?.effects?.unitCaptionSize, let unitCaptionFont = NSFont(name: headingFontName, size: unitCaptionSize) {
            self.unitCaptionFont = unitCaptionFont
        }
        
        if let unitFunctionSize = persistentState?.effects?.unitFunctionSize, let unitFunctionFont = NSFont(name: textFontName, size: unitFunctionSize) {
            self.unitFunctionFont = unitFunctionFont
        }
        
        if let masterUnitFunctionSize = persistentState?.effects?.masterUnitFunctionSize,
           let masterUnitFunctionFont = NSFont(name: headingFontName, size: masterUnitFunctionSize) {
            
            self.masterUnitFunctionFont = masterUnitFunctionFont
        }
        
        if let filterChartSize = persistentState?.effects?.filterChartSize, let filterChartFont = NSFont(name: textFontName, size: filterChartSize) {
            self.filterChartFont = filterChartFont
        }
        
        if let auRowTextYOffset = persistentState?.effects?.auRowTextYOffset {
            self.auRowTextYOffset = auRowTextYOffset
        }
    }
    
    init(preset: FontSchemePreset) {
        
        self.unitCaptionFont = preset.effectsUnitCaptionFont
        self.unitFunctionFont = preset.effectsUnitFunctionFont
        self.masterUnitFunctionFont = preset.effectsMasterUnitFunctionFont
        self.filterChartFont = preset.effectsFilterChartFont
        self.auRowTextYOffset = preset.effectsAURowTextYOffset
    }
    
    init(_ fontScheme: EffectsFontScheme) {
        
        self.unitCaptionFont = fontScheme.unitCaptionFont
        self.unitFunctionFont = fontScheme.unitFunctionFont
        self.masterUnitFunctionFont = fontScheme.masterUnitFunctionFont
        self.filterChartFont = fontScheme.filterChartFont
        self.auRowTextYOffset = fontScheme.auRowTextYOffset
    }
    
    func clone() -> EffectsFontScheme {
        return EffectsFontScheme(self)
    }
}
