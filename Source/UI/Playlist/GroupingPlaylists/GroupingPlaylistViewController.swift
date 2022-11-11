//
//  GroupingPlaylistViewController.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Base view controller for the hierarchical/grouping ("Artists", "Albums", and "Genres") playlist views
 */
class GroupingPlaylistViewController: NSViewController, Destroyable {
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet weak var playlistView: AuralPlaylistOutlineView!
    
    let fontSchemesManager: FontSchemesManager = objectGraph.fontSchemesManager
    let colorSchemesManager: ColorSchemesManager = objectGraph.colorSchemesManager
    
    var contextMenu: NSMenu! {
        
        didSet {
            playlistView.menu = contextMenu
        }
    }
    
    // Delegate that relays CRUD actions to the playlist
    let playlist: PlaylistDelegateProtocol = objectGraph.playlistDelegate
    
    // Delegate that retrieves current playback info
    let playbackInfo: PlaybackInfoDelegateProtocol = objectGraph.playbackInfoDelegate
    
    private let preferences: PlaylistPreferences = objectGraph.preferences.playlistPreferences
    
    private lazy var messenger = Messenger(for: self)
    
    // Intended to be overriden by subclasses
    
    // Indicates the type of each parent group in this playlist view
    var groupType: GroupType {.artist}
    
    // Indicates the type of playlist this view displays
    var playlistType: PlaylistType {.artists}
    
    private lazy var uiState: PlaylistUIState = objectGraph.playlistUIState
    
    override func viewDidLoad() {
        
        initSubscriptions()
        
        doApplyColorScheme(colorSchemesManager.systemScheme, false)
        
        if uiState.currentView == self.playlistType, preferences.showNewTrackInPlaylist {
            showPlayingTrack()
        }
    }
    
    private func initSubscriptions() {
        
        messenger.subscribeAsync(to: .playlist_trackAdded, handler: trackAdded(_:))
        messenger.subscribeAsync(to: .playlist_tracksRemoved, handler: tracksRemoved(_:))
        messenger.subscribeAsync(to: .playlist_doneAddingTracks, handler: doneAddingTracks(_:), filter: {(needToRefresh: Bool) in needToRefresh})
        
        messenger.subscribeAsync(to: .player_trackTransitioned, handler: trackTransitioned(_:))
        messenger.subscribeAsync(to: .player_trackNotPlayed, handler: trackNotPlayed(_:))
        
        // Don't bother responding if only album art was updated
        messenger.subscribeAsync(to: .player_trackInfoUpdated, handler: trackInfoUpdated(_:),
                                 filter: {msg in msg.updatedFields.contains(.duration)})
        
        // MARK: Command handling -------------------------------------------------------------------------------------------------
        
        let viewSelectionFilter: (PlaylistViewSelector) -> Bool = {selector in selector.contains(PlaylistViewSelector.selector(forView: self.playlistType))}
        
        messenger.subscribe(to: .playlist_selectSearchResult, handler: selectSearchResult(_:),
                            filter: {cmd in viewSelectionFilter(cmd.viewSelector)})
        
        messenger.subscribe(to: .playlist_refresh, handler: playlistView.reloadData, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_removeTracks, handler: removeTracks, filter: viewSelectionFilter)
        
        messenger.subscribe(to: .playlist_moveTracksUp, handler: moveTracksUp, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_moveTracksDown, handler: moveTracksDown, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_moveTracksToTop, handler: moveTracksToTop, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_moveTracksToBottom, handler: moveTracksToBottom, filter: viewSelectionFilter)
        
        messenger.subscribe(to: .playlist_clearSelection, handler: playlistView.clearSelection, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_invertSelection, handler: invertSelection, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_cropSelection, handler: cropSelection, filter: viewSelectionFilter)
        
        messenger.subscribe(to: .playlist_scrollToTop, handler: playlistView.scrollToTop, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_scrollToBottom, handler: playlistView.scrollToBottom, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_pageUp, handler: playlistView.pageUp, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_pageDown, handler: playlistView.pageDown, filter: viewSelectionFilter)
        
        messenger.subscribe(to: .playlist_expandSelectedGroups, handler: expandSelectedGroups, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_collapseSelectedItems, handler: collapseSelectedItems, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_expandAllGroups, handler: expandAllGroups, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_collapseAllGroups, handler: collapseAllGroups, filter: viewSelectionFilter)
        
        messenger.subscribe(to: .playlist_showPlayingTrack, handler: showPlayingTrack, filter: viewSelectionFilter)
        messenger.subscribe(to: .playlist_showTrackInFinder, handler: showTrackInFinder, filter: viewSelectionFilter)
        
        messenger.subscribe(to: .playlist_playSelectedItem, handler: playSelectedItem, filter: viewSelectionFilter)
        
        messenger.subscribe(to: .applyTheme, handler: applyTheme)
        messenger.subscribe(to: .applyFontScheme, handler: applyFontScheme(_:))
        messenger.subscribe(to: .applyColorScheme, handler: applyColorScheme(_:))
        messenger.subscribe(to: .changeBackgroundColor, handler: changeBackgroundColor(_:))
        
        messenger.subscribe(to: .playlist_changeTrackNameTextColor, handler: changeTrackNameTextColor(_:))
        messenger.subscribe(to: .playlist_changeIndexDurationTextColor, handler: changeDurationTextColor(_:))
        
        messenger.subscribe(to: .playlist_changeTrackNameSelectedTextColor, handler: changeTrackNameSelectedTextColor(_:))
        messenger.subscribe(to: .playlist_changeIndexDurationSelectedTextColor, handler: changeDurationSelectedTextColor(_:))
        
        messenger.subscribe(to: .playlist_changeGroupNameTextColor, handler: changeGroupNameTextColor(_:))
        messenger.subscribe(to: .playlist_changeGroupNameSelectedTextColor, handler: changeGroupNameSelectedTextColor(_:))
        
        messenger.subscribe(to: .playlist_changeGroupIconColor, handler: changeGroupIconColor(_:))
        
        messenger.subscribe(to: .playlist_changePlayingTrackIconColor, handler: changePlayingTrackIconColor(_:))
        messenger.subscribe(to: .playlist_changeSelectionBoxColor, handler: changeSelectionBoxColor(_:))
    }
    
