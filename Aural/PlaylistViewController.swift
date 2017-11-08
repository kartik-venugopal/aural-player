/*
    View controller for playlist CRUD controls (adding/removing/reordering tracks and saving/loading to/from playlist files)
 */

import Cocoa
import Foundation

class PlaylistViewController: NSViewController, AsyncMessageSubscriber, MessageSubscriber {
    
    // The 4 different playlist views
    @IBOutlet weak var tracksView: NSTableView!
    @IBOutlet weak var artistsView: NSOutlineView!
    @IBOutlet weak var albumsView: NSOutlineView!
    @IBOutlet weak var genresView: NSOutlineView!
    
    // The tab group that switches between the 4 playlist views
    @IBOutlet weak var tabGroup: NSTabView!
    
    // Tab group buttons
    @IBOutlet weak var btnTracksView: NSButton!
    @IBOutlet weak var btnArtistsView: NSButton!
    @IBOutlet weak var btnAlbumsView: NSButton!
    @IBOutlet weak var btnGenresView: NSButton!
    
    private var tabGroupButtons: [NSButton]?
    
    // Fields that display playlist summary info
    @IBOutlet weak var lblTracksSummary: NSTextField!
    @IBOutlet weak var lblDurationSummary: NSTextField!
    
    // Spinner that shows progress when tracks are being added to the playlist
    @IBOutlet weak var playlistWorkSpinner: NSProgressIndicator!
    
    // Delegate that relays CRUD actions to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    // Delegate that retrieves current playback info
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    override func viewDidLoad() {
        
        // Enable drag n drop into the playlist views
        [tracksView, artistsView, albumsView, genresView].forEach({$0.register(forDraggedTypes: [String(kUTTypeFileURL), "public.data"])})
        
        // Register self as a subscriber to various AsyncMessage notifications
        AsyncMessenger.subscribe([.trackAdded, .trackInfoUpdated, .tracksRemoved, .tracksNotAdded, .startedAddingTracks, .doneAddingTracks], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        // Register self as a subscriber to various synchronous message notifications
        SyncMessenger.subscribe(messageTypes: [.removeTrackRequest], subscriber: self)
        
        // Set up key press handler to enable natural scrolling of the playlist view with arrow keys and expansion/collapsing of track groups.
        
        let viewMappings: [PlaylistType: NSTableView] = [PlaylistType.tracks: tracksView, PlaylistType.artists: artistsView, PlaylistType.albums: albumsView, PlaylistType.genres: genresView]
        
        let playlistKeyPressHandler = PlaylistKeyPressHandler(viewMappings)
        NSEvent.addLocalMonitorForEvents(matching: NSEventMask.keyDown, handler: {(event: NSEvent!) -> NSEvent in
            playlistKeyPressHandler.handle(event)
            return event;
        });
        
        tabGroupButtons = [btnTracksView, btnArtistsView, btnAlbumsView, btnGenresView]
        
        // Set up tab group
        
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
            startedAddingTracks()
            playlist.addFiles(dialog.urls)
        }
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
        
        sequenceChanged()
    }
    
    private func sequenceChanged() {
        
        if (playbackInfo.getPlayingTrack() != nil) {
            SyncMessenger.publishNotification(SequenceChangedNotification.instance)
        }
    }
    
    private func tracksNotAdded(_ message: TracksNotAddedAsyncMessage) {
        
        // This needs to be done async. Otherwise, the add files dialog hangs.
        DispatchQueue.main.async {
            _ = UIUtils.showAlert(UIElements.tracksNotAddedAlertWithErrors(message.errors))
        }
    }
    
    // If tracks are currently being added to the playlist, the optional progress argument contains progress info that the spinner control uses for its animation
    private func updatePlaylistSummary(_ trackAddProgress: TrackAddedMessageProgress? = nil) {
        
        let summary = playlist.summary(PlaylistViewState.current)
        
        if (PlaylistViewState.current == .tracks) {
            
            let numTracks = summary.size
            let duration = StringUtils.formatSecondsToHMS(summary.totalDuration)
            
            lblTracksSummary.stringValue = String(format: "%d %@", numTracks, numTracks == 1 ? "track" : "tracks")
            lblDurationSummary.stringValue = String(format: "%@", duration)
            
        } else {
            
            let groupType = PlaylistViewState.groupType!
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
        
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.removeTracks, PlaylistViewState.current))
        
