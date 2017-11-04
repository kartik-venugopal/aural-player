import Foundation

// Marker protocol for a playlist reorder operation
protocol FlatPlaylistReorderOperation {}

struct TrackRemovalOperation: FlatPlaylistReorderOperation {
    
    var index: Int
}

struct TrackInsertionOperation: FlatPlaylistReorderOperation {
    
    var srcTrack: Track
    var destIndex: Int
}

protocol GroupingPlaylistReorderOperation {}

struct GroupedTrackRemovalOperation: GroupingPlaylistReorderOperation {
    
    var group: Group
    var trackIndex: Int
}

struct GroupedTrackInsertionOperation: GroupingPlaylistReorderOperation {
    
    var group: Group
    var srcTrack: Track
    
    var srcIndex: Int
    var destIndex: Int
}

struct GroupRemovalOperation: GroupingPlaylistReorderOperation {
    
    var index: Int
}

struct GroupInsertionOperation: GroupingPlaylistReorderOperation {
    
    var srcGroup: Group
    
    var srcIndex: Int
    var destIndex: Int
}
