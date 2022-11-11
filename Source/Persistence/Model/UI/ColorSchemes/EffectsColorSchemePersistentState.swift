//
//  EffectsColorSchemePersistentState.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for the effects component of a single color scheme.
///
/// - SeeAlso: `EffectsColorScheme`
///
struct EffectsColorSchemePersistentState: Codable {
    
    let functionCaptionTextColor: ColorPersistentState?
    let functionValueTextColor: ColorPersistentState?
    
    let sliderBackgroundColor: ColorPersistentState?
    let sliderBackgroundGradientType: ColorSchemeGradientType?
    let sliderBackgroundGradientAmount: Int?
    
    let sliderForegroundGradientType: ColorSchemeGradientType?
    let sliderForegroundGradientAmount: Int?
    
    let sliderKnobColor: ColorPersistentState?
    let sliderKnobColorSameAsForeground: Bool?
    
    let sliderTickColor: ColorPersistentState?
    
    let activeUnitStateColor: ColorPersistentState?
    let bypassedUnitStateColor: ColorPersistentState?
    let suppressedUnitStateColor: ColorPersistentState?
    
    init(_ scheme: EffectsColorScheme) {
     
        self.functionCaptionTextColor = ColorPersistentState(color: scheme.functionCaptionTextColor)
        self.functionValueTextColor = ColorPersistentState(color: scheme.functionValueTextColor)
        
        self.sliderBackgroundColor = ColorPersistentState(color: scheme.sliderBackgroundColor)
        self.sliderBackgroundGradientType = scheme.sliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = scheme.sliderBackgroundGradientAmount
        
        self.sliderForegroundGradientType = scheme.sliderForegroundGradientType
        self.sliderForegroundGradientAmount = scheme.sliderForegroundGradientAmount
        
        self.sliderKnobColor = ColorPersistentState(color: scheme.sliderKnobColor)
        self.sliderKnobColorSameAsForeground = scheme.sliderKnobColorSameAsForeground
        
        self.sliderTickColor = ColorPersistentState(color: scheme.sliderTickColor)
        
        self.activeUnitStateColor = ColorPersistentState(color: scheme.activeUnitStateColor)
        self.bypassedUnitStateColor = ColorPersistentState(color: scheme.bypassedUnitStateColor)
        self.suppressedUnitStateColor = ColorPersistentState(color: scheme.suppressedUnitStateColor)
    }
}
