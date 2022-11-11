//
//  PlaylistColorScheme.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

/*
    Encapsulates color values that are applicable to the playlist UI, e.g. color of the track name or duration.
 */
class PlaylistColorScheme {
    
    var trackNameTextColor: NSColor
    var groupNameTextColor: NSColor
    var indexDurationTextColor: NSColor
    
    var trackNameSelectedTextColor: NSColor
    var groupNameSelectedTextColor: NSColor
    var indexDurationSelectedTextColor: NSColor
    
    var summaryInfoColor: NSColor
    
    var playingTrackIconColor: NSColor
    
    var selectionBoxColor: NSColor
    
    var groupIconColor: NSColor
    
    var groupDisclosureTriangleColor: NSColor
    
    init(_ persistentState: PlaylistColorSchemePersistentState?) {
        
        self.trackNameTextColor = persistentState?.trackNameTextColor?.toColor() ?? ColorScheme.defaultScheme.playlist.trackNameTextColor
        self.groupNameTextColor = persistentState?.groupNameTextColor?.toColor() ?? ColorScheme.defaultScheme.playlist.groupNameTextColor
        self.indexDurationTextColor = persistentState?.indexDurationTextColor?.toColor() ?? ColorScheme.defaultScheme.playlist.indexDurationTextColor
        
        self.trackNameSelectedTextColor = persistentState?.trackNameSelectedTextColor?.toColor() ?? ColorScheme.defaultScheme.playlist.trackNameSelectedTextColor
        
        self.groupNameSelectedTextColor = persistentState?.groupNameSelectedTextColor?.toColor() ?? ColorScheme.defaultScheme.playlist.groupNameSelectedTextColor
        
        self.indexDurationSelectedTextColor = persistentState?.indexDurationSelectedTextColor?.toColor() ?? ColorScheme.defaultScheme.playlist.indexDurationSelectedTextColor
        
        self.summaryInfoColor = persistentState?.summaryInfoColor?.toColor() ?? ColorScheme.defaultScheme.playlist.summaryInfoColor
        
        self.selectionBoxColor = persistentState?.selectionBoxColor?.toColor() ?? ColorScheme.defaultScheme.playlist.selectionBoxColor
        
        self.playingTrackIconColor = persistentState?.playingTrackIconColor?.toColor() ?? ColorScheme.defaultScheme.playlist.playingTrackIconColor
        
        self.groupIconColor = persistentState?.groupIconColor?.toColor() ?? ColorScheme.defaultScheme.playlist.groupIconColor
        
        self.groupDisclosureTriangleColor = persistentState?.groupDisclosureTriangleColor?.toColor() ?? ColorScheme.defaultScheme.playlist.groupDisclosureTriangleColor
    }
    
    init(_ scheme: PlaylistColorScheme) {
        
        self.trackNameTextColor = scheme.trackNameTextColor
        self.groupNameTextColor = scheme.groupNameTextColor
        self.indexDurationTextColor = scheme.indexDurationTextColor
        
        self.trackNameSelectedTextColor = scheme.trackNameSelectedTextColor
        self.groupNameSelectedTextColor = scheme.groupNameSelectedTextColor
        self.indexDurationSelectedTextColor = scheme.indexDurationSelectedTextColor
        
        self.summaryInfoColor = scheme.summaryInfoColor
        
        self.selectionBoxColor = scheme.selectionBoxColor
        self.playingTrackIconColor = scheme.playingTrackIconColor
        
        self.groupIconColor = scheme.groupIconColor
        self.groupDisclosureTriangleColor = scheme.groupDisclosureTriangleColor
    }
    
    init(_ preset: ColorSchemePreset) {
        
        self.trackNameTextColor = preset.playlistTrackNameTextColor
        self.groupNameTextColor = preset.playlistGroupNameTextColor
        self.indexDurationTextColor = preset.playlistIndexDurationTextColor
        
        self.trackNameSelectedTextColor = preset.playlistTrackNameSelectedTextColor
        self.groupNameSelectedTextColor = preset.playlistGroupNameSelectedTextColor
        self.indexDurationSelectedTextColor = preset.playlistIndexDurationSelectedTextColor
        
        self.summaryInfoColor = preset.playlistSummaryInfoColor
        
        self.selectionBoxColor = preset.playlistSelectionBoxColor
        self.playingTrackIconColor = preset.playlistPlayingTrackIconColor
        
        self.groupIconColor = preset.playlistGroupIconColor
        self.groupDisclosureTriangleColor = preset.playlistGroupDisclosureTriangleColor
    }
    
    func applyPreset(_ preset: ColorSchemePreset) {
        
        self.trackNameTextColor = preset.playlistTrackNameTextColor
        self.groupNameTextColor = preset.playlistGroupNameTextColor
        self.indexDurationTextColor = preset.playlistIndexDurationTextColor
        
        self.trackNameSelectedTextColor = preset.playlistTrackNameSelectedTextColor
        self.groupNameSelectedTextColor = preset.playlistGroupNameSelectedTextColor
        self.indexDurationSelectedTextColor = preset.playlistIndexDurationSelectedTextColor
        
        self.summaryInfoColor = preset.playlistSummaryInfoColor
        
        self.selectionBoxColor = preset.playlistSelectionBoxColor
        self.playingTrackIconColor = preset.playlistPlayingTrackIconColor
        
        self.groupIconColor = preset.playlistGroupIconColor
        self.groupDisclosureTriangleColor = preset.playlistGroupDisclosureTriangleColor
    }
    
    func applyScheme(_ scheme: PlaylistColorScheme) {
        
        self.trackNameTextColor = scheme.trackNameTextColor
        self.groupNameTextColor = scheme.groupNameTextColor
        self.indexDurationTextColor = scheme.indexDurationTextColor
        
        self.trackNameSelectedTextColor = scheme.trackNameSelectedTextColor
        self.groupNameSelectedTextColor = scheme.groupNameSelectedTextColor
        self.indexDurationSelectedTextColor = scheme.indexDurationSelectedTextColor
        
        self.summaryInfoColor = scheme.summaryInfoColor
        
        self.selectionBoxColor = scheme.selectionBoxColor
        self.playingTrackIconColor = scheme.playingTrackIconColor
        
        self.groupIconColor = scheme.groupIconColor
        self.groupDisclosureTriangleColor = scheme.groupDisclosureTriangleColor
    }
    
    func clone() -> PlaylistColorScheme {
        return PlaylistColorScheme(self)
    }
    
    var persistentState: PlaylistColorSchemePersistentState {
        return PlaylistColorSchemePersistentState(self)
    }
}
