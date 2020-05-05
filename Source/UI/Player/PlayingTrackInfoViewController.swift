/*
    View controller for the Now Playing info box which displays information about the currently playing track
 */

import Cocoa

class PlayingTrackInfoViewController: NSViewController, ActionMessageSubscriber, MessageSubscriber, AsyncMessageSubscriber {
    
    @IBOutlet weak var defaultView: PlayerView!
    @IBOutlet weak var expandedArtView: PlayerView!
    
    private var theView: PlayerView {
        return PlayerViewState.viewType == .defaultView ? defaultView : expandedArtView
    }
    
    @IBOutlet weak var controlsView: PlayerControlsView!
    
    @IBOutlet weak var transcoderView: TranscoderView!
    
    private lazy var mouseTrackingView: MouseTrackingView = ViewFactory.mainWindowMouseTrackingView
    
    // Delegate that conveys all seek and playback info requests to the player
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    override func viewDidLoad() {
        
        initSubscriptions()
        theView.clearNowPlayingInfo()
        
        showView(PlayerViewState.viewType)
    }
    
    private func initSubscriptions() {
        
        // Subscribe to various notifications
        
        AsyncMessenger.subscribe([.trackNotPlayed, .gapStarted, .transcodingStarted], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(messageTypes: [.mouseEnteredView, .mouseExitedView, .trackChangedNotification, .chapterChangedNotification, .sequenceChangedNotification, .playingTrackInfoUpdatedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.changePlayerView, .showOrHideAlbumArt, .showOrHideArtist, .showOrHideAlbum, .showOrHideCurrentChapter, .showOrHideMainControls, .showOrHidePlayingTrackInfo, .showOrHideSequenceInfo, .showOrHidePlayingTrackFunctions, .showOrHideTimeElapsedRemaining, .setTimeElapsedDisplayFormat, .setTimeRemainingDisplayFormat], subscriber: self)
    }
    
    private func changeView(_ viewType: PlayerViewType) {
        
        // If this view is already the current view, do nothing
        if PlayerViewState.viewType != viewType {
            showView(viewType)
        }
    }
    
    private func showView(_ viewType: PlayerViewType) {
        
        PlayerViewState.viewType = viewType
        
        theView.needsMouseTracking ? mouseTrackingView.startTracking() : mouseTrackingView.stopTracking()
        
        transcoderView.hide()
        
        switch viewType {
            
        case .defaultView:
            
            expandedArtView.handOff(defaultView)
            showDefaultView()
            
        case .expandedArt:
            
            defaultView.handOff(expandedArtView)
            showExpandedArtView()
        }
    }
    
    private func showDefaultView() {
        
        PlayerViewState.viewType = .defaultView
        
        expandedArtView.hideView()
        defaultView.showView(player.state)
    }
    
    private func showExpandedArtView() {
        
        PlayerViewState.viewType = .expandedArt
        
        defaultView.hideView()
        expandedArtView.showView(player.state)
    }
    
    private func showOrHidePlayingTrackInfo() {
        
        PlayerViewState.showTrackInfo = !PlayerViewState.showTrackInfo
        
        theView.showOrHidePlayingTrackInfo()
        theView.needsMouseTracking ? mouseTrackingView.startTracking() : mouseTrackingView.stopTracking()
    }
    
    private func showOrHideSequenceInfo() {
        
        PlayerViewState.showSequenceInfo = !PlayerViewState.showSequenceInfo
        theView.showOrHideSequenceInfo()
    }
    
    private func showOrHidePlayingTrackFunctions() {
        
        PlayerViewState.showPlayingTrackFunctions = !PlayerViewState.showPlayingTrackFunctions
        
        theView.showOrHidePlayingTrackFunctions()
        theView.needsMouseTracking ? mouseTrackingView.startTracking() : mouseTrackingView.stopTracking()
    }
    
    private func showOrHideAlbumArt() {
        
        PlayerViewState.showAlbumArt = !PlayerViewState.showAlbumArt
        
        theView.showOrHideAlbumArt()
        theView.needsMouseTracking ? mouseTrackingView.startTracking() : mouseTrackingView.stopTracking()
    }
    
    private func showOrHideArtist() {
        
        PlayerViewState.showArtist = !PlayerViewState.showArtist
        
        theView.showOrHideArtist()
        theView.needsMouseTracking ? mouseTrackingView.startTracking() : mouseTrackingView.stopTracking()
    }
    
    private func showOrHideAlbum() {
        
        PlayerViewState.showAlbum = !PlayerViewState.showAlbum
        
        theView.showOrHideAlbum()
        theView.needsMouseTracking ? mouseTrackingView.startTracking() : mouseTrackingView.stopTracking()
    }
    
    private func showOrHideCurrentChapter() {
        
        PlayerViewState.showCurrentChapter = !PlayerViewState.showCurrentChapter
        
        theView.showOrHideCurrentChapter()
        theView.needsMouseTracking ? mouseTrackingView.startTracking() : mouseTrackingView.stopTracking()
    }
    
    private func showOrHideMainControls() {
        
        PlayerViewState.showControls = !PlayerViewState.showControls
        
        theView.showOrHideMainControls()
        theView.needsMouseTracking ? mouseTrackingView.startTracking() : mouseTrackingView.stopTracking()
    }
    
    private func setTimeElapsedDisplayFormat(_ format: TimeElapsedDisplayType) {
        
        PlayerViewState.timeElapsedDisplayType = format
        controlsView.setTimeElapsedDisplayFormat(format)
    }
    
    private func setTimeRemainingDisplayFormat(_ format: TimeRemainingDisplayType) {
        
        PlayerViewState.timeRemainingDisplayType = format
        controlsView.setTimeRemainingDisplayFormat(format)
    }
    
    private func showOrHideTimeElapsedRemaining() {
        
        PlayerViewState.showTimeElapsedRemaining = !PlayerViewState.showTimeElapsedRemaining
        controlsView.showOrHideTimeElapsedRemaining()
    }
    
    private func sequenceChanged() {
        
        PlayerViewState.showSequenceInfo = !PlayerViewState.showSequenceInfo
        
        theView.sequenceChanged(player.sequenceInfo)
        controlsView.sequenceChanged()
    }
    
    func mouseEntered() {
        theView.mouseEntered()
    }
    
    func mouseExited() {
        theView.mouseExited()
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChanged(_ newTrack: IndexedTrack?) {
        trackChanged(newTrack?.track)
    }
    
    private func trackChanged(_ track: Track?) {
        
        if let newTrack = player.playingTrack?.track, player.state != .transcoding {
            
            theView.showNowPlayingInfo(newTrack, player.state, player.sequenceInfo, player.playingChapter?.chapter.title)
            
        } else {
            
            // No track playing, clear the info fields
            theView.clearNowPlayingInfo()
        }
    }
    
    private func transcodingStarted(_ track: Track) {
        
        if let track = player.playingTrack?.track {
            theView.setPlayingInfo_dontShow(track, player.sequenceInfo)
        }
    }
    
    private func transcodingFinished() {
        
        if let newTrack = player.playingTrack?.track {
            theView.showNowPlayingInfo(newTrack, player.state, player.sequenceInfo, player.playingChapter?.chapter.title)
        }
    }
    
    private func trackNotPlayed(_ message: TrackNotPlayedAsyncMessage) {
        self.trackChanged(nil as Track?)
    }
    
    // When track info for the playing track changes, display fields need to be updated
    private func playingTrackInfoUpdated(_ notification: PlayingTrackInfoUpdatedNotification) {
        
        if let newTrack = player.playingTrack?.track {
            
            theView.showNowPlayingInfo(newTrack, player.state, player.sequenceInfo, player.playingChapter?.chapter.title)
            
        } else if let newTrack = player.waitingTrack?.track {   // If in a playback gap
            
            theView.artUpdated(newTrack)
        }
    }
    
    private func gapStarted(_ msg: PlaybackGapStartedAsyncMessage) {
        theView.gapStarted(msg.nextTrack.track, msg.gapEndTime)
    }
    
    private func chapterChanged(_ newChapter: IndexedChapter?) {
        
        if PlayerViewState.showCurrentChapter {
            theView.chapterChanged(newChapter?.chapter.title)
        }
    }
    
    // MARK: Message handling
    
    var subscriberId: String {
        return self.className
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .changePlayerView:
            
            if let viewType = (message as? PlayerViewActionMessage)?.viewType {
                changeView(viewType)
            }
            
        case .showOrHidePlayingTrackInfo:
            
            showOrHidePlayingTrackInfo()
            
        case .showOrHidePlayingTrackFunctions:
            
            showOrHidePlayingTrackFunctions()
            
        case .showOrHideAlbumArt:
            
            showOrHideAlbumArt()
            
        case .showOrHideArtist:
            
            showOrHideArtist()
            
        case .showOrHideAlbum:
            
            showOrHideAlbum()
            
        case .showOrHideCurrentChapter:
            
            showOrHideCurrentChapter()
            
        case .showOrHideMainControls:
            
            showOrHideMainControls()
            
        case .showOrHideSequenceInfo:
            
            showOrHideSequenceInfo()
            
        case .setTimeElapsedDisplayFormat:
            
            if let format = (message as? SetTimeElapsedDisplayFormatActionMessage)?.format {
                setTimeElapsedDisplayFormat(format)
            }
            
        case .setTimeRemainingDisplayFormat:
            
            if let format = (message as? SetTimeRemainingDisplayFormatActionMessage)?.format {
                setTimeRemainingDisplayFormat(format)
            }
            
        case .showOrHideTimeElapsedRemaining:
            
            showOrHideTimeElapsedRemaining()
                
        default: return
            
        }
    }
    
    // Consume synchronous notification messages
    func consumeNotification(_ notification: NotificationMessage) {
        
        if let trackChangedMsg = notification as? TrackChangedNotification {
            
            trackChanged(trackChangedMsg.newTrack)
            
        } else if let trackInfoUpdatedMsg = notification as? PlayingTrackInfoUpdatedNotification {
         
            playingTrackInfoUpdated(trackInfoUpdatedMsg)
            
        } else if notification is SequenceChangedNotification {
            
            sequenceChanged()
        }
        
        switch notification.messageType {
            
        case .mouseEnteredView:
            
            mouseEntered()
            
        case .mouseExitedView:
            
            mouseExited()
            
        case .chapterChangedNotification:
            
            if let chapterChangedMsg = notification as? ChapterChangedNotification {
                chapterChanged(chapterChangedMsg.newChapter)
            }
            
        default: return
            
        }
    }
    
    // Consume asynchronous messages
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if let gapStartedMsg = message as? PlaybackGapStartedAsyncMessage {
         
            gapStarted(gapStartedMsg)
            
        } else if let track = (message as? TranscodingStartedAsyncMessage)?.track {
         
            transcodingStarted(track)
            
        } else if message is TranscodingFinishedAsyncMessage {
            
            transcodingFinished()
            
        } else if let trackNotPlayedMsg = message as? TrackNotPlayedAsyncMessage {
            
            trackNotPlayed(trackNotPlayedMsg)
        }
    }
}
