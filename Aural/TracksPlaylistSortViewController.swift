import Cocoa

class TracksPlaylistSortViewController: NSViewController, SortViewProtocol {
    
    @IBOutlet weak var sortByName: NSButton!
    @IBOutlet weak var sortByDuration: NSButton!
    
    @IBOutlet weak var sortByArtist: NSButton!
    @IBOutlet weak var sortByArtist_andAlbum: NSButton!
    @IBOutlet weak var sortByArtist_andAlbum_andDiscTrack: NSButton!
    @IBOutlet weak var sortByArtist_andName: NSButton!
    
    @IBOutlet weak var sortByAlbum: NSButton!
    @IBOutlet weak var sortByAlbum_andDiscTrack: NSButton!
    @IBOutlet weak var sortByAlbum_andName: NSButton!
    
    @IBOutlet weak var sortAscending: NSButton!
    @IBOutlet weak var sortDescending: NSButton!
    
    override var nibName: String? {return "TracksPlaylistSort"}
    
    func getView() -> NSView {
        return self.view
    }
    
    func resetFields() {
        
        sortByName.on()
        sortAscending.on()
    }
    
    @IBAction func sortFieldsAction(_ sender: Any) {}
    
    @IBAction func sortOrderAction(_ sender: Any) {}
    
    func getSortOptions() -> Sort {
        
        if sortByName.isOn() {
            
            let tracksSort: TracksSort = TracksSort().withFields(.name).withOrder(sortAscending.isOn() ? .ascending : .descending)
            return Sort().withTracksSort(tracksSort)
            
        } else if sortByDuration.isOn() {
            
            let tracksSort = TracksSort().withFields(.duration).withOrder(sortAscending.isOn() ? .ascending : .descending)
            return Sort().withTracksSort(tracksSort)
            
        } else if sortByArtist.isOn() {
            
            let tracksSort = TracksSort().withFields(.artist).withOrder(sortAscending.isOn() ? .ascending : .descending)
            return Sort().withTracksSort(tracksSort)
            
        } else if sortByArtist_andAlbum.isOn() {
            
            let tracksSort = TracksSort().withFields(.artist, .album).withOrder(sortAscending.isOn() ? .ascending : .descending)
            return Sort().withTracksSort(tracksSort)
            
        } else if sortByArtist_andAlbum_andDiscTrack.isOn() {
            
            let tracksSort = TracksSort().withFields(.artist, .album, .discNumberAndTrackNumber).withOrder(sortAscending.isOn() ? .ascending : .descending)
            return Sort().withTracksSort(tracksSort)
            
        } else if sortByArtist_andName.isOn() {
            
            let tracksSort = TracksSort().withFields(.artist, .name).withOrder(sortAscending.isOn() ? .ascending : .descending)
            return Sort().withTracksSort(tracksSort)
            
        } else if sortByAlbum.isOn() {
            
            let tracksSort = TracksSort().withFields(.album).withOrder(sortAscending.isOn() ? .ascending : .descending)
            return Sort().withTracksSort(tracksSort)
            
        } else if sortByAlbum_andDiscTrack.isOn() {
            
            let tracksSort = TracksSort().withFields(.album, .discNumberAndTrackNumber).withOrder(sortAscending.isOn() ? .ascending : .descending)
            return Sort().withTracksSort(tracksSort)
            
        } else {
            
            // Sort by album and name
            let tracksSort = TracksSort().withFields(.album, .name).withOrder(sortAscending.isOn() ? .ascending : .descending)
            return Sort().withTracksSort(tracksSort)
        }
    }
}
