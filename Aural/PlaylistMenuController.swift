import Cocoa

/*
    Provides actions for the Playlist menu that perform various CRUD (model) operations and view navigation operations on the playlist.
 
    NOTE - No actions are directly handled by this class. Action messages are published to another app component that is responsible for these functions.
 */
class PlaylistMenuController: NSObject {
    
    // Invokes the Open file dialog, to allow the user to add tracks/playlists to the app playlist
    @IBAction func addFilesAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.addTracks, nil))
    }
    
    // Removes any selected playlist items from the playlist
    @IBAction func removeSelectedItemsAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.removeTracks, PlaylistViewState.current))
    }
    
    // Invokes the Save file dialog, to allow the user to save all playlist items to a playlist file
    @IBAction func savePlaylistAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.savePlaylist, nil))
    }
    
    // Removes all items from the playlist
    @IBAction func clearPlaylistAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.clearPlaylist, nil))
    }
    
    // Moves any selected playlist items up one row in the playlist
    @IBAction func moveItemsUpAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksUp, PlaylistViewState.current))
    }
    
    // Moves any selected playlist items down one row in the playlist
    @IBAction func moveItemsDownAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksDown, PlaylistViewState.current))
    }
    
    // Presents the search modal dialog to allow the user to search for playlist tracks
    @IBAction func playlistSearchAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.search, nil))
    }
    
    // Presents the sort modal dialog to allow the user to sort playlist tracks
    @IBAction func playlistSortAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.sort, nil))
    }

    // Switches the current playlist tab to the next one in the playlist tab group. Example: Tracks -> Artists or Albums -> Genres, Genres -> Tracks
    @IBAction func shiftTabAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.shiftTab, nil))
    }
    
    // Plays the selected playlist item (track or group)
    @IBAction func playSelectedItemAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.playSelectedItem, PlaylistViewState.current))
    }
    
    // Scrolls the current playlist view to the very top
    @IBAction func scrollToTopAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.scrollToTop, nil))
    }
    
    // Scrolls the current playlist view to the very bottom
    @IBAction func scrollToBottomAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.scrollToBottom, nil))
    }
}