    func destroy() {
        messenger.unsubscribeFromAll()
    }
    
    override func viewDidAppear() {
        
        // When this view appears, the playlist type (tab) has changed. Update state and notify observers.
        uiState.currentView = self.playlistType
        uiState.currentTableView = playlistView

        messenger.publish(.playlist_viewChanged, payload: self.playlistType)
    }
    
    private var selectedRows: IndexSet {playlistView.selectedRowIndexes}
    
    // Plays the track/group selected within the playlist, if there is one. If multiple items are selected, the first one will be chosen.
    @IBAction func playSelectedItemAction(_ sender: AnyObject) {
        playSelectedItem()
    }
    
    func playSelectedItem() {
        
        if let firstSelectedRow = selectedRows.min() {
            
            let item = playlistView.item(atRow: firstSelectedRow)
            
            if let track = item as? Track {
                messenger.publish(TrackPlaybackCommandNotification(track: track))
                
            } else if let group = item as? Group {
                messenger.publish(TrackPlaybackCommandNotification(group: group))
            }
        }
    }
    
    // Helper function that gathers all selected playlist items as tracks and groups
    private func collectSelectedTracksAndGroups() -> (tracks: [Track], groups: [Group]) {
        return doCollectTracksAndGroups(selectedRows)
    }
    
    private func doCollectTracksAndGroups(_ indexes: IndexSet) -> (tracks: [Track], groups: [Group]) {
        
        let tracks = indexes.compactMap {playlistView.item(atRow: $0) as? Track}
        let groups = indexes.compactMap {playlistView.item(atRow: $0) as? Group}
        
        return (tracks, groups)
    }
    
    private func removeTracks() {
        
        let tracksAndGroups = collectSelectedTracksAndGroups()
        let tracks = tracksAndGroups.tracks
        let groups = tracksAndGroups.groups
        
        if groups.isNonEmpty || tracks.isNonEmpty {
            playlist.removeTracksAndGroups(tracks, groups, groupType)
        }
    }
    
    // Selects (and shows) a certain track within the playlist view
    private func selectTrack(_ groupedTrack: GroupedTrack) {
        
        // Need to expand the parent group to make the child track visible
        playlistView.expandItem(groupedTrack.group)
        
        let trackRowIndex = playlistView.row(forItem: groupedTrack.track)

        playlistView.selectRow(trackRowIndex)
        playlistView.scrollRowToVisible(trackRowIndex)
    }
    
