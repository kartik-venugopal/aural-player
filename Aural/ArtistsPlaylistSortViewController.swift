import Cocoa

class ArtistsPlaylistSortViewController: NSViewController, SortViewProtocol {
    
    @IBOutlet weak var sortGroups: NSButton!
    
    @IBOutlet weak var sortGroups_byArtist: NSButton!
    @IBOutlet weak var sortGroups_byDuration: NSButton!
    
    @IBOutlet weak var sortGroups_ascending: NSButton!
    @IBOutlet weak var sortGroups_descending: NSButton!
    
    @IBOutlet weak var sortTracks: NSButton!
    
    @IBOutlet weak var sortTracks_allGroups: NSButton!
    @IBOutlet weak var sortTracks_selectedGroups: NSButton!
    
    @IBOutlet weak var sortTracks_byAlbum: NSButton!
    @IBOutlet weak var sortTracks_byAlbum_andDiscTrack: NSButton!
    @IBOutlet weak var sortTracks_byAlbum_andName: NSButton!
    @IBOutlet weak var sortTracks_byName: NSButton!
    @IBOutlet weak var sortTracks_byDuration: NSButton!
    
    @IBOutlet weak var sortTracks_ascending: NSButton!
    @IBOutlet weak var sortTracks_descending: NSButton!
    
    override var nibName: String? {return "ArtistsPlaylistSort"}
    
    func getView() -> NSView {
        return self.view
    }
    
    func resetFields() {
        
        sortGroups.on()
        sortGroups_byArtist.on()
        sortGroups_ascending.on()
        
        sortTracks.on()
        sortTracks_allGroups.on()
        sortTracks_byAlbum.on()
        sortTracks_ascending.on()
    }
    
    @IBAction func groupsSortToggleAction(_ sender: Any) {
        
        [sortGroups_byArtist, sortGroups_byDuration, sortGroups_ascending, sortGroups_descending].forEach({$0?.isEnabled = sortGroups.isOn()})
    }
    
    @IBAction func groupsSortFieldAction(_ sender: Any) {}
    
    @IBAction func groupsSortOrderAction(_ sender: Any) {}
    
    @IBAction func tracksSortToggleAction(_ sender: Any) {
        
        [sortTracks_allGroups, sortTracks_selectedGroups, sortTracks_byAlbum, sortTracks_byAlbum_andDiscTrack, sortTracks_byAlbum_andName, sortTracks_byName, sortTracks_byDuration, sortTracks_ascending, sortTracks_descending].forEach({$0?.isEnabled = sortTracks.isOn()})
    }
    
    @IBAction func tracksSortScopeAction(_ sender: Any) {}
    
    @IBAction func tracksSortFieldAction(_ sender: Any) {}
    
    @IBAction func tracksSortOrderAction(_ sender: Any) {}
    
    func getSortOptions() -> Sort {
        
        // Gather field values
        let sortOptions = Sort()
        
//        var sortFields = [SortField]()
        
//        if sortByName.isOn() {
//            sortFields.append(.name)
//        } else if sortByDuration.isOn() {
//            sortFields.append(.duration)
//        } else if sortByArtist.isOn() {
//            sortFields.append(.artist)
//            if sortByArtist_andByName.isOn() {
//                sortFields.append(.name)
//            }
//        } else if sortByAlbum.isOn() {
//            sortFields.append(.album)
//            if sortByAlbum_andByName.isOn() {
//                sortFields.append(.name)
//            }
//        }
        
//        sortOptions.order = sortAscending.isOn() ? SortOrder.ascending : SortOrder.descending
        
        return sortOptions
    }
}
