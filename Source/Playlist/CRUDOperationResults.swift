/*
    Definitions of structs used to hold results of various Playlist CRUD operations
 */
import Foundation

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
    let groupingPlaylistResults: [GroupType: [GroupedItemRemovalResult]]
    
    // Result from the flat playlist (indexes)
    let flatPlaylistResults: IndexSet
    
    let tracks: Set<Track>
}

// Base class (not meant to be instantiated) for a track/group removal result
class GroupedItemRemovalResult {
    
    // The group that was removed
    let group: Group
    
    // The index from which the group was removed
    let groupIndex: Int
    
    // The index by which these results will be sorted (for ex, a track index or group index)
    var sortIndex: Int {
        return groupIndex
    }
    
    fileprivate init(_ group: Group, _ groupIndex: Int) {
        
        self.group = group
        self.groupIndex = groupIndex
    }
}

// Contains the result of removing a group from a single grouping playlist
class GroupRemovalResult: GroupedItemRemovalResult {
    
    override init(_ group: Group, _ groupIndex: Int) {
        super.init(group, groupIndex)
    }
    
    static func compareAscending(_ result1: GroupRemovalResult, _ result2: GroupRemovalResult) -> Bool {
        return result1.sortIndex < result2.sortIndex
    }
    
    static func compareDescending(_ result1: GroupRemovalResult, _ result2: GroupRemovalResult) -> Bool {
        return result1.sortIndex > result2.sortIndex
    }
}

// Contains the results of removing a set of tracks from a group within a single grouping playlist
class GroupedTracksRemovalResult: GroupedItemRemovalResult {
    
    // Indexes of the removed tracks within their parent group
    let trackIndexesInGroup: IndexSet
    
    init(_ group: Group, _ groupIndex: Int, _ trackIndexesInGroup: IndexSet) {
        
        self.trackIndexesInGroup = trackIndexesInGroup
        super.init(group, groupIndex)
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

// Base class (not meant to be instantiated) for the result of a track/group move
class ItemMoveResult {
    
    // Index by which these results will be sorted
    var sortIndex: Int {
        return sourceIndex
    }
    
    // The old (source) index of the moved item
    let sourceIndex: Int
    
    // The new (destination) index of the moved item
    let destinationIndex: Int
    
    // Whether or not the track/group was moved up within the playlist
    let movedUp: Bool
    
    // Whether or not the track/group was moved down within the playlist
    let movedDown: Bool
    
    fileprivate init(_ sourceIndex: Int, _ destinationIndex: Int) {
        
        self.sourceIndex = sourceIndex
        self.destinationIndex = destinationIndex
        
        self.movedUp = destinationIndex < sourceIndex
        self.movedDown = !self.movedUp
    }
}

// Contains the result of moving a single group
class GroupMoveResult: ItemMoveResult {
    
    override init(_ sourceIndex: Int, _ destinationIndex: Int) {
        super.init(sourceIndex, destinationIndex)
    }
    
    static func compareAscending(_ result1: GroupMoveResult, _ result2: GroupMoveResult) -> Bool {
        return result1.sortIndex < result2.sortIndex
    }
    
    static func compareDescending(_ result1: GroupMoveResult, _ result2: GroupMoveResult) -> Bool {
        return result1.sortIndex > result2.sortIndex
    }
}

// Contains the result of moving a single track, either within a group, or within the flat playlist
class TrackMoveResult: ItemMoveResult {
    
    // The parent group, if the move occurred within a grouping playlist, or nil, if the move occurred within the flat playlist
    let parentGroup: Group?
    
    init(_ sourceIndex: Int, _ destinationIndex: Int, _ parentGroup: Group? = nil) {
        
        self.parentGroup = parentGroup
        super.init(sourceIndex, destinationIndex)
    }
    
    static func compareAscending(_ result1: TrackMoveResult, _ result2: TrackMoveResult) -> Bool {
        return result1.sortIndex < result2.sortIndex
    }
    
    static func compareDescending(_ result1: TrackMoveResult, _ result2: TrackMoveResult) -> Bool {
        return result1.sortIndex > result2.sortIndex
    }
}

struct ItemMoveResultComparators {
    
    private init() {}
    
    static func compareAscending(_ result1: ItemMoveResult, _ result2: ItemMoveResult) -> Bool {
        return result1.sortIndex < result2.sortIndex
    }
    
    static func compareDescending(_ result1: ItemMoveResult, _ result2: ItemMoveResult) -> Bool {
        return result1.sortIndex > result2.sortIndex
    }
}

struct GroupedItemRemovalResultComparators {
    
    private init() {}
    
    static func compareAscending(_ result1: GroupedItemRemovalResult, _ result2: GroupedItemRemovalResult) -> Bool {
        return result1.sortIndex < result2.sortIndex
    }
    
    static func compareDescending(_ result1: GroupedItemRemovalResult, _ result2: GroupedItemRemovalResult) -> Bool {
        return result1.sortIndex > result2.sortIndex
    }
}
