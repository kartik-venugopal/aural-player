/*
    View controller that handles the assembly of the player view tree from its multiple pieces, and handles general concerns for the view such as text size and color scheme changes.
 
    The player view tree consists of:
        
        - Playing track info (track info, art, etc)
            - Default view
            - Expanded Art view
 
        - Waiting track info (when a track is waiting to play after a delay)
 
        - Transcoder info (when a track is being transcoded)
 
        - Player controls (play/seek, next/previous track, repeat/shuffle, volume/balance)
 */
import Cocoa

class PlayerViewController: NSViewController, MessageSubscriber, AsyncMessageSubscriber {
    
    private var playingTrackView: PlayingTrackView = ViewFactory.playingTrackView as! PlayingTrackView
    private var waitingTrackView: NSView = ViewFactory.waitingTrackView
    private var transcodingTrackView: NSView = ViewFactory.transcodingTrackView
    
    // Delegate that conveys all seek and playback info requests to the player
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    override var nibName: String? {return "Player"}
    
    override func viewDidLoad() {
        
        [playingTrackView, waitingTrackView, transcodingTrackView].forEach({
            
            self.view.addSubview($0)
            $0.setFrameOrigin(NSPoint.zero)
        })
        
        initSubscriptions()
        switchView()
    }
    
    private func initSubscriptions() {
        
        AsyncMessenger.subscribe([.gapStarted, .transcodingStarted], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(messageTypes: [.trackChangedNotification], subscriber: self)
    }
    
    private func switchView() {
        
        switch player.state {

        case .noTrack, .playing, .paused:
            
            NSView.hideViews(waitingTrackView, transcodingTrackView)
            playingTrackView.showView()

        case .waiting:
            
            playingTrackView.hideView()
            transcodingTrackView.hide()
            
            waitingTrackView.show()

        case .transcoding:
            
            playingTrackView.hideView()
            waitingTrackView.hide()
            
            transcodingTrackView.show()
        }
    }
    
    // MARK: Message handling
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        if notification is TrackChangedNotification {
            
            switchView()
            return
        }
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if message is PlaybackGapStartedAsyncMessage || message is TranscodingStartedAsyncMessage {
            
            switchView()
            return
        }
    }
}
