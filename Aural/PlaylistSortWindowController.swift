import Cocoa

/*
    Window controller for the playlist sort dialog
 */
class PlaylistSortWindowController: NSWindowController, ModalDialogDelegate {
    
    convenience init() {
        self.init(windowNibName: "PlaylistSort")
    }
    
    // Playlist sort modal dialog fields
    
    @IBOutlet weak var sortPanel: NSPanel!
    
    @IBOutlet weak var sortByName: NSButton!
    @IBOutlet weak var sortByDuration: NSButton!
    
    @IBOutlet weak var sortAscending: NSButton!
    @IBOutlet weak var sortDescending: NSButton!
    
    @IBOutlet weak var sortTracksInGroups: NSButton!
    
    // Delegate that relays sort requests to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    // Delegate that retrieves current playback information
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    override func windowDidLoad() {
        
        self.window?.titlebarAppearsTransparent = true
        super.windowDidLoad()
    }
    
    func showDialog() {
        
        // Don't do anything if either no tracks or only 1 track in playlist
        if (playlist.size() < 2) {
            return
        }
        
        if (!self.isWindowLoaded) {
            _ = self.window!
        }
        
        sortTracksInGroups.isEnabled = PlaylistViewState.current != .tracks
        
        UIUtils.showModalDialog(self.window!)
    }
    
    @IBAction func sortOptionsChangedAction(_ sender: Any) {
        // Do nothing ... this action function is just to get the radio button groups to work
    }
    
    @IBAction func sortBtnAction(_ sender: Any) {
        
        // Gather field values
        let sortOptions = Sort()
        sortOptions.field = sortByName.state == 1 ? SortField.name : SortField.duration
        sortOptions.order = sortAscending.state == 1 ? SortOrder.ascending : SortOrder.descending
        
        if PlaylistViewState.groupType != nil {
            
            // This option is only applicable to grouping playlists
            sortOptions.options.sortTracksInGroups = sortTracksInGroups.state == 1
        }
        
        // Perform the sort
        playlist.sort(sortOptions, PlaylistViewState.current)
        
        // Notify playlist views
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.refresh, PlaylistViewState.current))
        
        // The playing track may have moved within the playlist. Update the sequence information displayed.
        if (playbackInfo.getPlayingTrack() != nil) {
            SyncMessenger.publishNotification(SequenceChangedNotification.instance)
        }
        
        UIUtils.dismissModalDialog()
    }
    
    @IBAction func sortCancelBtnAction(_ sender: Any) {
        UIUtils.dismissModalDialog()
    }
}
