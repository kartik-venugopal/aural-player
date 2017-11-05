import Foundation

struct TrackAddResult {
    
    let flatPlaylistResult: Int
    let groupingPlaylistResults: [GroupType: GroupedTrackAddResult]
}

struct GroupedTrackAddResult {
    
    let track: GroupedTrack
    let groupCreated: Bool
}

struct GroupedTrackUpdateResult {
    
    let track: GroupedTrack
    let groupCreated: Bool
    let oldGroupRemoved: Bool
}

struct TrackRemovalResults {
    
    let groupingPlaylistResults: [GroupType: [ItemRemovalResult]]
    let flatPlaylistResults: IndexSet
}

protocol ItemRemovalResult {
    var sortIndex: Int {get}
}

struct GroupRemovalResult: ItemRemovalResult {
    
    let group: Group
    let groupIndex: Int
    
    var sortIndex: Int {
        return groupIndex
    }
    
    init(_ group: Group, _ groupIndex: Int) {
        
        self.group = group
        self.groupIndex = groupIndex
    }
}

struct GroupedTracksRemovalResult: ItemRemovalResult {
    
    let trackIndexesInGroup: IndexSet
    let parentGroup: Group
    let groupIndex: Int
    
    var sortIndex: Int {
        return groupIndex
    }
    
    init(_ trackIndexesInGroup: IndexSet, _ parentGroup: Group, _ groupIndex: Int) {
        self.trackIndexesInGroup = trackIndexesInGroup
        self.parentGroup = parentGroup
        self.groupIndex = groupIndex
    }
}

struct ItemMoveResults {
    
    let results: [ItemMoveResult]
    let playlistType: PlaylistType
    
    init(_ results: [ItemMoveResult], _ playlistType: PlaylistType) {
        self.results = results
        self.playlistType = playlistType
    }
}

protocol ItemMoveResult {
    var sortIndex: Int {get}
    var movedUp: Bool {get}
    var movedDown: Bool {get}
}

struct GroupMoveResult: ItemMoveResult {
    
    let oldGroupIndex: Int
    let newGroupIndex: Int
    
    let movedUp: Bool
    let movedDown: Bool
    
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

struct TrackMoveResult: ItemMoveResult {
    
    let oldTrackIndex: Int
    let newTrackIndex: Int
    let parentGroup: Group?
    
    let movedUp: Bool
    let movedDown: Bool
    
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
