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
struct PlayerColorSchemePersistentState: Codable {
    
    let trackInfoPrimaryTextColor: ColorPersistentState?
    let trackInfoSecondaryTextColor: ColorPersistentState?
    let trackInfoTertiaryTextColor: ColorPersistentState?
    let sliderValueTextColor: ColorPersistentState?
    
    let sliderBackgroundColor: ColorPersistentState?
    let sliderBackgroundGradientType: ColorSchemeGradientType?
    let sliderBackgroundGradientAmount: Int?
    
    let sliderForegroundColor: ColorPersistentState?
    let sliderForegroundGradientType: ColorSchemeGradientType?
    let sliderForegroundGradientAmount: Int?
    
    let sliderKnobColor: ColorPersistentState?
    let sliderKnobColorSameAsForeground: Bool?
    let sliderLoopSegmentColor: ColorPersistentState?
    
    init(_ scheme: PlayerColorScheme) {
        
        self.trackInfoPrimaryTextColor = ColorPersistentState(color: scheme.trackInfoPrimaryTextColor)
        self.trackInfoSecondaryTextColor = ColorPersistentState(color: scheme.trackInfoSecondaryTextColor)
        self.trackInfoTertiaryTextColor = ColorPersistentState(color: scheme.trackInfoTertiaryTextColor)
        self.sliderValueTextColor = ColorPersistentState(color: scheme.sliderValueTextColor)
        
        self.sliderBackgroundColor = ColorPersistentState(color: scheme.sliderBackgroundColor)
        self.sliderBackgroundGradientType = scheme.sliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = scheme.sliderBackgroundGradientAmount
        
        self.sliderForegroundColor = ColorPersistentState(color: scheme.sliderForegroundColor)
        self.sliderForegroundGradientType = scheme.sliderForegroundGradientType
        self.sliderForegroundGradientAmount = scheme.sliderForegroundGradientAmount
        
        self.sliderKnobColor = ColorPersistentState(color: scheme.sliderKnobColor)
        self.sliderKnobColorSameAsForeground = scheme.sliderKnobColorSameAsForeground
        self.sliderLoopSegmentColor = ColorPersistentState(color: scheme.sliderLoopSegmentColor)
    }
}