        sequenceChanged()
        updatePlaylistSummary()
    }
    
    @IBAction func savePlaylistAction(_ sender: AnyObject) {
        
        // Make sure there is at least one track to save
        if (playlist.size() > 0) {
            
            let dialog = UIElements.savePlaylistDialog
            let modalResponse = dialog.runModal()
            
            if (modalResponse == NSModalResponseOK) {
                playlist.savePlaylist(dialog.url!)
            }
        }
    }
    
    @IBAction func clearPlaylistAction(_ sender: AnyObject) {
        
        playlist.clear()
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.refresh, nil))
        
        updatePlaylistSummary()
    }
    
    @IBAction func moveTracksUpAction(_ sender: AnyObject) {
        
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksUp, PlaylistViewState.current))
        sequenceChanged()
    }
    
    @IBAction func moveTracksDownAction(_ sender: AnyObject) {
        
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksDown, PlaylistViewState.current))
        sequenceChanged()
    }
    
    // Scrolls the playlist view to the very top
    @IBAction func scrollToTopAction(_ sender: AnyObject) {
        
        let playlistView = playlistViewForViewType()
        
        if (playlistView.numberOfRows > 0) {
            playlistView.scrollRowToVisible(0)
        }
    }
    
    // Scrolls the playlist view to the very bottom
    @IBAction func scrollToBottomAction(_ sender: AnyObject) {
        
        let playlistView = playlistViewForViewType()
        
        if (playlistView.numberOfRows > 0) {
            playlistView.scrollRowToVisible(playlistView.numberOfRows - 1)
        }
    }
    
    // Maps the current playlist view type to the corresponding playlist view
    private func playlistViewForViewType() -> NSTableView {
        
        switch PlaylistViewState.current {
            
        case .tracks: return tracksView
            
        case .artists: return artistsView
            
        case .albums: return albumsView
            
        case .genres: return genresView
            
        }
    }
    
    // Shows the currently playing track, within the playlist view
    @IBAction func showPlayingTrackAction(_ sender: Any) {
        
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.showPlayingTrack, PlaylistViewState.current))
    }
    
    // Plays the currently selected track/group
    @IBAction func playSelectedItemMenuAction(_ sender: Any) {
        
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.playSelectedItem, PlaylistViewState.current))
    }
    
    // Switches the tab group to the Tracks view
    @IBAction func tracksTabViewAction(_ sender: Any) {
        tabViewAction(btnTracksView, 0, .tracks)
    }
    
    // Switches the tab group to the Artists view
    @IBAction func artistsTabViewAction(_ sender: Any) {
        tabViewAction(btnArtistsView, 1, .artists)
    }
    
    // Switches the tab group to the Albums view
    @IBAction func albumsTabViewAction(_ sender: Any) {
        tabViewAction(btnAlbumsView, 2, .albums)
    }
    
    // Switches the tab group to the Genres view
    @IBAction func genresTabViewAction(_ sender: Any) {
        tabViewAction(btnGenresView, 3, .genres)
    }
    
    // Helper function to switch the tab group to a particular view
    private func tabViewAction(_ selectedButton: NSButton, _ tabIndex: Int, _ playlistType: PlaylistType) {
        
        tabGroupButtons!.forEach({
            $0.state = 0
            $0.needsDisplay = true
        })
        
        selectedButton.state = 1
        tabGroup.selectTabViewItem(at: tabIndex)
        
        PlaylistViewState.current = playlistType
        updatePlaylistSummary()
        SyncMessenger.publishNotification(PlaylistTypeChangedNotification(newPlaylistType: playlistType))
    }
    
    // Cycles between playlist tab group tabs
    @IBAction func shiftTabAction(_ sender: Any) {
        
        switch PlaylistViewState.current {
            
        case .tracks: artistsTabViewAction(self)
            
        case .artists: albumsTabViewAction(self)
            
        case .albums: genresTabViewAction(self)
            
        case .genres: tracksTabViewAction(self)
            
        }
    }
    
    private func trackAdded(_ message: TrackAddedAsyncMessage) {
        
        DispatchQueue.main.async {
            self.updatePlaylistSummary(message.progress)
        }
    }
    
    private func trackInfoUpdated(_ message: TrackUpdatedAsyncMessage) {
        
        DispatchQueue.main.async {
            
            // Track duration may have changed, affecting the total playlist duration
            self.updatePlaylistSummary()
            
            // If this is the playing track, tell other views that info has been updated
            let playingTrackIndex = self.playbackInfo.getPlayingTrack()?.index
            if (playingTrackIndex == message.trackIndex) {
                SyncMessenger.publishNotification(PlayingTrackInfoUpdatedNotification.instance)
            }
        }
    }
    
    private func removeTrack(_ request: RemoveTrackRequest) {
        
        playlist.removeTracks([request.index])
        
        sequenceChanged()
        updatePlaylistSummary()
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .trackAdded:
            
            trackAdded(message as! TrackAddedAsyncMessage)
            
        case .trackInfoUpdated:
            
            trackInfoUpdated(message as! TrackUpdatedAsyncMessage)
            
        case .tracksNotAdded:
            
            tracksNotAdded(message as! TracksNotAddedAsyncMessage)
            
        case .startedAddingTracks:
            
            startedAddingTracks()
            
        case .doneAddingTracks:
            
            doneAddingTracks()
            
        default: return
            
        }
    }
    
    func consumeNotification(_ message: NotificationMessage) {
        // This class does not consume synchronous notification messages
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        switch request.messageType {
            
        case .removeTrackRequest:
            
            removeTrack(request as! RemoveTrackRequest)
            
        default: break
            
        }
        
        // This class does not return any meaningful responses
        return EmptyResponse.instance
    }
}

// Convenient accessor for information about the current state of the playlist view
class PlaylistViewState {
    
    // The current playlist view type displayed within the playlist tab group
    static var current: PlaylistType = .tracks
    
    // The group type corresponding to the current playlist view type
    static var groupType: GroupType? {
    
        switch current {
            
        case .albums: return GroupType.album
            
        case .artists: return GroupType.artist
            
        case .genres: return GroupType.genre
            
        // Group type is not applicable to playlist type .tracks
        default: return nil
            
        }
    }
}
