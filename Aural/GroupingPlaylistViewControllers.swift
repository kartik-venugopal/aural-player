import Cocoa

/*
    Base view controller for the hierarchical/grouping ("Artists", "Albums", and "Genres") playlist views
 */
class GroupingPlaylistViewController: NSViewController, AsyncMessageSubscriber, MessageSubscriber, ActionMessageSubscriber {
    
    @IBOutlet weak var playlistView: NSOutlineView!
    
    // Delegate that relays CRUD actions to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // A serial operation queue to help perform playlist update tasks serially, without overwhelming the main thread
    private let playlistUpdateQueue = OperationQueue()
    
    // Intended to be overriden by subclasses
    
    // Indicates the type of each parent group in this playlist view
    internal var groupType: GroupType {return .artist}
    
    // Indicates the type of playlist this view displays
    internal var playlistType: PlaylistType {return .artists}
    
    override func viewDidLoad() {
        
        // Enable playback by double clicking
        playlistView.doubleAction = #selector(self.playSelectedItemAction(_:))
        playlistView.target = self
        
        // Register self as a subscriber to various message notifications
        AsyncMessenger.subscribe([.trackAdded, .trackInfoUpdated, .tracksRemoved, .tracksNotAdded], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(messageTypes: [.trackAddedNotification, .trackChangedNotification, .searchResultSelectionRequest], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.removeTracks, .moveTracksUp, .moveTracksDown, .refresh, .showPlayingTrack, .playSelectedItem], subscriber: self)
        
        // Set up the serial operation queue for playlist view updates
        playlistUpdateQueue.maxConcurrentOperationCount = 1
        playlistUpdateQueue.underlyingQueue = DispatchQueue.main
        playlistUpdateQueue.qualityOfService = .background
    }
    
    @IBAction func playSelectedItemAction(_ sender: AnyObject) {
        
        let selRow = playlistView.selectedRow
        if (selRow >= 0) {
            
            let item = playlistView.item(atRow: selRow)
            
            // The selected item is either a track or a group
            if let track = item as? Track {
                _ = SyncMessenger.publishRequest(PlaybackRequest(track: track))
            } else {
                
                let group = item as! Group
                _ = SyncMessenger.publishRequest(PlaybackRequest(group: group))
                
                // Expand the group to show the new playing track under the group
                playlistView.expandItem(group)
            }
            
            // Clear the selection and reload those rows
            let selIndexes = playlistView.selectedRowIndexes
            playlistView.deselectAll(self)
            playlistView.reloadData(forRowIndexes: selIndexes, columnIndexes: UIConstants.flatPlaylistViewColumnIndexes)
        }
    }
    
