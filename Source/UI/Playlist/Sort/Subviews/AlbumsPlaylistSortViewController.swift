import Cocoa

class AlbumsPlaylistSortViewController: NSViewController, SortViewProtocol {
    
    @IBOutlet weak var sortGroups: NSButton!
    
    @IBOutlet weak var sortGroups_byAlbum: NSButton!
    @IBOutlet weak var sortGroups_byDuration: NSButton!
    
    @IBOutlet weak var sortGroups_ascending: NSButton!
    @IBOutlet weak var sortGroups_descending: NSButton!
    
    @IBOutlet weak var sortTracks: NSButton!
    
    @IBOutlet weak var sortTracks_allGroups: NSButton!
    @IBOutlet weak var sortTracks_selectedGroups: NSButton!
    
    @IBOutlet weak var sortTracks_byDiscAndTrack: NSButton!
    @IBOutlet weak var sortTracks_byName: NSButton!
    @IBOutlet weak var sortTracks_byDuration: NSButton!
    
    @IBOutlet weak var sortTracks_ascending: NSButton!
    @IBOutlet weak var sortTracks_descending: NSButton!
    
    @IBOutlet weak var useTrackNameIfNoMetadata: NSButton!
    
    override var nibName: String? {return "AlbumsPlaylistSort"}
    
    var sortView: NSView {view}
    
    var playlistType: PlaylistType {.albums}
    
    func resetFields() {
        
        [sortGroups, sortGroups_byAlbum, sortGroups_ascending, sortTracks, sortTracks_allGroups, sortTracks_byName, sortTracks_ascending, useTrackNameIfNoMetadata].forEach {$0.on()}
        
        groupsSortToggleAction(self)
        tracksSortToggleAction(self)
    }
    
    @IBAction func groupsSortToggleAction(_ sender: Any) {}
    
    @IBAction func groupsSortFieldAction(_ sender: Any) {}
    
    @IBAction func groupsSortOrderAction(_ sender: Any) {}
    
    @IBAction func tracksSortToggleAction(_ sender: Any) {}
    
    @IBAction func tracksSortScopeAction(_ sender: Any) {}
    
    @IBAction func tracksSortFieldAction(_ sender: Any) {}
    
    @IBAction func tracksSortOrderAction(_ sender: Any) {}
    
    var sortOptions: Sort {
        
        // Gather field values
        let sort = Sort()
        
        if sortGroups.isOn {
            
            _ = sort.withGroupsSort(GroupsSort().withFields(sortGroups_byAlbum.isOn ? .name : .duration)
                .withOrder(sortGroups_ascending.isOn ? .ascending : .descending))
        }
        
        if sortTracks.isOn {
            
            let tracksSort: TracksSort = TracksSort().withScope(sortTracks_allGroups.isOn ? .allGroups : .selectedGroups)
            
            // Scope
            if tracksSort.scope == .selectedGroups {
                
                // Pick up only the groups selected (ignoring the tracks)
                let selGroups: [Group] = PlaylistViewState.selectedItems.compactMap {$0.group}
                _ = tracksSort.withParentGroups(selGroups)
            }
            
            // Fields
            if sortTracks_byDiscAndTrack.isOn {
                _ = tracksSort.withFields(.discNumberAndTrackNumber)
                
            } else if sortTracks_byName.isOn {
                _ = tracksSort.withFields(.name)
                
            } else {
                // By duration
                _ = tracksSort.withFields(.duration)
            }
            
            // Order
            _ = tracksSort.withOrder(sortTracks_ascending.isOn ? .ascending : .descending)
            
            // Options
            _ = useTrackNameIfNoMetadata.isOn ? tracksSort.withOptions(.useNameIfNoMetadata) : tracksSort.withNoOptions()
            
            _ = sort.withTracksSort(tracksSort)
        }
        
        return sort
    }
}
