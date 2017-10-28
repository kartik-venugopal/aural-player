/*
 View controller for playlist CRUD controls (adding/removing/reordering tracks and saving/loading to/from playlists)
 */

import Cocoa
import Foundation

class GroupingPlaylistViewController: NSViewController, AsyncMessageSubscriber, MessageSubscriber, ActionMessageSubscriber {
    
    @IBOutlet weak var playlistView: NSOutlineView!
    
    // Delegate that performs CRUD actions on the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    private let plAcc: PlaylistAccessorProtocol = ObjectGraph.getPlaylistAccessor()
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // A serial operation queue to help perform playlist update tasks serially, without overwhelming the main thread
    private let playlistUpdateQueue = OperationQueue()
    
    // Intended to be overriden by subclasses
    internal var groupType: GroupType {return .artist}
    internal var viewType: PlaylistViewType {return .artists}
    
    var adds = 0
    var updates = 0
    
    override func viewDidLoad() {
        
        // Register self as a subscriber to various AsyncMessage notifications
        AsyncMessenger.subscribe(.trackAdded, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.tracksRemoved, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.tracksNotAdded, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.startedAddingTracks, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.doneAddingTracks, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.trackInfoUpdated, subscriber: self, dispatchQueue: DispatchQueue.main)
        
        // Register self as a subscriber to various synchronous message notifications
//        SyncMessenger.subscribe(.trackAddedNotification, subscriber: self)
//        SyncMessenger.subscribe(.trackUpdatedNotification, subscriber: self)
        SyncMessenger.subscribe(.trackChangedNotification, subscriber: self)
        SyncMessenger.subscribe(.removeTrackRequest, subscriber: self)
        SyncMessenger.subscribe(.searchResultSelectionRequest, subscriber: self)
        
        SyncMessenger.subscribe(actionType: .removeTracks, subscriber: self)
        SyncMessenger.subscribe(actionType: .clearPlaylist, subscriber: self)
        SyncMessenger.subscribe(actionType: .moveTracksUp, subscriber: self)
        SyncMessenger.subscribe(actionType: .moveTracksDown, subscriber: self)
        SyncMessenger.subscribe(actionType: .refresh, subscriber: self)
        SyncMessenger.subscribe(actionType: .scrollToTop, subscriber: self)
        SyncMessenger.subscribe(actionType: .scrollToBottom, subscriber: self)
        SyncMessenger.subscribe(actionType: .showPlayingTrack, subscriber: self)
        
        // Set up the serial operation queue for playlist view updates
        playlistUpdateQueue.maxConcurrentOperationCount = 1
        playlistUpdateQueue.underlyingQueue = DispatchQueue.main
        playlistUpdateQueue.qualityOfService = .background
    }
    
