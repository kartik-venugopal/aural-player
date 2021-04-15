import Cocoa

/*
    Base view controller for the hierarchical/grouping ("Artists", "Albums", and "Genres") playlist views
 */
class GroupingPlaylistViewController: NSViewController, NotificationSubscriber {
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet weak var playlistView: AuralPlaylistOutlineView!
    @IBOutlet weak var playlistViewDelegate: GroupingPlaylistViewDelegate!
    
    private lazy var contextMenu: NSMenu! = WindowFactory.playlistContextMenu
    
    // Delegate that relays CRUD actions to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private let preferences: PlaylistPreferences = ObjectGraph.preferencesDelegate.preferences.playlistPreferences
    
    // Intended to be overriden by subclasses
    
    // Indicates the type of each parent group in this playlist view
    internal var groupType: GroupType {return .artist}
    
    // Indicates the type of playlist this view displays
    internal var playlistType: PlaylistType {return .artists}
    
    override func viewDidLoad() {
        
        // Enable drag n drop
        playlistView.enableDragDrop()
        playlistView.menu = contextMenu
        
        initSubscriptions()
        
        doApplyColorScheme(ColorSchemes.systemScheme, false)
    }
    
    private func initSubscriptions() {
        
        Messenger.subscribeAsync(self, .playlist_trackAdded, self.trackAdded(_:), queue: .main)
        Messenger.subscribeAsync(self, .playlist_tracksRemoved, self.tracksRemoved(_:), queue: .main)
        Messenger.subscribeAsync(self, .playlist_doneAddingTracks, self.doneAddingTracks(_:), filter: {(needToRefresh: Bool) in needToRefresh}, queue: .main)
        
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.trackTransitioned(_:), queue: .main)
        Messenger.subscribeAsync(self, .player_trackNotPlayed, self.trackNotPlayed(_:), queue: .main)
        
        // Don't bother responding if only album art was updated
        Messenger.subscribeAsync(self, .player_trackInfoUpdated, self.trackInfoUpdated(_:),
                                 filter: {msg in msg.updatedFields.contains(.duration) || msg.updatedFields.contains(.displayInfo)},
                                 queue: .main)
        
        // MARK: Command handling -------------------------------------------------------------------------------------------------
        
        Messenger.subscribe(self, .playlist_selectSearchResult, self.selectSearchResult(_:),
                            filter: {cmd in cmd.viewSelector.includes(self.playlistType)})
        
        let viewSelectionFilter: (PlaylistViewSelector) -> Bool = {selector in selector.includes(self.playlistType)}
        
