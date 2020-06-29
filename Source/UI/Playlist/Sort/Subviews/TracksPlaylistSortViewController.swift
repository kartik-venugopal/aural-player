import Cocoa

class TracksPlaylistSortViewController: NSViewController, SortViewProtocol {
    
    @IBOutlet weak var sortByName: NSButton!
    @IBOutlet weak var sortByDuration: NSButton!
    
    @IBOutlet weak var sortByArtist_andAlbum_andDiscTrack: NSButton!
    @IBOutlet weak var sortByArtist_andAlbum_andName: NSButton!
    @IBOutlet weak var sortByArtist_andName: NSButton!
    
    @IBOutlet weak var sortByAlbum_andDiscTrack: NSButton!
    @IBOutlet weak var sortByAlbum_andName: NSButton!
    
    @IBOutlet weak var sortAscending: NSButton!
    @IBOutlet weak var sortDescending: NSButton!
    
    @IBOutlet weak var useTrackNameIfNoMetadata: NSButton!
    
    override var nibName: String? {return "TracksPlaylistSort"}
    
    var sortView: NSView {self.view}
    
    var playlistType: PlaylistType {.tracks}
    
    func resetFields() {
        [sortByName, sortAscending, useTrackNameIfNoMetadata].forEach {$0.on()}
    }
    
    @IBAction func sortFieldsAction(_ sender: Any) {}
    
    @IBAction func sortOrderAction(_ sender: Any) {}
    
    var sortOptions: Sort {
        
        let tracksSort: TracksSort = TracksSort()
        let sort: Sort = Sort().withTracksSort(tracksSort)
        
        if sortByName.isOn {
            
            _ = tracksSort.withFields(.name)
            
        } else if sortByDuration.isOn {
            
            _ = tracksSort.withFields(.duration)
            
        } else if sortByArtist_andAlbum_andDiscTrack.isOn {
            
            _ = tracksSort.withFields(.artist, .album, .discNumberAndTrackNumber)
            
        } else if sortByArtist_andAlbum_andName.isOn {
            
            _ = tracksSort.withFields(.artist, .album, .name)
            
        } else if sortByArtist_andName.isOn {

            _ = tracksSort.withFields(.artist, .name)
            
        } else if sortByAlbum_andDiscTrack.isOn {
            
            _ = tracksSort.withFields(.album, .discNumberAndTrackNumber)
            
        } else {
            
            // Sort by album and name
            _ = tracksSort.withFields(.album, .name)
        }
        
        _ = tracksSort.withOrder(sortAscending.isOn ? .ascending : .descending)
        
        _ = useTrackNameIfNoMetadata.isOn ? tracksSort.withOptions(.useNameIfNoMetadata) : tracksSort.withNoOptions()
        
        return sort
    }
}
