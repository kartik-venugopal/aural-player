/*
    View controller for the Now Playing info box which displays information about the currently playing track
 */

import Cocoa

class NowPlayingViewController: NSViewController, MessageSubscriber {
    
    // Now playing track info
    @IBOutlet weak var lblTrackArtist: NSTextField!
    @IBOutlet weak var lblTrackTitle: NSTextField!
    @IBOutlet weak var lblTrackName: NSTextField!
    @IBOutlet weak var lblSeekPosition: NSTextField!
    @IBOutlet weak var artView: NSImageView!
    
    @IBOutlet weak var seekSlider: NSSlider!
    @IBOutlet weak var btnMoreInfo: NSButton!
    
    @IBOutlet weak var moreInfoMenuItem: NSMenuItem!
    
    private let player: PlaybackDelegateProtocol = ObjectGraph.getPlaybackDelegate()
    
    private lazy var popoverView: PopoverViewDelegateProtocol = {
        return PopoverViewController.create(self.btnMoreInfo as NSView)
    }()
    
    // Timer that periodically updates the seek bar
    private var seekTimer: ScheduledTaskExecutor? = nil
    
    override func viewDidLoad() {
        
        let appState = ObjectGraph.getUIAppState()
        
        // Timer interval depends on whether time stretch unit is active
        seekTimer = ScheduledTaskExecutor(intervalMillis: appState.seekTimerInterval, task: {self.updateSeekPosition()}, queue: DispatchQueue.main)
        
        SyncMessenger.subscribe(.trackChangedNotification, subscriber: self)
        SyncMessenger.subscribe(.playbackRateChangedNotification, subscriber: self)
        SyncMessenger.subscribe(.playbackStateChangedNotification, subscriber: self)
        SyncMessenger.subscribe(.seekPositionChangedNotification, subscriber: self)
    }
    
    @IBAction func moreInfoAction(_ sender: AnyObject) {
        
        let playingTrack = player.getPlayingTrack()
        playingTrack!.track?.loadDetailedInfo()
        
        if (playingTrack == nil) {
            return
        }
        
        popoverView.toggle()
    }
    
    private func showNowPlayingInfo(_ track: Track) {
        
        var artistAndTitleAvailable: Bool = false
        
        if (track.longDisplayName != nil) {
            
            if (track.longDisplayName!.artist != nil) {
                
                artistAndTitleAvailable = true
                
                // Both title and artist
                lblTrackArtist.stringValue = "Artist:  " + track.longDisplayName!.artist!
                lblTrackTitle.stringValue = "Title:  " + track.longDisplayName!.title!
                
            } else {
                
                // Title only
                lblTrackName.stringValue = track.longDisplayName!.title!
            }
            
        } else {
            
            // Short display name
            lblTrackName.stringValue = track.shortDisplayName!
        }
        
        lblTrackName.isHidden = artistAndTitleAvailable
        lblTrackArtist.isHidden = !artistAndTitleAvailable
        lblTrackTitle.isHidden = !artistAndTitleAvailable
        
        if (track.metadata!.art != nil) {
            artView.image = track.metadata!.art!
        } else {
            artView.image = UIConstants.imgMusicArt
        }
    }
    
    private func clearNowPlayingInfo() {
        
        lblTrackArtist.stringValue = ""
        lblTrackTitle.stringValue = ""
        lblTrackName.stringValue = ""
        lblSeekPosition.stringValue = UIConstants.zeroDurationString
        seekSlider.floatValue = 0
        artView.image = UIConstants.imgMusicArt
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
        
        if (player.getPlaybackState() == .playing) {
            
            let seekPosn = player.getSeekPosition()
            
            lblSeekPosition.stringValue = Utils.formatDuration(seekPosn.seconds)
            seekSlider.doubleValue = seekPosn.percentage
        }
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChange(_ newTrack: IndexedTrack?, _ errorState: Bool = false) {
        
        if (newTrack != nil) {
            
            showNowPlayingInfo(newTrack!.track!)
            
            if (!errorState) {
                setSeekTimerState(true)
                toggleMoreInfoButtons(true)
                
                if (popoverView.isShown()) {
                    
                    player.getPlayingTrack()?.track?.loadDetailedInfo()
                    popoverView.refresh()
                }
                
            } else {
                
                // Error state
                
                setSeekTimerState(false)
                toggleMoreInfoButtons(false)
                popoverView.close()
            }
            
        } else {
            
            setSeekTimerState(false)
            clearNowPlayingInfo()
        }
        
        resetSeekPosition()
    }
    
    private func playbackRateChanged(_ newRate: Float) {
        
        let interval = Int(1000 / (2 * newRate))
        
        if (interval != seekTimer?.getInterval()) {
            
            seekTimer?.stop()
            seekTimer = ScheduledTaskExecutor(intervalMillis: interval, task: {self.updateSeekPosition()}, queue: DispatchQueue.main)
            
            let playbackState = player.getPlaybackState()
            setSeekTimerState(playbackState == .playing)
        }
    }
    
    private func playbackStateChanged(_ newState: PlaybackState) {
        setSeekTimerState(newState == .playing)
    }
    
    private func resetSeekPosition() {
        
        lblSeekPosition.stringValue = UIConstants.zeroDurationString
        seekSlider.floatValue = 0
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if (notification is TrackChangedNotification) {
            let msg = notification as! TrackChangedNotification
            trackChange(msg.newTrack, false)
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
        }
    }
    
    func processRequest(_ request: RequestMessage) -> ResponseMessage {
        return EmptyResponse.instance
    }
}
