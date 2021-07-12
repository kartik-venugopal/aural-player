//
//  PlaylistNotifications.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

extension Notification.Name {
    
    // MARK: Notifications published by the playlist.

    // Signifies that the playlist has begun adding a set of tracks.
    static let playlist_startedAddingTracks = Notification.Name("playlist_startedAddingTracks")
    
    // Signifies that the playlist has finished adding a set of tracks.
    static let playlist_doneAddingTracks = Notification.Name("playlist_doneAddingTracks")
    
    // Signifies that some chosen tracks could not be added to the playlist (i.e. an error condition).
    static let playlist_tracksNotAdded = Notification.Name("playlist_tracksNotAdded")
    
    // Signifies that the playlist view/tab has changed (tracks / artist / albums / genres).
    static let playlist_viewChanged = Notification.Name("playlist_viewChanged")
    
    // Signifies that, within the search dialog, the search query text has changed.
    static let playlist_searchTextChanged = Notification.Name("playlist_searchTextChanged")
    
    // Signifies that a new track has been added to the playlist.
    static let playlist_trackAdded = Notification.Name("playlist_trackAdded")
    
    // Signifies that some tracks have been removed from the playlist.
    static let playlist_tracksRemoved = Notification.Name("playlist_tracksRemoved")
    
    // MARK: Playlist commands

    // Commands a playlist to refresh its list view (eg. in response to tracks being added/removed/updated).
    static let playlist_refresh = Notification.Name("playlist_refresh")

    // Invokes the file dialog to add tracks to the playlist
    static let playlist_addTracks = Notification.Name("playlist_addTracks")

    // Commands the playlist to remove any selected tracks selected in the current playlist view.
    static let playlist_removeTracks = Notification.Name("playlist_removeTracks")

    // Commands the playlist to save the tracks in the playlist to a file
    static let playlist_savePlaylist = Notification.Name("playlist_savePlaylist")

    // Command to clear the playlist of all tracks
    static let playlist_clearPlaylist = Notification.Name("playlist_clearPlaylist")
    
    // Commands the playlist to initiate playback of a selected item.
    static let playlist_playSelectedItem = Notification.Name("playlist_playSelectedItem")

    // Commands the playlist to move selected tracks up one row.
    static let playlist_moveTracksUp = Notification.Name("playlist_moveTracksUp")

    // Commands the playlist to move selected tracks to the top.
    static let playlist_moveTracksToTop = Notification.Name("playlist_moveTracksToTop")

    // Commands the playlist to move selected tracks down one row.
    static let playlist_moveTracksDown = Notification.Name("playlist_moveTracksDown")

    // Commands the playlist to move selected tracks to the bottom.
    static let playlist_moveTracksToBottom = Notification.Name("playlist_moveTracksToBottom")
    
    // Commands the playlist to clear its current selection.
    static let playlist_clearSelection = Notification.Name("playlist_clearSelection")

    // Commands the playlist to invert its current selection.
    static let playlist_invertSelection = Notification.Name("playlist_invertSelection")

    // Commands the playlist to crop the current selection. i.e. only selected tracks will
    // remain, with all other tracks being removed.
    static let playlist_cropSelection = Notification.Name("playlist_cropSelection")
    
    // Commands the playlist to expand all selected groups to reveal their children (i.e. tracks)
    static let playlist_expandSelectedGroups = Notification.Name("playlist_expandSelectedGroups")

    // Commands the playlist to collapse all selected groups to hide their children (i.e. tracks)
    static let playlist_collapseSelectedItems = Notification.Name("playlist_collapseSelectedItems")

    // Commands the playlist to expand all groups to reveal their children (i.e. tracks)
    static let playlist_expandAllGroups = Notification.Name("playlist_expandAllGroups")

    // Commands the playlist to collapse all groups to hide their children (i.e. tracks)
    static let playlist_collapseAllGroups = Notification.Name("playlist_collapseAllGroups")
    
