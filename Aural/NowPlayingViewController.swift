/*
    View controller for the Now Playing info box which displays information about the currently playing track
 */

import Cocoa

class NowPlayingViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber, AsyncMessageSubscriber, ConstituentView {
    
    @IBOutlet weak var nowPlayingView: NSView!
    @IBOutlet weak var gapView: NSView!
    
    @IBOutlet weak var gapView_lblTrackTitle: NSTextField!
    @IBOutlet weak var gapView_artView: NSImageView!
    @IBOutlet weak var gapView_lblTimeRemaining: NSTextField!
    
    // Fields that display playing track info
    @IBOutlet weak var lblTrackArtist: NSTextField!
    @IBOutlet weak var lblTrackTitle: NSTextField!
    @IBOutlet weak var lblTrackName: BannerLabel!
    @IBOutlet weak var artView: NSImageView!
    
    // Fields that display/control seek position within the playing track
    @IBOutlet weak var lblTimeElapsed: NSTextField!
    @IBOutlet weak var lblTimeRemainingOrDuration: NSTextField!
    
    // Fields that display information about the current playback scope
    @IBOutlet weak var lblSequenceProgress: NSTextField!
    @IBOutlet weak var lblPlaybackScope: NSTextField!
    @IBOutlet weak var imgScope: NSImageView!
    
    // Shows the time elapsed for the currently playing track, and allows arbitrary seeking within the track
    @IBOutlet weak var seekSlider: NSSlider!
    @IBOutlet weak var seekSliderCell: SeekSliderCell!
    
    // A clone of the seek slider, used to render the segment playback loop
    @IBOutlet weak var seekSliderClone: NSSlider!
    @IBOutlet weak var seekSliderCloneCell: SeekSliderCell!
    
    // Used to display the bookmark name prompt popover
    @IBOutlet weak var seekPositionMarker: NSView!
    
    // Button to display more details about the playing track
    @IBOutlet weak var btnMoreInfo: NSButton!
    
    // Button to show the currently playing track within the playlist
    @IBOutlet weak var btnShowPlayingTrackInPlaylist: NSButton!

    // Button to add/remove the currently playing track to/from the Favorites list
    @IBOutlet weak var btnFavorite: OnOffImageButton!
    
    // Button to bookmark current track and position
    @IBOutlet weak var btnBookmark: NSButton!
    
    // Delegate that conveys all seek and playback info requests to the player
    private let player: PlaybackDelegateProtocol = ObjectGraph.getPlaybackDelegate()
    
    // Delegate that retrieves Time Stretch information
    private let audioGraph: AudioGraphDelegateProtocol = ObjectGraph.getAudioGraphDelegate()
    
    // Delegate that provides access to History information
    private let favorites: FavoritesDelegateProtocol = ObjectGraph.getFavoritesDelegate()
    
    // Timer that periodically updates the seek position slider and label
    private var seekTimer: RepeatingTaskExecutor?
    private var gapTimer: RepeatingTaskExecutor?
    
    // Popover view that displays detailed info for the currently playing track
    private lazy var detailedInfoPopover: PopoverViewDelegate = ViewFactory.getDetailedTrackInfoPopover()
    
    // Popup view that displays a brief notification when the currently playing track is added/removed to/from the Favorites list
    private lazy var favoritesPopup: FavoritesPopupProtocol = ViewFactory.getFavoritesPopup()
    
    private let appState: NowPlayingState = ObjectGraph.getAppState().uiState.nowPlayingState
    
    override var nibName: String? {return "NowPlaying"}
    
    override func viewDidLoad() {
        
        // Use persistent app state to determine the initial state of the view
        initControls()
        AppModeManager.registerConstituentView(.regular, self)
    }
    
    func activate() {
        
        initSubscriptions()
        
        lblTrackName.beginAnimation()
        
        let newTrack = player.getPlayingTrack()
        
        if (newTrack != nil) {
            
            showNowPlayingInfo(newTrack!.track)
            renderLoop()
            setSeekTimerState(true)
            seekSlider.isEnabled = true
            togglePlayingTrackButtons(true)
            
        } else {
            
            // No track playing, clear the info fields
            clearNowPlayingInfo()
        }
    }
    
