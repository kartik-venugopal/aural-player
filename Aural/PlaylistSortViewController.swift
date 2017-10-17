/*
    View controller for the playlist sort modal dialog
 */

import Cocoa

class PlaylistSortViewController: NSViewController {
    
    // Playlist sort modal dialog fields
    
    @IBOutlet weak var sortPanel: NSPanel!
    
    @IBOutlet weak var sortByName: NSButton!
    @IBOutlet weak var sortByDuration: NSButton!
    
    @IBOutlet weak var sortAscending: NSButton!
    @IBOutlet weak var sortDescending: NSButton!
    
    @IBOutlet weak var playlistView: NSTableView!
    
    // Delegate that relays sort requests to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    // Delegate that retrieves current playback information
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    override func viewDidLoad() {
        sortPanel.titlebarAppearsTransparent = true
    }
    
    @IBAction func sortPlaylistAction(_ sender: Any) {
        
        // Don't do anything if either no tracks or only 1 track in playlist
        if (playlistView.numberOfRows < 2) {
            return
        }
        
        UIUtils.showModalDialog(sortPanel)
    }
    
    @IBAction func sortOptionsChangedAction(_ sender: Any) {
        // Do nothing ... this action function is just to get the radio button groups to work
    }
    
    @IBAction func sortBtnAction(_ sender: Any) {
        
        // Gather field values
        let sortOptions = Sort()
        sortOptions.field = sortByName.state.rawValue == 1 ? SortField.name : SortField.duration
        sortOptions.order = sortAscending.state.rawValue == 1 ? SortOrder.ascending : SortOrder.descending
        
        // Perform the sort
        playlist.sort(sortOptions)
        UIUtils.dismissModalDialog()
        
        // Update the UI
        playlistView.reloadData()
    }
    
    @IBAction func sortCancelBtnAction(_ sender: Any) {
        UIUtils.dismissModalDialog()
    }
}