    // Commands the playlist to reveal (i.e. scroll to and select) the currently playing track.
    static let playlist_showPlayingTrack = Notification.Name("playlist_showPlayingTrack")

    // Commands the playlist to reveal the currently playing track in Finder.
    static let playlist_showTrackInFinder = Notification.Name("playlist_showTrackInFinder")
    
    // Commands the playlist to scroll to the top of its list view.
    static let playlist_scrollToTop = Notification.Name("playlist_scrollToTop")

    // Commands the playlist to scroll to the bottom of its list view.
    static let playlist_scrollToBottom = Notification.Name("playlist_scrollToBottom")

    // Commands the playlist to scroll one page up within its list view.
    static let playlist_pageUp = Notification.Name("playlist_pageUp")

    // Commands the playlist to scroll one page down within its list view.
    static let playlist_pageDown = Notification.Name("playlist_pageDown")
    
    // Commands the playlist to switch to the previous playlist view (in the tab group)
    static let playlist_previousView = Notification.Name("playlist_previousView")

    // Commands the playlist to switch to the next playlist view (in the tab group)
    static let playlist_nextView = Notification.Name("playlist_nextView")
    
    // Commands the playlist to show the chapters list window for the currently playing track
    static let playlist_viewChaptersList = Notification.Name("playlist_viewChaptersList")
    
    // Commands the playlist to invoke the search dialog
    static let playlist_search = Notification.Name("playlist_search")

    // Commands the playlist to invoke the sort dialog
    static let playlist_sort = Notification.Name("playlist_sort")
    
    // Commands the playlist to select a specific search result within the current list view.
    static let playlist_selectSearchResult = Notification.Name("playlist_selectSearchResult")

    // ----------------------------------------------------------------------------------------
    
    // MARK: Chapters List commands
    
    // Commands the chapters list to initiate playback of the selected chapter
    static let chaptersList_playSelectedChapter = Notification.Name("chaptersList_playSelectedChapter")
    
    // MARK: Color scheme commands sent to the playlist UI
    
    // Commands all playlist views to change the color of the text in their track name column.
    static let playlist_changeTrackNameTextColor = Notification.Name("playlist_changeTrackNameTextColor")

    // Commands all playlist views to change the color of the text in their group name column.
    static let playlist_changeGroupNameTextColor = Notification.Name("playlist_changeGroupNameTextColor")

    // Commands all playlist views to change the color of the text in their index/duration columns.
    static let playlist_changeIndexDurationTextColor = Notification.Name("playlist_changeIndexDurationTextColor")

    // Commands all playlist views to change the color of the text in selected rows, in the track name column.
    static let playlist_changeTrackNameSelectedTextColor = Notification.Name("playlist_changeTrackNameSelectedTextColor")

    // Commands all playlist views to change the color of the text in selected rows, in the group name column.
    static let playlist_changeGroupNameSelectedTextColor = Notification.Name("playlist_changeGroupNameSelectedTextColor")

    // Commands all playlist views to change the color of the text in selected rows, in the index/duration columns.
    static let playlist_changeIndexDurationSelectedTextColor = Notification.Name("playlist_changeIndexDurationSelectedTextColor")

    // Commands all playlist views to change the color of their summary info text.
    static let playlist_changeSummaryInfoColor = Notification.Name("playlist_changeSummaryInfoColor")

    // Commands all playlist views to change the color of their group icons.
    static let playlist_changeGroupIconColor = Notification.Name("playlist_changeGroupIconColor")
    
    // Commands all playlist views to change the color of their group disclosure triangles.
    static let playlist_changeGroupDisclosureTriangleColor = Notification.Name("playlist_changeGroupDisclosureTriangleColor")
    
    // Commands all playlist views to change the color of their selection boxes.
    static let playlist_changeSelectionBoxColor = Notification.Name("playlist_changeSelectionBoxColor")

    // Commands all playlist views to change the color of their playing track marker icons.
    static let playlist_changePlayingTrackIconColor = Notification.Name("playlist_changePlayingTrackIconColor")
}
