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
struct PlayerFontSchemePersistentState: Codable {

    let titleSize: CGFloat?
    let artistAlbumSize: CGFloat?
    let chapterTitleSize: CGFloat?
    let trackTimesSize: CGFloat?
    let feedbackTextSize: CGFloat?

    init(_ scheme: PlayerFontScheme) {

        self.titleSize = scheme.infoBoxTitleFont.pointSize
        self.artistAlbumSize = scheme.infoBoxArtistAlbumFont.pointSize
        self.chapterTitleSize = scheme.infoBoxChapterTitleFont.pointSize
        self.trackTimesSize = scheme.trackTimesFont.pointSize
        self.feedbackTextSize = scheme.feedbackFont.pointSize
    }
}