    // Refreshes the playlist view by rearranging the items that were moved
    private func removeAndInsertItems(_ results: ItemMoveResults, _ sortComparator:  @escaping (ItemMoveResult, ItemMoveResult) -> Bool) {
 
        for result in results.results.sorted(by: sortComparator) {
            
            if let trackMovedResult = result as? TrackMoveResult {
                
                playlistView.removeItems(at: IndexSet(integer: trackMovedResult.sourceIndex), inParent: trackMovedResult.parentGroup,
                                         withAnimation: trackMovedResult.movedUp ? .slideUp : .slideDown)
                
                playlistView.insertItems(at: IndexSet(integer: trackMovedResult.destinationIndex), inParent: trackMovedResult.parentGroup,
                                         withAnimation: trackMovedResult.movedUp ? .slideDown : .slideUp)
                
            } else if let groupMovedResult = result as? GroupMoveResult {
                
                playlistView.removeItems(at: IndexSet(integer: groupMovedResult.sourceIndex), inParent: nil,
                                         withAnimation: groupMovedResult.movedUp ? .slideUp : .slideDown)
                
                playlistView.insertItems(at: IndexSet(integer: groupMovedResult.destinationIndex), inParent: nil,
                                         withAnimation: groupMovedResult.movedUp ? .slideDown : .slideUp)
            }
        }
    }
    
    // Refreshes the playlist view by rearranging the items that were moved
    private func moveItems(_ results: ItemMoveResults, _ sortComparator:  @escaping (ItemMoveResult, ItemMoveResult) -> Bool) {
        
        for result in results.results.sorted(by: sortComparator) {
            
            if let trackMovedResult = result as? TrackMoveResult {
                
                playlistView.moveItem(at: trackMovedResult.sourceIndex, inParent: trackMovedResult.parentGroup,
                                      to: trackMovedResult.destinationIndex, inParent: trackMovedResult.parentGroup)
                
            } else if let groupMovedResult = result as? GroupMoveResult {
                
                playlistView.moveItem(at: groupMovedResult.sourceIndex, inParent: nil,
                                      to: groupMovedResult.destinationIndex, inParent: nil)
            }
        }
    }
    
    // Selects all the specified items within the playlist view
    private func selectAllItems(_ items: [PlaylistItem]) {
        
        // Determine the row indexes for the items
        let selIndexes: [Int] = items.map {playlistView.row(forItem: $0)}
        
        // Select the item indexes
        playlistView.selectRows(selIndexes)
    }
    
    private func moveTracksUp() {
        doMoveItems(playlist.moveTracksAndGroupsUp, ItemMoveResult.compareAscending, self.moveItems)
    }
    
    private func moveTracksDown() {
        doMoveItems(playlist.moveTracksAndGroupsDown, ItemMoveResult.compareDescending, self.moveItems)
    }
    
    private func moveTracksToTop() {
        doMoveItems(playlist.moveTracksAndGroupsToTop, ItemMoveResult.compareAscending, self.removeAndInsertItems)
    }
    
    private func moveTracksToBottom() {
        doMoveItems(playlist.moveTracksAndGroupsToBottom, ItemMoveResult.compareDescending, self.removeAndInsertItems)
    }
    
    private func doMoveItems(_ moveAction: @escaping ([Track], [Group], GroupType) -> ItemMoveResults,
                             _ sortComparator:  @escaping (ItemMoveResult, ItemMoveResult) -> Bool,
                             _ refreshAction: @escaping (ItemMoveResults, @escaping (ItemMoveResult, ItemMoveResult) -> Bool) -> Void) {
        
        let tracksAndGroups = collectSelectedTracksAndGroups()
        let tracks = tracksAndGroups.tracks
        let groups = tracksAndGroups.groups
        
        // Cannot move both tracks and groups
        if tracks.isNonEmpty && groups.isNonEmpty {return}
        
        // Move items within the playlist and refresh the playlist view
        let results = moveAction(tracks, groups, self.groupType)
        refreshAction(results, sortComparator)
        
        // Re-select all the items that were moved
        selectAllItems(groups + tracks)
        
        // Scroll to make the first selected row visible
        playlistView.scrollRowToVisible(playlistView.selectedRow)
    }
    
    private func invertSelection() {
        playlistView.selectRows(invertedSelection)
    }
    
    private func isItemSelected(_ item: Any) -> Bool {
        return playlistView.isRowSelected(playlistView.row(forItem: item))
    }
    
    private var invertedSelection: IndexSet {
        
        // First, collect groups that are collapsed (not expanded) and not selected.
        var inversionItems: [Any] = allGroups.filter {!playlistView.isItemExpanded($0) && !isItemSelected($0)}
        
        // For groups that are expanded but not selected, invert the selection of their tracks.
        for group in allGroups.filter({playlistView.isItemExpanded($0) && !isItemSelected($0)}) {
            
            // If all tracks in group are to be selected, just select the group instead.
            let unselectedTracks = group.tracks.filter {!isItemSelected($0)}
            inversionItems += unselectedTracks.count == group.tracks.count ? [group] : unselectedTracks
        }
        
        // Map items to rows
        return IndexSet(inversionItems.compactMap {playlistView.row(forItem: $0)}.filter {$0 >= 0})
    }
    
