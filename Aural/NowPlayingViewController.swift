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
    
    @IBOutlet weak var lblSeekPosition: NSTextField!
    @IBOutlet weak var seekSlider: NSSlider!
    
    // Button and menu item to display more details about the playing track
    @IBOutlet weak var btnMoreInfo: NSButton!
    @IBOutlet weak var moreInfoMenuItem: NSMenuItem!
    
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
        
        // Subscribe to various notifications
        SyncMessenger.subscribe(.trackChangedNotification, subscriber: self)
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
            lblTrackArtist.stringValue = "Artist:  " + track.displayInfo.artist!
            lblTrackTitle.stringValue = "Title:  " + track.displayInfo.title!
            
        } else {
            
            lblTrackName.stringValue = track.conciseDisplayName
        }
        
        lblTrackName.isHidden = artistAndTitleAvailable
        lblTrackArtist.isHidden = !artistAndTitleAvailable
        lblTrackTitle.isHidden = !artistAndTitleAvailable
        
        if (track.displayInfo.art != nil) {
            artView.image = track.displayInfo.art!
        } else {
            // Default (placeholder) artwork
            artView.image = UIConstants.imgMusicArt
        }
    }
    
    private func clearNowPlayingInfo() {
        
        [lblTrackArtist, lblTrackTitle, lblTrackName].forEach({$0?.stringValue = ""})
        artView.image = UIConstants.imgMusicArt
        
        resetSeekPosition()
        setSeekTimerState(false)
        
        toggleMoreInfoButtons(false)
        popoverView.close()
    }
    
    private func toggleMoreInfoButtons(_ show: Bool) {
        btnMoreInfo.isHidden = !show
        moreInfoMenuItem.isEnabled = show
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
            
            lblSeekPosition.stringValue = Utils.formatDuration(seekPosn.seconds)
            seekSlider.doubleValue = seekPosn.percentage
        }
    }
    
    private func resetSeekPosition() {
        
        lblSeekPosition.stringValue = UIConstants.zeroDurationString
        seekSlider.floatValue = 0
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChange(_ newTrack: IndexedTrack?, _ errorState: Bool = false) {
        
        if (newTrack != nil) {
            
            showNowPlayingInfo(newTrack!.track)
            
            if (!errorState) {
                setSeekTimerState(true)
                toggleMoreInfoButtons(true)
                
                if (popoverView.isShown()) {
                    
                    playbackInfo.getPlayingTrack()?.track.loadDetailedInfo()
                    popoverView.refresh()
                }
                
            } else {
                
                // Error state
                
                setSeekTimerState(false)
            }
            
            resetSeekPosition()
            
        } else {
            
            clearNowPlayingInfo()
        }
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
    
    private func playbackStateChanged(_ newState: PlaybackState) {
        setSeekTimerState(newState == .playing)
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if (notification is TrackChangedNotification) {
            let msg = notification as! TrackChangedNotification
            trackChange(msg.newTrack, msg.errorState)
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
