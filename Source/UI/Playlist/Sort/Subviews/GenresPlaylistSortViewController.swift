//
//  GenresPlaylistSortViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
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
    
    @IBOutlet weak var useTrackNameIfNoMetadata: NSButton!
    
    override var nibName: String? {"GenresPlaylistSort"}
    
    var sortView: NSView {
        return self.view
    }
    
    var playlistType: PlaylistType {.genres}
    
    func resetFields() {
        
        [sortGroups, sortGroups_byGenre, sortGroups_ascending, sortTracks, sortTracks_allGroups, sortTracks_byName, sortTracks_ascending, useTrackNameIfNoMetadata].forEach {$0.on()}
        
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
            
            _ = sort.withGroupsSort(GroupsSort().withFields(sortGroups_byGenre.isOn ? .name : .duration)
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
            if sortTracks_byName.isOn {
                _ = tracksSort.withFields(.name)
                
            } else if sortTracks_byArtist_andName.isOn {
                _ = tracksSort.withFields(.artist, .name)
                
            } else if sortTracks_byArtist_andAlbum_andDiscTrack.isOn {
                _ = tracksSort.withFields(.artist, .album, .discNumberAndTrackNumber)
                
            } else if sortTracks_byArtist_andAlbum_andName.isOn {
                _ = tracksSort.withFields(.artist, .album, .name)
                
            } else if sortTracks_byAlbum_andDiscTrack.isOn {
                _ = tracksSort.withFields(.album, .discNumberAndTrackNumber)
                
            } else if sortTracks_byAlbum_andName.isOn {
                _ = tracksSort.withFields(.album, .name)
                
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
