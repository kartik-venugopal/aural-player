import Cocoa

/*
    A container view for the 2 types of player views - Default / Expanded Art view.
    Switches between the 2 views, shows/hides individual UI components, and handles functions such as auto-hide.
 */
class PlayingTrackView: MouseTrackingView, ColorSchemeable {
    
    @IBOutlet weak var tabView: NSTabView!
    
    @IBOutlet weak var defaultView: PlayingTrackSubview!
    @IBOutlet weak var expandedArtView: PlayingTrackSubview!
    
    @IBOutlet weak var functionsBox: NSBox!
 
    // The player view that is currently displayed
    private var activeView: PlayingTrackSubview {
        return PlayerViewState.viewType == .defaultView ? defaultView : expandedArtView
    }
    
    // The player view that is NOT currently displayed
    private var inactiveView: PlayingTrackSubview {
        return PlayerViewState.viewType == .defaultView ? expandedArtView : defaultView
    }
 
    // Info about the currently playing track
    var trackInfo: PlayingTrackInfo? {
        
        didSet {
            
            defaultView.trackInfo = trackInfo
            expandedArtView.trackInfo = trackInfo
        }
    }
    
//    override func awakeFromNib() {
//
////        self.addSubviews(defaultView, expandedArtView)
////        inactiveView.hideView()
//        
//        setUpMouseTracking()
//    }
    
    // Sets up the view for display.
    func showView() {
        
        switchView(PlayerViewState.viewType)
        
        setUpMouseTracking()
        activeView.showView()
        
        self.show()
    }
    
    // This is required when the player view is hidden.
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
    
    // Switches between the 2 sub-views (Default and Expanded Art)
    func switchView(_ viewType: PlayerViewType) {
        
        tabView.selectTabViewItem(at: PlayerViewState.viewType == .defaultView ? 0 : 1)
        
        inactiveView.hideView()
        activeView.showView()
        
        setUpMouseTracking()
    }
    
    func showOrHidePlayingTrackInfo() {
        
        defaultView.showOrHidePlayingTrackInfo()
        expandedArtView.showOrHidePlayingTrackInfo()
    }
    
    func showOrHidePlayingTrackFunctions() {
        
        defaultView.showOrHidePlayingTrackFunctions()
        expandedArtView.showOrHidePlayingTrackFunctions()
    }
    
    func showOrHideAlbumArt() {
        
        defaultView.showOrHideAlbumArt()
        expandedArtView.showOrHideAlbumArt()
    }
    
    func showOrHideArtist() {
        
        defaultView.showOrHideArtist()
        expandedArtView.showOrHideArtist()
    }
    
    func showOrHideAlbum() {
        
        defaultView.showOrHideAlbum()
        expandedArtView.showOrHideAlbum()
    }
    
    func showOrHideCurrentChapter() {
        
        defaultView.showOrHideCurrentChapter()
        expandedArtView.showOrHideCurrentChapter()
    }
    
    func showOrHideMainControls() {
        
        defaultView.showOrHideMainControls()
        expandedArtView.showOrHideMainControls()
        
        setUpMouseTracking()
    }
    
    override func mouseEntered(with event: NSEvent) {
        activeView.mouseEntered()
    }
    
    override func mouseExited(with event: NSEvent) {

        // If this check is not performed, the track-peeking buttons (previous/next track)
        // will cause a false positive mouse exit event.
        if !self.frame.contains(event.locationInWindow) {
            activeView.mouseExited()
        }
    }

    // Set up mouse tracking if necessary (for auto-hide).
    private func setUpMouseTracking() {
        
        if activeView.needsMouseTracking {
            
            if !isTracking {
                startTracking()
            }
            
        } else if isTracking {
            
            stopTracking()
        }
    }
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        
        defaultView.applyFontScheme(fontScheme)
        expandedArtView.applyFontScheme(fontScheme)
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
}
