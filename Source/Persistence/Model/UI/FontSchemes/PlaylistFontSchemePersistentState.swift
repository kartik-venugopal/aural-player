//
//  PlaylistFontSchemePersistentState.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Persistent state for the playlist component of a single font scheme.
///
/// - SeeAlso: `PlaylistFontScheme`
///
struct PlaylistFontSchemePersistentState: Codable {
    
    let trackTextSize: CGFloat?
    let trackTextYOffset: CGFloat?
    
    let groupTextSize: CGFloat?
    let groupTextYOffset: CGFloat?
    
    let summarySize: CGFloat?
    let tabButtonTextSize: CGFloat?
    
    let chaptersListHeaderSize: CGFloat?
    let chaptersListSearchSize: CGFloat?
    let chaptersListCaptionSize: CGFloat?

    init(_ scheme: PlaylistFontScheme) {

        self.trackTextSize = scheme.trackTextFont.pointSize
        self.trackTextYOffset = scheme.trackTextYOffset
        
        self.groupTextSize = scheme.groupTextFont.pointSize
        self.groupTextYOffset = scheme.groupTextYOffset
        
        self.summarySize = scheme.summaryFont.pointSize
        self.tabButtonTextSize = scheme.tabButtonTextFont.pointSize
        
        self.chaptersListHeaderSize = scheme.chaptersListHeaderFont.pointSize
        self.chaptersListCaptionSize = scheme.chaptersListCaptionFont.pointSize
        self.chaptersListSearchSize = scheme.chaptersListSearchFont.pointSize
    }
}
