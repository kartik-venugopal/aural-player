import Cocoa

/*
    Provides actions for the Playlist menu
 */
class PlaylistMenuController: NSObject {
    
    @IBAction func addFilesAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.addTracks, nil))
    }
    
    @IBAction func removeSelectedItemsAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.removeTracks, PlaylistViewState.current))
    }
    
    @IBAction func savePlaylistAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.savePlaylist, nil))
    }
    
    @IBAction func clearPlaylistAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.clearPlaylist, nil))
    }
    
    @IBAction func moveItemsUpAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksUp, PlaylistViewState.current))
    }
    
    @IBAction func moveItemsDownAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksDown, PlaylistViewState.current))
    }
    
    // Presents the search modal dialog
    @IBAction func playlistSearchAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.search, nil))
    }
    
    // Presents the sort modal dialog
    @IBAction func playlistSortAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.sort, nil))
    }
    
    @IBAction func shiftTabAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.shiftTab, nil))
    }
    
    @IBAction func playSelectedItemAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.playSelectedItem, PlaylistViewState.current))
    }
    
    // Scrolls the playlist view to the very top
    @IBAction func scrollToTopAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.scrollToTop, nil))
    }
    
    // Scrolls the playlist view to the very bottom
    @IBAction func scrollToBottomAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.scrollToBottom, nil))
    }
}
