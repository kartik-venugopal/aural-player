/*
 View controller for playlist CRUD controls (adding/removing/reordering tracks and saving/loading to/from playlists)
 */

import Cocoa
import Foundation

class PlaylistViewController: NSViewController, AsyncMessageSubscriber, MessageSubscriber {
    
    // Displays the playlist and summary
    
    @IBOutlet weak var tracksView: NSTableView!
    @IBOutlet weak var artistsView: NSOutlineView!
    @IBOutlet weak var albumsView: NSOutlineView!
    @IBOutlet weak var genresView: NSOutlineView!
    
    @IBOutlet weak var btnTracksView: NSButton!
    @IBOutlet weak var btnArtistsView: NSButton!
    @IBOutlet weak var btnAlbumsView: NSButton!
    @IBOutlet weak var btnGenresView: NSButton!
    
    @IBOutlet weak var tabGroup: NSTabView!
    private var tabViewButtons: [NSButton]?
    
    @IBOutlet weak var lblPlaylistSummary: NSTextField!
    @IBOutlet weak var playlistWorkSpinner: NSProgressIndicator!
    
    // Box that encloses the playlist controls. Used to position the spinner.
    @IBOutlet weak var controlsBox: NSBox!
    
    // Delegate that performs CRUD actions on the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    private let plAcc: PlaylistAccessorProtocol = ObjectGraph.getPlaylistAccessor()
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // A serial operation queue to help perform playlist update tasks serially, without overwhelming the main thread
    private let playlistUpdateQueue = OperationQueue()
    
    // Needed for playlist scrolling with arrow keys
    private var playlistKeyPressHandler: PlaylistKeyPressHandler?
    
    private var currentPlaylistView: NSTableView?
    private var currentViewGrouped: Bool = false
    private var currentGroupType: GroupType?
    
    override func viewDidLoad() {
        
        // Enable drag n drop into the playlist view
        tracksView.register(forDraggedTypes: [String(kUTTypeFileURL), "public.data"])
        
        // Register self as a subscriber to various AsyncMessage notifications
        AsyncMessenger.subscribe(.trackAdded, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.groupAdded, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.tracksNotAdded, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.startedAddingTracks, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.doneAddingTracks, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.trackInfoUpdated, subscriber: self, dispatchQueue: DispatchQueue.main)
        
        // Register self as a subscriber to various synchronous message notifications
        SyncMessenger.subscribe(.trackChangedNotification, subscriber: self)
        SyncMessenger.subscribe(.removeTrackRequest, subscriber: self)
        
        // Set up the serial operation queue for playlist view updates
        playlistUpdateQueue.maxConcurrentOperationCount = 1
        playlistUpdateQueue.underlyingQueue = DispatchQueue.main
        playlistUpdateQueue.qualityOfService = .background
        
        // Set up key press handler to enable natural scrolling of the playlist view with arrow keys
        playlistKeyPressHandler = PlaylistKeyPressHandler([tracksView, artistsView])
        NSEvent.addLocalMonitorForEvents(matching: NSEventMask.keyDown, handler: {(event: NSEvent!) -> NSEvent in
            self.playlistKeyPressHandler?.handle(event)
            return event;
        });
        
        tabViewButtons = [btnTracksView, btnArtistsView, btnAlbumsView, btnGenresView]
        
//        tracksTabViewAction(self)
        artistsTabViewAction(self)
    }
    
    // If tracks are currently being added to the playlist, the optional progress argument contains progress info that the spinner control uses for its animation
    private func updatePlaylistSummary(_ trackAddProgress: TrackAddedAsyncMessageProgress? = nil) {
        
        let summary = playlist.summary()
        let numTracks = summary.size
        
        lblPlaylistSummary.stringValue = String(format: "%d %@   %@", numTracks, numTracks == 1 ? "track" : "tracks", StringUtils.formatSecondsToHMS(summary.totalDuration))
        
        // Update spinner
        if (trackAddProgress != nil) {
            repositionSpinner()
            playlistWorkSpinner.doubleValue = trackAddProgress!.percentage
        }
    }
    
    @IBAction func addTracksAction(_ sender: AnyObject) {
        
        let dialog = UIElements.openDialog
        
        let modalResponse = dialog.runModal()
        
        if (modalResponse == NSModalResponseOK) {
            addFiles(dialog.urls)
        }
    }
    
