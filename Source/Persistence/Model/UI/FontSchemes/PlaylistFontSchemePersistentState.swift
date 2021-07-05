//
//  PlaylistFontSchemePersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

/*
    Encapsulates persistent app state for a single PlaylistFontScheme.
 */
struct PlaylistFontSchemePersistentState: Codable {

    let trackTextSize: CGFloat?
    let trackTextYOffset: Int?
    
    let groupTextSize: CGFloat?
    let groupTextYOffset: Int?
    
    let summarySize: CGFloat?
    let tabButtonTextSize: CGFloat?
    
    let chaptersListHeaderSize: CGFloat?
    let chaptersListSearchSize: CGFloat?
    let chaptersListCaptionSize: CGFloat?

    init(_ scheme: PlaylistFontScheme) {

        self.trackTextSize = scheme.trackTextFont.pointSize
        self.trackTextYOffset = scheme.trackTextYOffset.roundedInt
        
        self.groupTextSize = scheme.groupTextFont.pointSize
        self.groupTextYOffset = scheme.groupTextYOffset.roundedInt
        
        self.summarySize = scheme.summaryFont.pointSize
        self.tabButtonTextSize = scheme.tabButtonTextFont.pointSize
        
        self.chaptersListHeaderSize = scheme.chaptersListHeaderFont.pointSize
        self.chaptersListCaptionSize = scheme.chaptersListCaptionFont.pointSize
        self.chaptersListSearchSize = scheme.chaptersListSearchFont.pointSize
    }
}
