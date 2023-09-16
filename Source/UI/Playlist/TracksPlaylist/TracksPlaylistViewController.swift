//
//  TracksPlaylistViewController.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    View controller for the flat ("Tracks") playlist view
 */
class TracksPlaylistViewController: NSViewController, Destroyable {
    
    @IBOutlet weak var playlistView: NSTableView!
    
    lazy var playlistPreferences: PlaylistPreferences = objectGraph.preferences.playlistPreferences
    
    var contextMenu: NSMenu! {
        
        didSet {
            playlistView.menu = contextMenu
        }
    }
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    
    // Delegate that relays CRUD actions to the playlist
    let playlist: PlaylistDelegateProtocol = objectGraph.playlistDelegate
    
    // Delegate that retrieves current playback info
    let playbackInfo: PlaybackInfoDelegateProtocol = objectGraph.playbackInfoDelegate
    
    let fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    private let preferences: PlaylistPreferences = objectGraph.preferences.playlistPreferences
    
    override var nibName: String? {"Tracks"}
    
    private lazy var messenger = Messenger(for: self)
    
    private lazy var uiState: PlaylistUIState = objectGraph.playlistUIState
    
    override func viewDidLoad() {
        
        initSubscriptions()
        
        doApplyColorScheme(colorSchemesManager.systemScheme, false)
        
        if uiState.currentView == .tracks, preferences.showNewTrackInPlaylist {
            showPlayingTrack()
        }
    }
    
    private func initSubscriptions() {
        
        messenger.subscribeAsync(to: .playlist_trackAdded, handler: trackAdded(_:))
        messenger.subscribeAsync(to: .playlist_tracksRemoved, handler: tracksRemoved(_:))

        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribeAsync(to: .player_trackNotPlayed, handler: trackNotPlayed(_:))
        
        // Don't bother responding if only album art was updated
        messenger.subscribeAsync(to: .player_trackInfoUpdated, handler: trackInfoUpdated(_:),
                                 filter: {msg in msg.updatedFields.contains(.duration)})
        
        // MARK: Command handling -------------------------------------------------------------------------------------------------
        
        messenger.subscribe(to: .playlist_selectSearchResult, handler: selectSearchResult(_:),
                            filter: {cmd in cmd.viewSelector.contains(.tracks)})
        
        let viewSelectionFilter: (PlaylistViewSelector) -> Bool = {selector in selector.contains(.tracks)}
        
        messenger.subscribe(to: .playlist_refresh, handler: playlistView.reloadData, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_removeTracks, handler: removeTracks, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_cleared, handler: playlistCleared)
        
        messenger.subscribe(to: .playlist_moveTracksUp, handler: moveTracksUp, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_moveTracksDown, handler: moveTracksDown, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_moveTracksToTop, handler: moveTracksToTop, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_moveTracksToBottom, handler: moveTracksToBottom, filter: viewSelectionFilter)
        
        messenger.subscribe(to: .playlist_selectAllItems, handler: playlistView.selectAllItems, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_clearSelection, handler: playlistView.clearSelection, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_invertSelection, handler: playlistView.invertSelection, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_cropSelection, handler: cropSelection, filter: viewSelectionFilter)
        
        messenger.subscribe(to: .playlist_scrollToTop, handler: playlistView.scrollToTop, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_scrollToBottom, handler: playlistView.scrollToBottom, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_pageUp, handler: playlistView.pageUp, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_pageDown, handler: playlistView.pageDown, filter: viewSelectionFilter)
        
        messenger.subscribe(to: .playlist_showPlayingTrack, handler: showPlayingTrack, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_showTrackInFinder, handler: showTrackInFinder, filter: viewSelectionFilter)
        
        messenger.subscribe(to: .playlist_playSelectedItem, handler: playSelectedTrack, filter: viewSelectionFilter)
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)
        messenger.subscribe(to: .applyFontScheme, handler: applyFontScheme(_:))
        messenger.subscribe(to: .applyColorScheme, handler: applyColorScheme(_:))
        messenger.subscribe(to: .changeBackgroundColor, handler: changeBackgroundColor(_:))
        
