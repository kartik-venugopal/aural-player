/*
    View controller for the player controls (volume, pan, play/pause, prev/next track, seeking, repeat/shuffle)
 */
import Cocoa

class PlayerViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber, AsyncMessageSubscriber, ConstituentView {
    
    @IBOutlet weak var defaultView: PlayerView!
    @IBOutlet weak var expandedArtView: PlayerView!
    @IBOutlet weak var playbackBox: NSBox!
    @IBOutlet weak var functionsBox: NSBox!
    @IBOutlet weak var gapView: NSView!
    
    private lazy var mouseTrackingView: MouseTrackingView = ViewFactory.getMainWindowMouseTrackingView()
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = ObjectGraph.getPlaybackDelegate()
    
    override var nibName: String? {return "Player"}
    
    private var theView: PlayerView {
        return PlayerViewState.viewType == .defaultView ? defaultView : expandedArtView
    }
    
    override func viewDidLoad() {
        
        self.view.addSubview(defaultView)
        self.view.addSubview(expandedArtView)
        
        // TODO: This value will come from appState
        PlayerViewState.viewType = .defaultView
        
        showView(PlayerViewState.viewType)
        
        AppModeManager.registerConstituentView(.regular, self)
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
        
        SyncMessenger.subscribe(actionTypes: [.changePlayerView, .showOrHideAlbumArt, .showOrHideMainControls, .showOrHidePlayingTrackInfo, .showOrHidePlayingTrackFunctions], subscriber: self)
    }
    
    private func removeSubscriptions() {
        
        AsyncMessenger.unsubscribe([.gapStarted], subscriber: self)
        
        SyncMessenger.unsubscribe(messageTypes: [.mouseEnteredView, .mouseExitedView], subscriber: self)
        
        SyncMessenger.unsubscribe(actionTypes: [.changePlayerView, .showOrHideAlbumArt, .showOrHideMainControls, .showOrHidePlayingTrackInfo, .showOrHidePlayingTrackFunctions], subscriber: self)
    }
    
    private func gapStarted(_ msg: PlaybackGapStartedAsyncMessage) {
        gapView.isHidden = false
    }
    
    private func changeView(_ message: PlayerViewActionMessage) {
        showView(message.viewType)
    }
    
    private func showView(_ viewType: PlayerViewType) {
        
        PlayerViewState.viewType = viewType
        
        switch viewType {
            
        case .defaultView:
            
            showDefaultView()
            
        case .expandedArt:
            
            showExpandedArtView()
        }
        
        PlayerViewState.showControls ? mouseTrackingView.stopTracking() : mouseTrackingView.startTracking()
    }
    
    private func showDefaultView() {
        
        PlayerViewState.viewType = .defaultView
        
        expandedArtView.isHidden = true
        expandedArtView.hideView()

        defaultView.showView()
        defaultView.isHidden = false
    }
    
    private func showExpandedArtView() {
        
        PlayerViewState.viewType = .expandedArt
        
        defaultView.isHidden = true
        defaultView.hideView()
        
        expandedArtView.showView()
        expandedArtView.isHidden = false
    }
    
    private func showOrHidePlayingTrackInfo() {
        theView.showOrHidePlayingTrackInfo()
    }
    
    private func showOrHidePlayingTrackFunctions() {
        theView.showOrHidePlayingTrackFunctions()
    }
    
    private func showOrHideAlbumArt() {
        theView.showOrHideAlbumArt()
    }
    
    private func showOrHideMainControls() {
        
        theView.showOrHideMainControls()
        PlayerViewState.showControls ? mouseTrackingView.stopTracking() : mouseTrackingView.startTracking()
    }
    
    func mouseEntered() {
        theView.mouseEntered()
    }
    
    func mouseExited() {
        theView.mouseExited()
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
            
            mouseEntered()
            
        case .mouseExitedView:
            
            mouseExited()
            
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
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .changePlayerView:
            
            changeView((message as! PlayerViewActionMessage))
            
        case .showOrHidePlayingTrackInfo:
            
            showOrHidePlayingTrackInfo()
            
        case .showOrHidePlayingTrackFunctions:
            
            showOrHidePlayingTrackFunctions()
            
        case .showOrHideAlbumArt:
            
            showOrHideAlbumArt()
            
        case .showOrHideMainControls:
            
            showOrHideMainControls()
            
        default: return
            
        }
    }
}

// Convenient accessor for information about the current playlist view
class PlayerViewState {
    
    static var viewType: PlayerViewType = .defaultView
    
    static var timeElapsedDisplayType: TimeElapsedDisplayType = .formatted
    static var timeRemainingDisplayType: TimeRemainingDisplayType = .formatted
    
    static var showControls: Bool = true
    
    // Default view
    static var showPlayingTrackInfo: Bool = true
    static var showPlayingTrackFunctions: Bool = true
    static var showAlbumArt: Bool = true
    
    static func persistentState() -> PlayerState {
        
//        let state = NowPlayingState()
        let state = PlayerState()
//        state.showAlbumArt = DefaultViewState.showAlbumArt
//        state.showPlayingTrackFunctions = DefaultViewState.showPlayingTrackFunctions
        state.timeElapsedDisplayType = timeElapsedDisplayType
        state.timeRemainingDisplayType = timeRemainingDisplayType
        
        return state
    }
}

enum PlayerViewType: String {
    
    case defaultView
    case expandedArt
}
