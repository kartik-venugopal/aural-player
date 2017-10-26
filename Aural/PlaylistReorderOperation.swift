import Foundation

// Marker protocol for a playlist reorder operation
protocol PlaylistReorderOperation {}

struct TrackRemoveOperation: PlaylistReorderOperation {
    
    var index: Int
}

struct TrackInsertOperation: PlaylistReorderOperation {
    
    var srcTrack: Track
    var destIndex: Int
}

protocol GroupingPlaylistReorderOperation {}

struct GroupedTrackRemoveOperation: GroupingPlaylistReorderOperation {
    
    var group: Group
    var index: Int
}

struct GroupedTrackInsertOperation: GroupingPlaylistReorderOperation {
    
    var group: Group
    var srcTrack: Track
    
    var srcIndex: Int
    var destIndex: Int
}

struct GroupRemoveOperation: GroupingPlaylistReorderOperation {
    
    var index: Int
}

struct GroupInsertOperation: GroupingPlaylistReorderOperation {
    
    var srcGroup: Group
    
    var srcIndex: Int
    var destIndex: Int
}
