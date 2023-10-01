//
//  PlayerColorScheme.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

/*
    Encapsulates color values that are applicable to the player UI, e.g. color of the track title.
 */
class PlayerColorScheme {
    
    var trackInfoPrimaryTextColor: NSColor
    var trackInfoSecondaryTextColor: NSColor
    var trackInfoTertiaryTextColor: NSColor
    var sliderValueTextColor: NSColor
    
    var sliderBackgroundColor: NSColor
    var sliderBackgroundGradientType: ColorSchemeGradientType
    var sliderBackgroundGradientAmount: Int
    
    var sliderForegroundColor: NSColor
    var sliderForegroundGradientType: ColorSchemeGradientType
    var sliderForegroundGradientAmount: Int
    
    var sliderKnobColor: NSColor
    var sliderKnobColorSameAsForeground: Bool
    var sliderLoopSegmentColor: NSColor
    
    init(_ persistentState: PlayerColorSchemePersistentState?) {
        
        self.trackInfoPrimaryTextColor = persistentState?.trackInfoPrimaryTextColor?.toColor() ?? ColorScheme.defaultScheme.player.trackInfoPrimaryTextColor
        
        self.trackInfoSecondaryTextColor = persistentState?.trackInfoSecondaryTextColor?.toColor() ?? ColorScheme.defaultScheme.player.trackInfoSecondaryTextColor
        
        self.trackInfoTertiaryTextColor = persistentState?.trackInfoTertiaryTextColor?.toColor() ?? ColorScheme.defaultScheme.player.trackInfoTertiaryTextColor
        
        self.sliderValueTextColor = persistentState?.sliderValueTextColor?.toColor() ?? ColorScheme.defaultScheme.player.sliderValueTextColor
        
        self.sliderBackgroundColor = persistentState?.sliderBackgroundColor?.toColor() ?? ColorScheme.defaultScheme.player.sliderBackgroundColor
        
        self.sliderBackgroundGradientType = persistentState?.sliderBackgroundGradientType ?? ColorScheme.defaultScheme.player.sliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = persistentState?.sliderBackgroundGradientAmount ?? ColorScheme.defaultScheme.player.sliderBackgroundGradientAmount
        
        self.sliderForegroundColor = persistentState?.sliderForegroundColor?.toColor() ?? ColorScheme.defaultScheme.player.sliderForegroundColor
        
        self.sliderForegroundGradientType = persistentState?.sliderForegroundGradientType ?? ColorScheme.defaultScheme.player.sliderForegroundGradientType
        self.sliderForegroundGradientAmount = persistentState?.sliderForegroundGradientAmount ?? ColorScheme.defaultScheme.player.sliderForegroundGradientAmount
        
        self.sliderKnobColor = persistentState?.sliderKnobColor?.toColor() ?? ColorScheme.defaultScheme.player.sliderKnobColor
        self.sliderKnobColorSameAsForeground = persistentState?.sliderKnobColorSameAsForeground ?? ColorScheme.defaultScheme.player.sliderKnobColorSameAsForeground
        
        self.sliderLoopSegmentColor = persistentState?.sliderLoopSegmentColor?.toColor() ?? ColorScheme.defaultScheme.player.sliderLoopSegmentColor
    }
    
    init(_ scheme: PlayerColorScheme) {
        
        self.trackInfoPrimaryTextColor = scheme.trackInfoPrimaryTextColor
        self.trackInfoSecondaryTextColor = scheme.trackInfoSecondaryTextColor
        self.trackInfoTertiaryTextColor = scheme.trackInfoTertiaryTextColor
        self.sliderValueTextColor = scheme.sliderValueTextColor
        
        self.sliderBackgroundColor = scheme.sliderBackgroundColor
        self.sliderBackgroundGradientType = scheme.sliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = scheme.sliderBackgroundGradientAmount
        
        self.sliderForegroundColor = scheme.sliderForegroundColor
        self.sliderForegroundGradientType = scheme.sliderForegroundGradientType
        self.sliderForegroundGradientAmount = scheme.sliderForegroundGradientAmount
        
        self.sliderKnobColor = scheme.sliderKnobColor
        self.sliderKnobColorSameAsForeground = scheme.sliderKnobColorSameAsForeground
        self.sliderLoopSegmentColor = scheme.sliderLoopSegmentColor
    }
    