    private func cropSelection() {
        
        let rowsToDelete: IndexSet = invertedSelection
        playlistView.clearSelection()
        
        if rowsToDelete.count > 0 {
            
            let tracksAndGroups = doCollectTracksAndGroups(rowsToDelete)
            let tracks = tracksAndGroups.tracks
            let groups = tracksAndGroups.groups
            
            // If nothing selected, nothing to do
            if groups.isNonEmpty || tracks.isNonEmpty {
                playlist.removeTracksAndGroups(tracks, groups, groupType)
            }
        }
    }
    
    private func expandSelectedGroups() {
        
        let selectedGroups = selectedRows.compactMap {playlistView.item(atRow: $0) as? Group}
        selectedGroups.forEach {playlistView.expandItem($0)}
    }
    
    private func collapseSelectedItems() {
        
        let selectedTracksAndGroups = collectSelectedTracksAndGroups()
        
        let selectedGroups: [Group] = selectedTracksAndGroups.groups
        let selectedTracksParentGroups: [Group] = selectedTracksAndGroups.tracks.compactMap {playlistView.parent(forItem: $0) as? Group}
        
        let groupsToCollapse: Set<Group> = Set(selectedGroups + selectedTracksParentGroups)
        groupsToCollapse.forEach {playlistView.collapseItem($0, collapseChildren: false)}
        
        let indices = groupsToCollapse.map {playlistView.row(forItem: $0)}
        playlistView.selectRows(indices)
        playlistView.scrollRowToVisible(indices.min() ?? 0)
    }
    
    private func expandAllGroups() {
        playlistView.expandItem(nil, expandChildren: true)
    }
    
    private func collapseAllGroups() {
        playlistView.collapseItem(nil, collapseChildren: true)
    }
    
    // Selects the currently playing track, within the playlist view
    private func showPlayingTrack() {
        
        if let playingTrack = playbackInfo.playingTrack, let groupingInfo = playlist.groupingInfoForTrack(self.groupType, playingTrack) {
            selectTrack(groupingInfo)
        }
    }
 
    // Refreshes the playlist view in response to a new track being added to the playlist
    func trackAdded(_ notification: TrackAddedNotification) {
        
        if let grouping = notification.groupingInfo[self.groupType] {
            
            if grouping.groupCreated {
                
                // Insert the new group
                self.playlistView.insertItems(at: IndexSet(integer: grouping.track.groupIndex), inParent: nil, withAnimation: .effectFade)
                
            } else {
                
                // Insert the new track under its parent group, and reload the parent group
                let group = grouping.track.group
                
                self.playlistView.insertItems(at: IndexSet(integer: grouping.track.trackIndex), inParent: group, withAnimation: .effectGap)
                self.playlistView.reloadItem(group)
            }
        }
    }
    
    func doneAddingTracks(_ needToRefresh: Bool) {
        
        DispatchQueue.main.async {
            self.playlistView.reloadData()
        }
    }
    
    // Refreshes the playlist view in response to a track being updated with new information (e.g. duration)
    private func trackInfoUpdated(_ notification: TrackInfoUpdatedNotification) {
        
        let track = notification.updatedTrack
        
        if let groupInfo = playlist.groupingInfoForTrack(self.groupType, track) {
            
            // Reload the parent group (track duration affects group duration) and the track
            self.playlistView.reloadItem(groupInfo.group, reloadChildren: false)
            self.playlistView.reloadItem(groupInfo.track)
        }
    }
    
    // Refreshes the playlist view in response to tracks/groups being removed from the playlist
    private func tracksRemoved(_ results: TrackRemovalResults) {
        
        if uiState.currentView != self.playlistType {
            
            DispatchQueue.main.async {
                self.playlistView.reloadData()
            }
            
            return
        }
        
        if let removals = results.groupingPlaylistResults[self.groupType] {
            
            var groupsToReload = [Group]()
            
            for removal in removals.sorted(by: GroupedItemRemovalResult.compareDescending) {
                
                if let tracksRemoval = removal as? GroupedTracksRemovalResult {
                    
                    // Remove tracks from their parent group
                    playlistView.removeItems(at: tracksRemoval.trackIndexesInGroup, inParent: tracksRemoval.group, withAnimation: .effectFade)
                    
                    // Make note of the parent group for later
                    groupsToReload.append(tracksRemoval.group)
                    
                } else if let groupRemoval = removal as? GroupRemovalResult {
                    
                    // Remove group from the root
                    playlistView.removeItems(at: IndexSet(integer: groupRemoval.groupIndex), inParent: nil, withAnimation: .effectFade)
                }
            }
            
            // For all groups from which tracks were removed, reload them
            groupsToReload.forEach {playlistView.reloadItem($0)}
        }
    }
    
