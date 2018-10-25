/*
 View controller for the player controls (volume, pan, play/pause, prev/next track, seeking, repeat/shuffle)
 */
import Cocoa

class PlayerViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber, AsyncMessageSubscriber, ConstituentView {
    
    @IBOutlet weak var artView: NSImageView!
    @IBOutlet weak var playbackBox: NSBox!
    @IBOutlet weak var playbackInfoBox: NSBox!
    @IBOutlet weak var functionsBox: NSBox!
    @IBOutlet weak var overlayBox: NSBox!
    @IBOutlet weak var gapView: NSView!
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = ObjectGraph.getPlaybackDelegate()
    
    override var nibName: String? {return "Player"}
    
    override func viewDidLoad() {
        AppModeManager.registerConstituentView(.regular, self)
    }
    
    override func viewDidAppear() {
        overlayBox.isHidden = !PlayerViewState.overlay
    }
    
    func activate() {
        initSubscriptions()
    }
    
    func deactivate() {
        removeSubscriptions()
    }
    
    private func initSubscriptions() {
        
        // Subscribe to message notifications
        AsyncMessenger.subscribe([.gapStarted], subscriber: self, dispatchQueue: DispatchQueue.main)
        
        SyncMessenger.subscribe(messageTypes: [.mouseEnteredView, .mouseExitedView], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.showOrHideSeekBar, .setTimeElapsedDisplayFormat, .setTimeRemainingDisplayFormat], subscriber: self)
    }
    
    private func removeSubscriptions() {
        
        AsyncMessenger.unsubscribe([.gapStarted], subscriber: self)
        
        SyncMessenger.unsubscribe(messageTypes: [.mouseEnteredView, .mouseExitedView], subscriber: self)
        
        SyncMessenger.unsubscribe(actionTypes: [.showOrHideSeekBar], subscriber: self)
    }
    
    private func gapStarted(_ msg: PlaybackGapStartedAsyncMessage) {
        gapView.isHidden = false
    }
    
    private func showOrHidePlayingTrackInfo() {
        
        NowPlayingViewState.DefaultViewState.showPlayingTrackInfo = !NowPlayingViewState.DefaultViewState.showPlayingTrackInfo
        
        if NowPlayingViewState.DefaultViewState.showPlayingTrackInfo {
            
            playbackInfoBox.isHidden = false
            artView.isHidden = !NowPlayingViewState.DefaultViewState.showAlbumArt
            
        } else {
            
            playbackInfoBox.isHidden = true
            NowPlayingViewState.DefaultViewState.showAlbumArt = true
        }
    }
    
    private func showOrHidePlayingTrackFunctions() {
        
        NowPlayingViewState.DefaultViewState.showPlayingTrackFunctions = !NowPlayingViewState.DefaultViewState.showPlayingTrackFunctions
        functionsBox.isHidden = !NowPlayingViewState.DefaultViewState.showPlayingTrackFunctions
    }
    
    private func showOrHideAlbumArt() {
        
        NowPlayingViewState.DefaultViewState.showAlbumArt = !NowPlayingViewState.DefaultViewState.showAlbumArt
        
        if NowPlayingViewState.DefaultViewState.showAlbumArt {
            artView.isHidden = false
        } else {
            
            NowPlayingViewState.DefaultViewState.showPlayingTrackInfo = true
            playbackInfoBox.isHidden = false
            artView.isHidden = true
        }
    }
    
    private func showPlayerControls() {
        
        overlayBox.isHidden = false
        playbackBox.isHidden = false
        
        var superView = playbackBox.superview
        playbackBox.removeFromSuperview()
        superView?.addSubview(playbackBox, positioned: .above, relativeTo: nil)
        
        playbackInfoBox.isTransparent = true
        
        superView = playbackInfoBox.superview
        playbackInfoBox.removeFromSuperview()
        superView?.addSubview(playbackInfoBox, positioned: .above, relativeTo: nil)
        
        superView = functionsBox.superview
        functionsBox.removeFromSuperview()
        superView?.addSubview(functionsBox, positioned: .above, relativeTo: nil)
        
        playbackInfoBox.frame.origin.y = playbackBox.frame.maxY
        
        functionsBox.frame.origin.y = playbackInfoBox.frame.origin.y
    }
    
    private func hidePlayerControls() {
        
        overlayBox.isHidden = true
        playbackBox.isHidden = true
        playbackInfoBox.isTransparent = false
        
        playbackInfoBox.frame.origin.y = (self.view.frame.height / 2) - (playbackInfoBox.frame.height / 2)
        functionsBox.frame.origin.y = playbackInfoBox.frame.origin.y
    }
    
    func getLocationForBookmarkPrompt() -> (view: NSView, edge: NSRectEdge) {
        
        // TODO
        
        // Slider knob position
//        let knobRect = seekSliderCell.knobRect(flipped: false)
//        seekPositionMarker.setFrameOrigin(NSPoint(x: seekSlider.frame.origin.x + knobRect.minX + 2, y: seekSlider.frame.origin.y + knobRect.minY))
        
        return (functionsBox, NSRectEdge.maxY)
    }
    
    // MARK: Message handling
    
    func getID() -> String {
        return self.className
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
        switch notification.messageType {
            
        case .mouseEnteredView:
            
            showPlayerControls()
            
        case .mouseExitedView:
            
            hidePlayerControls()
            
        default: return
            
        }
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        switch message.messageType {
            
        case .gapStarted:
            
            gapStarted(message as! PlaybackGapStartedAsyncMessage)
            
        default: return
            
        }
    }
    
//    func consumeMessage(_ message: ActionMessage) {
//
//        switch message.actionType {
//
//        case .showOrHidePlayingTrackInfo:
//
//            showOrHidePlayingTrackInfo()
//
//        case .showOrHidePlayingTrackFunctions:
//
//            showOrHidePlayingTrackFunctions()
//
//        case .showOrHideAlbumArt:
//
//            showOrHideAlbumArt()
//
//        default: return
//
//        }
//    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
            
            
            // Player functions
      
//        case .showOrHideSeekBar:
//
//            showOrHideSeekBar()
//
//        case .showOrHideMainControls:
//
//            showOrHideMainControls()
//
//        case .setTimeElapsedDisplayFormat:
//
//            setTimeElapsedDisplayFormat((message as! SetTimeElapsedDisplayFormatActionMessage).format)
//
//        case .setTimeRemainingDisplayFormat:
//
//            setTimeRemainingDisplayFormat((message as! SetTimeRemainingDisplayFormatActionMessage).format)
            
        default: return
            
        }
    }
}
