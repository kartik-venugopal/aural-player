//
//  LegacyColorSchemesPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct LegacyColorSchemesPersistentState: Codable {

    let systemScheme: LegacyColorSchemePersistentState?
    let userSchemes: [LegacyColorSchemePersistentState]?
}

///
/// Persistent state for a single color scheme.
///
/// - SeeAlso: `ColorScheme`
///
struct LegacyColorSchemePersistentState: Codable {
    
    let name: String
    
    let general: LegacyGeneralColorSchemePersistentState?
    let player: LegacyPlayerColorSchemePersistentState?
    let playlist: LegacyPlaylistColorSchemePersistentState?
    let effects: LegacyEffectsColorSchemePersistentState?
}

struct LegacyGeneralColorSchemePersistentState: Codable {
    
    let appLogoColor: ColorPersistentState?
    let backgroundColor: ColorPersistentState?
    
    let functionButtonColor: ColorPersistentState?
    let textButtonMenuColor: ColorPersistentState?
    let toggleButtonOffStateColor: ColorPersistentState?
    let selectedTabButtonColor: ColorPersistentState?
    
    let mainCaptionTextColor: ColorPersistentState?
    let tabButtonTextColor: ColorPersistentState?
    let selectedTabButtonTextColor: ColorPersistentState?
    let buttonMenuTextColor: ColorPersistentState?
}

struct LegacyPlayerColorSchemePersistentState: Codable {
    
    let trackInfoPrimaryTextColor: ColorPersistentState?
    let trackInfoSecondaryTextColor: ColorPersistentState?
    let trackInfoTertiaryTextColor: ColorPersistentState?
    let sliderValueTextColor: ColorPersistentState?
    
    let sliderBackgroundColor: ColorPersistentState?
    let sliderForegroundColor: ColorPersistentState?
    
    let sliderKnobColor: ColorPersistentState?
    let sliderKnobColorSameAsForeground: Bool?
    let sliderLoopSegmentColor: ColorPersistentState?
}

struct LegacyPlaylistColorSchemePersistentState: Codable {
    
    let trackNameTextColor: ColorPersistentState?
    let groupNameTextColor: ColorPersistentState?
    let indexDurationTextColor: ColorPersistentState?
    
    let trackNameSelectedTextColor: ColorPersistentState?
    let groupNameSelectedTextColor: ColorPersistentState?
    let indexDurationSelectedTextColor: ColorPersistentState?

    let summaryInfoColor: ColorPersistentState?
    
    let playingTrackIconColor: ColorPersistentState?
    let selectionBoxColor: ColorPersistentState?
    let groupIconColor: ColorPersistentState?
    let groupDisclosureTriangleColor: ColorPersistentState?
}

struct LegacyEffectsColorSchemePersistentState: Codable {
    
    let functionCaptionTextColor: ColorPersistentState?
    let functionValueTextColor: ColorPersistentState?
    
    let sliderBackgroundColor: ColorPersistentState?
    let sliderKnobColor: ColorPersistentState?
    let sliderKnobColorSameAsForeground: Bool?
    
    let sliderTickColor: ColorPersistentState?
    
    let activeUnitStateColor: ColorPersistentState?
    let bypassedUnitStateColor: ColorPersistentState?
    let suppressedUnitStateColor: ColorPersistentState?
}
