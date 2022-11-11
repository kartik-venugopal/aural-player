//
//  PlayerFontScheme.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlayerFontScheme {
    
    var infoBoxTitleFont: NSFont
    var infoBoxArtistAlbumFont: NSFont
    var infoBoxChapterTitleFont: NSFont
    var trackTimesFont: NSFont
    var feedbackFont: NSFont
    
    init(_ persistentState: FontSchemePersistentState?) {
        
        self.infoBoxTitleFont = FontSchemePreset.standard.infoBoxTitleFont
        self.infoBoxArtistAlbumFont = FontSchemePreset.standard.infoBoxArtistAlbumFont
        self.infoBoxChapterTitleFont = FontSchemePreset.standard.infoBoxChapterTitleFont
        self.trackTimesFont = FontSchemePreset.standard.trackTimesFont
        self.feedbackFont = FontSchemePreset.standard.feedbackFont
        
        guard let textFontName = persistentState?.textFontName else {
            return
        }
        
        if let titleSize = persistentState?.player?.titleSize, let titleFont = NSFont(name: textFontName, size: titleSize) {
            self.infoBoxTitleFont = titleFont
        }
        
        if let artistAlbumSize = persistentState?.player?.artistAlbumSize, let artistAlbumFont = NSFont(name: textFontName, size: artistAlbumSize) {
            self.infoBoxArtistAlbumFont = artistAlbumFont
        }
        
        if let chapterTitleSize = persistentState?.player?.chapterTitleSize, let chapterTitleFont = NSFont(name: textFontName, size: chapterTitleSize) {
            self.infoBoxChapterTitleFont = chapterTitleFont
        }
        
        if let trackTimesSize = persistentState?.player?.trackTimesSize, let trackTimesFont = NSFont(name: textFontName, size: trackTimesSize) {
            self.trackTimesFont = trackTimesFont
        }
        
        if let feedbackTextSize = persistentState?.player?.feedbackTextSize, let feedbackFont = NSFont(name: textFontName, size: feedbackTextSize) {
            self.feedbackFont = feedbackFont
        }
    }

    init(preset: FontSchemePreset) {
        
        self.infoBoxTitleFont = preset.infoBoxTitleFont
        self.infoBoxArtistAlbumFont = preset.infoBoxArtistAlbumFont
        self.infoBoxChapterTitleFont = preset.infoBoxChapterTitleFont
        self.trackTimesFont = preset.trackTimesFont
        self.feedbackFont = preset.feedbackFont
    }
    
    init(_ fontScheme: PlayerFontScheme) {
        
        self.infoBoxTitleFont = fontScheme.infoBoxTitleFont
        self.infoBoxArtistAlbumFont = fontScheme.infoBoxArtistAlbumFont
        self.infoBoxChapterTitleFont = fontScheme.infoBoxChapterTitleFont
        self.trackTimesFont = fontScheme.trackTimesFont
        self.feedbackFont = fontScheme.feedbackFont
    }
    
    func clone() -> PlayerFontScheme {
        return PlayerFontScheme(self)
    }
}
