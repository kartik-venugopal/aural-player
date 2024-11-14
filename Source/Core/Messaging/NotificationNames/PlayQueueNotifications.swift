//
//  PlayQueueNotifications.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

extension Notification.Name {
    
    struct PlayQueue {
        
        // MARK: Notifications published by the play queue.
        
        // Signifies that the play queue has begun adding a set of tracks.
        static let startedAddingTracks = Notification.Name("playQueue_startedAddingTracks")
        
        // Signifies that the play queue has finished adding a set of tracks.
        static let doneAddingTracks = Notification.Name("playQueue_doneAddingTracks")
        
        // Signifies that some chosen tracks could not be added to the play queue (i.e. an error condition).
        static let tracksNotAdded = Notification.Name("playQueue_tracksNotAdded")
        
        // Signifies that new tracks have been added to the play queue.
        static let tracksAdded = Notification.Name("playQueue_tracksAdded")
        
        static let tracksRemoved = Notification.Name("playQueue_tracksRemoved")
        
        static let bulkCoverArtUpdate = Notification.Name("playQueue_bulkCoverArtUpdate")
        
        // Signifies that the currently playing track has been removed from the playlist, suggesting
        // that playback should stop.
        static let playingTrackRemoved = Notification.Name("playQueue_playingTrackRemoved")
        
        static let tracksDragDropped = Notification.Name("playQueue_tracksDragDropped")
        
        static let sorted = Notification.Name("playQueue_sorted")
        
        // Signifies that the summary for the play queue needs to be updated.
        static let updateSummary = Notification.Name("playQueue_updateSummary")
        
        // ----------------------------------------------------------------------------------------
        
        // MARK: Play Queue commands
        
        // Commands the play queue to display a file dialog to let the user add new tracks.
        static let addTracks = Notification.Name("playQueue_addTracks")
        
        // Commands the play queue to enqueue the given tracks and begin playing the first one immediately.
        static let enqueueAndPlayNow = Notification.Name("playQueue_enqueueAndPlayNow")
        
        static let loadAndPlayNow = Notification.Name("playQueue_loadAndPlayNow")
        
        // Commands the play queue to enqueue the given tracks so that they begin playing after the currently playing track.
        static let enqueueAndPlayNext = Notification.Name("playQueue_enqueueAndPlayNext")
        
        // Commands the play queue to enqueue the given tracks so that they begin playing after all the existing tracks have finished playing.
        static let enqueueAndPlayLater = Notification.Name("playQueue_enqueueAndPlayLater")
        
        // Commands the play queue view to reveal (i.e. scroll to and select) the currently playing track.
        static let showPlayingTrack = Notification.Name("playQueue_showPlayingTrack")
        
        // Commands the play queue to remove any selected tracks.
        static let removeTracks = Notification.Name("playQueue_removeTracks")
        static let removeAllTracks = Notification.Name("playQueue_removeAllTracks")
        static let refresh = Notification.Name("playQueue_refresh")
        
        // Commands the play queue to remove any selected tracks.
        static let exportAsPlaylistFile = Notification.Name("playQueue_exportAsPlaylistFile")
        
        // Commands the playlist to initiate playback of a selected item.
        static let playSelectedTrack = Notification.Name("playQueue_playSelectedTrack")
        
        // Context-menu action to play the selected track next.
        static let playNext = Notification.Name("playQueue_playNext")
        
        static let moveTracksUp = Notification.Name("playQueue_moveTracksUp")
        static let moveTracksDown = Notification.Name("playQueue_moveTracksDown")
        static let moveTracksToTop = Notification.Name("playQueue_moveTracksToTop")
        static let moveTracksToBottom = Notification.Name("playQueue_moveTracksToBottom")
        
        // Commands the currently displayed Play Queue view to select all its items.
        static let selectAllTracks = Notification.Name("playQueue_selectAllTracks")
        static let clearSelection = Notification.Name("playQueue_clearSelection")
        static let cropSelection = Notification.Name("playQueue_cropSelection")
        static let invertSelection = Notification.Name("playQueue_invertSelection")
        
        // Commands the playQueue to scroll to the top of its list view.
        static let scrollToTop = Notification.Name("playQueue_scrollToTop")
        
        // Commands the playQueue to scroll to the bottom of its list view.
        static let scrollToBottom = Notification.Name("playQueue_scrollToBottom")
        
        // Commands the playQueue to scroll one page up within its list view.
        static let pageUp = Notification.Name("playQueue_pageUp")
        
        // Commands the playQueue to scroll one page down within its list view.
        static let pageDown = Notification.Name("playQueue_pageDown")
        
        static let search = Notification.Name("playQueue_search")
        
        static let searchSettingsUpdated = Notification.Name("playQueue_searchSettingsUpdated")
    }
}
