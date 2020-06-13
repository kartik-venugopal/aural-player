import Cocoa

/*
    Base view controller for the hierarchical/grouping ("Artists", "Albums", and "Genres") playlist views
 */
class GroupingPlaylistViewController: NSViewController, AsyncMessageSubscriber, MessageSubscriber, ActionMessageSubscriber {
    
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var clipView: NSClipView!
    @IBOutlet weak var playlistView: AuralPlaylistOutlineView!
    @IBOutlet weak var playlistViewDelegate: GroupingPlaylistViewDelegate!
    
    private lazy var contextMenu: NSMenu! = WindowFactory.playlistContextMenu
    
    // Delegate that relays CRUD actions to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private let history: HistoryDelegateProtocol = ObjectGraph.historyDelegate
    
    private let preferences: PlaylistPreferences = ObjectGraph.preferencesDelegate.preferences.playlistPreferences
    
    // A serial operation queue to help perform playlist update tasks serially, without overwhelming the main thread
    private let playlistUpdateQueue = OperationQueue()
    
    // Intended to be overriden by subclasses
    
    // Indicates the type of each parent group in this playlist view
    internal var groupType: GroupType {return .artist}
    
    // Indicates the type of playlist this view displays
    internal var playlistType: PlaylistType {return .artists}
    
    override func viewDidLoad() {
        
        // Enable drag n drop
        playlistView.registerForDraggedTypes(convertToNSPasteboardPasteboardTypeArray([String(kUTTypeFileURL), "public.data"]))
        
        playlistView.menu = contextMenu
        
        initSubscriptions()
        
        // Register for key press and gesture events
        PlaylistInputEventHandler.registerViewForPlaylistType(self.playlistType, playlistView)
        
        // Set up the serial operation queue for playlist view updates
        playlistUpdateQueue.maxConcurrentOperationCount = 1
        playlistUpdateQueue.underlyingQueue = DispatchQueue.main
        playlistUpdateQueue.qualityOfService = .userInitiated
        
        applyColorScheme(ColorSchemes.systemScheme, false)
    }
    
