/*
    Definitions of structs used to hold results of various Playlist CRUD operations
 */
import Foundation

// TODO: Clean up these structs and make them more consistent with each other.

// Contains the aggregated results of adding a track to each of the playlist types
struct TrackAddResult {
    
    let track: Track
    
    // Index of the added track, within the flat playlist
    let flatPlaylistResult: Int
    
    // Grouping info for the added track, within each of the grouping playlists
    let groupingPlaylistResults: [GroupType: GroupedTrackAddResult]
}

// Contains the result of adding a track to a single grouping playlist
struct GroupedTrackAddResult {
    
    // Grouping info for the added track
    let track: GroupedTrack
    
    // Whether or not the parent group of the added track was created as a result of adding the track (i.e. the added track is the only child of the parent group)
    let groupCreated: Bool
}

// Contains the aggregated results of removing a set of tracks/groups from each of the playlist types
struct TrackRemovalResults {
    
    // Results from each of the grouping playlists (grouping info)
    let groupingPlaylistResults: [GroupType: [ItemRemovalResult]]
    
    // Result from the flat playlist (indexes)
    let flatPlaylistResults: IndexSet
    
    let tracks: [Track]
}

// Marker protocol for a track/group removal result
protocol ItemRemovalResult {
    
    // The index by which these results will be sorted (for ex, a track index or group index)
    var sortIndex: Int {get}
}

// Contains the result of removing a group from a single grouping playlist
struct GroupRemovalResult: ItemRemovalResult {
    
    // The group that was removed
    let group: Group
    
    // The index from which the group was removed
    let groupIndex: Int
    
    // These results will be sorted by groupIndex
    var sortIndex: Int {
        return groupIndex
    }
    
    init(_ group: Group, _ groupIndex: Int) {
        
        self.group = group
        self.groupIndex = groupIndex
    }
}

// Contains the results of removing a set of tracks from a group within a single grouping playlist
struct GroupedTracksRemovalResult: ItemRemovalResult {
    
    // Indexes of the removed tracks within their parent group
    let trackIndexesInGroup: IndexSet
    
    // The parent group from which the tracks were removed
    let parentGroup: Group
    
    // The index of the parent group
    let groupIndex: Int
    
    // These results will be sorted by the index of the parent group
    var sortIndex: Int {
        return groupIndex
    }
    
    init(_ trackIndexesInGroup: IndexSet, _ parentGroup: Group, _ groupIndex: Int) {
        self.trackIndexesInGroup = trackIndexesInGroup
        self.parentGroup = parentGroup
        self.groupIndex = groupIndex
    }
}

// Contains the aggregated results of moving a set of tracks/groups from one of the playlist types
struct ItemMoveResults {
    
    // The individual results
    let results: [ItemMoveResult]
    
    // The type of the playlist in which the tracks/groups were moved
    let playlistType: PlaylistType
    
    init(_ results: [ItemMoveResult], _ playlistType: PlaylistType) {
        self.results = results
        self.playlistType = playlistType
    }
}

// Marker protocol for the result of a track/group move
protocol ItemMoveResult {
    
    // Index by which these results will be sorted
    var sortIndex: Int {get}
    
    // Whether or not the track/group was moved up within the playlist
    var movedUp: Bool {get}
    
    // Whether or not the track/group was moved down within the playlist
    var movedDown: Bool {get}
}

// Contains the result of moving a single group
struct GroupMoveResult: ItemMoveResult {
    
    // The old (source) index of the moved group
    let oldGroupIndex: Int
    
    // The new (destination) index of the moved group
    let newGroupIndex: Int
    
    // Flags indicating whether the group was moved up/down
    let movedUp: Bool
    let movedDown: Bool
    
    // These results will be sorted by the source group index
    var sortIndex: Int {
        return oldGroupIndex
    }
    
    init(_ oldGroupIndex: Int, _ newGroupIndex: Int) {
        
        self.oldGroupIndex = oldGroupIndex
        self.newGroupIndex = newGroupIndex
        
        self.movedUp = newGroupIndex < oldGroupIndex
        self.movedDown = !self.movedUp
    }
}

// Contains the result of moving a single track, either within a group, or within the flat playlist
struct TrackMoveResult: ItemMoveResult {
    
    // The old (source) index of the moved track
    let oldTrackIndex: Int
    
    // The new (destination) index of the moved track
    let newTrackIndex: Int
    
    // The parent group, if the move occurred within a grouping playlist, or nil, if the move occurred within the flat playlist
    let parentGroup: Group?
    
    // Flags indicating whether the track was moved up/down
    let movedUp: Bool
    let movedDown: Bool
    
    // These results will be sorted by the source track index
    var sortIndex: Int {
        return oldTrackIndex
    }
    
    init(_ oldTrackIndex: Int, _ newTrackIndex: Int, _ parentGroup: Group? = nil) {
        
        self.oldTrackIndex = oldTrackIndex
        self.newTrackIndex = newTrackIndex
        self.parentGroup = parentGroup
        
        self.movedUp = newTrackIndex < oldTrackIndex
        self.movedDown = !self.movedUp
    }
}

struct SortResults {
    
    let playlistType: PlaylistType

    let tracksSorted: Bool
    
    // These 2 fields are only applicable when tracks are sorted within groups.
    let affectedGroupsScope: GroupsScope?
    let affectedParentGroups: [Group]   // This array will be non-empty only when affectedGroupsScope == .selectedGroups
    
    let groupsSorted: Bool
    
    init(_ playlistType: PlaylistType, _ sort: Sort) {
        
        self.playlistType = playlistType
        
        self.tracksSorted = sort.tracksSort != nil
        self.groupsSorted = sort.groupsSort != nil
        
        self.affectedGroupsScope = sort.tracksSort?.scope
        self.affectedParentGroups = sort.tracksSort?.parentGroups ?? []
    }
}
