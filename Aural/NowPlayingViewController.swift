/*
    View controller for the Now Playing info box which displays information about the currently playing track
 */

import Cocoa

class NowPlayingViewController: NSViewController, MessageSubscriber {
    
    // Fields that display playing track info
    @IBOutlet weak var lblTrackArtist: NSTextField!
    @IBOutlet weak var lblTrackTitle: NSTextField!
    @IBOutlet weak var lblTrackName: NSTextField!
    @IBOutlet weak var artView: NSImageView!
    
    // Fields that display/control seek position within the playing track
    @IBOutlet weak var lblTimeElapsed: NSTextField!
    @IBOutlet weak var lblTimeRemaining: NSTextField!
    
    @IBOutlet weak var lblSequenceProgress: NSTextField!
    @IBOutlet weak var lblPlaybackScope: NSTextField!
    @IBOutlet weak var imgScope: NSImageView!
    
    @IBOutlet weak var seekSlider: NSSlider!
    
    // Button and menu item to display more details about the playing track
    @IBOutlet weak var btnMoreInfo: NSButton!
    @IBOutlet weak var moreInfoMenuItem: NSMenuItem!
    
    // Button and menu item to show the currently playing track within the playlist
    @IBOutlet weak var btnShowPlayingTrackInPlaylist: NSButton!
    @IBOutlet weak var showInPlaylistMenuItem: NSMenuItem!
    
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
        artView.image = UIConstants.imgPlayingArt
        
