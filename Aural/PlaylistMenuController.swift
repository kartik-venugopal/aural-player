import Cocoa

/*
    Provides actions for the Playlist menu
 */
class PlaylistMenuController: NSObject {
    
//    private lazy var playlistSearchDialog: ModalDialogDelegate = WindowFactory.getPlaylistSearchDialog()
//    
//    private lazy var playlistSortDialog: ModalDialogDelegate = WindowFactory.getPlaylistSortDialog()
    
    // Presents the Playlist search modal dialog
    @IBAction func playlistSearchAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.search, nil))
    }
    
    // Presents the Playlist sort modal dialog
    @IBAction func playlistSortAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.sort, nil))
    }
    
    @IBAction func shiftTabAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.shiftTab, nil))
    }
    
    @IBAction func showPlayingTrackAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.showPlayingTrack, PlaylistViewState.current))
    }
    
    @IBAction func savePlaylistAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.savePlaylist, nil))
    }
    
    @IBAction func addFilesAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.addTracks, nil))
    }
    
    @IBAction func playSelectedItemAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.playSelectedItem, PlaylistViewState.current))
    }
    
    @IBAction func moveItemsUpAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksUp, PlaylistViewState.current))
    }
    
    @IBAction func moveItemsDownAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.moveTracksDown, PlaylistViewState.current))
    }
    
    @IBAction func removeSelectedItemsAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(PlaylistActionMessage(.removeTracks, PlaylistViewState.current))
    }
}
