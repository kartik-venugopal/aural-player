//
//  PlaylistColorScheme.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
//    var playingTrackIconSelectedRowsColor: NSColor
    
    var selectionBoxColor: NSColor
    
    var groupIconColor: NSColor
//    var groupIconSelectedRowsColor: NSColor
    
    var groupDisclosureTriangleColor: NSColor
//    var groupDisclosureTriangleSelectedRowsColor: NSColor
    
    init(_ persistentState: PlaylistColorSchemePersistentState?) {
        
        self.trackNameTextColor = persistentState?.trackNameTextColor?.toColor() ?? ColorSchemesManager.defaultScheme.playlist.trackNameTextColor
        self.groupNameTextColor = persistentState?.groupNameTextColor?.toColor() ?? ColorSchemesManager.defaultScheme.playlist.groupNameTextColor
        self.indexDurationTextColor = persistentState?.indexDurationTextColor?.toColor() ?? ColorSchemesManager.defaultScheme.playlist.indexDurationTextColor
        
        self.trackNameSelectedTextColor = persistentState?.trackNameSelectedTextColor?.toColor() ?? ColorSchemesManager.defaultScheme.playlist.trackNameSelectedTextColor
        
        self.groupNameSelectedTextColor = persistentState?.groupNameSelectedTextColor?.toColor() ?? ColorSchemesManager.defaultScheme.playlist.groupNameSelectedTextColor
        
        self.indexDurationSelectedTextColor = persistentState?.indexDurationSelectedTextColor?.toColor() ?? ColorSchemesManager.defaultScheme.playlist.indexDurationSelectedTextColor
        
        self.summaryInfoColor = persistentState?.summaryInfoColor?.toColor() ?? ColorSchemesManager.defaultScheme.playlist.summaryInfoColor
        
        self.selectionBoxColor = persistentState?.selectionBoxColor?.toColor() ?? ColorSchemesManager.defaultScheme.playlist.selectionBoxColor
        
        self.playingTrackIconColor = persistentState?.playingTrackIconColor?.toColor() ?? ColorSchemesManager.defaultScheme.playlist.playingTrackIconColor
        
//        self.playingTrackIconSelectedRowsColor = persistentState?.playingTrackIconSelectedRowsColor?.toColor() ?? ColorSchemes.defaultScheme.playlist.playingTrackIconSelectedRowsColor
        
        self.groupIconColor = persistentState?.groupIconColor?.toColor() ?? ColorSchemesManager.defaultScheme.playlist.groupIconColor
        
//        self.groupIconSelectedRowsColor = persistentState?.groupIconSelectedRowsColor?.toColor() ?? ColorSchemes.defaultScheme.playlist.groupIconSelectedRowsColor
        
        self.groupDisclosureTriangleColor = persistentState?.groupDisclosureTriangleColor?.toColor() ?? ColorSchemesManager.defaultScheme.playlist.groupDisclosureTriangleColor
        
//        self.groupDisclosureTriangleSelectedRowsColor = persistentState?.groupDisclosureTriangleSelectedRowsColor?.toColor() ?? ColorSchemes.defaultScheme.playlist.groupDisclosureTriangleSelectedRowsColor
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
//        self.playingTrackIconSelectedRowsColor = scheme.playingTrackIconSelectedRowsColor
        
        self.groupIconColor = scheme.groupIconColor
//        self.groupIconSelectedRowsColor = scheme.groupIconSelectedRowsColor
        
        self.groupDisclosureTriangleColor = scheme.groupDisclosureTriangleColor
//        self.groupDisclosureTriangleSelectedRowsColor = scheme.groupDisclosureTriangleSelectedRowsColor
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
//        self.playingTrackIconSelectedRowsColor = preset.playlistPlayingTrackIconSelectedRowsColor
        
        self.groupIconColor = preset.playlistGroupIconColor
//        self.groupIconSelectedRowsColor = preset.playlistGroupIconSelectedRowsColor
        
        self.groupDisclosureTriangleColor = preset.playlistGroupDisclosureTriangleColor
//        self.groupDisclosureTriangleSelectedRowsColor = preset.playlistGroupDisclosureTriangleSelectedRowsColor
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
