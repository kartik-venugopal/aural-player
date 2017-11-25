import Cocoa

/*
    View controller for the "Albums" playlist view
 */
class AlbumsPlaylistViewController: GroupingPlaylistViewController {
    
    override internal var groupType: GroupType {return .album}
    override internal var playlistType: PlaylistType {return .albums}
    
    override var nibName: String? {return "Albums"}
}
