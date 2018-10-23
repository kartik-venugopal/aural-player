import Cocoa

class GenresPlaylistSortViewController: NSViewController, SortViewProtocol {
    
    @IBOutlet weak var sortGroups: NSButton!
    
    @IBOutlet weak var sortGroups_byGenre: NSButton!
    @IBOutlet weak var sortGroups_byDuration: NSButton!
    
    @IBOutlet weak var sortGroups_ascending: NSButton!
    @IBOutlet weak var sortGroups_descending: NSButton!
    
    @IBOutlet weak var sortTracks: NSButton!
    
    @IBOutlet weak var sortTracks_allGroups: NSButton!
    @IBOutlet weak var sortTracks_selectedGroups: NSButton!
    
    @IBOutlet weak var sortTracks_byArtist_andName: NSButton!
    @IBOutlet weak var sortTracks_byArtist_andAlbum_andDiscTrack: NSButton!
    @IBOutlet weak var sortTracks_byArtist_andAlbum_andName: NSButton!
    
    @IBOutlet weak var sortTracks_byAlbum_andDiscTrack: NSButton!
    @IBOutlet weak var sortTracks_byAlbum_andName: NSButton!
    
    @IBOutlet weak var sortTracks_byName: NSButton!
    @IBOutlet weak var sortTracks_byDuration: NSButton!
    
    @IBOutlet weak var sortTracks_ascending: NSButton!
    @IBOutlet weak var sortTracks_descending: NSButton!
    
    override var nibName: String? {return "GenresPlaylistSort"}
    
    func getView() -> NSView {
        return self.view
    }
    
    func resetFields() {
        
        sortGroups.on()
        sortGroups_byGenre.on()
        sortGroups_ascending.on()
        groupsSortToggleAction(self)
        
        sortTracks.on()
        sortTracks_allGroups.on()
        sortTracks_byName.on()
        sortTracks_ascending.on()
        tracksSortToggleAction(self)
    }
    
    @IBAction func groupsSortToggleAction(_ sender: Any) {
        
        [sortGroups_byGenre, sortGroups_byDuration, sortGroups_ascending, sortGroups_descending].forEach({$0?.isEnabled = sortGroups.isOn()})
    }
    
    @IBAction func groupsSortFieldAction(_ sender: Any) {}
    
    @IBAction func groupsSortOrderAction(_ sender: Any) {}
    
    @IBAction func tracksSortToggleAction(_ sender: Any) {
        
        [sortTracks_allGroups, sortTracks_selectedGroups, sortTracks_byArtist_andName, sortTracks_byArtist_andAlbum_andName, sortTracks_byArtist_andAlbum_andDiscTrack, sortTracks_byAlbum_andDiscTrack, sortTracks_byAlbum_andName, sortTracks_byName, sortTracks_byDuration, sortTracks_ascending, sortTracks_descending].forEach({$0?.isEnabled = sortTracks.isOn()})
    }
    
    @IBAction func tracksSortScopeAction(_ sender: Any) {}
    
    @IBAction func tracksSortFieldAction(_ sender: Any) {}
    
    @IBAction func tracksSortOrderAction(_ sender: Any) {}
    
    func getSortOptions() -> Sort {
        
        // Gather field values
        let sort = Sort()
        
        if sortGroups.isOn() {
            
            let field: SortField = sortGroups_byGenre.isOn() ? .name : .duration
            _ = sort.withGroupsSort(GroupsSort().withFields(field).withOrder(sortGroups_ascending.isOn() ? .ascending : .descending))
        }
        
        if sortTracks.isOn() {
            
            let tracksSort: TracksSort = TracksSort()
            
            // Scope
            _ = tracksSort.withScope(sortTracks_allGroups.isOn() ? .allGroups : .selectedGroups)
            if tracksSort.scope == .selectedGroups {
                
                let selItems = PlaylistViewState.selectedItems
                var groups: [Group] = []
                
                // Pick up only the groups selected (ignoring the tracks)
                for item in selItems {
                    if let group = item.group {
                        groups.append(group)
                    }
                }
                
                _ = tracksSort.withParentGroups(groups)
            }
            
            // Fields
            if sortTracks_byName.isOn() {
                _ = tracksSort.withFields(.name)
            } else if sortTracks_byArtist_andName.isOn() {
                _ = tracksSort.withFields(.artist, .name)
            } else if sortTracks_byArtist_andAlbum_andDiscTrack.isOn() {
                _ = tracksSort.withFields(.artist, .album, .discNumberAndTrackNumber)
            } else if sortTracks_byArtist_andAlbum_andName.isOn() {
                _ = tracksSort.withFields(.artist, .album, .name)
            } else if sortTracks_byAlbum_andDiscTrack.isOn() {
                _ = tracksSort.withFields(.album, .discNumberAndTrackNumber)
            } else if sortTracks_byAlbum_andName.isOn() {
                _ = tracksSort.withFields(.album, .name)
            } else {
                // By duration
                _ = tracksSort.withFields(.duration)
            }
            
            // Order
            _ = tracksSort.withOrder(sortTracks_ascending.isOn() ? .ascending : .descending)
            
            _ = sort.withTracksSort(tracksSort)
        }
        
        return sort
    }
}
