//
//  LibraryArtistsSortView.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

typealias CheckBox = NSButton
typealias RadioButton = NSButton

/// Abstract class !!!
class LibrarySortView: NSView {
    
    @IBOutlet weak var sortGroups: CheckBox!
    
    @IBOutlet weak var sortGroups_byName: RadioButton!
    @IBOutlet weak var sortGroups_byDuration: RadioButton!
    
    @IBOutlet weak var sortGroups_ascending: RadioButton!
    @IBOutlet weak var sortGroups_descending: RadioButton!
    
    @IBOutlet weak var sortTracks: CheckBox!
    
    @IBOutlet weak var sortTracks_byName: RadioButton!
    @IBOutlet weak var sortTracks_byDuration: RadioButton!
    
    @IBOutlet weak var sortTracks_ascending: RadioButton!
    @IBOutlet weak var sortTracks_descending: RadioButton!
    
    // MARK: Actions for radio button groups
    
    @IBAction func groupsSortToggleAction(_ sender: Any) {
        
        groupSortControls.forEach {
            $0.enableIf(sortGroups.isOn)
        }
    }
    
    @IBAction func groupsSortFieldAction(_ sender: Any) {}
    
    @IBAction func groupsSortOrderAction(_ sender: Any) {}
    
    @IBAction func tracksSortToggleAction(_ sender: Any) {
        
        trackSortControls.forEach {
            $0.enableIf(sortTracks.isOn)
        }
    }
    
    @IBAction func tracksSortFieldAction(_ sender: Any) {}
    
    @IBAction func tracksSortOrderAction(_ sender: Any) {}
    
    fileprivate lazy var groupSortControls: [RadioButton] = [sortGroups_byName, sortGroups_byDuration, sortGroups_ascending, sortGroups_descending]
    fileprivate lazy var trackSortControls: [RadioButton] = [sortTracks_byName, sortTracks_byDuration, sortTracks_ascending, sortTracks_descending]
    
    var sort: GroupedTrackListSort {
        
        var groupSort: GroupSort?
        
        if sortGroups.isOn {
            groupSort = GroupSort(fields: groupSortFields, order: groupSortOrder)
        }
        
        var trackSort: TrackListSort?
        
        if sortTracks.isOn {
            trackSort = TrackListSort(fields: trackSortFields, order: trackSortOrder)
        }
        
        return GroupedTrackListSort(groupSort: groupSort, trackSort: trackSort)
    }
    
    var groupSortFields: [GroupSortField] {
        sortGroups_byName.isOn ? [.name] : [.duration]
    }
    
    var groupSortOrder: SortOrder {
        sortGroups_ascending.isOn ? .ascending : .descending
    }
    
    /// Override this !!!
    var trackSortFields: [TrackSortField] {
        [.name]
    }
    
    var trackSortOrder: SortOrder {
        sortTracks_ascending.isOn ? .ascending : .descending
    }
}

class LibraryArtistsSortView: LibraryAlbumsSortView {}

class LibraryAlbumsSortView: LibrarySortView {
    
    @IBOutlet weak var sortTracks_byDiscTrack: RadioButton!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        trackSortControls.append(sortTracks_byDiscTrack)
    }
    
    override var trackSortFields: [TrackSortField] {
        
        if sortTracks_byDiscTrack.isOn {
            return [.discNumberAndTrackNumber]
            
        } else if sortTracks_byName.isOn {
            return [.name]
            
        } else { // By duration
            return [.duration]
        }
    }
}

class LibraryGenresSortView: LibrarySortView {
    
    @IBOutlet weak var sortTracks_byAlbumAndDiscTrack: RadioButton!
    @IBOutlet weak var sortTracks_byAlbumAndName: RadioButton!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        trackSortControls.append(contentsOf: [sortTracks_byAlbumAndDiscTrack, sortTracks_byAlbumAndName])
    }
    
    override var trackSortFields: [TrackSortField] {
        
        if sortTracks_byAlbumAndDiscTrack.isOn {
            return [.album, .discNumberAndTrackNumber]
            
        } else if sortTracks_byAlbumAndName.isOn {
            return [.album, .name]
            
        } else if sortTracks_byName.isOn {
            return [.name]
            
        } else { // By duration
            return [.duration]
        }
    }
}

class LibraryDecadesSortView: LibraryGenresSortView {}