        // Subscribe to various notifications
        SyncMessenger.subscribe(.trackChangedNotification, subscriber: self)
        SyncMessenger.subscribe(.sequenceChangedNotification, subscriber: self)
        SyncMessenger.subscribe(.playbackRateChangedNotification, subscriber: self)
        SyncMessenger.subscribe(.playbackStateChangedNotification, subscriber: self)
        SyncMessenger.subscribe(.seekPositionChangedNotification, subscriber: self)
        SyncMessenger.subscribe(.playingTrackInfoUpdatedNotification, subscriber: self)
    }
    
    @IBAction func moreInfoAction(_ sender: AnyObject) {
        
        let playingTrack = playbackInfo.getPlayingTrack()
        
        // If there is a track currently playing, load detailed track info and toggle the popover view
        if (playingTrack != nil) {
            playingTrack!.track.loadDetailedInfo()
            popoverView.toggle()
        }
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
        lblTrackArtist.isHidden = !artistAndTitleAvailable
        lblTrackTitle.isHidden = !artistAndTitleAvailable
        
        if (track.displayInfo.art != nil) {
            artView.image = track.displayInfo.art!
        } else {
            
            // Default artwork animation
            artView.image = UIConstants.imgPlayingArt
            artView.animates = true
        }
        
        resetSeekPosition(track)
    }
    
    private func clearNowPlayingInfo() {
        
        [lblTrackArtist, lblTrackTitle, lblTrackName].forEach({$0?.stringValue = ""})
        artView.image = UIConstants.imgPlayingArt
        artView.animates = false
        
        seekSlider.floatValue = 0
        lblTimeElapsed.isHidden = true
        lblTimeRemaining.isHidden = true
        setSeekTimerState(false)
        
        togglePlayingTrackButtons(false)
        popoverView.close()
    }
    
    // When the playing track changes (or there is none), certain functions may or may not be available, so their corresponding UI controls need to be shown/enabled or hidden/disabled.
    private func togglePlayingTrackButtons(_ show: Bool) {
        
        btnMoreInfo.isHidden = !show
        moreInfoMenuItem.isEnabled = show
        
        btnShowPlayingTrackInPlaylist.isHidden = !show
        showInPlaylistMenuItem.isEnabled = show
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
    
    private func updateSeekPosition() {
        
        if (playbackInfo.getPlaybackState() == .playing) {
            
            let seekPosn = playbackInfo.getSeekPosition()
            
            let trackTimes = StringUtils.formatTrackTimes(seekPosn.timeElapsed, seekPosn.trackDuration)
            
            lblTimeElapsed.stringValue = trackTimes.elapsed
            lblTimeRemaining.stringValue = trackTimes.remaining
            
            seekSlider.doubleValue = seekPosn.percentageElapsed
        }
    }
    
    private func resetSeekPosition(_ track: Track) {
        
        lblTimeElapsed.stringValue = UIConstants.zeroDurationString
        lblTimeRemaining.stringValue = StringUtils.formatSecondsToHMS(track.duration, true)
        
        lblTimeElapsed.isHidden = false
        lblTimeRemaining.isHidden = false
        
        seekSlider.floatValue = 0
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChange(_ newTrack: IndexedTrack?, _ errorState: Bool = false) {
        
        if (newTrack != nil) {
            
            showNowPlayingInfo(newTrack!.track)
            
            if (!errorState) {
                setSeekTimerState(true)
                togglePlayingTrackButtons(true)
                
                let sequence = playbackInfo.getPlaybackSequenceInfo()
                let scope = sequence.scope
                
                let trackIndex = sequence.trackIndex
                let totalTracks = sequence.totalTracks
                
                switch scope.type {
                    
                case .allTracks:
                    
                    lblPlaybackScope.stringValue = "All tracks"
                    imgScope.image = UIConstants.imgPlaylistOn
                    
                case .allArtists:
                    
                    lblPlaybackScope.stringValue = "All artists"
                    imgScope.image = UIConstants.imgPlaylistOn
                    
                case .allAlbums:
                    
                    lblPlaybackScope.stringValue = "All albums"
                    imgScope.image = UIConstants.imgPlaylistOn
                    
                case .allGenres:
                    
                    lblPlaybackScope.stringValue = "All genres"
                    imgScope.image = UIConstants.imgPlaylistOn
                    
                case .artist, .album, .genre:
                    
                    lblPlaybackScope.stringValue = scope.scope!.name
                    imgScope.image = UIConstants.imgGroup
                }
                
                lblSequenceProgress.stringValue = String(format: "%d / %d", trackIndex, totalTracks)
                
                let scopeString: NSString = lblPlaybackScope.stringValue as NSString
                let size: CGSize = scopeString.size(withAttributes: [NSFontAttributeName: lblPlaybackScope.font as AnyObject])

                let lblWidth = lblPlaybackScope.frame.width
                let textWidth = min(size.width, lblWidth)
                
                let margin = (lblWidth - textWidth) / 2   
                let newImgX = lblPlaybackScope.frame.origin.x + margin - imgScope.frame.width - 4
                imgScope.frame.origin.x = max(UIConstants.minImgScopeLocationX, newImgX)
    
                
                if (popoverView.isShown()) {
                    
                    playbackInfo.getPlayingTrack()?.track.loadDetailedInfo()
                    popoverView.refresh()
                }
                
            } else {
                
                // Error state
                setSeekTimerState(false)
            }
            
        } else {
            
            [lblPlaybackScope, lblSequenceProgress].forEach({$0?.stringValue = ""})
            imgScope.image = nil
            clearNowPlayingInfo()
        }
    }
    
    private func sequenceChanged(_ msg: SequenceChangedNotification) {
        lblSequenceProgress.stringValue = String(format: "%d / %d", msg.trackIndex, msg.totalTracks)
    }
    
    // When the playback rate changes (caused by the Time Stretch fx unit), the seek timer interval needs to be updated, to ensure that the seek position fields are updated fast/slow enough to match the new playback rate.
    private func playbackRateChanged(_ newRate: Float) {
        
        let interval = Int(1000 / (2 * newRate))
        
        if (interval != seekTimer?.getInterval()) {
            
            seekTimer?.stop()
            seekTimer = RepeatingTaskExecutor(intervalMillis: interval, task: {self.updateSeekPosition()}, queue: DispatchQueue.main)
            
            let playbackState = playbackInfo.getPlaybackState()
            setSeekTimerState(playbackState == .playing)
        }
    }
    
    // When the playback state changes, the seek timer can be disabled when not needed (e.g. when paused)
    private func playbackStateChanged(_ newState: PlaybackState) {
        
        setSeekTimerState(newState == .playing)
        
        // Pause/resume the art animation (if it is playing)
        switch (newState) {
            
        case .playing:
            
            artView.animates = true
        
        default:
            
            // The track is either paused or no longer playing
            artView.animates = false
        }
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if (notification is TrackChangedNotification) {
            let msg = notification as! TrackChangedNotification
            trackChange(msg.newTrack, msg.errorState)
            return
        }
        
        if (notification is SequenceChangedNotification) {
            let msg = notification as! SequenceChangedNotification
            sequenceChanged(msg)
            return
        }
        
        if (notification is PlaybackRateChangedNotification) {
            let msg = notification as! PlaybackRateChangedNotification
            playbackRateChanged(msg.newPlaybackRate)
            return
        }
        
        if (notification is PlaybackStateChangedNotification) {
            let msg = notification as! PlaybackStateChangedNotification
            playbackStateChanged(msg.newPlaybackState)
            return
        }
        
        if (notification is SeekPositionChangedNotification) {
            updateSeekPosition()
            return
        }
        
        if (notification is PlayingTrackInfoUpdatedNotification) {
            showNowPlayingInfo(playbackInfo.getPlayingTrack()!.track)
            return
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        return EmptyResponse.instance
    }
}