    // When a track add operation starts, the spinner needs to be initialized
    private func startedAddingTracks() {
        
        playlistWorkSpinner.doubleValue = 0
        repositionSpinner()
        playlistWorkSpinner.isHidden = false
        playlistWorkSpinner.startAnimation(self)
    }
    
    // When a track add operation ends, the spinner needs to be de-initialized
    private func doneAddingTracks() {
        
        playlistWorkSpinner.stopAnimation(self)
        playlistWorkSpinner.isHidden = true
        
//        Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.refreshGroupedView(_:)), userInfo: nil, repeats: false)
    }
    
    @IBAction func refreshGroupedView(_ sender: AnyObject) {
        if let gv = currentPlaylistView as? NSOutlineView {
//        gv.reloadData()
//        print("GV refreshed !")
        }
    }
    
    // Move the spinner so it is adjacent to the summary text, on the left
    private func repositionSpinner() {
        
        let summaryString: NSString = lblPlaylistSummary.stringValue as NSString
        let size: CGSize = summaryString.size(withAttributes: [NSFontAttributeName: lblPlaylistSummary.font as AnyObject])
        let lblWidth = size.width
        
        let controlsBoxWidth = controlsBox.frame.width
        let newX = controlsBoxWidth - lblWidth - 10 - playlistWorkSpinner.frame.width
        playlistWorkSpinner.frame.origin.x = newX
    }
    
    @IBAction func removeTracksAction(_ sender: AnyObject) {
        
        if (currentPlaylistView == tracksView) {
        
            let selectedIndexes = tracksView.selectedRowIndexes
            if (selectedIndexes.count > 0) {
                
                // Special case: If all tracks were removed, this is the same as clearing the playlist, delegate to that (simpler and more efficient) function instead.
                if (selectedIndexes.count == tracksView.numberOfRows) {
                    clearPlaylistAction(sender)
                    return
                }
                
                // The $0 comparison is not needed, except to appease the compiler
                let indexes = selectedIndexes.filter({$0 >= 0})
                if (!indexes.isEmpty) {
                    removeTracks(indexes)
                }
                
                // Clear the playlist selection
                tracksView.deselectAll(self)
            }
            
        } else {
            
            // Sort ascending
            let indexes = artistsView.selectedRowIndexes.sorted(by: {x, y -> Bool in x < y})
            print("\nInx:", indexes)
            
//            var request = RemoveTracksAndGroupsRequest()
            var removedTracks: [Group: [Track]] = [Group: [Track]]()
            var removedGroups: [Group] = [Group]()
            
            var cur = 0
            
            while cur < indexes.count {
                
                let index = indexes[cur]
                let item = artistsView.item(atRow: index)
                
                if let group = item as? Group {
                    
                    removedGroups.append(group)
                    if (artistsView.isItemExpanded(group)) {
                        
                        // Skip all the group's selected children
                        let maxChildIndex = index + group.size()
                        while cur < indexes.count && indexes[cur] <= maxChildIndex {
                            cur += 1
                        }
                        
                        cur -= 1
                    }
                    
                } else {
                    
                    // Track
                    let track = item as! Track
                    let group = artistsView.parent(forItem: track) as! Group
                    
                    if (removedTracks[group] == nil) {
                        removedTracks[group] = [Track]()
                    }
                    
                    removedTracks[group]?.append(track)
                }
                
                cur += 1
            }
            
            for (group, tracks) in removedTracks {
                
                // If all tracks in group were removed, just remove the group instead
                if (tracks.count == group.size()) {
                    print("Removing group because all tracks selected:", group.name)
                    removedGroups.append(group)
                } else {
                    
                    // Sort descending by track number
                    removedTracks[group] = tracks.sorted(by: {t1, t2 -> Bool in
                        return group.indexOf(t1) > group.indexOf(t2)
                    })
                }
            }
            
            removedGroups.forEach({removedTracks.removeValue(forKey: $0)})
            
            var requestMappings: [(group: Group, groupIndex: Int, tracks: [Track]?, groupRemoved: Bool)] = [(group: Group, groupIndex: Int, tracks: [Track]?, groupRemoved: Bool)]()
            
            removedTracks.forEach({requestMappings.append(($0.key, plAcc.getGroupIndex($0.key), $0.value, false))})
            removedGroups.forEach({requestMappings.append(($0, plAcc.getGroupIndex($0), nil, true))})
            
            requestMappings = requestMappings.sorted(by: {m1, m2 -> Bool in
                return m1.groupIndex > m2.groupIndex
            })
            
            let request = RemoveTracksAndGroupsRequest(requestMappings)
            playlist.removeTracksAndGroups(request)
            
//            for (group, groupIndex, tracks, groupRemoved) in requestMappings {
//                
//                if (groupRemoved) {
//                    
//                    artistsView.removeItems(at: IndexSet(integer: groupIndex), inParent: nil, withAnimation: .effectFade)
//                } else {
//                    
//                    // Tracks
//                    for track in tracks! {
//                        artistsView.removeItems(at: IndexSet(integer: group.indexOf(track)), inParent: group, withAnimation: .effectFade)
//                        artistsView.reloadItem(group)
//                    }
//                }
//            }
            
            let tim = TimerUtils.start("reloadArtistsView")
            artistsView.reloadData()
            tim.end()
            
            TimerUtils.printStats()
            
            updatePlaylistSummary()
        }
    }
    
