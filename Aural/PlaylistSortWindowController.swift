import Cocoa

/*
    Window controller for the playlist sort dialog
 */
class PlaylistSortWindowController: NSWindowController, ModalDialogDelegate {
    
    @IBOutlet weak var container: NSBox!
    
    private var tracksPlaylistSortView: SortViewProtocol = TracksPlaylistSortViewController()
    private var artistsPlaylistSortView: SortViewProtocol = ArtistsPlaylistSortViewController()
    private var albumsPlaylistSortView: SortViewProtocol = AlbumsPlaylistSortViewController()
    private var genresPlaylistSortView: SortViewProtocol = GenresPlaylistSortViewController()
    
    // Delegate that relays sort requests to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    // Delegate that retrieves current playback information
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
    override var windowNibName: String? {return "PlaylistSortDialog"}
    
    override func windowDidLoad() {
        
        container.addSubview(tracksPlaylistSortView.sortView)
        container.addSubview(artistsPlaylistSortView.sortView)
        container.addSubview(albumsPlaylistSortView.sortView)
        container.addSubview(genresPlaylistSortView.sortView)
        
        ObjectGraph.windowManager.registerModalComponent(self)
        
        super.windowDidLoad()
    }
    
    var isModal: Bool {
        return self.window?.isVisible ?? false
    }
    
    func showDialog() -> ModalDialogResponse {
        
        // Don't do anything if either no tracks or only 1 track in playlist
        if (playlist.size < 2) {
            return .cancel
        }
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if (!self.isWindowLoaded) {
            _ = self.window!
        }
        
        // Choose sort view based on current playlist view
        [tracksPlaylistSortView, artistsPlaylistSortView, albumsPlaylistSortView, genresPlaylistSortView].forEach({$0.sortView.hide()})
        switch PlaylistViewState.current {

        case .tracks:
            
            tracksPlaylistSortView.sortView.show()
            tracksPlaylistSortView.resetFields()
            
        case .artists:
            
            artistsPlaylistSortView.sortView.show()
            artistsPlaylistSortView.resetFields()
            
        case .albums:
            
            albumsPlaylistSortView.sortView.show()
            albumsPlaylistSortView.resetFields()
            
        case .genres:
            
            genresPlaylistSortView.sortView.show()
            genresPlaylistSortView.resetFields()
        }
        
        UIUtils.showDialog(self.window!)
        return modalDialogResponse
    }
    
    @IBAction func sortBtnAction(_ sender: Any) {
        
        var sortOptions: Sort
        
        switch PlaylistViewState.current {
            
        case .tracks:  sortOptions = tracksPlaylistSortView.sortOptions
            
        case .artists: sortOptions = artistsPlaylistSortView.sortOptions
            
        case .albums: sortOptions = albumsPlaylistSortView.sortOptions
            
        case .genres: sortOptions = genresPlaylistSortView.sortOptions
            
        }
        
        // Perform the sort
        playlist.sort(sortOptions, PlaylistViewState.current)
        
        // Notify playlist views
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.refresh, PlaylistViewState.current))
        
        // The playing track may have moved within the playlist. Update the sequence information displayed.
        if (playbackInfo.playingTrack != nil) {
            SyncMessenger.publishNotification(SequenceChangedNotification.instance)
        }
        
        modalDialogResponse = .ok
        UIUtils.dismissDialog(self.window!)
    }
    
    @IBAction func sortCancelBtnAction(_ sender: Any) {
        modalDialogResponse = .cancel
        UIUtils.dismissDialog(self.window!)
    }
}

protocol SortViewProtocol {
    
    var sortView: NSView {get}
    var sortOptions: Sort {get}
    
    func resetFields()
}
