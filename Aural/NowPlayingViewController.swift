/*
    View controller for the Now Playing info box which displays information about the currently playing track
 */

import Cocoa

class NowPlayingViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber, AsyncMessageSubscriber {
    
    // Fields that display playing track info
    @IBOutlet weak var lblTrackArtist: NSTextField!
    @IBOutlet weak var lblTrackTitle: NSTextField!
    @IBOutlet weak var lblTrackName: NSTextField!
    @IBOutlet weak var artView: NSImageView!
    
    // Fields that display/control seek position within the playing track
    @IBOutlet weak var lblTimeElapsed: NSTextField!
    @IBOutlet weak var lblTimeRemaining: NSTextField!
    
    // Fields that display information about the current playback scope
    @IBOutlet weak var lblSequenceProgress: NSTextField!
    @IBOutlet weak var lblPlaybackScope: NSTextField!
    @IBOutlet weak var imgScope: NSImageView!
    
    // Shows the time elapsed for the currently playing track, and allows arbitrary seeking within the track
    @IBOutlet weak var seekSlider: NSSlider!
    
    // Button to display more details about the playing track
    @IBOutlet weak var btnMoreInfo: NSButton!
//    @IBOutlet weak var moreInfoMenuItem: NSMenuItem!
    
    // Button to show the currently playing track within the playlist
    @IBOutlet weak var btnShowPlayingTrackInPlaylist: NSButton!
//    @IBOutlet weak var showInPlaylistMenuItem: NSMenuItem!
    
    // Delegate that retrieves information about the player and the currently playing track
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    // The view that displays detailed track information, when requested by the user
    private lazy var popoverView: PopoverViewDelegateProtocol = {
        return PopoverViewController.create(self.btnMoreInfo as NSView)
    }()
    
    // Timer that periodically updates the seek position slider and label
    private var seekTimer: RepeatingTaskExecutor?
    