    // Assume non-empty array and valid indexes
    private func removeTracks(_ indexes: [Int]) {
        
        // Note down the index of the playing track, if there is one
        let oldPlayingTrackIndex = playbackInfo.getPlayingTrack()?.index
        
        // Remove the tracks from the playlist
        _ = playlist.removeTracks(indexes)
        
        // Update all rows from the first (i.e. smallest number) selected row, down to the end of the playlist
        
        let newPlaylistSize = tracksView.numberOfRows - indexes.count
        let minIndex = (indexes.min())!
        let newLastIndex = newPlaylistSize - 1
        
        // If not all selected rows are contiguous and at the end of the playlist
        if (minIndex <= newLastIndex) {
            let rowIndexes = IndexSet(minIndex...newLastIndex)
            tracksView.reloadData(forRowIndexes: rowIndexes, columnIndexes: UIConstants.playlistViewColumnIndexes)
        }
        
        // Tell the playlist view that the number of rows has changed, and update the playlist summary
        tracksView.noteNumberOfRowsChanged()
        updatePlaylistSummary()
        
        // Request the player to stop playback, if the playing track was removed
        if (oldPlayingTrackIndex != nil && indexes.contains(oldPlayingTrackIndex!)) {
            SyncMessenger.publishRequest(StopPlaybackRequest.instance)
        }
    }
    
