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
//    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.playbackInfoDelegate
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
    override var windowNibName: String? {return "PlaylistSortDialog"}
    
    private var theWindow: NSWindow {self.window!}
    
    private var displayedSortView: SortViewProtocol!
    
    override func windowDidLoad() {
        
        container.addSubviews(tracksPlaylistSortView.sortView, artistsPlaylistSortView.sortView, albumsPlaylistSortView.sortView, genresPlaylistSortView.sortView)
        WindowManager.registerModalComponent(self)
    }
    
    var isModal: Bool {window?.isVisible ?? false}
    
    func showDialog() -> ModalDialogResponse {
        
        // Don't do anything if either no tracks or only 1 track in playlist
        guard playlist.size >= 2 else {return .cancel}
        
        // Force loading of the window if it hasn't been loaded yet (only once)
        if !self.isWindowLoaded {_ = theWindow}
        
        // Choose sort view based on current playlist view
        NSView.hideViews(tracksPlaylistSortView.sortView, artistsPlaylistSortView.sortView, albumsPlaylistSortView.sortView, genresPlaylistSortView.sortView)
        
        switch PlaylistViewState.current {

        case .tracks:       displayedSortView = tracksPlaylistSortView
            
        case .artists:      displayedSortView = artistsPlaylistSortView
            
        case .albums:       displayedSortView = albumsPlaylistSortView
            
        case .genres:       displayedSortView = genresPlaylistSortView

        }
        
        displayedSortView.resetFields()
        displayedSortView.sortView.show()
        
        UIUtils.showDialog(theWindow)
        return modalDialogResponse
    }
    
    @IBAction func sortBtnAction(_ sender: Any) {

        // Perform the sort
        playlist.sort(displayedSortView.sortOptions, displayedSortView.playlistType)
        
        // Notify playlist views
        Messenger.publish(.playlist_refresh, payload: PlaylistViewSelector.forView(displayedSortView.playlistType))
        
        // The playing track may have moved within the playlist. Update the sequence information displayed.
//        if playbackInfo.currentTrack != nil {
//            SyncMessenger.publishNotification(SequenceChangedNotification.instance)
//        }
        
        modalDialogResponse = .ok
        UIUtils.dismissDialog(theWindow)
    }
    
    @IBAction func sortCancelBtnAction(_ sender: Any) {
        
        modalDialogResponse = .cancel
        UIUtils.dismissDialog(theWindow)
    }
}

protocol SortViewProtocol {
    
    var sortView: NSView {get}
    var sortOptions: Sort {get}
    var playlistType: PlaylistType {get}
    
    func resetFields()
}
