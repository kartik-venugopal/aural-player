import Cocoa

/*
    Provides actions for the Playlist menu
 */
class PlaylistMenuController: NSObject {
    
    private lazy var playlistSortDialog: ModalDialogDelegate = WindowFactory.getPlaylistSortDialog()
    
    // Presents the Playlist sort modal dialog
    @IBAction func playlistSortAction(_ sender: Any) {
        playlistSortDialog.showDialog()
    }
}
