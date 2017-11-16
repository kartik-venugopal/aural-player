import Cocoa

/*
    View controller for the "Albums" playlist view
 */
class AlbumsPlaylistViewController: GroupingPlaylistViewController {
    
    override internal var groupType: GroupType {return .album}
    override internal var playlistType: PlaylistType {return .albums}
    
    convenience init() {
        self.init(nibName: "Albums", bundle: Bundle.main)!
    }
}
