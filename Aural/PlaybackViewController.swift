import Cocoa

class PlaybackViewController: NSViewController, MessageSubscriber, AsyncMessageSubscriber {
    
    @IBOutlet weak var seekSlider: NSSlider!
    @IBOutlet weak var btnPlayPause: NSButton!
    
    // Toggle buttons (their images change)
    @IBOutlet weak var btnShuffle: NSButton!
    @IBOutlet weak var btnRepeat: NSButton!
    
    @IBOutlet weak var playlistView: NSTableView!
    
    private let player: PlaybackDelegateProtocol = ObjectGraph.getPlaybackDelegate()
    
    override func viewDidLoad() {
        
        // Set up a mouse listener (for double clicks -> play selected track)
        playlistView.doubleAction = #selector(self.playlistDoubleClickAction(_:))
        playlistView.target = self
        
        let appState = ObjectGraph.getUIAppState()
        
        switch appState.repeatMode {
            
        case .off: btnRepeat.image = UIConstants.imgRepeatOff
        case .one: btnRepeat.image = UIConstants.imgRepeatOne
        case .all: btnRepeat.image = UIConstants.imgRepeatAll
            
        }
        
        switch appState.shuffleMode {
            
        case .off: btnShuffle.image = UIConstants.imgShuffleOff
        case .on: btnShuffle.image = UIConstants.imgShuffleOn
            
        }
        
        AsyncMessenger.subscribe(.trackNotPlayed, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.trackChanged, subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(.stopPlaybackRequest, subscriber: self)
    }
    
    @IBAction func seekSliderAction(_ sender: AnyObject) {
        player.seekToPercentage(seekSlider.doubleValue)
        
        let seekPositionChangedNotification = SeekPositionChangedNotification.instance
        SyncMessenger.publishNotification(seekPositionChangedNotification)
    }
    
    @IBAction func playSelectedTrackMenuItemAction(_ sender: Any) {
        playSelectedTrack()
    }
    
    func playlistDoubleClickAction(_ sender: AnyObject) {
        playSelectedTrack()
    }
    
    func playSelectedTrack() {
        
        if (playlistView.selectedRow >= 0) {
            
            do {
                let track = try player.play(playlistView.selectedRow)
                trackChange(track)
                
            } catch let error as Error {
                
                if (error is InvalidTrackError) {
                    handleTrackNotPlayedError(error as! InvalidTrackError)
                }
            }
        }
    }
    
    @IBAction func repeatAction(_ sender: AnyObject) {
        
        let modes = player.toggleRepeatMode()
        updateRepeatAndShuffleButtons(modes.repeatMode, modes.shuffleMode)
    }
    
    @IBAction func shuffleAction(_ sender: AnyObject) {
        
        let modes = player.toggleShuffleMode()
        updateRepeatAndShuffleButtons(modes.repeatMode, modes.shuffleMode)
    }
    
    private func updateRepeatAndShuffleButtons(_ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode) {
        
        switch shuffleMode {
            
        case .off: btnShuffle.image = UIConstants.imgShuffleOff
        case .on: btnShuffle.image = UIConstants.imgShuffleOn
            
        }
        
        switch repeatMode {
            
        case .off: btnRepeat.image = UIConstants.imgRepeatOff
        case .one: btnRepeat.image = UIConstants.imgRepeatOne
        case .all: btnRepeat.image = UIConstants.imgRepeatAll
            
        }
    }
    
    // Play / Pause / Resume
    @IBAction func playPauseAction(_ sender: AnyObject) {
        
        do {
            
            let playbackInfo = try player.togglePlayPause()
            let playbackState = playbackInfo.playbackState
            
            switch playbackState {
                
            case .noTrack, .paused: setPlayPauseImage(UIConstants.imgPlay)
            SyncMessenger.publishNotification(PlaybackStateChangedNotification(playbackState))
                
            case .playing:
                
                if (playbackInfo.trackChanged) {
                    trackChange(playbackInfo.playingTrack)
                } else {
                    // Resumed the same track
                    setPlayPauseImage(UIConstants.imgPause)
                    SyncMessenger.publishNotification(PlaybackStateChangedNotification(playbackState))
                }
            }
            
        } catch let error as Error {
            
            if (error is InvalidTrackError) {
                handleTrackNotPlayedError(error as! InvalidTrackError)
            }
        }
    }
    
    private func stopPlayback() {
        player.stop()
        trackChange(nil)
    }
    
    @IBAction func prevTrackAction(_ sender: AnyObject) {
        
        do {
            
            let trackInfo = try player.previousTrack()
            if (trackInfo?.track != nil) {
                trackChange(trackInfo)
            }
            
        } catch let error as Error {
            
            if (error is InvalidTrackError) {
                handleTrackNotPlayedError(error as! InvalidTrackError)
            }
        }
    }
    
    @IBAction func nextTrackAction(_ sender: AnyObject) {
        
        do {
            let trackInfo = try player.nextTrack()
            if (trackInfo?.track != nil) {
                trackChange(trackInfo)
            }
            
        } catch let error as Error {
            
            if (error is InvalidTrackError) {
                handleTrackNotPlayedError(error as! InvalidTrackError)
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
    
    @IBAction func toggleRepeatModeMenuItemAction(_ sender: Any) {
        repeatAction(sender as AnyObject)
    }
    
    @IBAction func toggleShuffleModeMenuItemAction(_ sender: Any) {
        shuffleAction(sender as AnyObject)
    }
    
    @IBAction func togglePlayPauseMenuItemAction(_ sender: Any) {
        playPauseAction(sender as AnyObject)
    }
    
    @IBAction func nextTrackMenuItemAction(_ sender: Any) {
        nextTrackAction(sender as AnyObject)
    }
    
    @IBAction func previousTrackMenuItemAction(_ sender: Any) {
        prevTrackAction(sender as AnyObject)
    }
    
    @IBAction func seekForwardMenuItemAction(_ sender: Any) {
        seekForwardAction(sender as AnyObject)
    }
    
    @IBAction func seekBackwardMenuItemAction(_ sender: Any) {
        seekBackwardAction(sender as AnyObject)
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChange(_ newTrack: IndexedTrack?, _ errorState: Bool = false) {
        
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
        
        let trackChgNotification = TrackChangedNotification(newTrack)
        SyncMessenger.publishNotification(trackChgNotification)
    }
    
    private func setPlayPauseImage(_ image: NSImage) {
        btnPlayPause.image = image
    }
    
    func handleTrackNotPlayedError(_ error: InvalidTrackError) {
        
        // This needs to be done async. Otherwise, other open dialogs could hang.
        DispatchQueue.main.async {
            
            // First, select the problem track and update the now playing info
            let playingTrack = self.player.getPlayingTrack()
            self.trackChange(playingTrack, true)
            
            // Position and display the dialog with info
            let alert = UIElements.trackNotPlayedAlertWithError(error)
            let window = WindowState.window!
            
            let orig = NSPoint(x: window.frame.origin.x, y: min(window.frame.origin.y + 227, window.frame.origin.y + window.frame.height - alert.window.frame.height))
            
            alert.window.setFrameOrigin(orig)
            alert.window.setIsVisible(true)
            
            alert.runModal()
            
            // Remove the bad track from the playlist and update the UI
            
            let playingTrackIndex = playingTrack!.index!
            let removeTrackRequest = RemoveTrackRequest(playingTrackIndex)
            SyncMessenger.publishRequest(removeTrackRequest)
        }
    }
    
    // Playlist info changed, need to reset the UI
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if message is TrackChangedAsyncMessage {
            let _msg = message as! TrackChangedAsyncMessage
            trackChange(_msg.newTrack)
            return
        }
        
        if message is TrackNotPlayedAsyncMessage {
            let _msg = message as! TrackNotPlayedAsyncMessage
            handleTrackNotPlayedError(_msg.error)
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