        Messenger.subscribe(self, .playlist_refresh, {(PlaylistViewSelector) in self.refresh()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_removeTracks, {(PlaylistViewSelector) in self.removeTracks()}, filter: viewSelectionFilter)
        
        Messenger.subscribe(self, .playlist_moveTracksUp, {(PlaylistViewSelector) in self.moveTracksUp()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_moveTracksDown, {(PlaylistViewSelector) in self.moveTracksDown()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_moveTracksToTop, {(PlaylistViewSelector) in self.moveTracksToTop()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_moveTracksToBottom, {(PlaylistViewSelector) in self.moveTracksToBottom()}, filter: viewSelectionFilter)
        
        Messenger.subscribe(self, .playlist_clearSelection, {(PlaylistViewSelector) in self.clearSelection()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_invertSelection, {(PlaylistViewSelector) in self.invertSelection()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_cropSelection, {(PlaylistViewSelector) in self.cropSelection()}, filter: viewSelectionFilter)
        
        Messenger.subscribe(self, .playlist_scrollToTop, {(PlaylistViewSelector) in self.scrollToTop()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_scrollToBottom, {(PlaylistViewSelector) in self.scrollToBottom()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_pageUp, {(PlaylistViewSelector) in self.pageUp()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_pageDown, {(PlaylistViewSelector) in self.pageDown()}, filter: viewSelectionFilter)
        
        Messenger.subscribe(self, .playlist_expandSelectedGroups, {(PlaylistViewSelector) in self.expandSelectedGroups()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_collapseSelectedItems, {(PlaylistViewSelector) in self.collapseSelectedItems()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_expandAllGroups, {(PlaylistViewSelector) in self.expandAllGroups()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_collapseAllGroups, {(PlaylistViewSelector) in self.collapseAllGroups()}, filter: viewSelectionFilter)
        
        Messenger.subscribe(self, .playlist_showPlayingTrack, {(PlaylistViewSelector) in self.showPlayingTrack()}, filter: viewSelectionFilter)
        Messenger.subscribe(self, .playlist_showTrackInFinder, {(PlaylistViewSelector) in self.showTrackInFinder()}, filter: viewSelectionFilter)
        
        Messenger.subscribe(self, .playlist_playSelectedItem, {(PlaylistViewSelector) in self.playSelectedItem()}, filter: viewSelectionFilter)
        
        Messenger.subscribe(self, .applyFontScheme, self.applyFontScheme(_:))
        Messenger.subscribe(self, .applyColorScheme, self.applyColorScheme(_:))
        Messenger.subscribe(self, .changeBackgroundColor, self.changeBackgroundColor(_:))
        
        Messenger.subscribe(self, .playlist_changeTrackNameTextColor, self.changeTrackNameTextColor(_:))
        Messenger.subscribe(self, .playlist_changeIndexDurationTextColor, self.changeDurationTextColor(_:))
        
        Messenger.subscribe(self, .playlist_changeTrackNameSelectedTextColor, self.changeTrackNameSelectedTextColor(_:))
        Messenger.subscribe(self, .playlist_changeIndexDurationSelectedTextColor, self.changeDurationSelectedTextColor(_:))
        
        Messenger.subscribe(self, .playlist_changeGroupNameTextColor, self.changeGroupNameTextColor(_:))
        Messenger.subscribe(self, .playlist_changeGroupNameSelectedTextColor, self.changeGroupNameSelectedTextColor(_:))
        
        Messenger.subscribe(self, .playlist_changeGroupIconColor, self.changeGroupIconColor(_:))
        
        Messenger.subscribe(self, .playlist_changePlayingTrackIconColor, self.changePlayingTrackIconColor(_:))
        Messenger.subscribe(self, .playlist_changeSelectionBoxColor, self.changeSelectionBoxColor(_:))
    }
    
    override func viewDidAppear() {
        
        // When this view appears, the playlist type (tab) has changed. Update state and notify observers.
        PlaylistViewState.current = self.playlistType
        PlaylistViewState.currentView = playlistView

        Messenger.publish(.playlist_viewChanged, payload: self.playlistType)
    }
    
    private var selectedRows: IndexSet {playlistView.selectedRowIndexes}
    
    private var atLeastOneRow: Bool {playlistView.numberOfRows > 0}
    
    private var lastRow: Int {playlistView.numberOfRows - 1}
    
    // Plays the track/group selected within the playlist, if there is one. If multiple items are selected, the first one will be chosen.
    @IBAction func playSelectedItemAction(_ sender: AnyObject) {
        playSelectedItem()
    }
    
    func playSelectedItem() {
        
        if let firstSelectedRow = selectedRows.min() {
            
            let item = playlistView.item(atRow: firstSelectedRow)
            
            if let track = item as? Track {
                Messenger.publish(TrackPlaybackCommandNotification(track: track))
                
            } else if let group = item as? Group {
                Messenger.publish(TrackPlaybackCommandNotification(group: group))
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

        playlistView.selectRowIndexes(IndexSet(integer: trackRowIndex), byExtendingSelection: false)
        playlistView.scrollRowToVisible(trackRowIndex)
    }
    
    func refresh() {
        self.playlistView.reloadData()
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
        let selIndexes: [Int] = items.map { playlistView.row(forItem: $0) }
        
        // Select the item indexes
        playlistView.selectRowIndexes(IndexSet(selIndexes), byExtendingSelection: false)
    }
    
    private func moveTracksUp() {
        doMoveItems(playlist.moveTracksAndGroupsUp, ItemMoveResultComparators.compareAscending, self.moveItems)
    }
    
    private func moveTracksDown() {
        doMoveItems(playlist.moveTracksAndGroupsDown, ItemMoveResultComparators.compareDescending, self.moveItems)
    }
    
    private func moveTracksToTop() {
        doMoveItems(playlist.moveTracksAndGroupsToTop, ItemMoveResultComparators.compareAscending, self.removeAndInsertItems)
    }
    
    private func moveTracksToBottom() {
        doMoveItems(playlist.moveTracksAndGroupsToBottom, ItemMoveResultComparators.compareDescending, self.removeAndInsertItems)
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
        playlistView.selectRowIndexes(invertedSelection, byExtendingSelection: false)
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
    
    private func clearSelection() {
        playlistView.selectRowIndexes(IndexSet(), byExtendingSelection: false)
    }
    
    private func cropSelection() {
        
        let rowsToDelete: IndexSet = invertedSelection
        clearSelection()
        
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
        selectedGroups.forEach({playlistView.expandItem($0)})
    }
    
    private func collapseSelectedItems() {
        
        let selectedTracksAndGroups = collectSelectedTracksAndGroups()
        
        let selectedGroups: [Group] = selectedTracksAndGroups.groups
        let selectedTracksParentGroups: [Group] = selectedTracksAndGroups.tracks.compactMap {playlistView.parent(forItem: $0) as? Group}
        
        let groupsToCollapse: Set<Group> = Set(selectedGroups + selectedTracksParentGroups)
        groupsToCollapse.forEach({playlistView.collapseItem($0, collapseChildren: false)})
        
        let indices = IndexSet(groupsToCollapse.map {playlistView.row(forItem: $0)})
        playlistView.selectRowIndexes(indices, byExtendingSelection: false)
        playlistView.scrollRowToVisible(indices.min() ?? 0)
    }
    
    private func expandAllGroups() {
        playlistView.expandItem(nil, expandChildren: true)
    }
    
    private func collapseAllGroups() {
        playlistView.collapseItem(nil, collapseChildren: true)
    }
    
    // Scrolls the playlist view to the very top
    private func scrollToTop() {
        
        if atLeastOneRow {
            playlistView.scrollRowToVisible(0)
        }
    }
    
    // Scrolls the playlist view to the very bottom
    private func scrollToBottom() {
        
        if atLeastOneRow {
            playlistView.scrollRowToVisible(lastRow)
        }
    }
    
    private func pageUp() {
        playlistView.pageUp()
    }
    
    private func pageDown() {
        playlistView.pageDown()
    }
    
    // Selects the currently playing track, within the playlist view
    private func showPlayingTrack() {
        
        if let playingTrack = playbackInfo.currentTrack, let groupingInfo = playlist.groupingInfoForTrack(self.groupType, playingTrack) {
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
        
        if PlaylistViewState.current != self.playlistType {
            
            DispatchQueue.main.async {
                self.playlistView.reloadData()
            }
            
            return
        }
        
        if let removals = results.groupingPlaylistResults[self.groupType] {
            
            var groupsToReload = [Group]()
            
            for removal in removals.sorted(by: GroupedItemRemovalResultComparators.compareDescending) {
                
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
        if PlaylistViewState.current.toGroupType() == self.groupType && preferences.showNewTrackInPlaylist {
            notification.endTrack != nil ? showPlayingTrack() : clearSelection()
        }
    }
    
    func trackNotPlayed(_ notification: TrackNotPlayedNotification) {
        
        let errTrack = notification.errorTrack
        
        // Reload the old/error track.
        for track in Set([notification.oldTrack, errTrack]).compactMap({$0}) {
            playlistView.reloadItem(track)
        }

        // Only need to do this if this playlist view is shown
        if PlaylistViewState.current.toGroupType() == self.groupType,
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
            FileSystemUtils.showFileInFinder(selTrack.file)
        }
    }
    
    private func applyFontScheme(_ fontScheme: FontScheme) {
        
        let selectedRows = self.selectedRows
        playlistView.reloadData()
        playlistView.selectRowIndexes(selectedRows, byExtendingSelection: false)
    }
    
    private func applyColorScheme(_ scheme: ColorScheme) {
        doApplyColorScheme(scheme)
    }
    
    private func doApplyColorScheme(_ scheme: ColorScheme, _ mustReloadRows: Bool = true) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        
        if mustReloadRows {
            
            let selectedRows = self.selectedRows
            playlistView.reloadData()
            playlistView.selectRowIndexes(selectedRows, byExtendingSelection: false)
        }
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        scrollView.backgroundColor = color
        scrollView.drawsBackground = color.isOpaque
        
        clipView.backgroundColor = color
        clipView.drawsBackground = color.isOpaque
        
        playlistView.backgroundColor = color.isOpaque ? color : NSColor.clear
    }
    
    private var allRows: IndexSet {IndexSet(integersIn: 0..<playlistView.numberOfRows)}
    
    private var allGroups: [Group] {playlist.allGroups(self.groupType)}
    
    private func changeTrackNameTextColor(_ color: NSColor) {
        
        let trackRows = allRows.filteredIndexSet(includeInteger: {playlistView.item(atRow: $0) is Track})
        playlistView.reloadData(forRowIndexes: trackRows, columnIndexes: IndexSet(integer: 0))
    }
    
    private func changeGroupNameTextColor(_ color: NSColor) {
        allGroups.forEach({playlistView.reloadItem($0)})
    }
    
    private func changeDurationTextColor(_ color: NSColor) {
        playlistView.reloadData(forRowIndexes: allRows, columnIndexes: IndexSet(integer: 1))
    }
    
    private func changeTrackNameSelectedTextColor(_ color: NSColor) {
        
        let selectedTrackRows = selectedRows.filteredIndexSet(includeInteger: {playlistView.item(atRow: $0) is Track})
        playlistView.reloadData(forRowIndexes: selectedTrackRows, columnIndexes: IndexSet(integer: 0))
    }
    
    private func changeGroupNameSelectedTextColor(_ color: NSColor) {
        
        let selectedGroupRows = selectedRows.filteredIndexSet(includeInteger: {playlistView.item(atRow: $0) is Group})
        playlistView.reloadData(forRowIndexes: selectedGroupRows, columnIndexes: IndexSet(integer: 0))
    }
    
    private func changeDurationSelectedTextColor(_ color: NSColor) {
        playlistView.reloadData(forRowIndexes: selectedRows, columnIndexes: IndexSet(integer: 1))
    }
    
    private func changeSelectionBoxColor(_ color: NSColor) {
        
        // Note down the selected rows, clear the selection, and re-select the originally selected rows (to trigger a repaint of the selection boxes)
        let selectedRows = self.selectedRows
        
        if !selectedRows.isEmpty {
            
            clearSelection()
            playlistView.selectRowIndexes(selectedRows, byExtendingSelection: false)
        }
    }
    
    private func changePlayingTrackIconColor(_ color: NSColor) {
        
        if let playingTrack = playbackInfo.currentTrack {
            playlistView.reloadItem(playingTrack)
        }
    }
    
    private func changeGroupIconColor(_ color: NSColor) {
        allGroups.forEach {playlistView.reloadItem($0)}
    }
}
