import Cocoa

/*
    View controller for the "Artists" playlist view
 */
class ArtistsPlaylistViewController: GroupingPlaylistViewController {
    
    override internal var groupType: GroupType {return .artist}
    override internal var playlistType: PlaylistType {return .artists}
    
    override var nibName: String? {"Artists"}
}
