import Cocoa

class BarModeNowPlayingViewController: NSViewController, MessageSubscriber, AsyncMessageSubscriber, ConstituentView {
 
    // Fields that display playing track info
    @IBOutlet weak var lblTrackName: BannerLabel!
    @IBOutlet weak var artView: NSImageView!
    
    // Shows the time elapsed for the currently playing track, and allows arbitrary seeking within the track
    @IBOutlet weak var seekSlider: NSSlider!
    @IBOutlet weak var seekSliderCell: BarModeSeekSliderCell!
    
    // Used to render playback loops
    @IBOutlet weak var seekSliderClone: NSSlider!
    @IBOutlet weak var seekSliderCloneCell: BarModeSeekSliderCell!
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = ObjectGraph.getPlaybackDelegate()
    
    // Delegate that retrieves Time Stretch information
    private let audioGraph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    // Timer that periodically updates the seek position slider and label
    private var seekTimer: RepeatingTaskExecutor?
    
    override var nibName: String? {return "BarModeNowPlaying"}
    
    override func viewDidLoad() {
        
        // Use persistent app state to determine the initial state of the view
        oneTimeSetup()
        
        AppModeManager.registerConstituentView(.miniBar, self)
    }
    
    func activate() {
        
        lblTrackName.beginAnimation()
        
        if let plTrack = player.getPlayingTrack() {
            showNowPlayingInfo(plTrack.track)
            renderLoop()
        } else {
            clearNowPlayingInfo()
        }
        
        initSubscriptions()
    }
    
    func deactivate() {
        
        lblTrackName.endAnimation()
        removeSubscriptions()
    }
    
    private func oneTimeSetup() {
        
        let seekTimerInterval = audioGraph.isTimeBypass() ? UIConstants.seekTimerIntervalMillis : Int(1000 / (2 * audioGraph.getTimeRate().rate))
        
        // Timer interval depends on whether time stretch unit is active
        seekTimer = RepeatingTaskExecutor(intervalMillis: seekTimerInterval, task: {self.updateSeekPosition()}, queue: DispatchQueue.main)
        
        lblTrackName.font = Fonts.barModePlayingTrackTextFont
        lblTrackName.alignment = NSTextAlignment.center
    }
    
