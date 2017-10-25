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
    
    override func viewDidLoad() {
        
        // Register self as a subscriber to various AsyncMessage notifications
        AsyncMessenger.subscribe(.trackAdded, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.tracksRemoved, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.tracksNotAdded, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.startedAddingTracks, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.doneAddingTracks, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.trackInfoUpdated, subscriber: self, dispatchQueue: DispatchQueue.main)
        
        // Register self as a subscriber to various synchronous message notifications
        SyncMessenger.subscribe(.trackChangedNotification, subscriber: self)
        SyncMessenger.subscribe(.removeTrackRequest, subscriber: self)
        
        SyncMessenger.subscribe(actionType: .removeTracks, subscriber: self)
        SyncMessenger.subscribe(actionType: .clearPlaylist, subscriber: self)
        SyncMessenger.subscribe(actionType: .moveTracksUp, subscriber: self)
        SyncMessenger.subscribe(actionType: .moveTracksDown, subscriber: self)
        SyncMessenger.subscribe(actionType: .refresh, subscriber: self)
        
        // Set up the serial operation queue for playlist view updates
        playlistUpdateQueue.maxConcurrentOperationCount = 1
        playlistUpdateQueue.underlyingQueue = DispatchQueue.main
        playlistUpdateQueue.qualityOfService = .background
    }
    
    func removeTracks() {
        
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
    @IBAction func scrollToTopAction(_ sender: AnyObject) {
        
        if (playlistView.numberOfRows > 0) {
            playlistView.scrollRowToVisible(0)
        }
    }
    
    // Scrolls the playlist view to the very bottom
    @IBAction func scrollToBottomAction(_ sender: AnyObject) {
        
        if (playlistView.numberOfRows > 0) {
            playlistView.scrollRowToVisible(playlistView.numberOfRows - 1)
        }
    }
    
    func clearPlaylist() {
//        playlistView.reloadData()
    }
    
    func moveTracksUp() {
        
    }
    
    func moveTracksDown() {
        
    }
    
    private func trackAdded(_ message: TrackAddedAsyncMessage) {
        
        // Perform task serially wrt other such tasks
        
        let updateOp = BlockOperation(block: {
            
            // Find the groupInfo relevant to this playlist view
            let addResult = message.groupInfo[self.groupType]!
            
            if addResult.groupCreated {
                
                // Insert the new group
                self.playlistView.insertItems(at: IndexSet(integer: addResult.track.groupIndex), inParent: nil, withAnimation: .effectGap)
                
            } else {
                
                // Reload the existing group
                
                let group = addResult.track.group
                
                self.playlistView.reloadItem(group, reloadChildren: false)
                self.playlistView.insertItems(at: IndexSet(integer: addResult.track.trackIndex), inParent: group, withAnimation: .effectGap)
            }
        })
        
        playlistUpdateQueue.addOperation(updateOp)
    }
    
    // Shows the currently playing track, within the playlist view
    @IBAction func showInPlaylistAction(_ sender: Any) {
//        selectTrack(playbackInfo.getPlayingTrack())
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if let msg = message as? TrackAddedAsyncMessage {
            
            trackAdded(msg)
            return
        }
        
        if let msg = message as? TracksRemovedAsyncMessage {
            
            let updateOp = BlockOperation(block: {
                self.tracksRemoved(msg.results)
            })
            
            playlistUpdateQueue.addOperation(updateOp)
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if (notification is TrackChangedNotification) {
//            let msg = notification as! TrackChangedNotification
//            trackChange(msg.oldTrack, msg.newTrack, msg.errorState)
            return
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        if (request is RemoveTrackRequest) {
//            let req = request as! RemoveTrackRequest
//            removeTracks([req.index])
        }
        
        return EmptyResponse.instance
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if let msg = message as? PlaylistActionMessage {
            
//            print("Got AM:", String(describing: msg.actionType))
            
            if (msg.viewType != self.viewType && msg.viewType != .all) {
//                print("Not for ", String(describing: self.viewType), ". Ignoring AM ...")
                return
            }
            
//            print("For ", String(describing: self.viewType), ". Processing AM ...")
            
            switch (msg.actionType) {
                
            case .refresh: playlistView.reloadData()
                
            case .removeTracks: removeTracks()
                
            case .clearPlaylist: clearPlaylist()
                
            case .moveTracksUp: moveTracksUp()
                
            case .moveTracksDown: moveTracksDown()
                
            default: print("AM = ", String(describing: msg.actionType))
                
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
