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
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = ObjectGraph.getPlaybackDelegate()
    
    override func viewDidLoad() {
        
        let appState = ObjectGraph.getUIAppState()
        updateRepeatAndShuffleControls(appState.repeatMode, appState.shuffleMode)
        
        // Subscribe to message notifications
        AsyncMessenger.subscribe([.trackNotPlayed,.trackChanged], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(messageTypes: [.playbackRequest], subscriber: self)
    }
    
    // Moving the seek slider results in seeking the track to the new slider position
    @IBAction func seekSliderAction(_ sender: AnyObject) {
        
        player.seekToPercentage(seekSlider.doubleValue)
        SyncMessenger.publishNotification(SeekPositionChangedNotification.instance)
    }
    
    private func playTrackWithIndex(_ trackIndex: Int) {
        
        let oldTrack = player.getPlayingTrack()
        
        do {
            
            let track = try player.play(trackIndex)
            trackChanged(oldTrack, track)
            
        } catch let error {
            
            if (error is InvalidTrackError) {
                handleTrackNotPlayedError(oldTrack, error as! InvalidTrackError)
            }
        }
    }

    private func playTrack(_ track: Track) {
        
        let oldTrack = player.getPlayingTrack()
        
        do {
            
            let playingTrack = try player.play(track)
            trackChanged(oldTrack, playingTrack)
            
        } catch let error {
            
            if (error is InvalidTrackError) {
                handleTrackNotPlayedError(oldTrack, error as! InvalidTrackError)
            }
        }
    }
    
    private func playGroup(_ group: Group) {
        
        let oldTrack = player.getPlayingTrack()
        
        do {
            
            let track = try player.play(group)
            trackChanged(oldTrack, track)
            
        } catch let error {
            
            if (error is InvalidTrackError) {
                handleTrackNotPlayedError(oldTrack, error as! InvalidTrackError)
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
            
        case .off:
            
            btnShuffle.image = UIConstants.imgShuffleOff
            [shuffleOffMainMenuItem, shuffleOffDockMenuItem].forEach({$0?.state = 1})
            [shuffleOnMainMenuItem, shuffleOnDockMenuItem].forEach({$0?.state = 0})
            
        case .on:
            
            btnShuffle.image = UIConstants.imgShuffleOn
            [shuffleOffMainMenuItem, shuffleOffDockMenuItem].forEach({$0?.state = 0})
            [shuffleOnMainMenuItem, shuffleOnDockMenuItem].forEach({$0?.state = 1})
            
        }
        
        switch repeatMode {
            
        case .off:
            
            btnRepeat.image = UIConstants.imgRepeatOff
            [repeatOffMainMenuItem, repeatOffDockMenuItem].forEach({$0.state = 1})
            [repeatOneMainMenuItem, repeatOneDockMenuItem, repeatAllMainMenuItem, repeatAllDockMenuItem].forEach({$0?.state = 0})
            
        case .one:
            
            btnRepeat.image = UIConstants.imgRepeatOne
            [repeatOneMainMenuItem, repeatOneDockMenuItem].forEach({$0.state = 1})
            [repeatOffMainMenuItem, repeatOffDockMenuItem, repeatAllMainMenuItem, repeatAllDockMenuItem].forEach({$0?.state = 0})
            
        case .all:
            
            btnRepeat.image = UIConstants.imgRepeatAll
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
                
            case .noTrack, .paused:
                
                setPlayPauseImage(UIConstants.imgPlay)
                SyncMessenger.publishNotification(PlaybackStateChangedNotification(playbackState))
                
            case .playing:
                
                if (playbackInfo.trackChanged) {
                    trackChanged(oldTrack, playbackInfo.playingTrack)
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
    
    @IBAction func previousTrackAction(_ sender: AnyObject) {
        
        let oldTrack = player.getPlayingTrack()
        
        do {
            
            let prevTrack = try player.previousTrack()
            if (prevTrack?.track != nil) {
                trackChanged(oldTrack, prevTrack)
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
                trackChanged(oldTrack, nextTrack)
            }
            
        } catch let error {
            
            if (error is InvalidTrackError) {
                handleTrackNotPlayedError(oldTrack, error as! InvalidTrackError)
            }
        }
    }
    
    @IBAction func seekBackwardAction(_ sender: AnyObject) {
        
        player.seekBackward()
        SyncMessenger.publishNotification(SeekPositionChangedNotification.instance)
    }
    
    @IBAction func seekForwardAction(_ sender: AnyObject) {
        
        player.seekForward()
        SyncMessenger.publishNotification(SeekPositionChangedNotification.instance)
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChanged(_ oldTrack: IndexedTrack?, _ newTrack: IndexedTrack?, _ errorState: Bool = false) {
        
        if (newTrack != nil) {
            
            if (!errorState) {
                
                // No error, track is playing
                setPlayPauseImage(UIConstants.imgPause)
                
            } else {
                
                // Error state
                setPlayPauseImage(UIConstants.imgPlay)
            }
            
        } else {
            
            // No track playing
            setPlayPauseImage(UIConstants.imgPlay)
        }
        
        SyncMessenger.publishNotification(TrackChangedNotification(oldTrack, newTrack, errorState))
    }
    
    private func setPlayPauseImage(_ image: NSImage) {
        btnPlayPause.image = image
    }
    
    private func trackChanged(_ message: TrackChangedAsyncMessage) {
        trackChanged(message.oldTrack, message.newTrack)
    }
    
    private func trackNotPlayed(_ message: TrackNotPlayedAsyncMessage) {
        handleTrackNotPlayedError(message.oldTrack, message.error)
    }
    
    private func performPlayback(_ request: PlaybackRequest) {
        
        switch request.type {
            
        case .index: playTrackWithIndex(request.index!)
            
        case .track: playTrack(request.track!)
            
        case .group: playGroup(request.group!)
            
        }
    }
    
    private func handleTrackNotPlayedError(_ oldTrack: IndexedTrack?, _ error: InvalidTrackError) {
        
        // This needs to be done async. Otherwise, other open dialogs could hang.
        DispatchQueue.main.async {
            
            let playingTrack = self.player.getPlayingTrack()
            self.trackChanged(oldTrack, playingTrack, true)
            
            // Position and display an alert with error info
            _ = UIUtils.showAlert(UIElements.trackNotPlayedAlertWithError(error))
            
            // Remove the bad track from the playlist and update the UI
            _ = SyncMessenger.publishRequest(RemoveTrackRequest(playingTrack!.index))
        }
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .trackChanged:
            
            trackChanged(message as! TrackChangedAsyncMessage)
            
        case .trackNotPlayed:
            
            trackNotPlayed(message as! TrackNotPlayedAsyncMessage)
            
        default: return
            
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        // This class does not consume any notifications
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        switch request.messageType {
            
        case .playbackRequest:
            
            performPlayback(request as! PlaybackRequest)
            
        default: break
            
        }
        
        // This class does not return any meaningful responses
        return EmptyResponse.instance
    }
}