    private func initSubscriptions() {
        
        // Subscribe to various notifications
        AsyncMessenger.subscribe([.tracksRemoved], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(messageTypes: [.playbackRequest, .trackChangedNotification, .playbackRateChangedNotification, .playbackStateChangedNotification, .playbackLoopChangedNotification, .seekPositionChangedNotification, .playingTrackInfoUpdatedNotification], subscriber: self)
    }
    
    private func removeSubscriptions() {
        
        AsyncMessenger.unsubscribe([.tracksRemoved], subscriber: self)
        
        SyncMessenger.unsubscribe(messageTypes: [.playbackRequest, .trackChangedNotification, .playbackRateChangedNotification, .playbackStateChangedNotification, .seekPositionChangedNotification, .playingTrackInfoUpdatedNotification, .playbackLoopChangedNotification], subscriber: self)
    }
    
    // Moving the seek slider results in seeking the track to the new slider position
    @IBAction func seekSliderAction(_ sender: AnyObject) {
        player.seekToPercentage(seekSlider.doubleValue)
        updateSeekPosition()
    }
    
    private func showNowPlayingInfo(_ track: Track) {
        
        lblTrackName.text = track.conciseDisplayName
        
        if (track.displayInfo.art != nil) {
            artView.image = track.displayInfo.art!
        } else {
            
            // Default artwork
            let playing = player.getPlaybackState() == .playing
            artView.image = playing ? Images.imgPlayingArt : Images.imgPausedArt
        }
        
        initSeekPosition()
        setSeekTimerState(true)
    }
    
    private func clearNowPlayingInfo() {
        
        lblTrackName.text = ""
        artView.image = Images.imgPausedArt
        
        seekSlider.floatValue = 0
        setSeekTimerState(false)
    }
    
    private func setSeekTimerState(_ timerOn: Bool) {
        
        if (timerOn) {
            
            if (!seekSlider.isEnabled) {
                seekSlider.isEnabled = true
                seekTimer?.startOrResume()
            }
            
        } else {
            
            if (seekSlider.isEnabled) {
                seekTimer?.pause()
                seekSlider.isEnabled = false
            }
        }
    }
    
    // Updates the seek slider and time elapsed/remaining labels as playback proceeds
    private func updateSeekPosition() {
        
        if (player.getPlaybackState() == .playing) {
            seekSlider.doubleValue = player.getSeekPosition().percentageElapsed
        }
    }
    
    // Regardless of playback state
    private func initSeekPosition() {
        seekSlider.doubleValue = player.getSeekPosition().percentageElapsed
    }
    
    // Resets the seek slider and time elapsed/remaining labels when playback of a track begins
    private func resetSeekPosition() {
        seekSlider.floatValue = 0
    }
    
    private func tracksRemoved(_ message: TracksRemovedAsyncMessage) {
        
        // Check if the playing track was removed. If so, need to update display fields, because playback will have stopped.
        if (message.playingTrackRemoved) {
            trackChanged(nil)
        }
    }
    
    private func trackChanged(_ notification: TrackChangedNotification) {
        trackChanged(notification.newTrack, notification.errorState)
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChanged(_ newTrack: IndexedTrack?, _ errorState: Bool = false) {
        
        seekSliderCell.removeLoop()
        
        if (newTrack != nil) {
            
            showNowPlayingInfo(newTrack!.track)
            
            if (!errorState) {
                setSeekTimerState(true)
                
            } else {
                
                // Error state
                setSeekTimerState(false)
            }
            
        } else {
            
            // No track playing, clear the info fields
            clearNowPlayingInfo()
        }
    }
    
    // When the playback rate changes (caused by the Time Stretch fx unit), the seek timer interval needs to be updated, to ensure that the seek position fields are updated fast/slow enough to match the new playback rate.
    private func playbackRateChanged(_ notification: PlaybackRateChangedNotification) {
        
        let interval = Int(1000 / (2 * notification.newPlaybackRate))
        
        if (interval != seekTimer?.getInterval()) {
            
            seekTimer?.stop()
            seekTimer = RepeatingTaskExecutor(intervalMillis: interval, task: {self.updateSeekPosition()}, queue: DispatchQueue.main)
            
            let playbackState = player.getPlaybackState()
            setSeekTimerState(playbackState == .playing)
        }
    }
    
    // When the playback state changes (e.g. playing -> paused), fields may need to be updated
    private func playbackStateChanged(_ notification: PlaybackStateChangedNotification) {
        
        let isPlaying: Bool = (notification.newPlaybackState == .playing)
        
        // The seek timer can be disabled when not needed (e.g. when paused)
        setSeekTimerState(isPlaying)
        
        let track = (player.getPlayingTrack()?.track)!
        if (track.displayInfo.art == nil) {
            
            // Default artwork
            let playing = player.getPlaybackState() == .playing
            artView.image = playing ? Images.imgPlayingArt : Images.imgPausedArt
        }
    }
    
    // When track info for the playing track changes, display fields need to be updated
    private func playingTrackInfoUpdated(_ notification: PlayingTrackInfoUpdatedNotification) {
        showNowPlayingInfo(player.getPlayingTrack()!.track)
    }
    
    private func renderLoop() {
        
        if let loop = player.getPlaybackLoop() {
            
            let duration = (player.getPlayingTrack()?.track.duration)!
            
            // Mark start
            seekSliderClone.doubleValue = loop.startTime * 100 / duration
            seekSliderCell.markLoopStart(seekSliderCloneCell.knobCenter)
            
            // Mark end
            if (loop.isComplete()) {
                
                seekSliderClone.doubleValue = loop.endTime! * 100 / duration
                seekSliderCell.markLoopEnd(seekSliderCloneCell.knobCenter)
            }
            
        } else {
            
            seekSliderCell.removeLoop()
        }
        
        // Force a redraw of the seek slider
        updateSeekPosition()
    }
    
    private func playbackLoopChanged() {
        
        if let loop = player.getPlaybackLoop() {
            
            let duration = (player.getPlayingTrack()?.track.duration)!
            
            // Use the seek slider clone to mark the exact position of the center of the slider knob, at both the start and end points of the playback loop (for rendering)
            if (loop.isComplete()) {
                
                seekSliderClone.doubleValue = loop.endTime! * 100 / duration
                seekSliderCell.markLoopEnd(seekSliderCloneCell.knobCenter)
                
            } else {
                
                seekSliderClone.doubleValue = loop.startTime * 100 / duration
                seekSliderCell.markLoopStart(seekSliderCloneCell.knobCenter)
            }
            
        } else {
            
            seekSliderCell.removeLoop()
        }
        
        // Force a redraw of the seek slider
        updateSeekPosition()
    }

    // MARK: Message handlers
    
    // Consume synchronous notification messages
    func consumeNotification(_ notification: NotificationMessage) {
        
        switch notification.messageType {
            
        case .trackChangedNotification:
            
            trackChanged(notification as! TrackChangedNotification)
            
        case .playbackRateChangedNotification:
            
            playbackRateChanged(notification as! PlaybackRateChangedNotification)
            
        case .playbackStateChangedNotification:
            
            playbackStateChanged(notification as! PlaybackStateChangedNotification)
            
        case .playbackLoopChangedNotification:
            
            playbackLoopChanged()
            
        case .seekPositionChangedNotification:
            
            updateSeekPosition()
            
        case .playingTrackInfoUpdatedNotification:
            
            playingTrackInfoUpdated(notification as! PlayingTrackInfoUpdatedNotification)

        default: return
            
        }
    }
    
    // Consume asynchronous messages
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .tracksRemoved:
            
            tracksRemoved(message as! TracksRemovedAsyncMessage)
            
        default: return
            
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        // This class does not return any meaningful responses
        return EmptyResponse.instance
    }
    
    func getID() -> String {
        return self.className
    }
}
