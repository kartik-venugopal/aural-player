//
//  PlayerColorSchemePersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

/*
    Encapsulates persistent app state for a single PlayerColorScheme.
 */
class PlayerColorSchemePersistentState: PersistentStateProtocol {
    
    var trackInfoPrimaryTextColor: ColorPersistentState?
    var trackInfoSecondaryTextColor: ColorPersistentState?
    var trackInfoTertiaryTextColor: ColorPersistentState?
    var sliderValueTextColor: ColorPersistentState?
    
    var sliderBackgroundColor: ColorPersistentState?
    var sliderBackgroundGradientType: ColorSchemeGradientType?
    var sliderBackgroundGradientAmount: Int?
    
    var sliderForegroundColor: ColorPersistentState?
    var sliderForegroundGradientType: ColorSchemeGradientType?
    var sliderForegroundGradientAmount: Int?
    
    var sliderKnobColor: ColorPersistentState?
    var sliderKnobColorSameAsForeground: Bool?
    var sliderLoopSegmentColor: ColorPersistentState?
    
    init() {}
    
    init(_ scheme: PlayerColorScheme) {
        
        self.trackInfoPrimaryTextColor = ColorPersistentState.fromColor(scheme.trackInfoPrimaryTextColor)
        self.trackInfoSecondaryTextColor = ColorPersistentState.fromColor(scheme.trackInfoSecondaryTextColor)
        self.trackInfoTertiaryTextColor = ColorPersistentState.fromColor(scheme.trackInfoTertiaryTextColor)
        self.sliderValueTextColor = ColorPersistentState.fromColor(scheme.sliderValueTextColor)
        
        self.sliderBackgroundColor = ColorPersistentState.fromColor(scheme.sliderBackgroundColor)
        self.sliderBackgroundGradientType = scheme.sliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = scheme.sliderBackgroundGradientAmount
        
        self.sliderForegroundColor = ColorPersistentState.fromColor(scheme.sliderForegroundColor)
        self.sliderForegroundGradientType = scheme.sliderForegroundGradientType
        self.sliderForegroundGradientAmount = scheme.sliderForegroundGradientAmount
        
        self.sliderKnobColor = ColorPersistentState.fromColor(scheme.sliderKnobColor)
        self.sliderKnobColorSameAsForeground = scheme.sliderKnobColorSameAsForeground
        self.sliderLoopSegmentColor = ColorPersistentState.fromColor(scheme.sliderLoopSegmentColor)
    }
    
    required init?(_ map: NSDictionary) {
        
        self.trackInfoPrimaryTextColor = map.persistentColorValue(forKey: "trackInfoPrimaryTextColor")
        self.trackInfoSecondaryTextColor = map.persistentColorValue(forKey: "trackInfoSecondaryTextColor")
        self.trackInfoTertiaryTextColor = map.persistentColorValue(forKey: "trackInfoTertiaryTextColor")
        
        self.sliderValueTextColor = map.persistentColorValue(forKey: "sliderValueTextColor")
        
        self.sliderBackgroundColor = map.persistentColorValue(forKey: "sliderBackgroundColor")
        self.sliderBackgroundGradientType = map.enumValue(forKey: "sliderBackgroundGradientType",
                                                          ofType: ColorSchemeGradientType.self)
        self.sliderBackgroundGradientAmount = map.intValue(forKey: "sliderBackgroundGradientAmount")
        
        self.sliderForegroundColor = map.persistentColorValue(forKey: "sliderForegroundColor")
        self.sliderForegroundGradientType = map.enumValue(forKey: "sliderForegroundGradientType",
                                                          ofType: ColorSchemeGradientType.self)
        self.sliderForegroundGradientAmount = map.intValue(forKey: "sliderForegroundGradientAmount")
        
        self.sliderKnobColor = map.persistentColorValue(forKey: "sliderKnobColor")
        self.sliderKnobColorSameAsForeground = map["sliderKnobColorSameAsForeground", Bool.self]
        
        self.sliderLoopSegmentColor = map.persistentColorValue(forKey: "sliderLoopSegmentColor")
    }
}
