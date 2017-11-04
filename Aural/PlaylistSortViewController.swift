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
    
    @IBOutlet weak var sortTracksInGroups: NSButton!
    
    // Delegate that relays sort requests to the playlist
    private let playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    // Delegate that retrieves current playback information
    private let playbackInfo: PlaybackInfoDelegateProtocol = ObjectGraph.getPlaybackInfoDelegate()
    
    override func viewDidLoad() {
        sortPanel.titlebarAppearsTransparent = true
    }
    
    @IBAction func sortPlaylistAction(_ sender: Any) {
        
        // Don't do anything if either no tracks or only 1 track in playlist
        if (playlist.size() < 2) {
            return
        }
        
        sortTracksInGroups.isEnabled = PlaylistViewState.current != .tracks
        
        UIUtils.showModalDialog(sortPanel)
    }
    
    @IBAction func sortOptionsChangedAction(_ sender: Any) {
        // Do nothing ... this action function is just to get the radio button groups to work
    }
    
    @IBAction func sortBtnAction(_ sender: Any) {
        
        // Gather field values
        let sortOptions = Sort()
        sortOptions.field = sortByName.state == 1 ? SortField.name : SortField.duration
        sortOptions.order = sortAscending.state == 1 ? SortOrder.ascending : SortOrder.descending
        
        // Perform the sort
        if let groupType = PlaylistViewState.groupType {
            
            // One of the grouping playlist views
            sortOptions.options.sortTracksInGroups = sortTracksInGroups.state == 1
            playlist.sort(sortOptions, groupType)
            
        } else {
            
            // Flat tracks view
            playlist.sort(sortOptions)
        }
        
        // Notify playlist views
        let actionMsg = PlaylistActionMessage(.refresh, PlaylistViewState.current)
        SyncMessenger.publishActionMessage(actionMsg)
        
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