    func clearPlaylist() {
        playlist.clear()
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.refresh, .all))
    }
    
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
    
    func removeTracks() {
        
        let tracksAndGroups = collectTracksAndGroups()
        let tracks = tracksAndGroups.tracks
        let groups = tracksAndGroups.groups
        
        if (groups.count == plAcc.getNumberOfGroups(self.groupType)) {
            clearPlaylist()
            return
        }
        
        playlist.removeTracksAndGroups(tracks, groups, groupType)
    }
    
    func tracksRemoved(_ results: RemoveOperationResults) {
        
        let removals = results.groupingPlaylistResults[self.groupType]!
        
        for removal in removals.results {
            
            if let trackRemoval = removal as? TracksRemovedResult {
                
                playlistView.removeItems(at: trackRemoval.trackIndexesInGroup, inParent: trackRemoval.parentGroup, withAnimation: .effectFade)
                playlistView.reloadItem(trackRemoval.parentGroup, reloadChildren: false)
                
            } else {
                
                let groupRemoval = removal as! GroupRemovedResult
                playlistView.removeItems(at: IndexSet(integer: groupRemoval.groupIndex), inParent: nil, withAnimation: .effectFade)
            }
        }
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChange(_ oldTrack: GroupedTrack?, _ newTrack: GroupedTrack?, _ errorState: Bool = false) {

        if (oldTrack != nil) {
            playlistView.reloadItem(oldTrack!.track)
        }

        if (newTrack != nil) {
            playlistView.reloadItem(newTrack!.track)
        }
    }
    
    // Selects (and shows) a certain track within the playlist view
    private func selectTrack(_ track: GroupedTrack?) {
        
        if (playlistView.numberOfRows > 0) {
            
            if let _track = track?.track {
                
                // Need to expand the parent to make the child visible
                playlistView.expandItem(track?.group)
                
                let trackIndex = playlistView.row(forItem: _track)
                
                playlistView.selectRowIndexes(IndexSet(integer: trackIndex), byExtendingSelection: false)
                showPlaylistSelectedRow()
            }
        }
    }

    // Scrolls the playlist to show its selected row
    private func showPlaylistSelectedRow() {
        
        if (playlistView.numberOfRows > 0 && playlistView.selectedRow >= 0) {
            playlistView.scrollRowToVisible(playlistView.selectedRow)
        }
    }
    
    // Scrolls the playlist view to the very top
    func scrollToTop() {
        
        if (playlistView.numberOfRows > 0) {
            playlistView.scrollRowToVisible(0)
        }
    }
    
    // Scrolls the playlist view to the very bottom
    func scrollToBottom() {
        
        if (playlistView.numberOfRows > 0) {
            playlistView.scrollRowToVisible(playlistView.numberOfRows - 1)
        }
    }
    
    func refresh() {
        playlistView.reloadData()
    }
    
    func moveTracksUp() {
        
        let tim = TimerUtils.start("moveUp")
        
        let tracksAndGroups = collectTracksAndGroups()
        let tracks = tracksAndGroups.tracks
        let groups = tracksAndGroups.groups
        
        // Cannot move both tracks and groups
        if (tracks.count > 0 && groups.count > 0) {
            return
        }
        
        let results = playlist.moveTracksAndGroupsUp(tracks, groups, self.groupType)
        moveItems(results)
        
        var allItems: [GroupedPlaylistItem] = [GroupedPlaylistItem]()
        groups.forEach({allItems.append($0)})
        tracks.forEach({allItems.append($0)})
        selectAllItems(allItems)
        
        playlistView.scrollRowToVisible(playlistView.selectedRow)
        
        tim.end()
    }
    
    private func moveItems(_ results: ItemMovedResults) {
        
        for result in results.results {
            
            if let trackMovedResult = result as? TrackMovedResult {
                
                playlistView.moveItem(at: trackMovedResult.oldTrackIndex, inParent: trackMovedResult.parentGroup, to: trackMovedResult.newTrackIndex, inParent: trackMovedResult.parentGroup)
                
            } else {
                
                let groupMovedResult = result as! GroupMovedResult
                playlistView.moveItem(at: groupMovedResult.oldGroupIndex, inParent: nil, to: groupMovedResult.newGroupIndex, inParent: nil)
            }
        }
    }
    
    private func selectAllItems(_ items: [GroupedPlaylistItem]) {
        var selIndexes = [Int]()
        items.forEach({selIndexes.append(playlistView.row(forItem: $0))})
        playlistView.selectRowIndexes(IndexSet(selIndexes), byExtendingSelection: false)
    }
    
    func moveTracksDown() {
        
        let tim = TimerUtils.start("moveDown")
        
        let tracksAndGroups = collectTracksAndGroups()
        let tracks = tracksAndGroups.tracks
        let groups = tracksAndGroups.groups
        
        // Cannot move both tracks and groups
        if (tracks.count > 0 && groups.count > 0) {
            return
        }
        
        let results = playlist.moveTracksAndGroupsDown(tracks, groups, self.groupType)
        moveItems(results)
        
        var allItems: [GroupedPlaylistItem] = [GroupedPlaylistItem]()
        groups.forEach({allItems.append($0)})
        tracks.forEach({allItems.append($0)})
        selectAllItems(allItems)
        
        playlistView.scrollRowToVisible(playlistView.selectedRow)
        
        tim.end()
    }
    
    private func trackAdded(_ message: TrackAddedAsyncMessage) {
        
        // Perform task serially wrt other such tasks
        
            // Find the groupInfo relevant to this playlist view
            let addResult = message.groupInfo[self.groupType]!
        
        let updateOp = BlockOperation(block: {
            
            self.playlistView.beginUpdates()
        
            if addResult.groupCreated {
                
                // Insert the new group
                
                print("\tInserting group", addResult.track.group.name, "at", addResult.track.groupIndex)

                self.playlistView.insertItems(at: IndexSet(integer: addResult.track.groupIndex), inParent: nil, withAnimation: .effectGap)
                
            } else {
                
                // Reload the existing group
                
                let group = addResult.track.group
                
//                self.playlistView.beginUpdates()
                self.playlistView.reloadItem(group, reloadChildren: false)
                self.playlistView.insertItems(at: IndexSet(integer: addResult.track.trackIndex), inParent: group, withAnimation: .effectGap)
//                self.playlistView.endUpdates()
            }
            
            self.playlistView.endUpdates()
        })
////
        playlistUpdateQueue.addOperation(updateOp)
    }
    
    private func trackUpdated(_ message: TrackUpdatedAsyncMessage) {
        
        let track = message.groupInfo[self.groupType]!.track
        let group = message.groupInfo[self.groupType]!.group
        
        let updateOp = BlockOperation(block: {
            
            self.playlistView.beginUpdates()
        
            self.playlistView.reloadItem(group, reloadChildren: false)
            self.playlistView.reloadItem(track)
            
            self.playlistView.endUpdates()
        })
            
        playlistUpdateQueue.addOperation(updateOp)
    }
    
    // Shows the currently playing track, within the playlist view
    func showPlayingTrack() {
        selectTrack(playbackInfo.getPlayingTrackGroupInfo(self.groupType))
    }
    
    private func showSearchResult(_ result: SearchResult) {
        selectTrack(result.location.groupInfo)
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
//        if self.groupType != .artist {
//            return
//        }
        
        if let msg = message as? TrackAddedAsyncMessage {
            
            trackAdded(msg)
//            adds += 1
//            print("\nAdds:", adds)
            return
        }
        
        
        
        if let msg = message as? TrackUpdatedAsyncMessage {
//            trackUpdated(msg)
            return
        }
        
        if let msg = message as? TracksRemovedAsyncMessage {
            
            let updateOp = BlockOperation(block: {
                self.tracksRemoved(msg.results)
            })
            
            playlistUpdateQueue.addOperation(updateOp)
            return
        }
        
//        if let msg = message as? TrackUpdatedAsyncMessage {
//            
//            trackUpdated(msg)
//            updates += 1
//            print("\nUpdates:", updates)
//            return
//        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
//        if self.groupType != .artist {
//            return
//        }
        
//        if let msg = notification as? TrackAddedNotification {
//            trackAdded(msg)
//            return
//        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        if PlaylistViewState.current == self.viewType, let req = request as? SearchResultSelectionRequest {
            showSearchResult(req.searchResult)
            
            return EmptyResponse.instance
        }
        
        return EmptyResponse.instance
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if let msg = message as? PlaylistActionMessage {
            
            if (msg.viewType != self.viewType && msg.viewType != .all) {
                return
            }
            
            switch (msg.actionType) {
                
            case .refresh: refresh()
                
            case .removeTracks: removeTracks()
                
            case .showPlayingTrack: showPlayingTrack()
                
            case .moveTracksUp: moveTracksUp()
                
            case .moveTracksDown: moveTracksDown()
                
            case .scrollToTop: scrollToTop()
                
            case .scrollToBottom: scrollToBottom()
                
            default: return
                
            }
            
            return
        }
    }
}

extension IndexSet {
    
    func toArray() -> [Int] {
        return self.filter({$0 >= 0})
    }
}

class PlaylistArtistsViewController: GroupingPlaylistViewController {
    override internal var groupType: GroupType {return .artist}
    override internal var viewType: PlaylistViewType {return .artists}
}

class PlaylistAlbumsViewController: GroupingPlaylistViewController {
    override internal var groupType: GroupType {return .album}
    override internal var viewType: PlaylistViewType {return .albums}
}

class PlaylistGenresViewController: GroupingPlaylistViewController {
    override internal var groupType: GroupType {return .genre}
    override internal var viewType: PlaylistViewType {return .genres}
}