        messenger.subscribe(to: .playlist_changeTrackNameTextColor, handler: changeTrackNameTextColor(_:))
        messenger.subscribe(to: .playlist_changeIndexDurationTextColor, handler: changeIndexDurationTextColor(_:))
        
        messenger.subscribe(to: .playlist_changeTrackNameSelectedTextColor, handler: changeTrackNameSelectedTextColor(_:))
        messenger.subscribe(to: .playlist_changeIndexDurationSelectedTextColor, handler: changeIndexDurationSelectedTextColor(_:))
        
        messenger.subscribe(to: .playlist_changePlayingTrackIconColor, handler: changePlayingTrackIconColor(_:))
        messenger.subscribe(to: .playlist_changeSelectionBoxColor, handler: changeSelectionBoxColor(_:))
    }
    
    func destroy() {
        messenger.unsubscribeFromAll()
    }
    
    private var selectedRows: IndexSet {playlistView.selectedRowIndexes}
    
    private var selectedRowCount: Int {playlistView.numberOfSelectedRows}
    
    private var rowCount: Int {playlistView.numberOfRows}
    
    private var lastRow: Int {rowCount - 1}
    
    override func viewDidAppear() {
        
        // When this view appears, the playlist type (tab) has changed. Update state and notify observers.
        uiState.currentView = .tracks
        uiState.currentTableView = playlistView
        
        messenger.publish(.playlist_viewChanged, payload: PlaylistType.tracks)
    }
    
    // Plays the track selected within the playlist, if there is one. If multiple tracks are selected, the first one will be chosen.
    @IBAction func playSelectedTrackAction(_ sender: AnyObject) {
        playSelectedTrack()
    }
    
    func playSelectedTrack() {
        
        if let firstSelectedRow = playlistView.selectedRowIndexes.min() {
            messenger.publish(TrackPlaybackCommandNotification(index: firstSelectedRow))
        }
    }
    
    private func removeTracks() {
        
        if selectedRowCount > 0 {
            
            playlist.removeTracks(selectedRows)
            playlistView.clearSelection()
        }
    }
    
    // Selects (and shows) a certain track within the playlist view
    private func selectTrack(_ index: Int) {
        
        if index >= 0 && index < rowCount {
            
            playlistView.selectRow(index)
            playlistView.scrollRowToVisible(index)
        }
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    private func moveTracksUp() {

        guard rowCount > 1 && (1..<rowCount).contains(selectedRowCount) else {return}
        
        if let results = playlist.moveTracksUp(selectedRows).results as? [TrackMoveResult] {
            
            moveAndReloadItems(results.sorted(by: TrackMoveResult.compareAscending))
            
            if let minRow = selectedRows.min() {
                playlistView.scrollRowToVisible(minRow)
            }
        }
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    private func moveTracksDown() {
        
        guard rowCount > 1 && (1..<rowCount).contains(selectedRowCount) else {return}
        
        if let results = playlist.moveTracksDown(selectedRows).results as? [TrackMoveResult] {
            
            moveAndReloadItems(results.sorted(by: TrackMoveResult.compareDescending))
            
            if let minRow = selectedRows.min() {
                playlistView.scrollRowToVisible(minRow)
            }
        }
    }
    
    // Rearranges tracks within the view that have been reordered
    private func moveAndReloadItems(_ results: [TrackMoveResult]) {
        
        for result in results {
            
            playlistView.moveRow(at: result.sourceIndex, to: result.destinationIndex)
            playlistView.reloadRows([result.sourceIndex, result.destinationIndex])
        }
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    private func moveTracksToTop() {
        
        let selectedRows = self.selectedRows
        let selectedRowCount = self.selectedRowCount
        
        guard rowCount > 1 && (1..<rowCount).contains(selectedRowCount) else {return}
        
        if let results = playlist.moveTracksToTop(selectedRows).results as? [TrackMoveResult] {
            
            // Move the rows
            removeAndInsertItems(results.sorted(by: TrackMoveResult.compareAscending))
            
            // Refresh the relevant rows
            guard let maxSelectedRow = selectedRows.max() else {return}
            
            playlistView.reloadRows(0...maxSelectedRow)
            
            // Select all the same rows but now at the top
            playlistView.scrollToTop()
            playlistView.selectRows(0..<selectedRowCount)
        }
    }
    
    // Must have a non-empty playlist, and at least one selected row, but not all rows selected.
    private func moveTracksToBottom() {
        
        let selectedRows = self.selectedRows
        let selectedRowCount = self.selectedRowCount
        
        guard rowCount > 1 && (1..<rowCount).contains(selectedRowCount) else {return}
        
        if let results = playlist.moveTracksToBottom(selectedRows).results as? [TrackMoveResult] {

            // Move the rows
            removeAndInsertItems(results.sorted(by: TrackMoveResult.compareDescending))
            
            guard let minSelectedRow = selectedRows.min() else {return}
            
            let lastRow = self.lastRow

            // Refresh the relevant rows
            playlistView.reloadRows(minSelectedRow...lastRow)
            
            // Select all the same items but now at the bottom
            let firstSelectedRow = lastRow - selectedRowCount + 1
            playlistView.selectRows(firstSelectedRow...lastRow)
            playlistView.scrollToBottom()
        }
    }
    
    // Refreshes the playlist view by rearranging the items that were moved
    private func removeAndInsertItems(_ results: [TrackMoveResult]) {
        
        for result in results {
            
            playlistView.removeRows(at: IndexSet(integer: result.sourceIndex), withAnimation: result.movedUp ? .slideUp : .slideDown)
            playlistView.insertRows(at: IndexSet(integer: result.destinationIndex), withAnimation: result.movedUp ? .slideDown : .slideUp)
        }
    }
    
    // Shows the currently playing track, within the playlist view
    private func showPlayingTrack() {
        
        if let playingTrack = playbackInfo.playingTrack, let playingTrackIndex = playlist.indexOfTrack(playingTrack) {
            selectTrack(playingTrackIndex)
        }
    }
    
    func trackAdded(_ notification: TrackAddedNotification) {
        self.playlistView.insertRows(at: IndexSet(integer: notification.trackIndex), withAnimation: .slideDown)
    }
    
    private func trackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
        
        DispatchQueue.main.async {
            
            if let updatedTrackIndex = self.playlist.indexOfTrack(notification.updatedTrack) {
                self.playlistView.reloadRows([updatedTrackIndex])
            }
        }
    }
    
    private func tracksRemoved(_ results: TrackRemovalResults) {
        
        let indexes = results.flatPlaylistResults
        guard !indexes.isEmpty else {return}
        
        // Tell the playlist view that the number of rows has changed (should result in removal of rows)
        playlistView.noteNumberOfRowsChanged()
        
        // Update all rows from the first (i.e. smallest index) removed row, down to the end of the playlist
        guard let firstRemovedRow = indexes.min() else {return}
        
        let lastPlaylistRowAfterRemove = playlist.size - 1
        
        // This will be true unless a contiguous block of tracks was removed from the bottom of the playlist.
        if firstRemovedRow <= lastPlaylistRowAfterRemove {
            playlistView.reloadRows(firstRemovedRow...lastPlaylistRowAfterRemove)
        }
    }
    
    private func playlistCleared() {
        playlistView.reloadData()
    }
    
    private func trackTransitioned(_ notification: TrackTransitionNotification) {
        
        let refreshIndexes: IndexSet = IndexSet(Set([notification.beginTrack, notification.endTrack].compactMap {$0}).compactMap {playlist.indexOfTrack($0)})
        let needToShowTrack: Bool = uiState.currentView == .tracks && preferences.showNewTrackInPlaylist

        if let newTrack = notification.endTrack {
            
            if needToShowTrack {

                if let newTrackIndex = playlist.indexOfTrack(newTrack), newTrackIndex >= playlistView.numberOfRows {

                    // This means the track is in the playlist but has not yet been added to the playlist view (Bookmark/Recently played/Favorite item), and will be added shortly (this is a race condition). So, dispatch an async delayed handler to show the track in the playlist, after it is expected to be added.
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
                        self.showPlayingTrack()
                    })

                } else {
                    showPlayingTrack()
                }
            }

        } else if needToShowTrack {
            playlistView.clearSelection()
        }

        // If this is not done async, the row view could get garbled.
        // (because of other potential simultaneous updates - e.g. PlayingTrackInfoUpdated)
        DispatchQueue.main.async {
            self.playlistView.reloadRows(refreshIndexes)
        }
    }
    
    func trackNotPlayed(_ notification: TrackNotPlayedNotification) {
        
        let errTrack = notification.errorTrack
        
        let refreshIndexes: IndexSet = IndexSet(Set([notification.oldTrack, errTrack].compactMap {$0}).compactMap {playlist.indexOfTrack($0)})

        if let errTrackIndex = playlist.indexOfTrack(errTrack), uiState.currentView == .tracks {
            selectTrack(errTrackIndex)
        }

        playlistView.reloadRows(refreshIndexes)
    }
    
    // Selects an item within the playlist view, to show a single search result
    func selectSearchResult(_ command: SelectSearchResultCommandNotification) {
        
        if let trackIndex = command.searchResult.location.trackIndex {
            selectTrack(trackIndex)
        }
    }
    
    // Show the selected track in Finder
    private func showTrackInFinder() {
        
        if let selTrack = playlist.trackAtIndex(playlistView.selectedRow) {
            selTrack.file.showInFinder()
        }
    }
    
    private func cropSelection() {
        
        let tracksToDelete: IndexSet = playlistView.invertedSelection
        
        if tracksToDelete.count > 0 {
            
            playlist.removeTracks(tracksToDelete)
            playlistView.reloadData()
        }
    }
    
    private func applyTheme() {
        
        applyFontScheme(fontSchemesManager.systemScheme)
        applyColorScheme(colorSchemesManager.systemScheme)
    }
    
    private func applyFontScheme(_ fontScheme: FontScheme) {
        playlistView.reloadDataMaintainingSelection()
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        doApplyColorScheme(scheme)
    }
    
    private func doApplyColorScheme(_ scheme: ColorScheme, _ mustReloadRows: Bool = true) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        
        if mustReloadRows {
            playlistView.reloadDataMaintainingSelection()
        }
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        scrollView.backgroundColor = color
        clipView.backgroundColor = color
        playlistView.backgroundColor = color
    }
    
    private func changeTrackNameTextColor(_ color: NSColor) {
        playlistView.reloadAllRows(columns: [1])
    }
    
    private func changeIndexDurationTextColor(_ color: NSColor) {
        playlistView.reloadAllRows(columns: [0, 2])
    }
    
    private func changeTrackNameSelectedTextColor(_ color: NSColor) {
        playlistView.reloadRows(selectedRows, columns: [1])
    }
    
    private func changeIndexDurationSelectedTextColor(_ color: NSColor) {
        playlistView.reloadRows(selectedRows, columns: [0, 2])
    }
    
    private func changeSelectionBoxColor(_ color: NSColor) {
        playlistView.redoRowSelection()
    }
    
    private func changePlayingTrackIconColor(_ color: NSColor) {
        
        if let playingTrack = self.playbackInfo.playingTrack,
           let playingTrackIndex = self.playlist.indexOfTrack(playingTrack) {
            
            playlistView.reloadRows([playingTrackIndex], columns: [0])
        }
    }
}
