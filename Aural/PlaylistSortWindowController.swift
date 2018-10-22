import Cocoa

/*
    Window controller for the playlist sort dialog
 */
class PlaylistSortWindowController: NSWindowController, ModalDialogDelegate {
    
    // Playlist sort modal dialog fields
    
    @IBOutlet weak var sortPanel: NSPanel!
    
    @IBOutlet weak var sortByName: NSButton!
    @IBOutlet weak var sortByDuration: NSButton!
    @IBOutlet weak var sortByArtist: NSButton!
    @IBOutlet weak var sortByAlbum: NSButton!
    
    @IBOutlet weak var sortAscending: NSButton!
    @IBOutlet weak var sortDescending: NSButton!
    
    @IBOutlet weak var sortTracksInGroups: NSButton!
    
    // Delegate that relays sort requests to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    // Delegate that retrieves current playback information
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    private var modalDialogResponse: ModalDialogResponse = .ok
    
    override var windowNibName: String? {return "PlaylistSort"}
    
    override func windowDidLoad() {
        
        self.window?.titlebarAppearsTransparent = true
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
        
        sortTracksInGroups.isEnabled = PlaylistViewState.current != .tracks
        
        UIUtils.showModalDialog(self.window!)
        return modalDialogResponse
    }
    
    @IBAction func sortOptionsChangedAction(_ sender: Any) {
        // Do nothing ... this action function is just to get the radio button groups to work
    }
    
    @IBAction func sortBtnAction(_ sender: Any) {
        
        // Gather field values
        let sortOptions = Sort()
        sortOptions.field = sortByName.isOn() ? SortField.name : SortField.duration
        sortOptions.order = sortAscending.isOn() ? SortOrder.ascending : SortOrder.descending
        
        if PlaylistViewState.groupType != nil {
            
            // This option is only applicable to grouping playlists
            sortOptions.options.sortTracksInGroups = sortTracksInGroups.isOn()
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