    func trackTransitioned(_ notification: TrackTransitionNotification) {

        // Reload the old/new track. If this is not done async, the row view could get garbled.
        // (because of other potential simultaneous updates - e.g. PlayingTrackInfoUpdated)
        DispatchQueue.main.async {
        
            for track in Set([notification.beginTrack, notification.endTrack]).compactMap({$0}) {
                self.playlistView.reloadItem(track)
            }
        }
        
        // Check if there is a new track, and change the selection accordingly.
        if uiState.currentView.toGroupType() == self.groupType && preferences.showNewTrackInPlaylist {
            notification.endTrack != nil ? showPlayingTrack() : playlistView.clearSelection()
        }
    }
    
    func trackNotPlayed(_ notification: TrackNotPlayedNotification) {
        
        let errTrack = notification.errorTrack
        
        // Reload the old/error track.
        for track in Set([notification.oldTrack, errTrack]).compactMap({$0}) {
            playlistView.reloadItem(track)
        }

        // Only need to do this if this playlist view is shown
        if uiState.currentView.toGroupType() == self.groupType,
           let groupingInfo = playlist.groupingInfoForTrack(self.groupType, errTrack) {

            selectTrack(groupingInfo)
        }
    }
    
    // Selects an item within the playlist view, to show a single search result
    func selectSearchResult(_ command: SelectSearchResultCommandNotification) {
        
        if let groupingInfo = command.searchResult.location.groupInfo {
            selectTrack(groupingInfo)
        }
    }
    
    private var selectedItem: Any? {playlistView.item(atRow: playlistView.selectedRow)}
    
    // Show the selected track in Finder
    private func showTrackInFinder() {
        
        // This is a safe typecast, because the context menu will prevent this function from being executed on groups. In other words, the selected item will always be a track.
        if let selTrack = selectedItem as? Track {
            selTrack.file.showInFinder()
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
        scrollView.drawsBackground = color.isOpaque
        
        clipView.backgroundColor = color
        clipView.drawsBackground = color.isOpaque
        
        playlistView.backgroundColor = color.isOpaque ? color : NSColor.clear
    }
    
    private var allGroups: [Group] {playlist.allGroups(self.groupType)}
    
    private func changeTrackNameTextColor(_ color: NSColor) {
        
        let trackRows = playlistView.allRowIndices.filteredIndexSet(includeInteger: {playlistView.item(atRow: $0) is Track})
        playlistView.reloadRows(trackRows, columns: [0])
    }
    
    private func changeGroupNameTextColor(_ color: NSColor) {
        allGroups.forEach {playlistView.reloadItem($0)}
    }
    
    private func changeDurationTextColor(_ color: NSColor) {
        playlistView.reloadAllRows(columns: [1])
    }
    
    private func changeTrackNameSelectedTextColor(_ color: NSColor) {
        
        let selectedTrackRows = selectedRows.filteredIndexSet(includeInteger: {playlistView.item(atRow: $0) is Track})
        playlistView.reloadRows(selectedTrackRows, columns: [0])
    }
    
    private func changeGroupNameSelectedTextColor(_ color: NSColor) {
        
        let selectedGroupRows = selectedRows.filteredIndexSet(includeInteger: {playlistView.item(atRow: $0) is Group})
        playlistView.reloadRows(selectedGroupRows, columns: [0])
    }
    
    private func changeDurationSelectedTextColor(_ color: NSColor) {
        playlistView.reloadRows(selectedRows, columns: [1])
    }
    
    private func changeSelectionBoxColor(_ color: NSColor) {
        playlistView.redoRowSelection()
    }
    
    private func changePlayingTrackIconColor(_ color: NSColor) {
        
        if let playingTrack = playbackInfo.playingTrack {
            playlistView.reloadItem(playingTrack)
        }
    }
    
    private func changeGroupIconColor(_ color: NSColor) {
        allGroups.forEach {playlistView.reloadItem($0)}
    }
}