    private func initSubscriptions() {
        
        // Register self as a subscriber to various message notifications
        AsyncMessenger.subscribe([.trackAdded, .trackInfoUpdated, .tracksRemoved, .tracksNotAdded, .trackNotPlayed, .transcodingCancelled], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        Messenger.subscribe(self, .selectSearchResult, self.selectSearchResult(_:), filter: {msg in PlaylistViewState.current == self.playlistType})
        
        SyncMessenger.subscribe(messageTypes: [.trackTransitionNotification, .gapUpdatedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.removeTracks, .moveTracksUp, .moveTracksToTop, .moveTracksDown, .moveTracksToBottom, .clearSelection, .invertSelection, .cropSelection, .expandSelectedGroups, .collapseSelectedItems, .collapseParentGroup, .expandAllGroups, .collapseAllGroups, .scrollToTop, .scrollToBottom, .pageUp, .pageDown, .refresh, .showPlayingTrack, .playSelectedItem, .playSelectedItemWithDelay, .showTrackInFinder, .insertGaps, .removeGaps, .changePlaylistTextSize, .applyColorScheme, .changeBackgroundColor, .changePlaylistTrackNameTextColor, .changePlaylistTrackNameSelectedTextColor, .changePlaylistGroupNameTextColor, .changePlaylistGroupNameSelectedTextColor, .changePlaylistIndexDurationTextColor, .changePlaylistIndexDurationSelectedTextColor, .changePlaylistSelectionBoxColor, .changePlaylistPlayingTrackIconColor, .changePlaylistGroupIconColor, .changePlaylistGroupDisclosureTriangleColor], subscriber: self)
    }
    
    override func viewDidAppear() {
        
        // When this view appears, the playlist type (tab) has changed. Update state and notify observers.
        
        PlaylistViewState.current = self.playlistType
        PlaylistViewState.currentView = playlistView

        Messenger.publish(PlaylistTypeChangedNotification(newPlaylistType: self.playlistType))
    }
    
    // Plays the track/group selected within the playlist, if there is one. If multiple items are selected, the first one will be chosen.
    @IBAction func playSelectedItemAction(_ sender: AnyObject) {
        playSelectedItemWithDelay(nil)
    }
    
    private func playSelectedItemWithDelay(_ delay: Double?) {
        
        let selRowIndexes = playlistView.selectedRowIndexes
        
        if (!selRowIndexes.isEmpty) {
            
            let item = playlistView.item(atRow: selRowIndexes.min()!)
            
            // The selected item is either a track or a group
            var request: PlaybackRequest = item is Track ? PlaybackRequest(track: item as! Track) : PlaybackRequest(group: item as! Group)
            request.delay = delay
            
            _ = SyncMessenger.publishRequest(request)
        }
    }
    
    private func clearPlaylist() {
        
        playlist.clear()
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.refresh, nil))
    }
    
    // Helper function that gathers all selected playlist items as tracks and groups
    private func collectTracksAndGroups() -> (tracks: [Track], groups: [Group]) {
        return doCollectTracksAndGroups(playlistView.selectedRowIndexes)
    }
    
    private func doCollectTracksAndGroups(_ indexes: IndexSet) -> (tracks: [Track], groups: [Group]) {
        
        var tracks = [Track]()
        var groups = [Group]()
        
        indexes.forEach({
            
            let item = playlistView.item(atRow: $0)
            item is Track ? tracks.append(item as! Track) : groups.append(item as! Group)
        })
        
        return (tracks, groups)
    }
    
    private func removeTracks() {
        
        let tracksAndGroups = collectTracksAndGroups()
        let tracks = tracksAndGroups.tracks
        let groups = tracksAndGroups.groups
        
        if (groups.isEmpty && tracks.isEmpty) {
            
            // Nothing selected, nothing to do
            return
        }
        
        // If all groups are selected, this is the same as clearing the playlist
        if (groups.count == playlist.numberOfGroups(self.groupType)) {
            clearPlaylist()
            return
        }
        
        _ = playlist.removeTracksAndGroups(tracks, groups, groupType)
    }
    
    private func selectTrack(_ track: Track?) {
        
        if playlistView.numberOfRows > 0, let _track = track, let group = playlist.groupingInfoForTrack(self.groupType, _track)?.group {
                
            // Need to expand the parent group to make the child track visible
            playlistView.expandItem(group)
            
            let trackRowIndex = playlistView.row(forItem: _track)
            
            playlistView.selectRowIndexes(IndexSet(integer: trackRowIndex), byExtendingSelection: false)
            playlistView.scrollRowToVisible(trackRowIndex)
        }
    }
    
    // Selects (and shows) a certain track within the playlist view
    private func selectTrack(_ track: GroupedTrack?) {
        
        if playlistView.numberOfRows > 0, let _track = track?.track, let parentGroup = track?.group {
                
            // Need to expand the parent group to make the child track visible
            playlistView.expandItem(parentGroup)
            
            let trackRowIndex = playlistView.row(forItem: _track)

            playlistView.selectRowIndexes(IndexSet(integer: trackRowIndex), byExtendingSelection: false)
            playlistView.scrollRowToVisible(trackRowIndex)
        }
    }
    
    private func refresh() {
        
        DispatchQueue.main.async {
            self.playlistView.reloadData()
        }
    }
    
    // Refreshes the playlist view by rearranging the items that were moved
    private func removeAndInsertItems(_ results: ItemMoveResults) {
 
        for result in results.results {
            
            if let trackMovedResult = result as? TrackMoveResult {
                
                playlistView.removeItems(at: IndexSet([trackMovedResult.oldTrackIndex]), inParent: trackMovedResult.parentGroup, withAnimation: trackMovedResult.movedUp ? .slideUp : .slideDown)
                
                playlistView.insertItems(at: IndexSet([trackMovedResult.newTrackIndex]), inParent: trackMovedResult.parentGroup, withAnimation: trackMovedResult.movedUp ? .slideDown : .slideUp)
                
            } else if let groupMovedResult = result as? GroupMoveResult {
                
                playlistView.removeItems(at: IndexSet([groupMovedResult.oldGroupIndex]), inParent: nil, withAnimation: groupMovedResult.movedUp ? .slideUp : .slideDown)
                
                playlistView.insertItems(at: IndexSet([groupMovedResult.newGroupIndex]), inParent: nil, withAnimation: groupMovedResult.movedUp ? .slideDown : .slideUp)
            }
        }
    }
    
    
    
    // Refreshes the playlist view by rearranging the items that were moved
    private func moveItems(_ results: ItemMoveResults) {
        
        for result in results.results {
            
            if let trackMovedResult = result as? TrackMoveResult {
                
                playlistView.moveItem(at: trackMovedResult.oldTrackIndex, inParent: trackMovedResult.parentGroup, to: trackMovedResult.newTrackIndex, inParent: trackMovedResult.parentGroup)
                
            } else if let groupMovedResult = result as? GroupMoveResult {
                
                playlistView.moveItem(at: groupMovedResult.oldGroupIndex, inParent: nil, to: groupMovedResult.newGroupIndex, inParent: nil)
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
        doMoveItems(playlist.moveTracksAndGroupsUp(_:_:_:), self.moveItems(_:))
    }
    
    private func moveTracksDown() {
        doMoveItems(playlist.moveTracksAndGroupsDown(_:_:_:), self.moveItems(_:))
    }
    
    private func moveTracksToTop() {
        doMoveItems(playlist.moveTracksAndGroupsToTop(_:_:_:), self.removeAndInsertItems(_:))
    }
    
    private func moveTracksToBottom() {
        doMoveItems(playlist.moveTracksAndGroupsToBottom(_:_:_:), self.removeAndInsertItems(_:))
    }
    
    private func doMoveItems(_ moveAction: @escaping ([Track], [Group], GroupType) -> ItemMoveResults,
                             _ refreshAction: @escaping (ItemMoveResults) -> Void) {
        
        let tracksAndGroups = collectTracksAndGroups()
        let tracks = tracksAndGroups.tracks
        let groups = tracksAndGroups.groups
        
        // Cannot move both tracks and groups
        if tracks.count > 0 && groups.count > 0 {
            return
        }
        
        // Move items within the playlist and refresh the playlist view
        let results = moveAction(tracks, groups, self.groupType)
        refreshAction(results)
        
        // Re-select all the items that were moved
        var allItems: [PlaylistItem] = []
        groups.forEach({allItems.append($0)})
        tracks.forEach({allItems.append($0)})
        selectAllItems(allItems)
        
        // Scroll to make the first selected row visible
        playlistView.scrollRowToVisible(playlistView.selectedRow)
    }
    
    private func invertSelection() {
        playlistView.selectRowIndexes(invertedSelection, byExtendingSelection: false)
    }
    
    // TODO: Simplify this method
    // for row in 0..<numRows if !selRows.contains(row) invSelRows.add(row)
    private var invertedSelection: IndexSet {
        
        let selRows = playlistView.selectedRowIndexes
        
        var curIndex: Int = 0
        var itemsInspected: Int = 0
        
        let playlistSize = playlist.size
        var targetSelRows = IndexSet()

        // Iterate through items, till all items have been inspected
        while itemsInspected < playlistSize {
            
            let item = playlistView.item(atRow: curIndex)
            
            if let group = item as? Group {
             
                let selected: Bool = selRows.contains(curIndex)
                let expanded: Bool = playlistView.isItemExpanded(group)
                
                if selected {
                    
                    // Ignore this group as it is selected
                    if expanded {
                        curIndex += group.size
                    }
                    
                } else {
                    
                    // Group not selected
                    
                    if expanded {
                        
                        // Check for selected children
                        
                        let childIndexes = selRows.filter({$0 > curIndex && $0 <= curIndex + group.size})
                        if childIndexes.isEmpty {
                            
                            // No children selected, add group index
                            targetSelRows.insert(curIndex)
                            
                        } else {
                            
                            // Check each child track
                            for index in 1...group.size {
                                
                                if !selRows.contains(curIndex + index) {
                                    targetSelRows.insert(curIndex + index)
                                }
                            }
                        }
                        
                        curIndex += group.size
                        
                    } else {
                        
                        // Group (and children) not selected, add this group to inverted selection
                        targetSelRows.insert(curIndex)
                    }
                }
                
                curIndex += 1
                itemsInspected += group.size
            }
        }
        
        return targetSelRows
    }
    
    private func clearSelection() {
        playlistView.selectRowIndexes(IndexSet([]), byExtendingSelection: false)
    }
    
    private func cropSelection() {
        
        let tracksToDelete: IndexSet = invertedSelection
        clearSelection()
        
        if (tracksToDelete.count > 0) {
            
            let tracksAndGroups = doCollectTracksAndGroups(tracksToDelete)
            let tracks = tracksAndGroups.tracks
            let groups = tracksAndGroups.groups
            
            if (groups.isEmpty && tracks.isEmpty) {
                
                // Nothing selected, nothing to do
                return
            }
            
            // If all groups are selected, this is the same as clearing the playlist
            if (groups.count == playlist.numberOfGroups(self.groupType)) {
                clearPlaylist()
                return
            }
            
            _ = playlist.removeTracksAndGroups(tracks, groups, groupType)
        }
    }
    
    private func expandSelectedGroups() {
        
        // Need to sort in descending order because expanding a group will change the row indexes of other selected items :)
        let sortedIndexes = playlistView.selectedRowIndexes.sorted(by: {x, y -> Bool in x > y})
        sortedIndexes.forEach({playlistView.expandItem(playlistView.item(atRow: $0))})
    }
    
    private func collapseSelectedItems() {
        
        // Need to sort in descending order because collapsing a group will change the row indexes of other selected items :)
        let sortedIndexes = playlistView.selectedRowIndexes.sorted(by: {x, y -> Bool in x > y})
        
        var groups = Set<Group>()
        sortedIndexes.forEach({
            
            let item = playlistView.item(atRow: $0)
            if let track = item as? Track {
                
                let parent = playlistView.parent(forItem: track)
                groups.insert(parent as! Group)
                
            } else {
                // Group
                groups.insert(item as! Group)
            }
        })
        
        groups.forEach({playlistView.collapseItem($0, collapseChildren: false)})
    }
    
    private func expandAllGroups() {
        playlistView.expandItem(nil, expandChildren: true)
    }
    
    private func collapseAllGroups() {
        playlistView.collapseItem(nil, collapseChildren: true)
    }
    
    // Scrolls the playlist view to the very top
    private func scrollToTop() {
        
        if (playlistView.numberOfRows > 0) {
            playlistView.scrollRowToVisible(0)
        }
    }
    
    // Scrolls the playlist view to the very bottom
    private func scrollToBottom() {
        
        if (playlistView.numberOfRows > 0) {
            playlistView.scrollRowToVisible(playlistView.numberOfRows - 1)
        }
    }
    
    private func pageUp() {
        
        // Determine if the first row currently displayed has been truncated so it is not fully visible
        
        let firstRowShown = playlistView.rows(in: playlistView.visibleRect).lowerBound
        let firstRowShown_height = playlistView.rect(ofRow: firstRowShown).height
        let firstRowShown_minY = playlistView.rect(ofRow: firstRowShown).minY
        
        let visibleRect_minY = playlistView.visibleRect.minY
        
        let truncationAmount =  visibleRect_minY - firstRowShown_minY
        let truncationRatio = truncationAmount / firstRowShown_height
        
        // If the first row currently displayed has been truncated more than 10%, show it again in the next page
        
        let lastRowToShow = truncationRatio > 0.1 ? firstRowShown : firstRowShown - 1
        let lastRowToShow_maxY = playlistView.rect(ofRow: lastRowToShow).maxY
        
        let visibleRect_maxY = playlistView.visibleRect.maxY
        
        // Calculate the scroll amount, as a function of the last row to show next, using the visible rect origin (i.e. the top of the first row in the playlist) as the stopping point
        
        let scrollAmount = min(playlistView.visibleRect.origin.y, visibleRect_maxY - lastRowToShow_maxY)
        
        if scrollAmount > 0 {
            
            let up = playlistView.visibleRect.origin.applying(CGAffineTransform.init(translationX: 0, y: -scrollAmount))
            playlistView.enclosingScrollView!.contentView.scroll(to: up)
        }
    }
    
    private func pageDown() {
        
        // Determine if the last row currently displayed has been truncated so it is not fully visible
        
        let visibleRows = playlistView.rows(in: playlistView.visibleRect)
        
        let lastRowShown = visibleRows.lowerBound + visibleRows.length - 1
        let lastRowShown_maxY = playlistView.rect(ofRow: lastRowShown).maxY
        let lastRowShown_height = playlistView.rect(ofRow: lastRowShown).height
        
        let lastRowInPlaylist = playlistView.numberOfRows - 1
        let lastRowInPlaylist_maxY = playlistView.rect(ofRow: lastRowInPlaylist).maxY
        
        // If the first row currently displayed has been truncated more than 10%, show it again in the next page
        
        let visibleRect_maxY = playlistView.visibleRect.maxY
        
        let truncationAmount = lastRowShown_maxY - visibleRect_maxY
        let truncationRatio = truncationAmount / lastRowShown_height
        
        let firstRowToShow = truncationRatio > 0.1 ? lastRowShown : lastRowShown + 1
        
        let visibleRect_originY = playlistView.visibleRect.origin.y
        let firstRowToShow_originY = playlistView.rect(ofRow: firstRowToShow).origin.y
        
        // Calculate the scroll amount, as a function of the first row to show next, using the visible rect maxY (i.e. the bottom of the last row in the playlist) as the stopping point
        
        let scrollAmount = min(firstRowToShow_originY - visibleRect_originY, lastRowInPlaylist_maxY - playlistView.visibleRect.maxY)
        
        if scrollAmount > 0 {
            
            let down = playlistView.visibleRect.origin.applying(CGAffineTransform.init(translationX: 0, y: scrollAmount))
            playlistView.enclosingScrollView!.contentView.scroll(to: down)
        }
    }
    
    // Selects the currently playing track, within the playlist view
    private func showPlayingTrack() {
        
        if let playingTrack = playbackInfo.currentTrack,
            let groupingInfo = playlist.groupingInfoForTrack(self.groupType, playingTrack) {
            
            selectTrack(groupingInfo)
        }
    }
 
    // Refreshes the playlist view in response to a new track being added to the playlist
    private func trackAdded(_ msg: TrackAddedAsyncMessage) {
        
        if let grouping = msg.groupInfo[self.groupType] {
            
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
    
    // Refreshes the playlist view in response to a track being updated with new information (e.g. duration)
    private func trackInfoUpdated(_ message: TrackUpdatedAsyncMessage) {
        
        let track = message.track
        if let groupInfo = playlist.groupingInfoForTrack(self.groupType, track) {
            
            // Reload the parent group and the track
            self.playlistView.reloadItem(groupInfo.group, reloadChildren: false)
            self.playlistView.reloadItem(groupInfo.track)
        }
    }
    
    // Refreshes the playlist view in response to tracks/groups being removed from the playlist
    private func tracksRemoved(_ message: TracksRemovedAsyncMessage) {
        
        let removals = message.results.groupingPlaylistResults[self.groupType]!
        var groupsToReload = [Group]()

        for removal in removals {

            if let tracksRemoval = removal as? GroupedTracksRemovalResult {
                
                // Remove tracks from their parent group
                playlistView.removeItems(at: tracksRemoval.trackIndexesInGroup, inParent: tracksRemoval.parentGroup, withAnimation: .effectFade)

                // Make note of the parent group for later
                groupsToReload.append(tracksRemoval.parentGroup)

            } else {
                
                // Remove group from the root
                let groupRemoval = removal as! GroupRemovalResult
                playlistView.removeItems(at: IndexSet(integer: groupRemoval.groupIndex), inParent: nil, withAnimation: .effectFade)
            }
        }

        // For all groups from which tracks were removed, reload them
        groupsToReload.forEach({playlistView.reloadItem($0)})
    }
    
    private func trackTransitioned(_ message: TrackTransitionNotification) {
        
        let oldTrack = message.beginTrack
        
        if let _oldTrack = oldTrack {
            
            // If this is not done async, the row view could get garbled.
            // (because of other potential simultaneous updates - e.g. PlayingTrackInfoUpdated)
            DispatchQueue.main.async {
            
                self.playlistView.reloadItem(_oldTrack)
            
                let row = self.playlistView.row(forItem: _oldTrack)
                self.playlistView.noteHeightOfRows(withIndexesChanged: IndexSet([row]))
            }
        }
        
        let needToShowTrack: Bool = PlaylistViewState.current.toGroupType() == self.groupType && preferences.showNewTrackInPlaylist
        
        if let newTrack = message.endTrack {
            
            // There is a new track, select it if necessary
            
            if newTrack != oldTrack {
                
                // If this is not done async, the row view could get garbled.
                // (because of other potential simultaneous updates - e.g. PlayingTrackInfoUpdated)
                DispatchQueue.main.async {
                
                    self.playlistView.reloadItem(newTrack)
                    
                    let row = self.playlistView.row(forItem: newTrack)
                    self.playlistView.noteHeightOfRows(withIndexesChanged: IndexSet([row]))
                }
            }
            
            if needToShowTrack {
                showPlayingTrack()
            }
            
        } else if needToShowTrack {
 
            // No new track
            clearSelection()
        }
    }
    
    private func trackNotPlayed(_ message: TrackNotPlayedAsyncMessage) {
        
        let oldTrack = message.oldTrack
        
        if let _oldTrack = oldTrack {
            playlistView.reloadItem(_oldTrack)
        }
        
        // TODO: Remove errTrack, simply reference track
        if let track = message.error.track, let errTrack = playlist.indexOfTrack(track) {
            
            if errTrack.track != oldTrack {
                playlistView.reloadItem(errTrack.track)
            }
            
            // Only need to do this if this playlist view is shown
            if PlaylistViewState.current.toGroupType() == self.groupType {
                selectTrack(playlist.groupingInfoForTrack(self.groupType, errTrack.track))
            }
        }
    }
    
    // Selects an item within the playlist view, to show a single search result
    func selectSearchResult(_ command: SelectSearchResultCommandNotification) {
        selectTrack(command.searchResult.location.groupInfo)
    }
    
    // Show the selected track in Finder
    private func showTrackInFinder() {
        
        // This is a safe typecast, because the context menu will prevent this function from being executed on groups. In other words, the selected item will always be a track.
        if let selTrack = playlistView.item(atRow: playlistView.selectedRow) as? Track {
            FileSystemUtils.showFileInFinder(selTrack.file)
        }
    }
    
    private func insertGap(_ gapBefore: PlaybackGap?, _ gapAfter: PlaybackGap?) {
        
        if let selTrack = playlistView.item(atRow: playlistView.selectedRow) as? Track {
            
            playlist.setGapsForTrack(selTrack, gapBefore, gapAfter)
            SyncMessenger.publishNotification(PlaybackGapUpdatedNotification(selTrack))
        }
    }
    
    private func removeGaps() {
        
        if let selTrack = playlistView.item(atRow: playlistView.selectedRow) as? Track {
            
            playlist.removeGapsForTrack(selTrack)
            SyncMessenger.publishNotification(PlaybackGapUpdatedNotification(selTrack))
        }
    }
    
    private func gapUpdated(_ message: PlaybackGapUpdatedNotification) {
        
        // Find track and refresh it
        let updatedRow = playlistView.row(forItem: message.updatedTrack)
        
        if updatedRow >= 0 {
            refreshRow(updatedRow)
        }
    }
    
    private func refreshSelectedRow() {
        refreshRow(playlistView.selectedRow)
    }
    
    private func refreshRow(_ row: Int) {
        
        playlistView.reloadData(forRowIndexes: IndexSet([row]), columnIndexes: UIConstants.groupingPlaylistViewColumnIndexes)
        playlistView.noteHeightOfRows(withIndexesChanged: IndexSet([row]))
    }
    
    private func changeTextSize() {
        
        let selRows = playlistView.selectedRowIndexes
        playlistView.reloadData()
        playlistView.selectRowIndexes(selRows, byExtendingSelection: false)
    }
    
    private func applyColorScheme(_ scheme: ColorScheme, _ mustReloadRows: Bool = true) {
        
        changeBackgroundColor(scheme.general.backgroundColor)
        
        if mustReloadRows {
            
            playlistViewDelegate.changeGroupIconColor(scheme.playlist.groupIconColor)
            playlistViewDelegate.changeGapIndicatorColor(scheme.playlist.indexDurationSelectedTextColor)
            playlistView.changeDisclosureIconColor(scheme.playlist.groupDisclosureTriangleColor)
            
            let selRows = playlistView.selectedRowIndexes
            playlistView.reloadData()
            playlistView.selectRowIndexes(selRows, byExtendingSelection: false)
        }
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        scrollView.backgroundColor = color
        scrollView.drawsBackground = color.isOpaque
        
        clipView.backgroundColor = color
        clipView.drawsBackground = color.isOpaque
        
        playlistView.backgroundColor = color.isOpaque ? color : NSColor.clear
    }
    
    private var allRows: IndexSet {
        return IndexSet(integersIn: 0..<playlistView.numberOfRows)
    }
    
    private var allGroups: [Group] {
        return playlist.allGroups(self.groupType)
    }
    
    private func changeTrackNameTextColor(_ color: NSColor) {
        
        playlistViewDelegate.changeGapIndicatorColor(color)
        
        let trackRows = allRows.filteredIndexSet(includeInteger: {playlistView.item(atRow: $0) is Track})
        playlistView.reloadData(forRowIndexes: trackRows, columnIndexes: IndexSet([0]))
    }
    
    private func changeGroupNameTextColor(_ color: NSColor) {
        allGroups.forEach({playlistView.reloadItem($0)})
    }
    
    private func changeDurationTextColor(_ color: NSColor) {
        playlistView.reloadData(forRowIndexes: allRows, columnIndexes: IndexSet([1]))
    }
    
    private func changeTrackNameSelectedTextColor(_ color: NSColor) {
        
        let selTrackRows = playlistView.selectedRowIndexes.filteredIndexSet(includeInteger: {playlistView.item(atRow: $0) is Track})
        playlistView.reloadData(forRowIndexes: selTrackRows, columnIndexes: IndexSet([0]))
    }
    
    private func changeGroupNameSelectedTextColor(_ color: NSColor) {
        
        let selGroupRows = playlistView.selectedRowIndexes.filteredIndexSet(includeInteger: {playlistView.item(atRow: $0) is Group})
        playlistView.reloadData(forRowIndexes: selGroupRows, columnIndexes: IndexSet([0]))
    }
    
    private func changeDurationSelectedTextColor(_ color: NSColor) {
        playlistView.reloadData(forRowIndexes: playlistView.selectedRowIndexes, columnIndexes: IndexSet([1]))
    }
    
    private func changeSelectionBoxColor(_ color: NSColor) {
        
        // Note down the selected rows, clear the selection, and re-select the originally selected rows (to trigger a repaint of the selection boxes)
        let selRows = playlistView.selectedRowIndexes
        
        if !selRows.isEmpty {
            clearSelection()
            playlistView.selectRowIndexes(selRows, byExtendingSelection: false)
        }
    }
    
    private func changePlayingTrackIconColor(_ color: NSColor) {
        
        if let playingTrack = playbackInfo.currentTrack {
            playlistView.reloadItem(playingTrack)
        }
    }
    
    private func changeGroupIconColor(_ color: NSColor) {
        
        playlistViewDelegate.changeGroupIconColor(color)
        allGroups.forEach({playlistView.reloadItem($0)})
    }
    
    private func changeGroupDisclosureTriangleColor(_ color: NSColor) {
        playlistView.changeDisclosureIconColor(color)
    }
    
    // MARK: Message handlers
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .trackAdded:
            
            trackAdded(message as! TrackAddedAsyncMessage)
            
        case .trackInfoUpdated:
            
            trackInfoUpdated(message as! TrackUpdatedAsyncMessage)
            
        case .tracksRemoved:
            
            tracksRemoved(message as! TracksRemovedAsyncMessage)
            
        case .trackNotPlayed:
            
            trackNotPlayed(message as! TrackNotPlayedAsyncMessage)
            
        default: return
            
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        switch notification.messageType {
            
        case .trackTransitionNotification:
            
            if let trackTransitionMsg = notification as? TrackTransitionNotification {
                trackTransitioned(trackTransitionMsg)
            }
            
        case .gapUpdatedNotification:
            
            gapUpdated(notification as! PlaybackGapUpdatedNotification)
            
        default: return
            
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if let msg = message as? PlaylistActionMessage {
            
            // Check if this message is intended for this playlist view
            if let playlistType = msg.playlistType, playlistType != self.playlistType {
                return
            }
            
            switch msg.actionType {
                
            case .refresh:
                
                refresh()
                
            case .removeTracks:
                
                removeTracks()
                
            case .showPlayingTrack:
                
                showPlayingTrack()
                
            case .playSelectedItem:
                
                playSelectedItemAction(self)
                
            case .moveTracksUp:
                
                moveTracksUp()
                
            case .moveTracksDown:
                
                moveTracksDown()
                
            case .moveTracksToTop:
                
                moveTracksToTop()
                
            case .moveTracksToBottom:
                
                moveTracksToBottom()
                
            case .scrollToTop:
                
                scrollToTop()
                
            case .scrollToBottom:
                
                scrollToBottom()
                
            case .pageUp:
                
                pageUp()
                
            case .pageDown:
                
                pageDown()
                
            case .showTrackInFinder:
                
                showTrackInFinder()
                
            case .clearSelection:
                
                clearSelection()
                
            case .invertSelection:
                
                invertSelection()
                
            case .cropSelection:
                
                cropSelection()
                
            case .expandSelectedGroups:
                
                expandSelectedGroups()
                
            case .collapseSelectedItems:
                
                collapseSelectedItems()
                
            case .expandAllGroups:
                
                expandAllGroups()
                
            case .collapseAllGroups:
                
                collapseAllGroups()
                
            default: return
                
            }
        }
        
        if message is TextSizeActionMessage {
            
            changeTextSize()
            return
        }
        
        if let colorChangeMsg = message as? ColorSchemeComponentActionMessage {
            
            switch colorChangeMsg.actionType {
                
            case .changeBackgroundColor:
                
                changeBackgroundColor(colorChangeMsg.color)
                
            case .changePlaylistTrackNameTextColor:
                
                changeTrackNameTextColor(colorChangeMsg.color)
                
            case .changePlaylistGroupNameTextColor:
                
                changeGroupNameTextColor(colorChangeMsg.color)
                
            case .changePlaylistIndexDurationTextColor:
                
                changeDurationTextColor(colorChangeMsg.color)
                
            case .changePlaylistTrackNameSelectedTextColor:
                
                changeTrackNameSelectedTextColor(colorChangeMsg.color)
                
            case .changePlaylistGroupNameSelectedTextColor:
                
                changeGroupNameSelectedTextColor(colorChangeMsg.color)
                
            case .changePlaylistIndexDurationSelectedTextColor:
                
                changeDurationSelectedTextColor(colorChangeMsg.color)
                
            case .changePlaylistPlayingTrackIconColor:
                
                changePlayingTrackIconColor(colorChangeMsg.color)
                
            case .changePlaylistSelectionBoxColor:
                
                changeSelectionBoxColor(colorChangeMsg.color)
                
            case .changePlaylistGroupIconColor:
                
                changeGroupIconColor(colorChangeMsg.color)
                
            case .changePlaylistGroupDisclosureTriangleColor:
                
                changeGroupDisclosureTriangleColor(colorChangeMsg.color)
                
            default: return
                
            }
            
            return
        }
        
        if let colorSchemeMsg = message as? ColorSchemeActionMessage {
            
            applyColorScheme(colorSchemeMsg.scheme)
            return
        }
        
        if let delayedPlaybackMsg = message as? DelayedPlaybackActionMessage {
            
            if delayedPlaybackMsg.playlistType == self.playlistType {
                playSelectedItemWithDelay(delayedPlaybackMsg.delay)
            }
            
            return
        }
        
        if let insertGapsMsg = message as? InsertPlaybackGapsActionMessage {
            
            // Check if this message is intended for this playlist view
            if insertGapsMsg.playlistType == self.playlistType {
                insertGap(insertGapsMsg.gapBeforeTrack, insertGapsMsg.gapAfterTrack)
            }
            
            return
        }
        
        if let removeGapMsg = message as? RemovePlaybackGapsActionMessage {
            
            if removeGapMsg.playlistType == self.playlistType {
                removeGaps()
            }
            
            return
        }
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToNSPasteboardPasteboardTypeArray(_ input: [String]) -> [NSPasteboard.PasteboardType] {
	return input.map { key in NSPasteboard.PasteboardType(key) }
}
