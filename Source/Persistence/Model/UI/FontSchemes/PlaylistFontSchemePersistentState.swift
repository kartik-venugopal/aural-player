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
class PlaylistFontSchemePersistentState: PersistentStateProtocol {

    var trackTextSize: CGFloat?
    var trackTextYOffset: Int?
    
    var groupTextSize: CGFloat?
    var groupTextYOffset: Int?
    
    var summarySize: CGFloat?
    var tabButtonTextSize: CGFloat?
    
    var chaptersListHeaderSize: CGFloat?
    var chaptersListSearchSize: CGFloat?
    var chaptersListCaptionSize: CGFloat?

    init() {}

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

    required init?(_ map: NSDictionary) {
        
        self.trackTextSize = map.cgFloatValue(forKey: "trackTextSize")
        self.trackTextYOffset = map.intValue(forKey: "trackTextYOffset")
        self.groupTextSize = map.cgFloatValue(forKey: "groupTextSize")
        self.groupTextYOffset = map.intValue(forKey: "groupTextYOffset")
        self.summarySize = map.cgFloatValue(forKey: "summarySize")
        self.tabButtonTextSize = map.cgFloatValue(forKey: "tabButtonTextSize")
        self.chaptersListHeaderSize = map.cgFloatValue(forKey: "chaptersListHeaderSize")
        self.chaptersListCaptionSize = map.cgFloatValue(forKey: "chaptersListCaptionSize")
        self.chaptersListSearchSize = map.cgFloatValue(forKey: "chaptersListSearchSize")
    }
}
