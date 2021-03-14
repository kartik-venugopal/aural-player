import Cocoa

/*
    View controller for the "Genres" playlist view
 */
class GenresPlaylistViewController: GroupingPlaylistViewController {
    
    override internal var groupType: GroupType {return .genre}
    override internal var playlistType: PlaylistType {return .genres}

    override var nibName: String? {return "Genres"}
}