    init(_ preset: ColorSchemePreset) {
        
        self.trackInfoPrimaryTextColor = preset.playerTrackInfoPrimaryTextColor
        self.trackInfoSecondaryTextColor = preset.playerTrackInfoSecondaryTextColor
        self.trackInfoTertiaryTextColor = preset.playerTrackInfoTertiaryTextColor
        self.sliderValueTextColor = preset.playerSliderValueTextColor
        
        self.sliderBackgroundColor = preset.playerSliderBackgroundColor
        self.sliderBackgroundGradientType = preset.playerSliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = preset.playerSliderBackgroundGradientAmount
        
        self.sliderForegroundColor = preset.playerSliderForegroundColor
        self.sliderForegroundGradientType = preset.playerSliderForegroundGradientType
        self.sliderForegroundGradientAmount = preset.playerSliderForegroundGradientAmount
        
        self.sliderKnobColor = preset.playerSliderKnobColor
        self.sliderKnobColorSameAsForeground = preset.playerSliderKnobColorSameAsForeground
        self.sliderLoopSegmentColor = preset.playerSliderLoopSegmentColor
    }
    
    func applyPreset(_ preset: ColorSchemePreset) {
        
        self.trackInfoPrimaryTextColor = preset.playerTrackInfoPrimaryTextColor
        self.trackInfoSecondaryTextColor = preset.playerTrackInfoSecondaryTextColor
        self.trackInfoTertiaryTextColor = preset.playerTrackInfoTertiaryTextColor
        self.sliderValueTextColor = preset.playerSliderValueTextColor
        
        self.sliderBackgroundColor = preset.playerSliderBackgroundColor
        self.sliderBackgroundGradientType = preset.playerSliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = preset.playerSliderBackgroundGradientAmount
        
        self.sliderForegroundColor = preset.playerSliderForegroundColor
        self.sliderForegroundGradientType = preset.playerSliderForegroundGradientType
        self.sliderForegroundGradientAmount = preset.playerSliderForegroundGradientAmount
        
        self.sliderKnobColor = preset.playerSliderKnobColor
        self.sliderKnobColorSameAsForeground = preset.playerSliderKnobColorSameAsForeground
        self.sliderLoopSegmentColor = preset.playerSliderLoopSegmentColor
    }
    
    func applyScheme(_ scheme: PlayerColorScheme) {

        self.trackInfoPrimaryTextColor = scheme.trackInfoPrimaryTextColor
        self.trackInfoSecondaryTextColor = scheme.trackInfoSecondaryTextColor
        self.trackInfoTertiaryTextColor = scheme.trackInfoTertiaryTextColor
        self.sliderValueTextColor = scheme.sliderValueTextColor
        
        self.sliderBackgroundColor = scheme.sliderBackgroundColor
        self.sliderBackgroundGradientType = scheme.sliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = scheme.sliderBackgroundGradientAmount
        
        self.sliderForegroundColor = scheme.sliderForegroundColor
        self.sliderForegroundGradientType = scheme.sliderForegroundGradientType
        self.sliderForegroundGradientAmount = scheme.sliderForegroundGradientAmount
        
        self.sliderKnobColor = scheme.sliderKnobColor
        self.sliderKnobColorSameAsForeground = scheme.sliderKnobColorSameAsForeground
        self.sliderLoopSegmentColor = scheme.sliderLoopSegmentColor
    }
    
    func clone() -> PlayerColorScheme {
        return PlayerColorScheme(self)
    }

    var persistentState: PlayerColorSchemePersistentState {
        return PlayerColorSchemePersistentState(self)
    }
}
