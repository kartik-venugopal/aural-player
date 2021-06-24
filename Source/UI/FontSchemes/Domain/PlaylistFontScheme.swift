//
//  PlaylistFontScheme.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class PlaylistFontScheme {

    var trackTextFont: NSFont
    var trackTextYOffset: CGFloat
    
    var groupTextFont: NSFont
    var groupTextYOffset: CGFloat
    
    var summaryFont: NSFont
    var tabButtonTextFont: NSFont
    var chaptersListHeaderFont: NSFont
    var chaptersListSearchFont: NSFont
    var chaptersListCaptionFont: NSFont
    
    init(_ persistentState: FontSchemePersistentState?) {
        
        self.trackTextFont = FontSchemePreset.standard.playlistTrackTextFont
        self.trackTextYOffset = FontSchemePreset.standard.playlistTrackTextYOffset
        
        self.groupTextFont = FontSchemePreset.standard.playlistGroupTextFont
        self.groupTextYOffset = FontSchemePreset.standard.playlistGroupTextYOffset
        
        self.summaryFont = FontSchemePreset.standard.playlistSummaryFont
        self.tabButtonTextFont = FontSchemePreset.standard.playlistTabButtonTextFont
        
        self.chaptersListHeaderFont = FontSchemePreset.standard.chaptersListHeaderFont
        self.chaptersListCaptionFont = FontSchemePreset.standard.chaptersListCaptionFont
        self.chaptersListSearchFont = FontSchemePreset.standard.chaptersListSearchFont
        
        guard let textFontName = persistentState?.textFontName, let headingFontName = persistentState?.headingFontName else {
            return
        }
        
        if let trackTextSize = persistentState?.playlist?.trackTextSize, let trackTextFont = NSFont(name: textFontName, size: trackTextSize) {
            self.trackTextFont = trackTextFont
        }
        
        if let trackTextYOffset = persistentState?.playlist?.trackTextYOffset {
            self.trackTextYOffset = CGFloat(trackTextYOffset)
        }
        
        if let groupTextSize = persistentState?.playlist?.groupTextSize, let groupTextFont = NSFont(name: textFontName, size: groupTextSize) {
            self.groupTextFont = groupTextFont
        }
        
        if let groupTextYOffset = persistentState?.playlist?.groupTextYOffset {
            self.groupTextYOffset = CGFloat(groupTextYOffset)
        }
        
        if let summarySize = persistentState?.playlist?.summarySize, let summaryFont = NSFont(name: textFontName, size: summarySize) {
            self.summaryFont = summaryFont
        }
        
        if let tabButtonTextSize = persistentState?.playlist?.tabButtonTextSize, let tabButtonTextFont = NSFont(name: headingFontName, size: tabButtonTextSize) {
            self.tabButtonTextFont = tabButtonTextFont
        }
        
        if let chaptersListHeaderSize = persistentState?.playlist?.chaptersListHeaderSize,
           let chaptersListHeaderFont = NSFont(name: headingFontName, size: chaptersListHeaderSize) {
            
            self.chaptersListHeaderFont = chaptersListHeaderFont
        }
        
        if let chaptersListCaptionSize = persistentState?.playlist?.chaptersListCaptionSize,
           let chaptersListCaptionFont = NSFont(name: headingFontName, size: chaptersListCaptionSize) {
            
            self.chaptersListCaptionFont = chaptersListCaptionFont
        }
        
        if let chaptersListSearchSize = persistentState?.playlist?.chaptersListSearchSize,
           let chaptersListSearchFont = NSFont(name: textFontName, size: chaptersListSearchSize) {
            
            self.chaptersListSearchFont = chaptersListSearchFont
        }
    }

    init(preset: FontSchemePreset) {
        
        self.trackTextFont = preset.playlistTrackTextFont
        self.trackTextYOffset = preset.playlistTrackTextYOffset
        self.groupTextFont = preset.playlistGroupTextFont
        self.groupTextYOffset = preset.playlistGroupTextYOffset
        self.summaryFont = preset.playlistSummaryFont
        self.tabButtonTextFont = preset.playlistTabButtonTextFont
        self.chaptersListHeaderFont = preset.chaptersListHeaderFont
        self.chaptersListSearchFont = preset.chaptersListSearchFont
        self.chaptersListCaptionFont = preset.chaptersListCaptionFont
    }
    
    init(_ fontScheme: PlaylistFontScheme) {
        
        self.trackTextFont = fontScheme.trackTextFont
        self.trackTextYOffset = fontScheme.trackTextYOffset
        self.groupTextFont = fontScheme.groupTextFont
        self.groupTextYOffset = fontScheme.groupTextYOffset
        self.summaryFont = fontScheme.summaryFont
        self.tabButtonTextFont = fontScheme.tabButtonTextFont
        self.chaptersListHeaderFont = fontScheme.chaptersListHeaderFont
        self.chaptersListSearchFont = fontScheme.chaptersListSearchFont
        self.chaptersListCaptionFont = fontScheme.chaptersListCaptionFont
    }
    
    func clone() -> PlaylistFontScheme {
        return PlaylistFontScheme(self)
    }
}
