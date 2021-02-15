/*
    View controller that handles the assembly of the player view tree from its multiple pieces, and switches between high-level views depending on current player state (i.e. playing / transcoding / stopped, etc).
 
    The player view tree consists of:
        
        - Playing track info (track info, art, etc)
            - Default view
            - Expanded Art view
 
        - Transcoder info (when a track is being transcoded)
 
        - Player controls (play/seek, next/previous track, repeat/shuffle, volume/balance)
 
        - Functions toolbar (detailed track info / favorite / bookmark, etc)
 */
import Cocoa

class PlayerViewController: NSViewController, NotificationSubscriber {
    
    private var playingTrackView: PlayingTrackView = ViewFactory.playingTrackView as! PlayingTrackView
    private var transcodingTrackView: NSView = ViewFactory.transcodingTrackView
    
    // Delegate that conveys all seek and playback info requests to the player
    private let player: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    override var nibName: String? {return "Player"}
    
    override func viewDidLoad() {
        
        [playingTrackView, transcodingTrackView].forEach({
            
            self.view.addSubview($0)
            $0.setFrameOrigin(NSPoint.zero)
        })

        switchView()
        Messenger.subscribeAsync(self, .player_trackTransitioned, self.switchView, queue: .main)
        Messenger.subscribeAsync(self, .transcoder_finished, self.transcodingFinished(_:), queue: .main)
    }
    
    // Depending on current player state, switch to one of the 3 views.
    func switchView() {
        
        switch player.state {

        case .noTrack, .playing, .paused:
            
            transcodingTrackView.hide()
            playingTrackView.showView()

        case .transcoding:
            
            playingTrackView.hideView()
            transcodingTrackView.show()
        }
    }
    
    func transcodingFinished(_ notif: TranscodingFinishedNotification) {
        
        // Check if transcoding failed.
        if !notif.success {
            
            // Hide the transcoding view.
            transcodingTrackView.hide()
            playingTrackView.showView()
        }
    }
}
