import Cocoa

class PlayingTrackView: MouseTrackingView, ColorSchemeable, TextSizeable {
    
    @IBOutlet weak var defaultView: PlayingTrackSubview!
    @IBOutlet weak var expandedArtView: PlayingTrackSubview!
    
    private var activeView: PlayingTrackSubview {
        return PlayerViewState.viewType == .defaultView ? defaultView : expandedArtView
    }
    
    private var inactiveView: PlayingTrackSubview {
        return PlayerViewState.viewType == .defaultView ? expandedArtView : defaultView
    }
 
    var trackInfo: PlayingTrackInfo? {
        
        didSet {
            
            defaultView.trackInfo = trackInfo
            expandedArtView.trackInfo = trackInfo
        }
    }
    
    override func awakeFromNib() {
        
        self.addSubviews(defaultView, expandedArtView)
        
        switchView(PlayerViewState.viewType)
        setUpMouseTracking()
    }
    
    // This is required when the player view was hidden and is now shown (eg. after waiting or transcoding).
    func showView() {
        
        setUpMouseTracking()
        activeView.showView()
        
        self.show()
    }
    
    // This is required when the player view is hidden (eg. when waiting or transcoding).
    func hideView() {
        
        self.hide()
        
        if isTracking {
            stopTracking()
        }
    }
    
    func update() {
        
        defaultView.update()
        expandedArtView.update()
    }
    
    private func switchView(_ viewType: PlayerViewType) {
        
        PlayerViewState.viewType = viewType
        
        inactiveView.hideView()
        activeView.showView()
    }
    
    private func showOrHidePlayingTrackInfo() {
        
        PlayerViewState.showTrackInfo.toggle()
        
        defaultView.showOrHidePlayingTrackInfo()
        expandedArtView.showOrHidePlayingTrackInfo()
    }
    
    private func showOrHidePlayingTrackFunctions() {
        
        PlayerViewState.showPlayingTrackFunctions.toggle()
        
        defaultView.showOrHidePlayingTrackFunctions()
        expandedArtView.showOrHidePlayingTrackFunctions()
    }
    
    private func showOrHideAlbumArt() {
        
        PlayerViewState.showAlbumArt.toggle()
        
        defaultView.showOrHideAlbumArt()
        expandedArtView.showOrHideAlbumArt()
    }
    
    private func showOrHideArtist() {
        
        PlayerViewState.showArtist.toggle()

        defaultView.showOrHideArtist()
        expandedArtView.showOrHideArtist()
    }
    
    private func showOrHideAlbum() {
        
        PlayerViewState.showAlbum.toggle()
        
        defaultView.showOrHideAlbum()
        expandedArtView.showOrHideAlbum()
    }
    
    private func showOrHideCurrentChapter() {
        
        PlayerViewState.showCurrentChapter.toggle()
        
        defaultView.showOrHideCurrentChapter()
        expandedArtView.showOrHideCurrentChapter()
    }
    
    private func showOrHideMainControls() {
        
        PlayerViewState.showControls.toggle()
        
        defaultView.showOrHideMainControls()
        expandedArtView.showOrHideMainControls()
    }
    
    override func mouseEntered(with event: NSEvent) {
        activeView.mouseEntered()
    }
    
    override func mouseExited(with event: NSEvent) {
        activeView.mouseExited()
    }
    
    func changeTextSize(_ size: TextSize) {
        
        defaultView.changeTextSize(size)
        expandedArtView.changeTextSize(size)
    }
    
    func applyColorSchemeComponent(_ msg: ColorSchemeComponentActionMessage) {
     
        switch msg.actionType {
            
        case .changeBackgroundColor:
            
            changeBackgroundColor(msg.color)
            
        case .changePlayerTrackInfoPrimaryTextColor:
            
            changePrimaryTextColor(msg.color)
            
        case .changePlayerTrackInfoSecondaryTextColor:
            
            changeSecondaryTextColor(msg.color)
            
        case .changePlayerTrackInfoTertiaryTextColor:
            
            changeTertiaryTextColor(msg.color)
            
        default:
            
            return
        }
    }
    
    func applyColorScheme(_ scheme: ColorScheme) {
        
        defaultView.applyColorScheme(scheme)
        expandedArtView.applyColorScheme(scheme)
    }
    
    func changeBackgroundColor(_ color: NSColor) {
        
        defaultView.changeBackgroundColor(color)
        expandedArtView.changeBackgroundColor(color)
    }
    
    func changePrimaryTextColor(_ color: NSColor) {
        
        defaultView.changePrimaryTextColor(color)
        expandedArtView.changePrimaryTextColor(color)
    }
    
    func changeSecondaryTextColor(_ color: NSColor) {
        
        defaultView.changeSecondaryTextColor(color)
        expandedArtView.changeSecondaryTextColor(color)
    }
    
    func changeTertiaryTextColor(_ color: NSColor) {
        
        defaultView.changeTertiaryTextColor(color)
        expandedArtView.changeTertiaryTextColor(color)
    }
    
    func performAction(_ action: PlayerViewActionMessage) {
        
        switch action.actionType {
            
        case .changePlayerView:
            
            if let viewType = action.viewType {
                switchView(viewType)
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
            
        default: return
            
        }
        
        setUpMouseTracking()
    }

    // Set up mouse tracking if necessary.
    private func setUpMouseTracking() {
        
        if activeView.needsMouseTracking {
            
            if !isTracking {
                startTracking()
            }
            
        } else if isTracking {
            
            stopTracking()
        }
    }
}
