/*
    View controller for the playback controls (play/pause, prev/next track, seeking, repeat/shuffle)
 */
import Cocoa

class PlaybackViewController: NSViewController, MessageSubscriber, AsyncMessageSubscriber {
    
    // Playback control fields
    
    @IBOutlet weak var seekSlider: NSSlider!
    @IBOutlet weak var btnPlayPause: NSButton!
    
    // Toggle buttons (their images change)
    @IBOutlet weak var btnShuffle: NSButton!
    @IBOutlet weak var btnRepeat: NSButton!
    
    @IBOutlet weak var repeatOffMainMenuItem: NSMenuItem!
    @IBOutlet weak var repeatOneMainMenuItem: NSMenuItem!
    @IBOutlet weak var repeatAllMainMenuItem: NSMenuItem!
    
    @IBOutlet weak var shuffleOffMainMenuItem: NSMenuItem!
    @IBOutlet weak var shuffleOnMainMenuItem: NSMenuItem!
    
    @IBOutlet weak var repeatOffDockMenuItem: NSMenuItem!
    @IBOutlet weak var repeatOneDockMenuItem: NSMenuItem!
    @IBOutlet weak var repeatAllDockMenuItem: NSMenuItem!
    
    @IBOutlet weak var shuffleOffDockMenuItem: NSMenuItem!
    @IBOutlet weak var shuffleOnDockMenuItem: NSMenuItem!
    
    // The playlist views can initiate playback of a track (through double clicks)
    @IBOutlet weak var tracksView: NSTableView!
    @IBOutlet weak var artistsView: NSOutlineView!
    @IBOutlet weak var albumsView: NSOutlineView!
    @IBOutlet weak var genresView: NSOutlineView!
    
    // Delegate that conveys all playback requests to the player / playback sequence
    private let player: PlaybackDelegateProtocol = ObjectGraph.getPlaybackDelegate()
    