    func deactivate() {
        
        lblTrackName.endAnimation()
        removeSubscriptions()
    }
    
    private func initControls() {
        
        NowPlayingViewState.showDuration = appState.showDuration
        
        nowPlayingView.isHidden = false
        gapView.isHidden = true
        
        let timeBypassed = audioGraph.getTimeState() != .active
        let seekTimerInterval = timeBypassed ? UIConstants.seekTimerIntervalMillis : Int(1000 / (2 * audioGraph.getTimeRate().rate))
        
        // Timer interval depends on whether time stretch unit is active
        seekTimer = RepeatingTaskExecutor(intervalMillis: seekTimerInterval, task: {
            
            if (self.player.getPlaybackState() == .playing) {
                self.updateSeekPosition()
            }
        
        }, queue: DispatchQueue.main)
        
        // TODO: Can't this be done in Interface Builder ???
        lblTrackName.font = Fonts.regularModeTrackNameTextFont
        lblTrackName.alignment = NSTextAlignment.center
        
        // Allow clicks on the time remaining label to switch to  track duration display
        let gestureRecognizer: NSGestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(self.switchTrackTimeDisplayAction(_:)))
        lblTimeRemainingOrDuration.addGestureRecognizer(gestureRecognizer)
    }
    
    private func initSubscriptions() {
        
        // Subscribe to various notifications
        
        AsyncMessenger.subscribe([.trackAdded, .tracksRemoved, .addedToFavorites, .removedFromFavorites, .gapStarted], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(messageTypes: [.trackChangedNotification, .sequenceChangedNotification, .playbackRateChangedNotification, .playbackStateChangedNotification, .playbackLoopChangedNotification, .seekPositionChangedNotification, .playingTrackInfoUpdatedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.moreInfo], subscriber: self)
    }
    
    private func removeSubscriptions() {
        
        AsyncMessenger.unsubscribe([.trackAdded, .tracksRemoved, .addedToFavorites, .removedFromFavorites], subscriber: self)
        
        SyncMessenger.unsubscribe(messageTypes: [.trackChangedNotification, .sequenceChangedNotification, .playbackRateChangedNotification, .playbackStateChangedNotification, .playbackLoopChangedNotification, .seekPositionChangedNotification, .playingTrackInfoUpdatedNotification], subscriber: self)
        
        SyncMessenger.unsubscribe(actionTypes: [.moreInfo], subscriber: self)
    }
    
    // Moving the seek slider results in seeking the track to the new slider position
    @IBAction func seekSliderAction(_ sender: AnyObject) {
        player.seekToPercentage(seekSlider.doubleValue)
        updateSeekPosition()
    }
    
    // Shows a popover with detailed information for the currently playing track, if there is one
    @IBAction func moreInfoAction(_ sender: AnyObject) {
        
        let playingTrack = player.getPlayingTrack()
        
        // If there is a track currently playing, load detailed track info and toggle the popover view
        if (playingTrack != nil) {
            
            // TODO: This should be done through a delegate (TrackDelegate ???)
            playingTrack!.track.loadDetailedInfo()
            detailedInfoPopover.toggle(playingTrack!.track, btnMoreInfo, NSRectEdge.maxX)
        }
    }
    
    // Shows (selects) the currently playing track, within the playlist, if there is one
    @IBAction func showPlayingTrackAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.showPlayingTrack, PlaylistViewState.current))
    }
    
    // Adds/removes the currently playing track to/from the "Favorites" list
    @IBAction func favoriteAction(_ sender: Any) {
        
        // Toggle the button state
        btnFavorite.toggle()
        
        // Assume there is a track playing (this function cannot be invoked otherwise)
        let playingTrack = (player.getPlayingTrack()?.track)!
        
        // Publish an action message to add/remove the item to/from Favorites
        if btnFavorite.isOn() {
            _ = favorites.addFavorite(playingTrack)
        } else {
            favorites.deleteFavoriteWithFile(playingTrack.file)
        }
    }
    
    // Adds/removes the currently playing track to/from the "Favorites" list
    @IBAction func bookmarkAction(_ sender: Any) {
        
        // Publish an action message to add/remove the item to/from Favorites
        SyncMessenger.publishActionMessage(BookmarkActionMessage.instance)
    }
    
    // Responds to a notification that a track has been added to / removed from the Favorites list, by updating the UI to reflect the new state
    private func favoritesUpdated(_ message: FavoritesUpdatedAsyncMessage) {
        
        if let playingTrack = player.getPlayingTrack()?.track {
        
        // Do this only if the track in the message is the playing track
            if message.file.path == playingTrack.file.path {
                
                if (message.messageType == .addedToFavorites) {
                    btnFavorite.on()
                    favoritesPopup.showAddedMessage(btnFavorite, NSRectEdge.maxX)
                } else {
                    btnFavorite.off()
                    favoritesPopup.showRemovedMessage(btnFavorite, NSRectEdge.maxX)
                }
            }
        }
    }
    
    @IBAction func switchTrackTimeDisplayAction(_ sender: Any) {
        NowPlayingViewState.showDuration = !NowPlayingViewState.showDuration
        updateSeekPosition()
    }
    
    private func showNowPlayingInfo(_ track: Track) {
        
        var artistAndTitleAvailable: Bool = false
        
        if (track.displayInfo.hasArtistAndTitle()) {
            
            artistAndTitleAvailable = true
            
            // Both title and artist
            lblTrackArtist.stringValue = track.displayInfo.artist!
            lblTrackTitle.stringValue = track.displayInfo.title!
            
        } else {
            
            lblTrackName.text = track.conciseDisplayName
        }
        
        lblTrackName.isHidden = artistAndTitleAvailable
        [lblTrackArtist, lblTrackTitle].forEach({$0?.isHidden = !artistAndTitleAvailable})
        
        if (track.displayInfo.art != nil) {
            artView.image = track.displayInfo.art!
        } else {
            
            // Default artwork
            let playing = player.getPlaybackState() == .playing
            artView.image = playing ? Images.imgPlayingArt : Images.imgPausedArt
        }
        
        initSeekPosition()
        showPlaybackScope()
        
        btnFavorite.onIf(favorites.favoriteWithFileExists(track.file))
    }
    
    /* 
        Displays information about the current playback scope (i.e. the set of tracks that make up the current playback sequence - for ex. a specific artist group, or all tracks), and progress within that sequence - for ex. 5/67 (5th track playing out of a total of 67 tracks).
     */
    private func showPlaybackScope() {
        
        let sequence = player.getPlaybackSequenceInfo()
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
        let stringSize: CGSize = scopeString.size(withAttributes: convertToOptionalNSAttributedStringKeyDictionary([convertFromNSAttributedStringKey(NSAttributedString.Key.font): lblPlaybackScope.font as AnyObject]))
        let lblWidth = lblPlaybackScope.frame.width
        let textWidth = min(stringSize.width, lblWidth)
        
        // Position the scope image a few pixels to the left of the scope string
        let margin = (lblWidth - textWidth) / 2
        let newImgX = lblPlaybackScope.frame.origin.x + margin - imgScope.frame.width - 4
        imgScope.frame.origin.x = max(Dimensions.minImgScopeLocationX, newImgX)
    }
    
    private func clearNowPlayingInfo() {
        
        [lblTrackArtist, lblTrackTitle, lblPlaybackScope, lblSequenceProgress].forEach({$0?.stringValue = ""})
        lblTrackName.text = ""
        artView.image = Images.imgPausedArt
        imgScope.image = nil
        
        seekSlider.floatValue = 0
        lblTimeElapsed.isHidden = true
        lblTimeRemainingOrDuration.isHidden = true
        setSeekTimerState(false)
        seekSlider.isEnabled = false
        
        togglePlayingTrackButtons(false)
        detailedInfoPopover.close()
    }
    
    // When the playing track changes (or there is none), certain functions may or may not be available, so their corresponding UI controls need to be shown/enabled or hidden/disabled.
    private func togglePlayingTrackButtons(_ show: Bool) {
        
        [btnMoreInfo, btnShowPlayingTrackInPlaylist, btnFavorite, btnBookmark].forEach({$0.isHidden = !show})
    }
    
    private func setSeekTimerState(_ timerOn: Bool) {
        timerOn ? seekTimer?.startOrResume() : seekTimer?.pause()
    }
    
    // Updates the seek slider and time elapsed/remaining labels as playback proceeds
    private func updateSeekPosition() {
        
        let seekPosn = player.getSeekPosition()
        
        seekSlider.doubleValue = seekPosn.percentageElapsed
        
        let trackTimes = StringUtils.formatTrackTimes(seekPosn.timeElapsed, seekPosn.trackDuration)
        
        lblTimeElapsed.stringValue = trackTimes.elapsed
        lblTimeRemainingOrDuration.stringValue = NowPlayingViewState.showDuration ? StringUtils.formatSecondsToHMS(seekPosn.trackDuration) : trackTimes.remaining
    }
    
    private func initSeekPosition() {
        
        lblTimeElapsed.isHidden = false
        lblTimeRemainingOrDuration.isHidden = false
        updateSeekPosition()
    }
    
    // Resets the seek slider and time elapsed/remaining labels when playback of a track begins
    private func resetSeekPosition(_ track: Track) {
        
        lblTimeElapsed.stringValue = Strings.zeroDurationString
        lblTimeRemainingOrDuration.stringValue = NowPlayingViewState.showDuration ? StringUtils.formatSecondsToHMS(track.duration) : StringUtils.formatSecondsToHMS(track.duration, true)
        
        lblTimeElapsed.isHidden = false
        lblTimeRemainingOrDuration.isHidden = false
        
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
        
        gapTimer?.stop()
        gapView.isHidden = true
        nowPlayingView.isHidden = false
        
        if (player.getPlaybackLoop()) != nil {
            renderLoop()
        } else {
            seekSliderCell.removeLoop()
        }
        
        if (newTrack != nil) {
            
            showNowPlayingInfo(newTrack!.track)
            
            if (!errorState) {
                setSeekTimerState(true)
                seekSlider.isEnabled = true
                togglePlayingTrackButtons(true)
                
                if (detailedInfoPopover.isShown()) {
                    
                    player.getPlayingTrack()!.track.loadDetailedInfo()
                    detailedInfoPopover.refresh(player.getPlayingTrack()!.track)
                }
                
            } else {
                
                // Error state
                setSeekTimerState(false)
                seekSlider.isEnabled = false
            }
            
        } else {
            
            // No track playing, clear the info fields
            clearNowPlayingInfo()
        }
    }
    
    // Whenever the playback sequence changes (without the playing track changing), the sequence progress might have changed. For example, when the playing track is moved up one row, its progress will change from "4/10" to "3/10". The display fields need to be updated accordingly.
    private func sequenceChanged() {
        
        let sequence = player.getPlaybackSequenceInfo()
        lblSequenceProgress.stringValue = String(format: "%d / %d", sequence.trackIndex, sequence.totalTracks)
    }
    
    // When the playback rate changes (caused by the Time Stretch fx unit), the seek timer interval needs to be updated, to ensure that the seek position fields are updated fast/slow enough to match the new playback rate.
    private func playbackRateChanged(_ notification: PlaybackRateChangedNotification) {
        
        let interval = Int(1000 / (2 * notification.newPlaybackRate))
        
        if (interval != seekTimer?.getInterval()) {
            
            seekTimer?.stop()
            seekTimer = RepeatingTaskExecutor(intervalMillis: interval, task: {
                
                if (self.player.getPlaybackState() == .playing) {
                    self.updateSeekPosition()
                }
                }, queue: DispatchQueue.main)
            
            let playbackState = player.getPlaybackState()
            setSeekTimerState(playbackState == .playing)
        }
    }
    
    // When the playback state changes (e.g. playing -> paused), fields may need to be updated
    private func playbackStateChanged(_ notification: PlaybackStateChangedNotification) {
        
        let isPlaying: Bool = (notification.newPlaybackState == .playing)
    
        // The seek timer can be disabled when not needed (e.g. when paused)
        setSeekTimerState(isPlaying)
        
        if let track = player.getPlayingTrack()?.track, track.displayInfo.art == nil {
        
            // Default artwork
            artView.image = isPlaying ? Images.imgPlayingArt : Images.imgPausedArt
        }
    }
    
    // When the playback loop for the current playing track is changed, the seek slider needs to be updated (redrawn) to show the current loop state
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
    
    private func renderLoop() {
        
        if let loop = player.getPlaybackLoop() {
            
            let duration = (player.getPlayingTrack()?.track.duration)!
            
            // Mark start
            seekSliderClone.doubleValue = loop.startTime * 100 / duration
            seekSliderCell.markLoopStart(seekSliderCloneCell.knobCenter)
            
            // Use the seek slider clone to mark the exact position of the center of the slider knob, at both the start and end points of the playback loop (for rendering)
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
    
    // When track info for the playing track changes, display fields need to be updated
    private func playingTrackInfoUpdated(_ notification: PlayingTrackInfoUpdatedNotification) {
        showNowPlayingInfo(player.getPlayingTrack()!.track)
    }
    
    private func updateGapCountdown(_ endTime: Date) {
        gapView_lblTimeRemaining.stringValue = StringUtils.formatSecondsToHMS(max(DateUtils.timeUntil(endTime), 0))
    }
    
    private func gapStarted(_ msg: PlaybackGapStartedAsyncMessage) {
        
        nowPlayingView.isHidden = true
        
        let track = msg.nextTrack.track
        
        gapView_lblTrackTitle.stringValue = String(format: "Up next:   %@", track.conciseDisplayName)
        updateGapCountdown(msg.gapEndTime)
        
        if (track.displayInfo.art != nil) {
            
            gapView_artView.image = track.displayInfo.art!
            
        } else {
            
            // Default artwork
            gapView_artView.image = Images.imgPausedArt
        }
        
        gapView.isHidden = false
        
        gapTimer = RepeatingTaskExecutor(intervalMillis: 500, task: {
            
            self.updateGapCountdown(msg.gapEndTime)
            
        }, queue: DispatchQueue.main)
        
        gapTimer?.startOrResume()
    }
    
    private func trackAdded(_ message: TrackAddedAsyncMessage) {
        
        let playbackState = player.getPlaybackState()
        
        if playbackState == .playing || playbackState == .paused {
        
            DispatchQueue.main.async {
                self.sequenceChanged()
            }
        }
    }
    
    // MARK: Message handling
    
    func getID() -> String {
        return self.className
    }
    
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
            
        case .playbackLoopChangedNotification:
            
            playbackLoopChanged()
            
        case .seekPositionChangedNotification:
            
            updateSeekPosition()
            
        case .playingTrackInfoUpdatedNotification:
            
            playingTrackInfoUpdated(notification as! PlayingTrackInfoUpdatedNotification)
            
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
            
        case .trackAdded:
            
            trackAdded(message as! TrackAddedAsyncMessage)
            
        case .tracksRemoved:
            
            tracksRemoved(message as! TracksRemovedAsyncMessage)
            
        case .addedToFavorites, .removedFromFavorites:
            
            favoritesUpdated(message as! FavoritesUpdatedAsyncMessage)
            
        case .gapStarted:
            
            gapStarted(message as! PlaybackGapStartedAsyncMessage)
            
        default: return
        
        }
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .moreInfo: moreInfoAction(self)
            
        default: return
            
        }
    }
    
    // Used to position the bookmark name popover relative to the seek slider cell
    func getLocationForBookmarkPrompt() -> (view: NSView, edge: NSRectEdge) {
 
        // Slider knob position
        let knobRect = seekSliderCell.knobRect(flipped: false)
        seekPositionMarker.setFrameOrigin(NSPoint(x: seekSlider.frame.origin.x + knobRect.minX + 4, y: seekSlider.frame.origin.y + knobRect.height / 2))
        
        return (seekPositionMarker, NSRectEdge.minY)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
	guard let input = input else { return nil }
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
	return input.rawValue
}

// Convenient accessor for information about the current playlist view
class NowPlayingViewState {
    
    static var showDuration: Bool = false
    
    static func persistentState() -> NowPlayingState {
    
        let state = NowPlayingState()
        state.showDuration = showDuration
        
        return state
    }
}
