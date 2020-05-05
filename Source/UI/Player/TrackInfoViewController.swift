/*
    View controller for the Now Playing info box which displays information about the currently playing track
 */

import Cocoa

class TrackInfoViewController: NSViewController, MessageSubscriber, AsyncMessageSubscriber {
    
    @IBOutlet weak var defaultView: PlayerView!
    @IBOutlet weak var expandedArtView: PlayerView!
    
    private var theView: PlayerView {
        return PlayerViewState.viewType == .defaultView ? defaultView : expandedArtView
    }
    
    // Delegate that conveys all seek and playback info requests to the player
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    override func viewDidLoad() {
        
        initSubscriptions()
        theView.clearNowPlayingInfo()
    }
    
    private func initSubscriptions() {
        
        AsyncMessenger.subscribe([.trackNotPlayed, .gapStarted, .transcodingStarted], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        // Subscribe to various notifications
        SyncMessenger.subscribe(messageTypes: [.trackChangedNotification, .sequenceChangedNotification, .playingTrackInfoUpdatedNotification], subscriber: self)
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
    
    private func sequenceChanged() {
        theView.sequenceChanged(player.sequenceInfo)
    }
    
    private func gapStarted(_ msg: PlaybackGapStartedAsyncMessage) {
        theView.gapStarted(msg)
    }
    
    // MARK: Message handling
    
    var subscriberId: String {
        return self.className
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
