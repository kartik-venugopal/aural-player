//
//  Grouping.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import OrderedCollections

class Grouping {
    
    let name: String
    let function: GroupingFunction
    let rootGroup: Group
    
    static let defaultGroupSortOrder: GroupComparator = groupSortByName
    
    /// The user-specified custom sort order. (Will override the default sort order.)
    var sortOrder: GroupedTrackListSort? = nil {
        
        didSet {
            sortSubgroups(in: rootGroup)
        }
    }
    
    init(name: String, function: GroupingFunction, rootGroup: Group) {

        self.name = name
        self.function = function
        self.rootGroup = rootGroup
    }
    
    var numberOfGroups: Int {rootGroup.numberOfSubGroups}
    
    func group(at index: Int) -> Group {
        rootGroup.subGroup(at: index)
    }
    
    func group(named name: String) -> Group? {
        rootGroup.findSubGroup(named: name)
    }
    
    func addTracks(_ newTracks: [Track]) {
        
        rootGroup.addTracks(newTracks)
        rootGroup.sortTracks(by: function.trackSortOrder)
        
        subGroupTracks(in: rootGroup, by: self.function)
    }
    
    fileprivate func subGroupTracks(in group: Group, by function: GroupingFunction) {
        
        guard function.canSubGroup(group: group) else {return}
        
        let tracksByGroupName = group.tracks.categorizeOneToManyBy {track in
            function.keyFunction(track)
        }
        
        for (groupName, tracks) in tracksByGroupName {
            
            let subGroup = group.findOrCreateSubGroup(named: groupName)
            subGroup.addTracks(tracks)
            
            if function.subGroupingFunction == nil {
                subGroup.sortTracks(by: function.trackSortOrder)
            }
        }
        
        // Tracks no longer in parent.
        group.removeAllTracks()
        
        group.sortSubGroups(by: groupSortByName)
        
        if let subGroupingFunction = function.subGroupingFunction {
            
            for subGroup in group.subGroups.values {
                subGroupTracks(in: subGroup, by: subGroupingFunction)
            }
        }
    }
    
    func findParent(forTrack track: Track) -> Group? {
        
        var function: GroupingFunction? = self.function
        var parent: Group? = rootGroup
        
        while let theFunction = function, let theParent = parent, theFunction.canSubGroup(group: theParent) {
            
            let groupName = theFunction.keyFunction(track)
            
            parent = theParent.findSubGroup(named: groupName)
            function = function?.subGroupingFunction
        }
        
        return parent
    }
    
    func removeTracks(_ tracksToRemove: [Track]) {
        
        for track in tracksToRemove {
            findParent(forTrack: track)?.removeTracks([track])
        }
    }
    
    func remove(tracks tracksToRemove: [GroupedTrack], andGroups groupsToRemove: [Group]) {
        
        var groupedTracks: [Group: [Track]] = [:]
        
        for track in tracksToRemove {
            groupedTracks[track.group, default: []].append(track.track)
        }
        
        for (parent, tracks) in groupedTracks {
            
            // If all tracks were removed from this group, remove the group itself.
            if parent.numberOfTracks == tracks.count {
                parent.removeFromParent()
                
            } else {
                parent.removeTracks(tracks)
            }
        }
        
        for group in groupsToRemove {
            group.removeFromParent()
        }
    }
    
    func removeAllTracks() {
        rootGroup.removeAllSubGroups()
    }
    
    /// Tracks were cropped in this grouping.
    func cropTracks(_ tracksToKeep: [Track]) {
        
        removeAllTracks()
        addTracks(tracksToKeep)
    }
    
    fileprivate func sortSubgroups(in parentGroup: Group) {
        
        if let groupSortOrder = sortOrder?.groupSort?.comparator {
            parentGroup.sortSubGroups(by: groupSortOrder)
        }
        
        if parentGroup.hasSubGroups {
            
            for subGroup in parentGroup.subGroups.values {
                sortSubgroups(in: subGroup)
            }
            
        } else if let trackSortOrder = sortOrder?.trackSort?.comparator {
            
            // Sort tracks at the last level
            parentGroup.sortTracks(by: trackSortOrder)
        }
    }
}

extension Grouping: Hashable {
    
    static func == (lhs: Grouping, rhs: Grouping) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

class ArtistsGrouping: Grouping {
    
    init() {
        
        super.init(name: "Artists",
                   function: GroupingFunction.fromFunctions([(artistsKeyFunction, groupSortByName, trackAlbumDiscAndTrackNumberAscendingComparator),
                                                             (albumsKeyFunction, groupSortByName, trackNumberAscendingComparator),
                                                             (albumDiscsKeyFunction, groupSortByName, trackNumberAscendingComparator)]),
                   rootGroup: ArtistsRootGroup(name: "Artists-Root", depth: 0))
    }
}

class AlbumsGrouping: Grouping {
    
    init() {
        
        super.init(name: "Albums", function: GroupingFunction.fromFunctions([(albumsKeyFunction, Self.defaultGroupSortOrder, trackNumberAscendingComparator),
                                                                             (albumDiscsKeyFunction, Self.defaultGroupSortOrder, trackNumberAscendingComparator)]),
        rootGroup: AlbumsRootGroup(name: "Albums-Root", depth: 0))
    }
}

class GenresGrouping: Grouping {
    
    init() {
        
        super.init(name: "Genres", function: GroupingFunction.fromFunctions([(genresKeyFunction, Self.defaultGroupSortOrder, trackArtistAlbumDiscTrackNumberComparator),
                                                                              (artistsKeyFunction, Self.defaultGroupSortOrder, trackAlbumDiscAndTrackNumberAscendingComparator)]),
                   rootGroup: GenresRootGroup(name: "Genres-Root", depth: 0))
    }
}

class DecadesGrouping: Grouping {
    
    init() {
        
        super.init(name: "Decades", function: GroupingFunction.fromFunctions([(decadesKeyFunction, Self.defaultGroupSortOrder, trackArtistAlbumDiscTrackNumberComparator),
                                                                              (artistsKeyFunction, Self.defaultGroupSortOrder, trackAlbumDiscAndTrackNumberAscendingComparator)]),
                   rootGroup: DecadesRootGroup(name: "Decades-Root", depth: 0))
    }
}
