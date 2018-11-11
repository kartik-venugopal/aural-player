/*
    View controller for the Now Playing info box which displays information about the currently playing track
 */

import Cocoa

class TrackInfoViewController: NSViewController, MessageSubscriber, AsyncMessageSubscriber, ConstituentView {
    
    @IBOutlet weak var defaultView: PlayerView!
    @IBOutlet weak var expandedArtView: PlayerView!
    
    private var theView: PlayerView? {
        return PlayerViewState.viewType == .defaultView ? defaultView : expandedArtView
    }
    
    // Delegate that conveys all seek and playback info requests to the player
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    override func viewDidLoad() {
        
        // Use persistent app state to determine the initial state of the view
        AppModeManager.registerConstituentView(.regular, self)
    }
    
    func activate() {
        
        initSubscriptions()
        
        let newTrack = player.playingTrack
        
        if (newTrack != nil) {
            
            let sequence = player.sequenceInfo
            theView?.showNowPlayingInfo(newTrack!.track, player.state, sequence)
            
        } else {
            
            // No track playing, clear the info fields
            theView?.clearNowPlayingInfo()
        }
    }
    
    func deactivate() {
        removeSubscriptions()
    }
    
    private func initSubscriptions() {
        
        AsyncMessenger.subscribe([.gapStarted], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        // Subscribe to various notifications
        SyncMessenger.subscribe(messageTypes: [.trackChangedNotification, .sequenceChangedNotification, .playingTrackInfoUpdatedNotification], subscriber: self)
    }
    
    private func removeSubscriptions() {
        
        AsyncMessenger.unsubscribe([.gapStarted], subscriber: self)
        SyncMessenger.unsubscribe(messageTypes: [.trackChangedNotification, .sequenceChangedNotification, .playingTrackInfoUpdatedNotification], subscriber: self)
    }
    
    // The "errorState" arg indicates whether the player is in an error state (i.e. the new track cannot be played back). If so, update the UI accordingly.
    private func trackChanged(_ newTrack: IndexedTrack?) {
        
        if (newTrack != nil) {
            theView?.showNowPlayingInfo(newTrack!.track, player.state, player.sequenceInfo)
        } else {
            
            // No track playing, clear the info fields
            theView?.clearNowPlayingInfo()
        }
    }
    
    // When track info for the playing track changes, display fields need to be updated
    private func playingTrackInfoUpdated(_ notification: PlayingTrackInfoUpdatedNotification) {
        theView?.showNowPlayingInfo(player.playingTrack!.track, player.state, player.sequenceInfo)
    }
    
    private func sequenceChanged() {
        theView?.sequenceChanged(player.sequenceInfo)
    }
    
    private func gapStarted(_ msg: PlaybackGapStartedAsyncMessage) {
        theView?.gapStarted(msg)
    }
    
    // MARK: Message handling
    
    func getID() -> String {
        return self.className
    }
    
    // Consume synchronous notification messages
    func consumeNotification(_ notification: NotificationMessage) {
        
        switch notification.messageType {
            
        case .trackChangedNotification:
            
            trackChanged((notification as! TrackChangedNotification).newTrack)
            
        case .playingTrackInfoUpdatedNotification:
            
            playingTrackInfoUpdated(notification as! PlayingTrackInfoUpdatedNotification)
            
        case .sequenceChangedNotification:
            
            sequenceChanged()
            
        default: return
            
        }
    }
    
    // Consume asynchronous messages
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .gapStarted:
            
            gapStarted(message as! PlaybackGapStartedAsyncMessage)
            
        default: return
            
        }
    }
}
