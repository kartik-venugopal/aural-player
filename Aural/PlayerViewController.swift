/*
    View controller for the player controls (volume, pan, play/pause, prev/next track, seeking, repeat/shuffle)
 */
import Cocoa

// TODO: Merge this with TrackInfoViewController
class PlayerViewController: NSViewController, MessageSubscriber, ActionMessageSubscriber {
    
    @IBOutlet weak var playerView: NSView!
    
    @IBOutlet weak var defaultView: PlayerView!
    @IBOutlet weak var expandedArtView: PlayerView!
    @IBOutlet weak var transcoderView: TranscoderView!
    
    private lazy var mouseTrackingView: MouseTrackingView = ViewFactory.mainWindowMouseTrackingView
    
    // Delegate that conveys all playback requests to the player / playback sequencer
    private let player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    override var nibName: String? {return "Player"}
    
    private var theView: PlayerView {
        return PlayerViewState.viewType == .defaultView ? defaultView : expandedArtView
    }
    
    override func viewDidLoad() {
        
        playerView.addSubview(defaultView)
        playerView.addSubview(expandedArtView)
        
        self.view.addSubview(playerView)
        self.view.addSubview(transcoderView)
        
        defaultView.setFrameOrigin(NSPoint.zero)
        expandedArtView.setFrameOrigin(NSPoint.zero)
        transcoderView.setFrameOrigin(NSPoint.zero)
        
        changeTextSize()
        
        showView(PlayerViewState.viewType)
        initSubscriptions()
    }
    
    private func initSubscriptions() {
        
        // Subscribe to message notifications
        SyncMessenger.subscribe(messageTypes: [.mouseEnteredView, .mouseExitedView, .chapterChangedNotification], subscriber: self)
        
        SyncMessenger.subscribe(actionTypes: [.changePlayerView, .showOrHideAlbumArt, .showOrHideArtist, .showOrHideAlbum, .showOrHideCurrentChapter, .showOrHideMainControls, .showOrHidePlayingTrackInfo, .showOrHideSequenceInfo, .showOrHidePlayingTrackFunctions, .changePlayerTextSize, .changeBackgroundColor, .changeTrackInfoPrimaryTextColor, .changeTrackInfoSecondaryTextColor, .changeTrackInfoTertiaryTextColor], subscriber: self)
    }
    
    private func changeView(_ message: PlayerViewActionMessage) {
        
        // If this view is already the current view, do nothing
        if PlayerViewState.viewType == message.viewType {return}
        
        showView(message.viewType)
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
        
        expandedArtView.hide()
        expandedArtView.hideView()

        defaultView.showView(player.state)
        defaultView.show()
    }
    
    private func showExpandedArtView() {
        
        PlayerViewState.viewType = .expandedArt
        
        defaultView.hide()
        defaultView.hideView()
        
        expandedArtView.showView(player.state)
        expandedArtView.show()
    }
    
    private func showOrHidePlayingTrackInfo() {
        
        theView.showOrHidePlayingTrackInfo()
        theView.needsMouseTracking ? mouseTrackingView.startTracking() : mouseTrackingView.stopTracking()
    }
    
    private func showOrHideSequenceInfo() {
        theView.showOrHideSequenceInfo()
    }
    
    private func showOrHidePlayingTrackFunctions() {
        
        theView.showOrHidePlayingTrackFunctions()
        theView.needsMouseTracking ? mouseTrackingView.startTracking() : mouseTrackingView.stopTracking()
    }
    
    private func showOrHideAlbumArt() {
        
        theView.showOrHideAlbumArt()
        theView.needsMouseTracking ? mouseTrackingView.startTracking() : mouseTrackingView.stopTracking()
    }
    
    private func showOrHideArtist() {
        
        theView.showOrHideArtist()
        theView.needsMouseTracking ? mouseTrackingView.startTracking() : mouseTrackingView.stopTracking()
    }
    
    private func showOrHideAlbum() {
        
        theView.showOrHideAlbum()
        theView.needsMouseTracking ? mouseTrackingView.startTracking() : mouseTrackingView.stopTracking()
    }
    
    private func showOrHideCurrentChapter() {
        
        theView.showOrHideCurrentChapter()
        theView.needsMouseTracking ? mouseTrackingView.startTracking() : mouseTrackingView.stopTracking()
    }
    
    private func showOrHideMainControls() {
        
        theView.showOrHideMainControls()
        theView.needsMouseTracking ? mouseTrackingView.startTracking() : mouseTrackingView.stopTracking()
    }
    
    func mouseEntered() {
        theView.mouseEntered()
    }
    
    func mouseExited() {
        theView.mouseExited()
    }
    
    func changeTextSize() {
        
        defaultView.changeTextSize()
        expandedArtView.changeTextSize()
    }
    
    private func changeBackgroundColor(_ color: NSColor) {
        
        defaultView.changeBackgroundColor(color)
        expandedArtView.changeBackgroundColor(color)
        transcoderView.changeBackgroundColor(color)
    }
    
    private func changeTrackInfoPrimaryTextColor(_ color: NSColor) {
        
        defaultView.changeTrackInfoPrimaryTextColor(color)
        expandedArtView.changeTrackInfoPrimaryTextColor(color)
        transcoderView.changeTrackInfoPrimaryTextColor()
    }
    
    private func changeTrackInfoSecondaryTextColor(_ color: NSColor) {
        
        defaultView.changeTrackInfoSecondaryTextColor(color)
        expandedArtView.changeTrackInfoSecondaryTextColor(color)
        transcoderView.changeTrackInfoSecondaryTextColor()
    }
    
    private func changeTrackInfoTertiaryTextColor(_ color: NSColor) {
        
        defaultView.changeTrackInfoTertiaryTextColor(color)
        expandedArtView.changeTrackInfoTertiaryTextColor(color)
        transcoderView.changeTrackInfoTertiaryTextColor()
    }
    
    private func changeControlTextColor(_ color: NSColor) {
        
        defaultView.changeControlTextColor(color)
        expandedArtView.changeControlTextColor(color)
        transcoderView.changeControlTextColor()
    }
    
    private func chapterChanged(_ newChapter: IndexedChapter?) {
        theView.chapterChanged(newChapter?.chapter.title)
    }
    
    // MARK: Message handling
    
    var subscriberId: String {
        return self.className
    }
    
    func consumeNotification(_ notification: NotificationMessage) {
        
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
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .changePlayerView:
            
            if let changeViewMsg = message as? PlayerViewActionMessage {
                changeView(changeViewMsg)
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
            
        case .changePlayerTextSize:
            
            changeTextSize()
            
        default:
            
            if let colorSchemeMsg = message as? ColorSchemeActionMessage {
                
                switch colorSchemeMsg.actionType {
                    
                case .changeBackgroundColor:
                    
                    changeBackgroundColor(colorSchemeMsg.color)
                    
                case .changeTrackInfoPrimaryTextColor:
                    
                    changeTrackInfoPrimaryTextColor(colorSchemeMsg.color)
                    
                case .changeTrackInfoSecondaryTextColor:
                    
                    changeTrackInfoSecondaryTextColor(colorSchemeMsg.color)
                    
                case .changeTrackInfoTertiaryTextColor:
                    
                    changeTrackInfoTertiaryTextColor(colorSchemeMsg.color)
                    
                case .changeControlTextColor:
                    
                    changeControlTextColor(colorSchemeMsg.color)
                    
                default: return
                    
                }
            }
            
            return
            
        }
    }
}
