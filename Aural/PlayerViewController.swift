/*
    View controller for the player controls (volume, pan, play/pause, prev/next track, seeking, repeat/shuffle)
 */
import Cocoa

class PlayerViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber, ConstituentView {
    
    @IBOutlet weak var defaultView: PlayerView!
    @IBOutlet weak var expandedArtView: PlayerView!
    
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
        
        defaultView.setFrameOrigin(NSPoint.zero)
        expandedArtView.setFrameOrigin(NSPoint.zero)
        
        PlayerViewState.initialize(ObjectGraph.getAppState().uiState.playerState)
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
        SyncMessenger.subscribe(messageTypes: [.mouseEnteredView, .mouseExitedView], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.changePlayerView, .showOrHideAlbumArt, .showOrHideMainControls, .showOrHidePlayingTrackInfo, .showOrHideSequenceInfo, .showOrHidePlayingTrackFunctions], subscriber: self)
    }
    
    private func removeSubscriptions() {
        
        SyncMessenger.unsubscribe(messageTypes: [.mouseEnteredView, .mouseExitedView], subscriber: self)
        
        SyncMessenger.unsubscribe(actionTypes: [.changePlayerView, .showOrHideAlbumArt, .showOrHideMainControls, .showOrHidePlayingTrackInfo, .showOrHideSequenceInfo, .showOrHidePlayingTrackFunctions], subscriber: self)
    }
    
    private func changeView(_ message: PlayerViewActionMessage) {
        
        // If this view is already the current view, do nothing
        if PlayerViewState.viewType == message.viewType {return}
        
        showView(message.viewType)
    }
    
    private func showView(_ viewType: PlayerViewType) {
        
        PlayerViewState.viewType = viewType
        
        theView.needsMouseTracking() ? mouseTrackingView.startTracking() : mouseTrackingView.stopTracking()
        
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
        
        expandedArtView.hide()
        expandedArtView.hideView()

        defaultView.showView(player.getPlaybackState())
        defaultView.show()
    }
    
    private func showExpandedArtView() {
        
        PlayerViewState.viewType = .expandedArt
        
        defaultView.hide()
        defaultView.hideView()
        
        expandedArtView.showView(player.getPlaybackState())
        expandedArtView.show()
    }
    
    private func showOrHidePlayingTrackInfo() {
        
        theView.showOrHidePlayingTrackInfo()
        theView.needsMouseTracking() ? mouseTrackingView.startTracking() : mouseTrackingView.stopTracking()
    }
    
    private func showOrHideSequenceInfo() {
        theView.showOrHideSequenceInfo()
    }
    
    private func showOrHidePlayingTrackFunctions() {
        
        theView.showOrHidePlayingTrackFunctions()
        theView.needsMouseTracking() ? mouseTrackingView.startTracking() : mouseTrackingView.stopTracking()
    }
    
    private func showOrHideAlbumArt() {
        
        theView.showOrHideAlbumArt()
        theView.needsMouseTracking() ? mouseTrackingView.startTracking() : mouseTrackingView.stopTracking()
    }
    
    private func showOrHideMainControls() {
        
        theView.showOrHideMainControls()
        theView.needsMouseTracking() ? mouseTrackingView.startTracking() : mouseTrackingView.stopTracking()
    }
    
    func mouseEntered() {
        theView.mouseEntered()
    }
    
    func mouseExited() {
        theView.mouseExited()
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
            
        case .showOrHideSequenceInfo:
            
            showOrHideSequenceInfo()
            
        default: return
            
        }
    }
}

// Convenient accessor for information about the current playlist view
class PlayerViewState {
    
    static var viewType: PlayerViewType = .defaultView
    
    static var showAlbumArt: Bool = true
    static var showTrackInfo: Bool = true
    static var showSequenceInfo: Bool = true
    static var showPlayingTrackFunctions: Bool = true
    static var showControls: Bool = true
    static var showTimeElapsedRemaining: Bool = true
    
    static var timeElapsedDisplayType: TimeElapsedDisplayType = .formatted
    static var timeRemainingDisplayType: TimeRemainingDisplayType = .formatted
    
    static func initialize(_ appState: PlayerState) {
        
        viewType = appState.viewType
        
        showAlbumArt = appState.showAlbumArt
        showTrackInfo = appState.showTrackInfo
        showSequenceInfo = appState.showSequenceInfo
        showPlayingTrackFunctions = appState.showPlayingTrackFunctions
        showControls = appState.showControls
        showTimeElapsedRemaining = appState.showTimeElapsedRemaining
        
        timeElapsedDisplayType = appState.timeElapsedDisplayType
        timeRemainingDisplayType = appState.timeRemainingDisplayType
    }
    
    static func persistentState() -> PlayerState {
        
        let state = PlayerState()
        
        state.viewType = viewType
        
        state.showAlbumArt = showAlbumArt
        state.showTrackInfo = showTrackInfo
        state.showSequenceInfo = showSequenceInfo
        state.showPlayingTrackFunctions = showPlayingTrackFunctions
        state.showControls = showControls
        state.showTimeElapsedRemaining = showTimeElapsedRemaining
        
        state.timeElapsedDisplayType = timeElapsedDisplayType
        state.timeRemainingDisplayType = timeRemainingDisplayType
        
        return state
    }
}

enum PlayerViewType: String {
    
    case defaultView
    case expandedArt
}
