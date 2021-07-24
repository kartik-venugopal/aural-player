//
//  ColorSchemesPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

class ColorSchemesPersistenceTests: PersistenceTestCase {
    
    func testPersistence() {
        
        for _ in 1...(runLongRunningTests ? 1000 : 100) {
            
            let systemScheme = randomColorScheme(named: "_system_")
            let userSchemes = randomColorSchemes()
            
            let state = ColorSchemesPersistentState(systemScheme: systemScheme, userSchemes: userSchemes)
            doTestPersistence(serializedState: state)
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension ColorSchemesPersistentState: Equatable {
    
    static func == (lhs: ColorSchemesPersistentState, rhs: ColorSchemesPersistentState) -> Bool {
        lhs.systemScheme == rhs.systemScheme && lhs.userSchemes == rhs.userSchemes
    }
}

extension ColorSchemePersistentState: Equatable {
    
    init(name: String, general: GeneralColorSchemePersistentState?, player: PlayerColorSchemePersistentState?, playlist: PlaylistColorSchemePersistentState?, effects: EffectsColorSchemePersistentState?) {
        
        self.name = name
        self.general = general
        self.player = player
        self.playlist = playlist
        self.effects = effects
    }
    
    static func == (lhs: ColorSchemePersistentState, rhs: ColorSchemePersistentState) -> Bool {
        
        lhs.name == rhs.name &&
            lhs.general == rhs.general &&
            lhs.player == rhs.player &&
            lhs.playlist == rhs.playlist &&
            lhs.effects == rhs.effects
    }
}

extension GeneralColorSchemePersistentState: Equatable {
    
    init(appLogoColor: ColorPersistentState?, backgroundColor: ColorPersistentState?, viewControlButtonColor: ColorPersistentState?, functionButtonColor: ColorPersistentState?, textButtonMenuColor: ColorPersistentState?, toggleButtonOffStateColor: ColorPersistentState?, selectedTabButtonColor: ColorPersistentState?, mainCaptionTextColor: ColorPersistentState?, tabButtonTextColor: ColorPersistentState?, selectedTabButtonTextColor: ColorPersistentState?, buttonMenuTextColor: ColorPersistentState?) {
        
        self.appLogoColor = appLogoColor
        self.backgroundColor = backgroundColor
        self.functionButtonColor = functionButtonColor
        self.textButtonMenuColor = textButtonMenuColor
        self.toggleButtonOffStateColor = toggleButtonOffStateColor
        self.selectedTabButtonColor = selectedTabButtonColor
        self.mainCaptionTextColor = mainCaptionTextColor
        self.tabButtonTextColor = tabButtonTextColor
        self.selectedTabButtonTextColor = selectedTabButtonTextColor
        self.buttonMenuTextColor = buttonMenuTextColor
    }
    
    static func == (lhs: GeneralColorSchemePersistentState, rhs: GeneralColorSchemePersistentState) -> Bool {
        
        lhs.appLogoColor == rhs.appLogoColor &&
            lhs.backgroundColor == rhs.backgroundColor &&
            lhs.buttonMenuTextColor == rhs.buttonMenuTextColor &&
            lhs.functionButtonColor == rhs.functionButtonColor &&
            lhs.mainCaptionTextColor == rhs.mainCaptionTextColor &&
            lhs.selectedTabButtonColor == rhs.selectedTabButtonColor &&
            lhs.selectedTabButtonTextColor == rhs.selectedTabButtonTextColor &&
            lhs.tabButtonTextColor == rhs.tabButtonTextColor &&
            lhs.textButtonMenuColor == rhs.textButtonMenuColor &&
            lhs.toggleButtonOffStateColor == rhs.toggleButtonOffStateColor
    }
}

extension PlayerColorSchemePersistentState: Equatable {
    
    init(trackInfoPrimaryTextColor: ColorPersistentState?, trackInfoSecondaryTextColor: ColorPersistentState?, trackInfoTertiaryTextColor: ColorPersistentState?, sliderValueTextColor: ColorPersistentState?, sliderBackgroundColor: ColorPersistentState?, sliderBackgroundGradientType: ColorSchemeGradientType?, sliderBackgroundGradientAmount: Int?, sliderForegroundColor: ColorPersistentState?, sliderForegroundGradientType: ColorSchemeGradientType?, sliderForegroundGradientAmount: Int?, sliderKnobColor: ColorPersistentState?, sliderKnobColorSameAsForeground: Bool?, sliderLoopSegmentColor: ColorPersistentState?) {
        
        self.trackInfoPrimaryTextColor = trackInfoPrimaryTextColor
        self.trackInfoSecondaryTextColor = trackInfoSecondaryTextColor
        self.trackInfoTertiaryTextColor = trackInfoTertiaryTextColor
        self.sliderValueTextColor = sliderValueTextColor
        self.sliderBackgroundColor = sliderBackgroundColor
        self.sliderBackgroundGradientType = sliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = sliderBackgroundGradientAmount
        self.sliderForegroundColor = sliderForegroundColor
        self.sliderForegroundGradientType = sliderForegroundGradientType
        self.sliderForegroundGradientAmount = sliderForegroundGradientAmount
        self.sliderKnobColor = sliderKnobColor
        self.sliderKnobColorSameAsForeground = sliderKnobColorSameAsForeground
        self.sliderLoopSegmentColor = sliderLoopSegmentColor
    }
    
    static func == (lhs: PlayerColorSchemePersistentState, rhs: PlayerColorSchemePersistentState) -> Bool {
        
        lhs.sliderBackgroundColor == rhs.sliderBackgroundColor &&
            lhs.sliderForegroundColor == rhs.sliderForegroundColor &&
            lhs.sliderKnobColor == rhs.sliderKnobColor &&
            lhs.sliderLoopSegmentColor == rhs.sliderLoopSegmentColor &&
            lhs.sliderValueTextColor == rhs.sliderValueTextColor &&
            lhs.trackInfoPrimaryTextColor == rhs.trackInfoPrimaryTextColor &&
            lhs.trackInfoSecondaryTextColor == rhs.trackInfoSecondaryTextColor &&
            lhs.trackInfoTertiaryTextColor == rhs.trackInfoTertiaryTextColor &&
            lhs.sliderBackgroundGradientAmount == rhs.sliderBackgroundGradientAmount &&
            lhs.sliderBackgroundGradientType == rhs.sliderBackgroundGradientType &&
            lhs.sliderForegroundGradientAmount == rhs.sliderForegroundGradientAmount &&
            lhs.sliderForegroundGradientType == rhs.sliderForegroundGradientType &&
            lhs.sliderKnobColorSameAsForeground == rhs.sliderKnobColorSameAsForeground
    }
}

extension PlaylistColorSchemePersistentState: Equatable {
    
    init(trackNameTextColor: ColorPersistentState?, groupNameTextColor: ColorPersistentState?, indexDurationTextColor: ColorPersistentState?, trackNameSelectedTextColor: ColorPersistentState?, groupNameSelectedTextColor: ColorPersistentState?, indexDurationSelectedTextColor: ColorPersistentState?, summaryInfoColor: ColorPersistentState?, playingTrackIconColor: ColorPersistentState?, selectionBoxColor: ColorPersistentState?, groupIconColor: ColorPersistentState?, groupDisclosureTriangleColor: ColorPersistentState?) {
        
        self.trackNameTextColor = trackNameTextColor
        self.groupNameTextColor = groupNameTextColor
        self.indexDurationTextColor = indexDurationTextColor
        self.trackNameSelectedTextColor = trackNameSelectedTextColor
        self.groupNameSelectedTextColor = groupNameSelectedTextColor
        self.indexDurationSelectedTextColor = indexDurationSelectedTextColor
        self.summaryInfoColor = summaryInfoColor
        self.playingTrackIconColor = playingTrackIconColor
        self.selectionBoxColor = selectionBoxColor
        self.groupIconColor = groupIconColor
        self.groupDisclosureTriangleColor = groupDisclosureTriangleColor
    }
    
    static func == (lhs: PlaylistColorSchemePersistentState, rhs: PlaylistColorSchemePersistentState) -> Bool {
        
        lhs.groupDisclosureTriangleColor == rhs.groupDisclosureTriangleColor &&
            lhs.groupIconColor == rhs.groupIconColor &&
            lhs.groupNameSelectedTextColor == rhs.groupNameSelectedTextColor &&
            lhs.groupNameTextColor == rhs.groupNameTextColor &&
            lhs.indexDurationSelectedTextColor == rhs.indexDurationSelectedTextColor &&
            lhs.indexDurationTextColor == rhs.indexDurationTextColor &&
            lhs.playingTrackIconColor == rhs.playingTrackIconColor &&
            lhs.selectionBoxColor == rhs.selectionBoxColor &&
            lhs.summaryInfoColor == rhs.summaryInfoColor &&
            lhs.trackNameSelectedTextColor == rhs.trackNameSelectedTextColor &&
            lhs.trackNameTextColor == rhs.trackNameTextColor
    }
}

extension EffectsColorSchemePersistentState: Equatable {
    
    init(functionCaptionTextColor: ColorPersistentState?, functionValueTextColor: ColorPersistentState?, sliderBackgroundColor: ColorPersistentState?, sliderBackgroundGradientType: ColorSchemeGradientType?, sliderBackgroundGradientAmount: Int?, sliderForegroundGradientType: ColorSchemeGradientType?, sliderForegroundGradientAmount: Int?, sliderKnobColor: ColorPersistentState?, sliderKnobColorSameAsForeground: Bool?, sliderTickColor: ColorPersistentState?, activeUnitStateColor: ColorPersistentState?, bypassedUnitStateColor: ColorPersistentState?, suppressedUnitStateColor: ColorPersistentState?) {
        
        self.functionCaptionTextColor = functionCaptionTextColor
        self.functionValueTextColor = functionValueTextColor
        self.sliderBackgroundColor = sliderBackgroundColor
        self.sliderBackgroundGradientType = sliderBackgroundGradientType
        self.sliderBackgroundGradientAmount = sliderBackgroundGradientAmount
        self.sliderForegroundGradientType = sliderForegroundGradientType
        self.sliderForegroundGradientAmount = sliderForegroundGradientAmount
        self.sliderKnobColor = sliderKnobColor
        self.sliderKnobColorSameAsForeground = sliderKnobColorSameAsForeground
        self.sliderTickColor = sliderTickColor
        self.activeUnitStateColor = activeUnitStateColor
        self.bypassedUnitStateColor = bypassedUnitStateColor
        self.suppressedUnitStateColor = suppressedUnitStateColor
    }
    
    static func == (lhs: EffectsColorSchemePersistentState, rhs: EffectsColorSchemePersistentState) -> Bool {
        
        lhs.activeUnitStateColor == rhs.activeUnitStateColor &&
            lhs.bypassedUnitStateColor == rhs.bypassedUnitStateColor &&
            lhs.functionCaptionTextColor == rhs.functionCaptionTextColor &&
            lhs.functionValueTextColor == rhs.functionValueTextColor &&
            lhs.sliderBackgroundColor == rhs.sliderBackgroundColor &&
            lhs.sliderBackgroundGradientAmount == rhs.sliderBackgroundGradientAmount &&
            lhs.sliderBackgroundGradientType == rhs.sliderBackgroundGradientType &&
            lhs.sliderForegroundGradientAmount == rhs.sliderForegroundGradientAmount &&
            lhs.sliderForegroundGradientType == rhs.sliderForegroundGradientType &&
            lhs.sliderKnobColor == rhs.sliderKnobColor &&
            lhs.sliderKnobColorSameAsForeground == rhs.sliderKnobColorSameAsForeground &&
            lhs.sliderTickColor == rhs.sliderTickColor &&
            lhs.suppressedUnitStateColor == rhs.suppressedUnitStateColor
    }
}
