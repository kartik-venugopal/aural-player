//
//  FontSchemesPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

#if os(iOS)
import UIKit
#endif

///
/// Encapsulates all persistent state for application font schemes.
///
/// - SeeAlso: `FontSchemesManager`
///
struct FontSchemesPersistentState: Codable {

    let systemScheme: FontSchemePersistentState?
    let userSchemes: [FontSchemePersistentState]?
    
    init(systemScheme: FontSchemePersistentState?, userSchemes: [FontSchemePersistentState]?) {
        
        self.systemScheme = systemScheme
        self.userSchemes = userSchemes
    }
    
    init(legacyPersistentState: LegacyFontSchemesPersistentState?) {
        
        self.systemScheme = .init(legacyPersistentState: legacyPersistentState?.systemScheme)
        self.userSchemes = legacyPersistentState?.userSchemes?.compactMap {.init(legacyPersistentState: $0)}
    }
}

///
/// Persistent state for a single font scheme.
///
/// - SeeAlso: `FontScheme`
///
struct FontSchemePersistentState: Codable {

    let name: String?
    
    let textFontName: String?
    let captionFontName: String?
    
    let captionSize: CGFloat?

    let normalSize: CGFloat?
    let prominentSize: CGFloat?
    let smallSize: CGFloat?
    let extraSmallSize: CGFloat?
    
    let tableYOffset: CGFloat?
    
#if os(macOS)

    // When saving app state to disk
    init(_ scheme: FontScheme) {

        self.name = scheme.name
        
        self.textFontName = scheme.normalFont.fontName
        self.captionFontName = scheme.captionFont.fontName
        
        self.captionSize = scheme.captionFont.pointSize
        
        self.normalSize = scheme.normalFont.pointSize
        self.prominentSize = scheme.prominentFont.pointSize
        self.smallSize = scheme.smallFont.pointSize
        self.extraSmallSize = scheme.extraSmallFont.pointSize
        
        self.tableYOffset = scheme.tableYOffset
    }
    
    init?(legacyPersistentState: LegacyFontSchemePersistentState?) {
        
        guard let legacyPersistentState = legacyPersistentState else {return nil}
        
        guard let name = legacyPersistentState.name,
        let textFontName = legacyPersistentState.textFontName,
        let headingFontName = legacyPersistentState.headingFontName else {return nil}
        
        self.name = name
        
        self.textFontName = textFontName
        self.captionFontName = headingFontName
        
        self.captionSize = legacyPersistentState.effects?.unitCaptionSize
        
        self.prominentSize = legacyPersistentState.player?.titleSize
        self.normalSize = legacyPersistentState.playlist?.trackTextSize
        self.smallSize = legacyPersistentState.player?.feedbackTextSize
        self.extraSmallSize = legacyPersistentState.effects?.filterChartSize
        
        self.tableYOffset = legacyPersistentState.playlist?.trackTextYOffset
    }
    
#endif
}
