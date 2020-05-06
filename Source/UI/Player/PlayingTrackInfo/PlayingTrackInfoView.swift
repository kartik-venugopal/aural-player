import Cocoa

class PlayingTrackInfoView: MouseTrackingView {
    
    @IBOutlet weak var defaultView: PlayerView!
    @IBOutlet weak var expandedArtView: PlayerView!
    
    private var activeView: PlayerView {
        return PlayerViewState.viewType == .defaultView ? defaultView : expandedArtView
    }
    
    private var inactiveView: PlayerView {
        return PlayerViewState.viewType == .defaultView ? expandedArtView : defaultView
    }
 
    var trackInfo: PlayingTrackInfo? {
        
        didSet {
            
            defaultView.trackInfo = trackInfo
            expandedArtView.trackInfo = trackInfo
        }
    }
    
    func update() {
        
        defaultView.update()
        expandedArtView.update()
    }
    
    private func showView(_ viewType: PlayerViewType) {
        
        PlayerViewState.viewType = viewType
        
        inactiveView.hideView()
        
        activeView.needsMouseTracking ? startTracking() : stopTracking()
        activeView.showView()
    }
    
    private func showOrHidePlayingTrackInfo() {
        
        PlayerViewState.showTrackInfo = !PlayerViewState.showTrackInfo
        activeView.showOrHidePlayingTrackInfo()
    }
    
    private func showOrHidePlayingTrackFunctions() {
        
        PlayerViewState.showPlayingTrackFunctions = !PlayerViewState.showPlayingTrackFunctions
        activeView.showOrHidePlayingTrackFunctions()
    }
    
    private func showOrHideAlbumArt() {
        
        PlayerViewState.showAlbumArt = !PlayerViewState.showAlbumArt
        activeView.showOrHideAlbumArt()
    }
    
    private func showOrHideArtist() {
        
        PlayerViewState.showArtist = !PlayerViewState.showArtist
        activeView.showOrHideArtist()
    }
    
    private func showOrHideAlbum() {
        
        PlayerViewState.showAlbum = !PlayerViewState.showAlbum
        activeView.showOrHideAlbum()
    }
    
    private func showOrHideCurrentChapter() {
        
        PlayerViewState.showCurrentChapter = !PlayerViewState.showCurrentChapter
        activeView.showOrHideCurrentChapter()
    }
    
    private func showOrHideMainControls() {
        
        PlayerViewState.showControls = !PlayerViewState.showControls
        activeView.showOrHideMainControls()
    }
    
    override func mouseEntered(with event: NSEvent) {
        activeView.mouseEntered()
    }
    
    override func mouseExited(with event: NSEvent) {
        activeView.mouseExited()
    }
    
    func performAction(_ action: PlayerViewActionMessage) {
        
        switch action.actionType {
            
        case .changePlayerView:
            
            if let viewType = action.viewType {
                showView(viewType)
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
    }
}

struct PlayingTrackInfo {
    
    let track: Track?
    let playingChapterTitle: String?
    
    var art: NSImage? {
        return track?.displayInfo.art?.image
    }
    
    var artist: String? {
        return track?.displayInfo.artist
    }
    
    var album: String? {
        return track?.groupingInfo.album
    }
    
    var displayName: String? {
        return track?.displayInfo.title ?? track?.conciseDisplayName
    }
    
    init(_ track: Track?, _ playingChapterTitle: String?) {
        
        self.track = track
        self.playingChapterTitle = playingChapterTitle
    }
}
