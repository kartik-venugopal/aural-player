//
//  PlayerFontSchemePersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

/*
    Encapsulates persistent app state for a single PlayerFontScheme.
 */
class PlayerFontSchemePersistentState: PersistentStateProtocol {

    var titleSize: CGFloat?
    var artistAlbumSize: CGFloat?
    var chapterTitleSize: CGFloat?
    var trackTimesSize: CGFloat?
    var feedbackTextSize: CGFloat?

    init() {}

    init(_ scheme: PlayerFontScheme) {

        self.titleSize = scheme.infoBoxTitleFont.pointSize
        self.artistAlbumSize = scheme.infoBoxArtistAlbumFont.pointSize
        self.chapterTitleSize = scheme.infoBoxChapterTitleFont.pointSize
        self.trackTimesSize = scheme.trackTimesFont.pointSize
        self.feedbackTextSize = scheme.feedbackFont.pointSize
    }

    required init?(_ map: NSDictionary) {

        self.titleSize = map.cgFloatValue(forKey: "titleSize")
        self.artistAlbumSize = map.cgFloatValue(forKey: "artistAlbumSize")
        self.chapterTitleSize = map.cgFloatValue(forKey: "chapterTitleSize")
        self.trackTimesSize = map.cgFloatValue(forKey: "trackTimesSize")
        self.feedbackTextSize = map.cgFloatValue(forKey: "feedbackTextSize")
    }
}
