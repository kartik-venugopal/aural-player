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
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    // Delegate that retrieves current playback information
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
    override var windowNibName: String? {return "PlaylistSortDialog"}
    
    override func windowDidLoad() {
        
        self.window?.titlebarAppearsTransparent = true
        
        container.addSubview(tracksPlaylistSortView.getView())
        container.addSubview(artistsPlaylistSortView.getView())
        container.addSubview(albumsPlaylistSortView.getView())
        container.addSubview(genresPlaylistSortView.getView())
        
        super.windowDidLoad()
    }
    
    func showDialog() -> ModalDialogResponse {
        
        // Don't do anything if either no tracks or only 1 track in playlist
        if (playlist.size() < 2) {
            return .cancel
        }
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if (!self.isWindowLoaded) {
            _ = self.window!
        }
        
        // Choose sort view based on current playlist view
        [tracksPlaylistSortView, artistsPlaylistSortView, albumsPlaylistSortView, genresPlaylistSortView].forEach({$0.getView().isHidden = true})
        switch PlaylistViewState.current {

        case .tracks:
            
            tracksPlaylistSortView.getView().isHidden = false
            tracksPlaylistSortView.resetFields()
            
        case .artists:
            
            artistsPlaylistSortView.getView().isHidden = false
            artistsPlaylistSortView.resetFields()
            
        case .albums:
            
            albumsPlaylistSortView.getView().isHidden = false
            albumsPlaylistSortView.resetFields()
            
        case .genres:
            
            genresPlaylistSortView.getView().isHidden = false
            genresPlaylistSortView.resetFields()
        }
        
        UIUtils.showModalDialog(self.window!)
        return modalDialogResponse
    }
    
    @IBAction func sortBtnAction(_ sender: Any) {
        
        var sortOptions: Sort
        
        switch PlaylistViewState.current {
            
        case .tracks:  sortOptions = tracksPlaylistSortView.getSortOptions()
            
        case .artists: sortOptions = artistsPlaylistSortView.getSortOptions()
            
        case .albums: sortOptions = albumsPlaylistSortView.getSortOptions()
            
        case .genres: sortOptions = genresPlaylistSortView.getSortOptions()
            
        }
        
        // Perform the sort
        playlist.sort(sortOptions, PlaylistViewState.current)
        
        // Notify playlist views
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.refresh, PlaylistViewState.current))
        
        // The playing track may have moved within the playlist. Update the sequence information displayed.
        if (playbackInfo.getPlayingTrack() != nil) {
            SyncMessenger.publishNotification(SequenceChangedNotification.instance)
        }
        
        modalDialogResponse = .ok
        UIUtils.dismissModalDialog()
    }
    
    @IBAction func sortCancelBtnAction(_ sender: Any) {
        modalDialogResponse = .cancel
        UIUtils.dismissModalDialog()
    }
}

protocol SortViewProtocol {
    
    func getView() -> NSView
    
    func resetFields()
    
    func getSortOptions() -> Sort
}
