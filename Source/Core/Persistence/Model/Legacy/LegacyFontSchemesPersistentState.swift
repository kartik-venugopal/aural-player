//
//  LegacyFontSchemesPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct LegacyFontSchemesPersistentState: Codable {
    
    let systemScheme: LegacyFontSchemePersistentState?
    let userSchemes: [LegacyFontSchemePersistentState]?
}

struct LegacyFontSchemePersistentState: Codable {

    let name: String?
    
    let textFontName: String?
    let headingFontName: String?

    let player: LegacyPlayerFontSchemePersistentState?
    let playlist: LegacyPlaylistFontSchemePersistentState?
    let effects: LegacyEffectsFontSchemePersistentState?
}

struct LegacyPlayerFontSchemePersistentState: Codable {

    // Prominent text
    let titleSize: CGFloat?
    
    // Small text
    let feedbackTextSize: CGFloat?
}

struct LegacyPlaylistFontSchemePersistentState: Codable {
    
    // Normal text
    let trackTextSize: CGFloat?
    
    // Table offset
    let trackTextYOffset: CGFloat?
}

struct LegacyEffectsFontSchemePersistentState: Codable {

    // Caption text
    let unitCaptionSize: CGFloat?
    
    // Xtra Small text
    let filterChartSize: CGFloat?
    
    // TODO: Probably not required ???
    let auRowTextYOffset: CGFloat?
}
