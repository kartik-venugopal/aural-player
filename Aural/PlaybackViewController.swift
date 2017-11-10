/*
    View controller for the playback controls (play/pause, prev/next track, seeking, repeat/shuffle)
 */
import Cocoa

class PlaybackViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber, AsyncMessageSubscriber {
    
    // Playback control fields
    
    @IBOutlet weak var seekSlider: NSSlider!
    @IBOutlet weak var btnPlayPause: NSButton!
    
    // Toggle buttons (their images change)
    @IBOutlet weak var btnShuffle: NSButton!
    @IBOutlet weak var btnRepeat: NSButton!
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = ObjectGraph.getPlaybackDelegate()
    
    override func viewDidLoad() {
        
        let appState = ObjectGraph.getUIAppState()
        updateRepeatAndShuffleControls(appState.repeatMode, appState.shuffleMode)
        
        // Subscribe to message notifications
        AsyncMessenger.subscribe([.trackNotPlayed,.trackChanged], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(messageTypes: [.playbackRequest], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.playOrPause, .previousTrack, .nextTrack, .seekBackward, .seekForward, .repeatOff, .repeatOne, .repeatAll, .shuffleOff, .shuffleOn], subscriber: self)
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
    
    private func repeatOff() {
        
        let modes = player.setRepeatMode(.off)
        updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    private func repeatOne() {
        
        let modes = player.setRepeatMode(.one)
        updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    private func repeatAll() {
        
        let modes = player.setRepeatMode(.all)
        updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    private func shuffleOff() {
        
        let modes = player.setShuffleMode(.off)
        updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    private func shuffleOn() {
        
        let modes = player.setShuffleMode(.on)
        updateRepeatAndShuffleControls(modes.repeatMode, modes.shuffleMode)
    }
    
    private func updateRepeatAndShuffleControls(_ repeatMode: RepeatMode, _ shuffleMode: ShuffleMode) {
        
        btnShuffle.image = shuffleMode == .off ? Images.imgShuffleOff : Images.imgShuffleOn
        
        switch repeatMode {
            
        case .off:
            
            btnRepeat.image = Images.imgRepeatOff
            
        case .one:
            
            btnRepeat.image = Images.imgRepeatOne

        case .all:
            
            btnRepeat.image = Images.imgRepeatAll
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
                
                setPlayPauseImage(Images.imgPlay)
                SyncMessenger.publishNotification(PlaybackStateChangedNotification(playbackState))
                
            case .playing:
                
                if (playbackInfo.trackChanged) {
                    trackChanged(oldTrack, playbackInfo.playingTrack)
                } else {
                    // Resumed the same track
                    setPlayPauseImage(Images.imgPause)
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
                setPlayPauseImage(Images.imgPause)
                
            } else {
                
                // Error state
                setPlayPauseImage(Images.imgPlay)
            }
            
        } else {
            
            // No track playing
            setPlayPauseImage(Images.imgPlay)
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
            _ = UIUtils.showAlert(DialogsAndAlerts.trackNotPlayedAlertWithError(error))
            
            // Remove the bad track from the playlist and update the UI
            _ = SyncMessenger.publishRequest(RemoveTrackRequest(playingTrack!.index))
        }
    }
    
    // MARK: Message handling
    
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
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .playOrPause: playPauseAction(self)
            
        case .previousTrack: previousTrackAction(self)
            
        case .nextTrack: nextTrackAction(self)
            
        case .seekBackward: seekBackwardAction(self)
            
        case .seekForward: seekForwardAction(self)
            
        case .repeatOff: repeatOff()
            
        case .repeatOne: repeatOne()
            
        case .repeatAll: repeatAll()
            
        case .shuffleOff: shuffleOff()
            
        case .shuffleOn: shuffleOn()
            
        default: return
            
        }
    }
}
