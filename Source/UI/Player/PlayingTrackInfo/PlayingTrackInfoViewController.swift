/*
    View controller for the Now Playing info box which displays information about the currently playing track
 */

import Cocoa

class PlayingTrackInfoViewController: NSViewController, ActionMessageSubscriber, MessageSubscriber, AsyncMessageSubscriber {
    
    @IBOutlet weak var infoView: PlayingTrackInfoView!
    
    @IBOutlet weak var controlsBox: NSBox!
    @IBOutlet weak var functionsBox: NSBox!
    
//    private var controlsView: PlayerControlsView = ViewFactory.controlsView as! PlayerControlsView
//    private var playingTrackFunctionsView: PlayingTrackFunctionsView = ViewFactory.playingTrackFunctionsView as! PlayingTrackFunctionsView
    
    // Delegate that conveys all seek and playback info requests to the player
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    override var nibName: String? {return "PlayingTrackInfo"}
    
    override func viewDidLoad() {
        
        controlsBox.contentView?.addSubview(ViewFactory.controlsView)
        functionsBox.contentView?.addSubview(ViewFactory.playingTrackFunctionsView)
        
        initSubscriptions()
        showView()
    }
    
    private func initSubscriptions() {
        
        // Subscribe to various notifications
        
        AsyncMessenger.subscribe([.trackNotPlayed], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(messageTypes: [.trackChangedNotification, .chapterChangedNotification, .playingTrackInfoUpdatedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.changePlayerView, .showOrHideAlbumArt, .showOrHideArtist, .showOrHideAlbum, .showOrHideCurrentChapter, .showOrHideMainControls, .showOrHidePlayingTrackInfo, .showOrHideSequenceInfo, .showOrHidePlayingTrackFunctions], subscriber: self)
    }
    
    private func showView() {
        
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChanged(_ newTrack: IndexedTrack?) {
        trackChanged(newTrack?.track)
    }
    
    private func trackChanged(_ track: Track?) {
        
        // TODO: Do a switch here ... on state
        infoView.trackInfo = PlayingTrackInfo(track, player.playingChapter?.chapter.title)
    }
    
    private func trackNotPlayed(_ message: TrackNotPlayedAsyncMessage) {
        self.trackChanged(nil as Track?)
    }
    
    // When track info for the playing track changes, display fields need to be updated
    private func playingTrackInfoUpdated(_ notification: PlayingTrackInfoUpdatedNotification) {
        
        // TODO: Do a switch here ... on state
        infoView.update()
    }
    
    private func chapterChanged(_ newChapter: IndexedChapter?) {
        
        if PlayerViewState.showCurrentChapter {
//            playerView.chapterChanged(newChapter?.chapter.title)
        }
    }
    
    // MARK: Message handling
    
    var subscriberId: String {
        return self.className
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if let pvActionMsg = message as? PlayerViewActionMessage {
            
            infoView.performAction(pvActionMsg)
            return
        }
    }
    
    // Consume synchronous notification messages
    func consumeNotification(_ notification: NotificationMessage) {
        
        if let trackChangedMsg = notification as? TrackChangedNotification {
            
            trackChanged(trackChangedMsg.newTrack)
            return
            
        } else if let trackInfoUpdatedMsg = notification as? PlayingTrackInfoUpdatedNotification {
         
            playingTrackInfoUpdated(trackInfoUpdatedMsg)
            return
            
        } else if let chapterChangedMsg = notification as? ChapterChangedNotification {
            
            chapterChanged(chapterChangedMsg.newChapter)
            return
        }
    }
    
    // Consume asynchronous messages
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if let trackNotPlayedMsg = message as? TrackNotPlayedAsyncMessage {
            
            trackNotPlayed(trackNotPlayedMsg)
        }
    }
}