    private func handleTracksNotAddedError(_ errors: [InvalidTrackError]) {
        
        // This needs to be done async. Otherwise, the add files dialog hangs.
        DispatchQueue.main.async {
            UIUtils.showAlert(UIElements.tracksNotAddedAlertWithErrors(errors))
        }
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChange(_ oldTrack: IndexedTrack?, _ newTrack: IndexedTrack?, _ errorState: Bool = false) {
        
        var rowsArr = [Int]()
        
        if (oldTrack != nil) {
            rowsArr.append(oldTrack!.index)
        }
        
        if (newTrack != nil) {
            rowsArr.append(newTrack!.index)
        }
        
        tracksView.reloadData(forRowIndexes: IndexSet(rowsArr), columnIndexes: UIConstants.playlistViewColumnIndexes)
    }
    
    // Selects (and shows) a certain track within the playlist view
    private func selectTrack(_ track: IndexedTrack?) {
        
        if (!currentViewGrouped) {
            
            if (tracksView.numberOfRows > 0) {
                
                let index = track?.index
                
                if (index != nil && index! >= 0) {
                    tracksView.selectRowIndexes(IndexSet(integer: index!), byExtendingSelection: false)
                } else {
                    // Select first track in list
                    tracksView.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
                }
                
                showPlaylistSelectedRow()
            }
            
        } else {
            
            let groupedView = currentPlaylistView as! NSOutlineView
            
            if (groupedView.numberOfRows > 0) {
                
                if let _track = track?.track {
                    
                    let ginfo = plAcc.getGroupingInfoForTrack(_track, currentGroupType!)
                    
                    // Need to expand the parent to make the child visible
                    groupedView.expandItem(ginfo.group)
                    
                    let trackIndex = groupedView.row(forItem: _track)
                    
                    groupedView.selectRowIndexes(IndexSet(integer: trackIndex), byExtendingSelection: false)
                    groupedView.scrollRowToVisible(trackIndex)
                    
                } else {
                    // Expand unknown folder
                }
            }
        }
    }
    
    // Scrolls the playlist to show its selected row
    private func showPlaylistSelectedRow() {
        if (tracksView.numberOfRows > 0 && tracksView.selectedRow >= 0) {
            tracksView.scrollRowToVisible(tracksView.selectedRow)
        }
    }
    
    // Scrolls the playlist view to the very top
    @IBAction func scrollToTopAction(_ sender: AnyObject) {
        if (tracksView.numberOfRows > 0) {
            tracksView.scrollRowToVisible(0)
        }
    }
    
    // Scrolls the playlist view to the very bottom
    @IBAction func scrollToBottomAction(_ sender: AnyObject) {
        if (tracksView.numberOfRows > 0) {
            tracksView.scrollRowToVisible(tracksView.numberOfRows - 1)
        }
    }
    
    @IBAction func clearPlaylistAction(_ sender: AnyObject) {
        
        playlist.clear()
        
        [tracksView, artistsView, albumsView, genresView].forEach({$0?.reloadData()})
        updatePlaylistSummary()
        
        // Request the player to stop playback, if there is a track playing
        SyncMessenger.publishRequest(StopPlaybackRequest.instance)
    }
    
    @IBAction func moveTracksDownAction(_ sender: AnyObject) {
        moveTracksDown()
    }
    
    @IBAction func moveTracksUpAction(_ sender: AnyObject) {
        moveTracksUp()
    }
    
    private func moveTracksUp() {
        
        if (tracksView.selectedRowIndexes.count > 0) {
            
            let selRows = tracksView.selectedRowIndexes
            let newIndexes = playlist.moveTracksUp(selRows)
            
            let refreshIndexes = selRows.union(newIndexes)
            
            // Reload data in the affected rows
            tracksView.reloadData(forRowIndexes: IndexSet(refreshIndexes), columnIndexes: UIConstants.playlistViewColumnIndexes)
            
            tracksView.selectRowIndexes(IndexSet(newIndexes), byExtendingSelection: false)
        }
    }
    
    private func moveTracksDown() {
        
        if (tracksView.selectedRowIndexes.count > 0) {
            
            let selRows = tracksView.selectedRowIndexes
            let newIndexes = playlist.moveTracksDown(selRows)
            
            let refreshIndexes = selRows.union(newIndexes)
            
            // Reload data in the affected rows
            tracksView.reloadData(forRowIndexes: IndexSet(refreshIndexes), columnIndexes: UIConstants.playlistViewColumnIndexes)
            
            tracksView.selectRowIndexes(IndexSet(newIndexes), byExtendingSelection: false)
        }
    }
    
    @IBAction func savePlaylistAction(_ sender: AnyObject) {
        
        // Make sure there is at least one track to save
        if (playlist.summary().size > 0) {
            
            let dialog = UIElements.savePlaylistDialog
            
            let modalResponse = dialog.runModal()
            
            if (modalResponse == NSModalResponseOK) {
                
                let file = dialog.url
                playlist.savePlaylist(file!)
            }
        }
    }
    
    // Adds a set of files (or directories, i.e. files within them) to the current playlist, if supported
    private func addFiles(_ files: [URL]) {
        startedAddingTracks()
        playlist.addFiles(files)
    }
    
    // Shows the currently playing track, within the playlist view
    @IBAction func showInPlaylistAction(_ sender: Any) {
        selectTrack(playbackInfo.getPlayingTrack())
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if message is TrackAddedAsyncMessage {
            
            let _msg = message as! TrackAddedAsyncMessage
            
            // Perform task serially wrt other such tasks
            
            let updateOp = BlockOperation(block: {
                
//                self.tracksView.noteNumberOfRowsChanged()
                
                let group = _msg.group
                self.artistsView.reloadItem(group, reloadChildren: true)
                
                self.updatePlaylistSummary(_msg.progress)
            })
            
            playlistUpdateQueue.addOperation(updateOp)
            
            return
        }
        
        if message is GroupAddedAsyncMessage {
            
            let msg = message as! GroupAddedAsyncMessage
            
            let updateOp = BlockOperation(block: {
                self.artistsView.insertItems(at: IndexSet(integer: msg.groupIndex), inParent: nil, withAnimation: NSTableViewAnimationOptions.effectFade)
            })
            
            playlistUpdateQueue.addOperation(updateOp)
            
            return
        }
        
        if message is TracksNotAddedAsyncMessage {
            let _msg = message as! TracksNotAddedAsyncMessage
            handleTracksNotAddedError(_msg.errors)
            return
        }
        
        if message is StartedAddingTracksAsyncMessage {
            startedAddingTracks()
            return
        }
        
        if message is DoneAddingTracksAsyncMessage {
            doneAddingTracks()
            return
        }
        
        if (message is TrackInfoUpdatedAsyncMessage) {
            
            // Perform task serially wrt other such tasks
            
            let updateOp = BlockOperation(block: {
                
                let _msg = (message as! TrackInfoUpdatedAsyncMessage)
                let index = _msg.trackIndex
                
                
//                self.tracksView.reloadData(forRowIndexes: IndexSet(integer: index), columnIndexes: UIConstants.playlistViewColumnIndexes)
                
                let track = self.playlist.peekTrackAt(index)
                let group = _msg.group
                
//                NSLog("Reloading group: %@ for UPDATED track: %@", group.name, track?.track.conciseDisplayName)
                let tn = track?.track.conciseDisplayName
                NSLog("Reloading group: %@ for UPDATED track: %@", group.name, tn ?? "FUCK")
                
                self.artistsView.reloadItem(group, reloadChildren: true)
                
                self.updatePlaylistSummary()
                
                // If this is the playing track, tell other views that info has been updated
                let playingTrackIndex = self.playbackInfo.getPlayingTrack()?.index
                if (playingTrackIndex == index) {
                    SyncMessenger.publishNotification(PlayingTrackInfoUpdatedNotification.instance)
                }
            })
            
            playlistUpdateQueue.addOperation(updateOp)
            
            return
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if (notification is TrackChangedNotification) {
            let msg = notification as! TrackChangedNotification
            trackChange(msg.oldTrack, msg.newTrack, msg.errorState)
            return
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        if (request is RemoveTrackRequest) {
            let req = request as! RemoveTrackRequest
            removeTracks([req.index])
        }
        
        return EmptyResponse.instance
    }
    
    @IBAction func tracksTabViewAction(_ sender: Any) {
     
        tabViewButtons!.forEach({
            $0.state = 0
            $0.needsDisplay = true
        })
        
        btnTracksView.state = 1
        tabGroup.selectTabViewItem(at: 0)
        
        currentPlaylistView = tracksView
        currentViewGrouped = false
        currentGroupType = nil
    }
    
    @IBAction func artistsTabViewAction(_ sender: Any) {
        
//        artistsView.reloadData()
        
        tabViewButtons!.forEach({
            $0.state = 0
            $0.needsDisplay = true
        })
        
        btnArtistsView.state = 1
        tabGroup.selectTabViewItem(at: 1)
        
        currentPlaylistView = artistsView
        currentViewGrouped = true
        currentGroupType = .artist
    }
    
    @IBAction func albumsTabViewAction(_ sender: Any) {
        
//        albumsView.reloadData()
        
        tabViewButtons!.forEach({
            $0.state = 0
            $0.needsDisplay = true
        })
        
        btnAlbumsView.state = 1
        tabGroup.selectTabViewItem(at: 2)
        
        currentPlaylistView = albumsView
        currentViewGrouped = true
        currentGroupType = .album
    }
    
    @IBAction func genresTabViewAction(_ sender: Any) {
        
//        genresView.reloadData()
        
        tabViewButtons!.forEach({
            $0.state = 0
            $0.needsDisplay = true
        })
        
        btnGenresView.state = 1
        tabGroup.selectTabViewItem(at: 3)
        
        currentPlaylistView = genresView
        currentViewGrouped = true
        currentGroupType = .genre
    }
}