    override func viewDidLoad() {
        
        // Retrieve persistent app state, to determine the initial state of the view
        let appState = ObjectGraph.getUIAppState()
        
        // Timer interval depends on whether time stretch unit is active
        seekTimer = RepeatingTaskExecutor(intervalMillis: appState.seekTimerInterval, task: {self.updateSeekPosition()}, queue: DispatchQueue.main)
        
        // Set up the art view and the default animation
        artView.canDrawSubviewsIntoLayer = true
        artView.image = Images.imgPlayingArt
        
        // Subscribe to various notifications
        
        AsyncMessenger.subscribe([.tracksRemoved], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(messageTypes: [.trackChangedNotification, .sequenceChangedNotification, .playbackRateChangedNotification, .playbackStateChangedNotification, .seekPositionChangedNotification, .playingTrackInfoUpdatedNotification, .appInBackgroundNotification, .appInForegroundNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.moreInfo], subscriber: self)
    }
    
    @IBAction func moreInfoAction(_ sender: AnyObject) {
        
        let playingTrack = playbackInfo.getPlayingTrack()
        
        // If there is a track currently playing, load detailed track info and toggle the popover view
        if (playingTrack != nil) {
            
            // TODO: This should be done through a delegate (TrackDelegate ???)
            playingTrack!.track.loadDetailedInfo()
            
            popoverView.toggle()
        }
    }
    
    @IBAction func showPlayingTrackAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.showPlayingTrack, PlaylistViewState.current))
    }
    
    private func showNowPlayingInfo(_ track: Track) {
        
        var artistAndTitleAvailable: Bool = false
        
        if (track.displayInfo.hasArtistAndTitle()) {
            
            artistAndTitleAvailable = true
            
            // Both title and artist
            lblTrackArtist.stringValue = track.displayInfo.artist!
            lblTrackTitle.stringValue = track.displayInfo.title!
            
        } else {
            
            lblTrackName.stringValue = track.conciseDisplayName
            
            // Re-position and resize the track name label, depending on whether it is displaying one or two lines of text (i.e. depending on the length of the track name)
            
            // Determine how many lines the track name will occupy, within the label
            let numLines = StringUtils.numberOfLines(track.conciseDisplayName, lblTrackName.font!, lblTrackName.frame.width)
            
            // The Y co-ordinate is a pre-determined constant
            var origin = lblTrackName.frame.origin
            origin.y = numLines == 1 ? UIConstants.trackNameLabelLocationY_oneLine : UIConstants.trackNameLabelLocationY_twoLines
            
            // The height is a pre-determined constant
            var lblFrameSize = lblTrackName.frame.size
            lblFrameSize.height = numLines == 1 ? UIConstants.trackNameLabelHeight_oneLine : UIConstants.trackNameLabelHeight_twoLines
            
            // Resize the label
            lblTrackName.setFrameSize(lblFrameSize)
            
            // Re-position the label
            lblTrackName.setFrameOrigin(origin)
        }
        
        lblTrackName.isHidden = artistAndTitleAvailable
        [lblTrackArtist, lblTrackTitle].forEach({$0?.isHidden = !artistAndTitleAvailable})
        
        if (track.displayInfo.art != nil) {
            artView.image = track.displayInfo.art!
        } else {
            
            // Default artwork animation
            artView.image = Images.imgPlayingArt
            artView.animates = true
        }
        
        resetSeekPosition(track)
        showPlaybackScope()
    }
    
    /* 
        Displays information about the current playback scope (i.e. the set of tracks that make up the current playback sequence - for ex. a specific artist group, or all tracks), and progress within that sequence - for ex. 5/67 (5th track playing out of a total of 67 tracks).
     */
    private func showPlaybackScope() {
        
        let sequence = playbackInfo.getPlaybackSequenceInfo()
        let scope = sequence.scope
        
        // Description and image for playback scope
        switch scope.type {
            
        case .allTracks, .allArtists, .allAlbums, .allGenres:
            
            lblPlaybackScope.stringValue = StringUtils.splitCamelCaseWord(scope.type.rawValue, false)
            imgScope.image = Images.imgPlaylistOn
            
        case .artist, .album, .genre:
            
            lblPlaybackScope.stringValue = scope.scope!.name
            imgScope.image = Images.imgGroup
        }
        
        // Sequence progress. For example, "5 / 10" (tracks)
        let trackIndex = sequence.trackIndex
        let totalTracks = sequence.totalTracks
        lblSequenceProgress.stringValue = String(format: "%d / %d", trackIndex, totalTracks)
        
        // Dynamically position the scope image relative to the scope description string
        
        // Determine the width of the scope string
        let scopeString: NSString = lblPlaybackScope.stringValue as NSString
        let stringSize: CGSize = scopeString.size(withAttributes: [NSFontAttributeName: lblPlaybackScope.font as AnyObject])
        let lblWidth = lblPlaybackScope.frame.width
        let textWidth = min(stringSize.width, lblWidth)
        
        // Position the scope image a few pixels to the left of the scope string
        let margin = (lblWidth - textWidth) / 2
        let newImgX = lblPlaybackScope.frame.origin.x + margin - imgScope.frame.width - 4
        imgScope.frame.origin.x = max(UIConstants.minImgScopeLocationX, newImgX)
    }
    
    private func clearNowPlayingInfo() {
        
        [lblTrackArtist, lblTrackTitle, lblTrackName, lblPlaybackScope, lblSequenceProgress].forEach({$0?.stringValue = ""})
        artView.image = Images.imgPlayingArt
        artView.animates = false
        imgScope.image = nil
        
        seekSlider.floatValue = 0
        lblTimeElapsed.isHidden = true
        lblTimeRemaining.isHidden = true
        setSeekTimerState(false)
        
        togglePlayingTrackButtons(false)
        popoverView.close()
    }
    
    // When the playing track changes (or there is none), certain functions may or may not be available, so their corresponding UI controls need to be shown/enabled or hidden/disabled.
    private func togglePlayingTrackButtons(_ show: Bool) {
        
        [btnMoreInfo, btnShowPlayingTrackInPlaylist].forEach({$0.isHidden = !show})
    }
    
    private func setSeekTimerState(_ timerOn: Bool) {
        
        if (timerOn) {
            seekSlider.isEnabled = true
            seekTimer?.startOrResume()
        } else {
            seekTimer?.pause()
            seekSlider.isEnabled = false
        }
    }
    
    // Updates the seek slider and time elapsed/remaining labels as playback proceeds
    private func updateSeekPosition() {
        
        if (playbackInfo.getPlaybackState() == .playing) {
            
            let seekPosn = playbackInfo.getSeekPosition()
            
            let trackTimes = StringUtils.formatTrackTimes(seekPosn.timeElapsed, seekPosn.trackDuration)
            
            lblTimeElapsed.stringValue = trackTimes.elapsed
            lblTimeRemaining.stringValue = trackTimes.remaining
            
            seekSlider.doubleValue = seekPosn.percentageElapsed
        }
    }
    
    // Resets the seek slider and time elapsed/remaining labels when playback of a track begins
    private func resetSeekPosition(_ track: Track) {
        
        lblTimeElapsed.stringValue = UIConstants.zeroDurationString
        lblTimeRemaining.stringValue = StringUtils.formatSecondsToHMS(track.duration, true)
        
        lblTimeElapsed.isHidden = false
        lblTimeRemaining.isHidden = false
        
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
        
        if (newTrack != nil) {
            
            showNowPlayingInfo(newTrack!.track)
            
            if (!errorState) {
                setSeekTimerState(true)
                togglePlayingTrackButtons(true)
                
                if (popoverView.isShown()) {
                    
                    playbackInfo.getPlayingTrack()?.track.loadDetailedInfo()
                    popoverView.refresh()
                }
                
            } else {
                
                // Error state
                setSeekTimerState(false)
            }
            
        } else {
            
            // No track playing, clear the info fields
            clearNowPlayingInfo()
        }
    }
    
    // Whenever the playback sequence changes (without the playing track changing), the sequence progress might have changed. For example, when the playing track is moved up one row, its progress will change from "4/10" to "3/10". The display fields need to be updated accordingly.
    private func sequenceChanged() {
        
        let sequence = playbackInfo.getPlaybackSequenceInfo()
        lblSequenceProgress.stringValue = String(format: "%d / %d", sequence.trackIndex, sequence.totalTracks)
    }
    
    // When the playback rate changes (caused by the Time Stretch fx unit), the seek timer interval needs to be updated, to ensure that the seek position fields are updated fast/slow enough to match the new playback rate.
    private func playbackRateChanged(_ notification: PlaybackRateChangedNotification) {
        
        let interval = Int(1000 / (2 * notification.newPlaybackRate))
        
        if (interval != seekTimer?.getInterval()) {
            
            seekTimer?.stop()
            seekTimer = RepeatingTaskExecutor(intervalMillis: interval, task: {self.updateSeekPosition()}, queue: DispatchQueue.main)
            
            let playbackState = playbackInfo.getPlaybackState()
            setSeekTimerState(playbackState == .playing)
        }
    }
    
    // When the playback state changes (e.g. playing -> paused), fields may need to be updated
    private func playbackStateChanged(_ notification: PlaybackStateChangedNotification) {
        
        let isPlaying: Bool = (notification.newPlaybackState == .playing)
    
        // The seek timer can be disabled when not needed (e.g. when paused)
        setSeekTimerState(isPlaying)
        
        // Pause/resume the art animation
        artView.animates = shouldAnimate()
    }
    
    // When track info for the playing track changes, display fields need to be updated
    private func playingTrackInfoUpdated(_ notification: PlayingTrackInfoUpdatedNotification) {
        showNowPlayingInfo(playbackInfo.getPlayingTrack()!.track)
    }
    
    private func appInBackground() {
        artView.animates = false
    }
    
    private func appInForeground() {
        artView.animates = shouldAnimate()
    }
    
    // Helper function that determines whether or not the playing track animation should be shown animated
    private func shouldAnimate() -> Bool {
        
        // Animation enabled only if 1 - the appropriate playlist view is currently shown, 2 - a track is currently playing (not paused), and 3 - the app window is currently in the foreground
        return (playbackInfo.getPlaybackState() == .playing) && WindowState.inForeground
    }
    
    // MARK: Message handlers
    
    // Consume synchronous notification messages
    func consumeNotification(_ notification: NotificationMessage) {
        
        switch notification.messageType {
            
        case .trackChangedNotification:
            
            trackChanged(notification as! TrackChangedNotification)
            
        case .sequenceChangedNotification:
            
            sequenceChanged()
            
        case .playbackRateChangedNotification:
            
            playbackRateChanged(notification as! PlaybackRateChangedNotification)
            
        case .playbackStateChangedNotification:
            
            playbackStateChanged(notification as! PlaybackStateChangedNotification)
            
        case .seekPositionChangedNotification:
            
            updateSeekPosition()
            
        case .playingTrackInfoUpdatedNotification:
            
            playingTrackInfoUpdated(notification as! PlayingTrackInfoUpdatedNotification)
            
        case .appInBackgroundNotification:
            
            appInBackground()
            
        case .appInForegroundNotification:
            
            appInForeground()
            
        default: return
            
        }
    }
    
    // Process synchronous request messages
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        
        // This class does not process any requests
        return EmptyResponse.instance
    }
    
    // Consume asynchronous messages
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .tracksRemoved:
            
            tracksRemoved(message as! TracksRemovedAsyncMessage)
            
        default: return
        
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .moreInfo: moreInfoAction(self)
            
        default: return
            
        }
    }
}
