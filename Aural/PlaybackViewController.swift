import Cocoa

class PlaybackViewController: NSViewController, MessageSubscriber, AsyncMessageSubscriber {
    
    @IBOutlet weak var seekSlider: NSSlider!
    @IBOutlet weak var btnPlayPause: NSButton!
    
    // Toggle buttons (their images change)
    @IBOutlet weak var btnShuffle: NSButton!
    @IBOutlet weak var btnRepeat: NSButton!
    
    @IBOutlet weak var playlistView: NSTableView!
    
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
    
    private let player: PlaybackDelegateProtocol = ObjectGraph.getPlaybackDelegate()
    
    override func viewDidLoad() {
        
        // Set up a mouse listener (for double clicks -> play selected track)
        playlistView.doubleAction = #selector(self.playSelectedTrackAction(_:))
        playlistView.target = self
        
        let appState = ObjectGraph.getUIAppState()
        updateRepeatAndShuffleControls(appState.repeatMode, appState.shuffleMode)
        
        AsyncMessenger.subscribe(.trackNotPlayed, subscriber: self, dispatchQueue: DispatchQueue.main)
        AsyncMessenger.subscribe(.trackChanged, subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(.stopPlaybackRequest, subscriber: self)
    }
    
    @IBAction func seekSliderAction(_ sender: AnyObject) {
        player.seekToPercentage(seekSlider.doubleValue)
        
        let seekPositionChangedNotification = SeekPositionChangedNotification.instance
        SyncMessenger.publishNotification(seekPositionChangedNotification)
    }
    
    @IBAction func playSelectedTrackAction(_ sender: AnyObject) {
        
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
        
        let trackChgNotification = TrackChangedNotification(newTrack, errorState)
        SyncMessenger.publishNotification(trackChgNotification)
    }
    
    private func setPlayPauseImage(_ image: NSImage) {
        btnPlayPause.image = image
    }
    
    private func handleTrackNotPlayedError(_ error: InvalidTrackError) {
        
        // This needs to be done async. Otherwise, other open dialogs could hang.
        DispatchQueue.main.async {
            
            // First, select the problem track and update the now playing info
            let playingTrack = self.player.getPlayingTrack()
            self.trackChange(playingTrack, true)
            
            // Position and display the dialog with info
            let alert = UIElements.trackNotPlayedAlertWithError(error)
            UIUtils.showAlert(alert)
            
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