    private func clearPlaylist() {
        playlist.clear()
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.refresh, nil))
    }
    
    // Helper function that gathers all selected playlist items as tracks and groups
    private func collectTracksAndGroups() -> (tracks: [Track], groups: [Group]) {
        
        let indexes = playlistView.selectedRowIndexes
        var tracks = [Track]()
        var groups = [Group]()
        
        indexes.forEach({
            
            let item = playlistView.item(atRow: $0)
            
            if let track = item as? Track {
                tracks.append(track)
            } else {
                // Group
                groups.append(item as! Group)
            }
        })
        
        return (tracks, groups)
    }
    
    private func removeTracks() {
        
        let tracksAndGroups = collectTracksAndGroups()
        let tracks = tracksAndGroups.tracks
        let groups = tracksAndGroups.groups
        
        // If all groups are selected, this is the same as clearing the playlist
        if (groups.count == playlist.numberOfGroups(self.groupType)) {
            clearPlaylist()
            return
        }
        
        playlist.removeTracksAndGroups(tracks, groups, groupType)
    }
    
    // Selects (and shows) a certain track within the playlist view
    private func selectTrack(_ track: GroupedTrack?) {
        
        if (playlistView.numberOfRows > 0) {
            
            if let _track = track?.track {
                
                // Need to expand the parent group to make the child track visible
                playlistView.expandItem(track?.group)
                
                let trackRowIndex = playlistView.row(forItem: _track)
                
                playlistView.selectRowIndexes(IndexSet(integer: trackRowIndex), byExtendingSelection: false)
                playlistView.scrollRowToVisible(trackRowIndex)
            }
        }
    }
    
    private func refresh() {
        playlistView.reloadData()
    }
    
    private func moveTracksUp() {
        
        let tracksAndGroups = collectTracksAndGroups()
        let tracks = tracksAndGroups.tracks
        let groups = tracksAndGroups.groups
        
        // Cannot move both tracks and groups
        if (!tracks.isEmpty && !groups.isEmpty) {
            return
        }
        
        // Move items within the playlist and refresh the playlist view
        let results = playlist.moveTracksAndGroupsUp(tracks, groups, self.groupType)
        moveItems(results)
        
        // Re-select all the items that were moved
        var allItems: [GroupedPlaylistItem] = [GroupedPlaylistItem]()
        groups.forEach({allItems.append($0)})
        tracks.forEach({allItems.append($0)})
        selectAllItems(allItems)
        
        // Scroll to make the first selected row visible
        playlistView.scrollRowToVisible(playlistView.selectedRow)
    }
    
    // Refreshes the playlist view by rearranging the items that were moved
    private func moveItems(_ results: ItemMoveResults) {
        
        for result in results.results {
            
            if let trackMovedResult = result as? TrackMoveResult {
                
                playlistView.moveItem(at: trackMovedResult.oldTrackIndex, inParent: trackMovedResult.parentGroup, to: trackMovedResult.newTrackIndex, inParent: trackMovedResult.parentGroup)
                
            } else {
                
                let groupMovedResult = result as! GroupMoveResult
                playlistView.moveItem(at: groupMovedResult.oldGroupIndex, inParent: nil, to: groupMovedResult.newGroupIndex, inParent: nil)
            }
        }
    }
    
    // Selects all the specified items within the playlist view
    private func selectAllItems(_ items: [GroupedPlaylistItem]) {
        
        // Determine the row indexes for the items
        var selIndexes = [Int]()
        items.forEach({selIndexes.append(playlistView.row(forItem: $0))})
        
        // Select the item indexes
        playlistView.selectRowIndexes(IndexSet(selIndexes), byExtendingSelection: false)
    }
    
    private func moveTracksDown() {
        
        let tracksAndGroups = collectTracksAndGroups()
        let tracks = tracksAndGroups.tracks
        let groups = tracksAndGroups.groups
        
        // Cannot move both tracks and groups
        if (tracks.count > 0 && groups.count > 0) {
            return
        }
        
        // Move items within the playlist and refresh the playlist view
        let results = playlist.moveTracksAndGroupsDown(tracks, groups, self.groupType)
        moveItems(results)
        
        // Re-select all the items that were moved
        var allItems: [GroupedPlaylistItem] = [GroupedPlaylistItem]()
        groups.forEach({allItems.append($0)})
        tracks.forEach({allItems.append($0)})
        selectAllItems(allItems)
        
        // Scroll to make the first selected row visible
        playlistView.scrollRowToVisible(playlistView.selectedRow)
    }
    
    // Selects the currently playing track, within the playlist view
    private func showPlayingTrack() {
        selectTrack(playbackInfo.getPlayingTrackGroupInfo(self.groupType))
    }
 
    // Refreshes the playlist view in response to a new track being added to the playlist
    private func trackAdded(_ message: TrackAddedAsyncMessage) {
        
        let result = message.groupInfo[self.groupType]!
        
        if result.groupCreated {
        
            // If a new parent group was created, for this new track, insert the new group under the root
            playlistView.insertItems(at: IndexSet(integer: result.track.groupIndex), inParent: nil, withAnimation: NSTableViewAnimationOptions.effectFade)
            
        } else {
        
            // Insert the new track under its parent group, and reload the parent group
            let group = result.track.group
            
            playlistView.insertItems(at: IndexSet(integer: result.track.trackIndex), inParent: group, withAnimation: .effectGap)
            playlistView.reloadItem(group)
        }
    }
    
    // Refreshes the playlist view in response to a track being updated with new information
    private func trackInfoUpdated(_ message: TrackUpdatedAsyncMessage) {
        
        let track = message.groupInfo[self.groupType]!.track
        let group = message.groupInfo[self.groupType]!.group
        
        // Reload the parent group and the track
        self.playlistView.reloadItem(group, reloadChildren: false)
        self.playlistView.reloadItem(track)
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
    
    private func trackChanged(_ notification: TrackChangedNotification) {
        
        let oldTrack = notification.oldTrack
        let newTrack = notification.newTrack
        
        if (oldTrack != nil) {
            playlistView.reloadItem(oldTrack!.track)
        }
        
        if (newTrack != nil) {
            playlistView.reloadItem(newTrack!.track)
        }
    }
    
    private func handleSearchResultSelection(_ request: SearchResultSelectionRequest) {
        
        if PlaylistViewState.current == self.playlistType {
            
            // Select (show) the search result within the playlist view
            selectTrack(request.searchResult.location.groupInfo)
        }
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
            
        default: return
            
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        switch notification.messageType {
            
        case .trackChangedNotification:
            
            trackChanged(notification as! TrackChangedNotification)
            
        default: return
            
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        switch request.messageType {
            
        case .searchResultSelectionRequest:
            
            handleSearchResultSelection(request as! SearchResultSelectionRequest)
            
        default: break
            
        }
        
        // No meaningful response to return
        return EmptyResponse.instance
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        let msg = message as! PlaylistActionMessage
        
        // Check if this message is intended for this playlist view
        if (msg.playlistType != nil && msg.playlistType != self.playlistType) {
            return
        }
        
        switch (msg.actionType) {
            
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
        }
    }
}

extension IndexSet {

    // Convenience function to convert an IndexSet to an array
    func toArray() -> [Int] {
        return self.filter({$0 >= 0})
    }
}

/*
    View controller for the "Artists" playlist view
 */
class PlaylistArtistsViewController: GroupingPlaylistViewController {
    
    override internal var groupType: GroupType {return .artist}
    override internal var playlistType: PlaylistType {return .artists}
}

/*
    View controller for the "Albums" playlist view
 */
class PlaylistAlbumsViewController: GroupingPlaylistViewController {
    
    override internal var groupType: GroupType {return .album}
    override internal var playlistType: PlaylistType {return .albums}
}

/*
    View controller for the "Genres" playlist view
 */
class PlaylistGenresViewController: GroupingPlaylistViewController {
    
    override internal var groupType: GroupType {return .genre}
    override internal var playlistType: PlaylistType {return .genres}
}
