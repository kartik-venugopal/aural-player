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
    
    private var playlistViews: [NSTableView]?
    
    @IBOutlet weak var btnTracksView: NSButton!
    @IBOutlet weak var btnArtistsView: NSButton!
    @IBOutlet weak var btnAlbumsView: NSButton!
    @IBOutlet weak var btnGenresView: NSButton!
    
    @IBOutlet weak var tabGroup: NSTabView!
    private var tabViewButtons: [NSButton]?
    
    @IBOutlet weak var lblDurationSummary: NSTextField!
    @IBOutlet weak var lblTracksSummary: NSTextField!
    
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
    
    override func viewDidLoad() {
        
        // Enable drag n drop into the playlist view
        playlistViews = [tracksView, artistsView, albumsView, genresView]
        playlistViews!.forEach({$0.register(forDraggedTypes: [String(kUTTypeFileURL), "public.data"])})
        
        // Register self as a subscriber to various AsyncMessage notifications
        AsyncMessenger.subscribe(.trackAdded, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.trackInfoUpdated, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.tracksNotAdded, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.startedAddingTracks, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.doneAddingTracks, subscriber: self, dispatchQueue: DispatchQueue.main)
        
        // Register self as a subscriber to various synchronous message notifications
        SyncMessenger.subscribe(.removeTrackRequest, subscriber: self)
        
        // Set up the serial operation queue for playlist view updates
        playlistUpdateQueue.maxConcurrentOperationCount = 1
        playlistUpdateQueue.underlyingQueue = DispatchQueue.main
        playlistUpdateQueue.qualityOfService = .background
        
        // Set up key press handler to enable natural scrolling of the playlist view with arrow keys
        playlistKeyPressHandler = PlaylistKeyPressHandler(playlistViews!)
        NSEvent.addLocalMonitorForEvents(matching: NSEventMask.keyDown, handler: {(event: NSEvent!) -> NSEvent in
            self.playlistKeyPressHandler?.handle(event)
            return event;
        });
        
        tabViewButtons = [btnTracksView, btnArtistsView, btnAlbumsView, btnGenresView]
        
        artistsTabViewAction(self)
        albumsTabViewAction(self)
        genresTabViewAction(self)
        
        // Default view is the Tracks view
        tracksTabViewAction(self)
    }
    
    @IBAction func addTracksAction(_ sender: AnyObject) {
        
        let dialog = UIElements.openDialog
        
        let modalResponse = dialog.runModal()
        
        if (modalResponse == NSModalResponseOK) {
            addFiles(dialog.urls)
        }
    }
    
    // Adds a set of files (or directories, i.e. files within them) to the current playlist, if supported
    private func addFiles(_ files: [URL]) {
        startedAddingTracks()
        playlist.addFiles(files)
    }
    
    // When a track add operation starts, the spinner needs to be initialized
    private func startedAddingTracks() {
        
        playlistWorkSpinner.doubleValue = 0
        playlistWorkSpinner.isHidden = false
        playlistWorkSpinner.startAnimation(self)
    }
    
    // When a track add operation ends, the spinner needs to be de-initialized
    private func doneAddingTracks() {
        
        playlistWorkSpinner.stopAnimation(self)
        playlistWorkSpinner.isHidden = true
        
        if (playbackInfo.getPlayingTrack() != nil) {
            let seqInfo = playbackInfo.getPlaybackSequenceInfo()
            let sequenceChangedMsg = SequenceChangedNotification(seqInfo.scope, seqInfo.trackIndex, seqInfo.totalTracks)
            SyncMessenger.publishNotification(sequenceChangedMsg)
        }
    }
    
    private func handleTracksNotAddedError(_ errors: [InvalidTrackError]) {
        
        // This needs to be done async. Otherwise, the add files dialog hangs.
        DispatchQueue.main.async {
            _ = UIUtils.showAlert(UIElements.tracksNotAddedAlertWithErrors(errors))
        }
    }
    
    // If tracks are currently being added to the playlist, the optional progress argument contains progress info that the spinner control uses for its animation
    private func updatePlaylistSummary(_ trackAddProgress: TrackAddedMessageProgress? = nil) {
        
        if (PlaylistViewState.current == .tracks) {
            
            let summary = playlist.summary()
            let numTracks = summary.size
            let duration = StringUtils.formatSecondsToHMS(summary.totalDuration)
            
            lblTracksSummary.stringValue = String(format: "%d %@", numTracks, numTracks == 1 ? "track" : "tracks")
            lblDurationSummary.stringValue = String(format: "%@", duration)
            
        } else {
            
            let groupType = PlaylistViewState.groupType!
            let summary = playlist.summary(groupType)
            
            let numGroups = summary.numGroups
            let numTracks = summary.size
            let duration = StringUtils.formatSecondsToHMS(summary.totalDuration)
            
            lblTracksSummary.stringValue = String(format: "%d %@   %d %@", numGroups, groupType.rawValue + (numGroups == 1 ? "" : "s"), numTracks, numTracks == 1 ? "track" : "tracks", duration)
            lblDurationSummary.stringValue = String(format: "%@", duration)
        }
        
        // Update spinner with current progress, if tracks are being added
        if (trackAddProgress != nil) {
            playlistWorkSpinner.doubleValue = trackAddProgress!.percentage
        }
    }
    
    @IBAction func removeTracksAction(_ sender: AnyObject) {
        
        let message = PlaylistActionMessage(.removeTracks, PlaylistViewState.current)
        SyncMessenger.publishActionMessage(message)
        
        if (playbackInfo.getPlayingTrack() != nil) {
            let seqInfo = playbackInfo.getPlaybackSequenceInfo()
            let sequenceChangedMsg = SequenceChangedNotification(seqInfo.scope, seqInfo.trackIndex, seqInfo.totalTracks)
            SyncMessenger.publishNotification(sequenceChangedMsg)
        }
        
        updatePlaylistSummary()
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
    
    @IBAction func clearPlaylistAction(_ sender: AnyObject) {
        
        playlist.clear()
        
        let message = PlaylistActionMessage(.clearPlaylist, PlaylistViewState.current)
        SyncMessenger.publishActionMessage(message)
        
        let refreshMsg = PlaylistActionMessage(.refresh, nil)
        SyncMessenger.publishActionMessage(refreshMsg)
        
        updatePlaylistSummary()
        
        // Request the player to stop playback, if there is a track playing
        _ = SyncMessenger.publishRequest(StopPlaybackRequest.instance)
    }
    
    @IBAction func moveTracksUpAction(_ sender: AnyObject) {
        
        let message = PlaylistActionMessage(.moveTracksUp, PlaylistViewState.current)
        SyncMessenger.publishActionMessage(message)
        
        if (playbackInfo.getPlayingTrack() != nil) {
            let seqInfo = playbackInfo.getPlaybackSequenceInfo()
            let sequenceChangedMsg = SequenceChangedNotification(seqInfo.scope, seqInfo.trackIndex, seqInfo.totalTracks)
            SyncMessenger.publishNotification(sequenceChangedMsg)
        }
    }
    
    @IBAction func moveTracksDownAction(_ sender: AnyObject) {
        
        let message = PlaylistActionMessage(.moveTracksDown, PlaylistViewState.current)
        SyncMessenger.publishActionMessage(message)
        
        if (playbackInfo.getPlayingTrack() != nil) {
            let seqInfo = playbackInfo.getPlaybackSequenceInfo()
            let sequenceChangedMsg = SequenceChangedNotification(seqInfo.scope, seqInfo.trackIndex, seqInfo.totalTracks)
            SyncMessenger.publishNotification(sequenceChangedMsg)
        }
    }
    
    // Scrolls the playlist view to the very top
    @IBAction func scrollToTopAction(_ sender: AnyObject) {
        
        let message = PlaylistActionMessage(.scrollToTop, PlaylistViewState.current)
        SyncMessenger.publishActionMessage(message)
    }
    
    // Scrolls the playlist view to the very bottom
    @IBAction func scrollToBottomAction(_ sender: AnyObject) {
        
        let message = PlaylistActionMessage(.scrollToBottom, PlaylistViewState.current)
        SyncMessenger.publishActionMessage(message)
    }
    
    // Shows the currently playing track, within the playlist view
    @IBAction func showPlayingTrackAction(_ sender: Any) {
        
        let message = PlaylistActionMessage(.showPlayingTrack, PlaylistViewState.current)
        SyncMessenger.publishActionMessage(message)
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if message is TrackAddedAsyncMessage {
            
            let _msg = message as! TrackAddedAsyncMessage
            
            // Perform task serially wrt other such tasks
            
            let updateOp = BlockOperation(block: {
                self.updatePlaylistSummary(_msg.progress)
            })
            
            playlistUpdateQueue.addOperation(updateOp)
            
            return
        }
        
        if (message is TrackUpdatedAsyncMessage) {
            
            // Perform task serially wrt other such tasks
            
            let updateOp = BlockOperation(block: {
                
                let _msg = (message as! TrackUpdatedAsyncMessage)
                
                self.updatePlaylistSummary()
                
                // If this is the playing track, tell other views that info has been updated
                let playingTrackIndex = self.playbackInfo.getPlayingTrack()?.index
                if (playingTrackIndex == _msg.trackIndex) {
                    SyncMessenger.publishNotification(PlayingTrackInfoUpdatedNotification.instance)
                }
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
    }
    
    func consumeNotification(_ message: NotificationMessage) {
        
//        if message is TrackAddedNotification {
//            
//            let _msg = message as! TrackAddedNotification
//            
//            // Perform task serially wrt other such tasks
//            
//            let updateOp = BlockOperation(block: {
//                self.updatePlaylistSummary(_msg.progress)
//            })
//            
//            playlistUpdateQueue.addOperation(updateOp)
//            
//            return
//        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        if (request is RemoveTrackRequest) {
            
            let req = request as! RemoveTrackRequest
            _ = playlist.removeTracks([req.index])
            
            // TODO: Send out refresh message to all views
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
        
        PlaylistViewState.current = .tracks
        updatePlaylistSummary()
        SyncMessenger.publishNotification(PlaylistTypeChangedNotification(newPlaylistType: .tracks))
    }
    
    @IBAction func artistsTabViewAction(_ sender: Any) {
        
        tabViewButtons!.forEach({
            $0.state = 0
            $0.needsDisplay = true
        })
        
        btnArtistsView.state = 1
        tabGroup.selectTabViewItem(at: 1)
        
        PlaylistViewState.current = .artists
        updatePlaylistSummary()
        SyncMessenger.publishNotification(PlaylistTypeChangedNotification(newPlaylistType: .artists))
    }
    
    @IBAction func albumsTabViewAction(_ sender: Any) {
        
        tabViewButtons!.forEach({
            $0.state = 0
            $0.needsDisplay = true
        })
        
        btnAlbumsView.state = 1
        tabGroup.selectTabViewItem(at: 2)
        
        PlaylistViewState.current = .albums
        updatePlaylistSummary()
        SyncMessenger.publishNotification(PlaylistTypeChangedNotification(newPlaylistType: .albums))
    }
    
    @IBAction func genresTabViewAction(_ sender: Any) {
        
        tabViewButtons!.forEach({
            $0.state = 0
            $0.needsDisplay = true
        })
        
        btnGenresView.state = 1
        tabGroup.selectTabViewItem(at: 3)
        
        PlaylistViewState.current = .genres
        updatePlaylistSummary()
        SyncMessenger.publishNotification(PlaylistTypeChangedNotification(newPlaylistType: .genres))
    }
}

class PlaylistViewState {
    
    static var current: PlaylistType = .tracks
    static var groupType: GroupType? {
    
        switch current {
            
        case .albums: return GroupType.album
            
        case .artists: return GroupType.artist
            
        case .genres: return GroupType.genre
            
        default: return nil
        }
    }
}
