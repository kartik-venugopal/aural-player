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
    
    private var playlist: PlaylistDelegateProtocol = ObjectGraph.getPlaylistDelegate()
    
    override func viewDidLoad() {
        sortPanel.titlebarAppearsTransparent = true
    }
    
    @IBAction func sortPlaylistAction(_ sender: Any) {
        
        // Don't do anything if no tracks in playlist
        if (playlistView.numberOfRows == 0) {
            return
        }
        
        let window = WindowState.window!
        
        // Position the sort modal dialog and show it
        let sortFrameOrigin = NSPoint(x: window.frame.origin.x + 73, y: min(window.frame.origin.y + 227, window.frame.origin.y + window.frame.height - sortPanel.frame.height))
        
        sortPanel.setFrameOrigin(sortFrameOrigin)
        sortPanel.setIsVisible(true)
        
        NSApp.runModal(for: sortPanel)
        sortPanel.close()
    }
    
    @IBAction func sortOptionsChangedAction(_ sender: Any) {
        // Do nothing ... this action function is just to get the radio button groups to work
    }
    
    @IBAction func sortBtnAction(_ sender: Any) {
        
        // Gather field values
        let sortOptions = Sort()
        sortOptions.field = sortByName.state == 1 ? SortField.name : SortField.duration
        sortOptions.order = sortAscending.state == 1 ? SortOrder.ascending : SortOrder.descending
        
        playlist.sort(sortOptions)
        dismissModalDialog()
        
        playlistView.reloadData()
        
        // TODO
//        selectTrack(playlist.getPlayingTrack()?.index)
    }
    
    @IBAction func sortCancelBtnAction(_ sender: Any) {
        dismissModalDialog()
    }
    
    @IBAction func sortPlaylistMenuItemAction(_ sender: Any) {
        sortPlaylistAction(sender)
    }
    
    func dismissModalDialog() {
        NSApp.stopModal()
    }
}