    override func viewDidLoad() {
        
        // Set up a mouse listener (for double clicks -> play selected track)
        tracksView.doubleAction = #selector(self.playSelectedTrackAction(_:))
        tracksView.target = self
        
        [artistsView!, albumsView!, genresView!].forEach({
            $0.doubleAction = #selector(self.playSelectedGroupedTrackAction(_:))
            $0.target = self
        })
        
        let appState = ObjectGraph.getUIAppState()
        updateRepeatAndShuffleControls(appState.repeatMode, appState.shuffleMode)
        
        // Subscribe for message notifications
        
        AsyncMessenger.subscribe(.trackNotPlayed, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.trackChanged, subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(.stopPlaybackRequest, subscriber: self)
    }
    
    // Moving the seek slider results in seeking the track to the new slider position
    @IBAction func seekSliderAction(_ sender: AnyObject) {
        
        player.seekToPercentage(seekSlider.doubleValue)
        
        SyncMessenger.publishNotification(SeekPositionChangedNotification.instance)
    }
    
    @IBAction func playSelectedTrackAction(_ sender: AnyObject) {
        
        if PlaylistViewState.current == .tracks {
        
            if (tracksView.selectedRow >= 0) {
                
                let oldTrack = player.getPlayingTrack()
                
                do {
                    
                    let track = try player.play(tracksView.selectedRow)
                    trackChange(oldTrack, track)
                    tracksView.deselectAll(self)
                    
                } catch let error {
                    
                    if (error is InvalidTrackError) {
                        handleTrackNotPlayedError(oldTrack, error as! InvalidTrackError)
                    }
                }
            }
            
        } else {
            
            var playlistView: NSOutlineView?
            
            switch PlaylistViewState.current {
                
            case .artists: playlistView = artistsView
                
            case .albums: playlistView = albumsView
                
            case .genres: playlistView = genresView
                
            default: playlistView = nil
                
            }
            
            if let view = playlistView {
                playSelectedGroupedTrackAction(view)
            }
        }
    }
    
    @IBAction func playSelectedGroupedTrackAction(_ sender: AnyObject) {
        
        let playlistView = sender as! NSOutlineView
        
        let item = playlistView.item(atRow: playlistView.selectedRow)
        let oldTrack = player.getPlayingTrack()
        
        if let track = item as? Track {
            
            do {
                
                let track = try player.play(track)
                trackChange(oldTrack, track)
                playlistView.deselectAll(self)
                
            } catch let error {
                
                if (error is InvalidTrackError) {
                    handleTrackNotPlayedError(oldTrack, error as! InvalidTrackError)
                }
            }
            
        } else {
            
            let group = item as! Group
            
            playlistView.expandItem(group)
            
            do {
                
                let track = try player.play(group)
                trackChange(oldTrack, track)
                playlistView.deselectAll(self)
                
            } catch let error {
                
                if (error is InvalidTrackError) {
                    handleTrackNotPlayedError(oldTrack, error as! InvalidTrackError)
                }
            }
        }
    }
    
    @IBAction func repeatAction(_ sender: AnyObject) {
        
        let modes = player.toggleRepeatMode()
        updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    @IBAction func shuffleAction(_ sender: AnyObject) {
        
        let modes = player.toggleShuffleMode()
        updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    @IBAction func repeatOffAction(_ sender: AnyObject) {
        
        let modes = player.setRepeatMode(.off)
        updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    @IBAction func repeatOneAction(_ sender: AnyObject) {
        
        let modes = player.setRepeatMode(.one)
        updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    @IBAction func repeatAllAction(_ sender: AnyObject) {
        
        let modes = player.setRepeatMode(.all)
        updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    @IBAction func shuffleOffAction(_ sender: AnyObject) {
        
        let modes = player.setShuffleMode(.off)
        updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    @IBAction func shuffleOnAction(_ sender: AnyObject) {
        
        let modes = player.setShuffleMode(.on)
        updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    private func updateRepeatAndShuffleControls(_ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode) {
        
        switch shuffleMode {
            
        case .off: btnShuffle.image = UIConstants.imgShuffleOff
        [shuffleOffMainMenuItem, shuffleOffDockMenuItem].forEach({$0?.state = 1})
        [shuffleOnMainMenuItem, shuffleOnDockMenuItem].forEach({$0?.state = 0})
            
        case .on: btnShuffle.image = UIConstants.imgShuffleOn
        [shuffleOffMainMenuItem, shuffleOffDockMenuItem].forEach({$0?.state = 0})
        [shuffleOnMainMenuItem, shuffleOnDockMenuItem].forEach({$0?.state = 1})
        }
        
        switch repeatMode {
            
        case .off: btnRepeat.image = UIConstants.imgRepeatOff
        [repeatOffMainMenuItem, repeatOffDockMenuItem].forEach({$0.state = 1})
        [repeatOneMainMenuItem, repeatOneDockMenuItem, repeatAllMainMenuItem, repeatAllDockMenuItem].forEach({$0?.state = 0})
            
        case .one: btnRepeat.image = UIConstants.imgRepeatOne
        [repeatOneMainMenuItem, repeatOneDockMenuItem].forEach({$0.state = 1})
        [repeatOffMainMenuItem, repeatOffDockMenuItem, repeatAllMainMenuItem, repeatAllDockMenuItem].forEach({$0?.state = 0})
            
        case .all: btnRepeat.image = UIConstants.imgRepeatAll
        [repeatAllMainMenuItem, repeatAllDockMenuItem].forEach({$0.state = 1})
        [repeatOneMainMenuItem, repeatOneDockMenuItem, repeatOffMainMenuItem, repeatOffDockMenuItem].forEach({$0?.state = 0})
        }
    }
    
    // Play / Pause / Resume
    @IBAction func playPauseAction(_ sender: AnyObject) {
        
        let oldTrack = player.getPlayingTrack()
        
        do {
            
            let playbackInfo = try player.togglePlayPause()
            let playbackState = playbackInfo.playbackState
            
            switch playbackState {
                
            case .noTrack, .paused: setPlayPauseImage(UIConstants.imgPlay)
            SyncMessenger.publishNotification(PlaybackStateChangedNotification(playbackState))
                
            case .playing:
                
                if (playbackInfo.trackChanged) {
                    trackChange(oldTrack, playbackInfo.playingTrack)
                } else {
                    // Resumed the same track
                    setPlayPauseImage(UIConstants.imgPause)
                    SyncMessenger.publishNotification(PlaybackStateChangedNotification(playbackState))
                }
            }
            
        } catch let error {
            
            if (error is InvalidTrackError) {
                handleTrackNotPlayedError(oldTrack, error as! InvalidTrackError)
            }
        }
    }
    
    private func stopPlayback() {
        
        let oldTrack = player.getPlayingTrack()
        player.stop()
        trackChange(oldTrack, nil)
    }
    
    @IBAction func prevTrackAction(_ sender: AnyObject) {
        
        let oldTrack = player.getPlayingTrack()
        
        do {
            
            let prevTrack = try player.previousTrack()
            if (prevTrack?.track != nil) {
                trackChange(oldTrack, prevTrack)
            }
            
        } catch let error {
            
            if (error is InvalidTrackError) {
                handleTrackNotPlayedError(oldTrack, error as! InvalidTrackError)
            }
        }
    }
    
    @IBAction func nextTrackAction(_ sender: AnyObject) {
        
        let oldTrack = player.getPlayingTrack()
        
        do {
            let nextTrack = try player.nextTrack()
            if (nextTrack?.track != nil) {
                trackChange(oldTrack, nextTrack)
            }
            
        } catch let error {
            
            if (error is InvalidTrackError) {
                handleTrackNotPlayedError(oldTrack, error as! InvalidTrackError)
            }
        }
    }
    
    @IBAction func seekBackwardAction(_ sender: AnyObject) {
        player.seekBackward()
        
        let seekPositionChangedNotification = SeekPositionChangedNotification.instance
        SyncMessenger.publishNotification(seekPositionChangedNotification)
    }
    
    @IBAction func seekForwardAction(_ sender: AnyObject) {
        player.seekForward()
        
        let seekPositionChangedNotification = SeekPositionChangedNotification.instance
        SyncMessenger.publishNotification(seekPositionChangedNotification)
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChange(_ oldTrack: IndexedTrack?, _ newTrack: IndexedTrack?, _ errorState: Bool = false) {
        
        if (newTrack != nil) {
            
            if (!errorState) {
                setPlayPauseImage(UIConstants.imgPause)
                
            } else {
                
                // Error state
                setPlayPauseImage(UIConstants.imgPlay)
            }
            
        } else {
            
            setPlayPauseImage(UIConstants.imgPlay)
        }
        
        let trackChgNotification = TrackChangedNotification(oldTrack, newTrack, errorState)
        SyncMessenger.publishNotification(trackChgNotification)
    }
    
    private func setPlayPauseImage(_ image: NSImage) {
        btnPlayPause.image = image
    }
    
    private func handleTrackNotPlayedError(_ oldTrack: IndexedTrack?, _ error: InvalidTrackError) {
        
        // This needs to be done async. Otherwise, other open dialogs could hang.
        DispatchQueue.main.async {
            
            // First, select the problem track and update the now playing info
            let playingTrack = self.player.getPlayingTrack()
            self.trackChange(oldTrack, playingTrack, true)
            
            // Position and display the dialog with info
            let alert = UIElements.trackNotPlayedAlertWithError(error)
            _ = UIUtils.showAlert(alert)
            
            // Remove the bad track from the playlist and update the UI
            
            let playingTrackIndex = playingTrack!.index
            let removeTrackRequest = RemoveTrackRequest(playingTrackIndex)
            _ = SyncMessenger.publishRequest(removeTrackRequest)
        }
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if message is TrackChangedAsyncMessage {
            let _msg = message as! TrackChangedAsyncMessage
            trackChange(_msg.oldTrack, _msg.newTrack)
            return
        }
        
        if message is TrackNotPlayedAsyncMessage {
            let _msg = message as! TrackNotPlayedAsyncMessage
            handleTrackNotPlayedError(_msg.oldTrack, _msg.error)
            return
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        if (request is StopPlaybackRequest) {
            stopPlayback()
        }
        
        return EmptyResponse.instance
    }
}
