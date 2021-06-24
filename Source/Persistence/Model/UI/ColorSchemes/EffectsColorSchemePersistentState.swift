//
//  EffectsColorSchemePersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

/*
    Encapsulates persistent app state for a single EffectsColorScheme.
 */
class EffectsColorSchemePersistentState: PersistentStateProtocol {
    
    var functionCaptionTextColor: ColorPersistentState?
    var functionValueTextColor: ColorPersistentState?
    
    var sliderBackgroundColor: ColorPersistentState?
    var sliderBackgroundGradientType: ColorSchemeGradientType?
    var sliderBackgroundGradientAmount: Int?
    
    var sliderForegroundGradientType: ColorSchemeGradientType?
    var sliderForegroundGradientAmount: Int?
    
    var sliderKnobColor: ColorPersistentState?
    var sliderKnobColorSameAsForeground: Bool?
    
    var sliderTickColor: ColorPersistentState?
    
    var activeUnitStateColor: ColorPersistentState?
    var bypassedUnitStateColor: ColorPersistentState?
    var suppressedUnitStateColor: ColorPersistentState?
    
    init() {}
    
    init(_ scheme: EffectsColorScheme) {
     
        self.functionCaptionTextColor = ColorPersistentState.fromColor(scheme.functionCaptionTextColor)
        self.functionValueTextColor = ColorPersistentState.fromColor(scheme.functionValueTextColor)
        
        self.sliderBackgroundColor = ColorPersistentState.fromColor(scheme.sliderBackgroundColor)
        self.sliderBackgroundGradientType = scheme.sliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = scheme.sliderBackgroundGradientAmount
        
        self.sliderForegroundGradientType = scheme.sliderForegroundGradientType
        self.sliderForegroundGradientAmount = scheme.sliderForegroundGradientAmount
        
        self.sliderKnobColor = ColorPersistentState.fromColor(scheme.sliderKnobColor)
        self.sliderKnobColorSameAsForeground = scheme.sliderKnobColorSameAsForeground
        
        self.sliderTickColor = ColorPersistentState.fromColor(scheme.sliderTickColor)
        
        self.activeUnitStateColor = ColorPersistentState.fromColor(scheme.activeUnitStateColor)
        self.bypassedUnitStateColor = ColorPersistentState.fromColor(scheme.bypassedUnitStateColor)
        self.suppressedUnitStateColor = ColorPersistentState.fromColor(scheme.suppressedUnitStateColor)
    }
    
    required init?(_ map: NSDictionary) {
        
        self.functionCaptionTextColor = map.persistentColorValue(forKey: "functionCaptionTextColor")
        self.functionValueTextColor = map.persistentColorValue(forKey: "functionValueTextColor")
        
        self.sliderBackgroundColor = map.persistentColorValue(forKey: "sliderBackgroundColor")
        
        self.sliderBackgroundGradientType = map.enumValue(forKey: "sliderBackgroundGradientType",
                                                          ofType: ColorSchemeGradientType.self)
        
        self.sliderBackgroundGradientAmount = map["sliderBackgroundGradientAmount", Int.self]
        
        self.sliderForegroundGradientType = map.enumValue(forKey: "sliderForegroundGradientType",
                                                          ofType: ColorSchemeGradientType.self)
        
        self.sliderForegroundGradientAmount = map["sliderForegroundGradientAmount", Int.self]
        
        self.sliderKnobColor = map.persistentColorValue(forKey: "sliderKnobColor")
        self.sliderKnobColorSameAsForeground = map["sliderKnobColorSameAsForeground", Bool.self]
        self.sliderTickColor = map.persistentColorValue(forKey: "sliderTickColor")
        
        self.activeUnitStateColor = map.persistentColorValue(forKey: "activeUnitStateColor")
        self.bypassedUnitStateColor = map.persistentColorValue(forKey: "bypassedUnitStateColor")
        self.suppressedUnitStateColor = map.persistentColorValue(forKey: "suppressedUnitStateColor")
    }
}
