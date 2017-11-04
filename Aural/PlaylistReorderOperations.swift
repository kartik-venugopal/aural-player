import Foundation

// Marker protocol for a playlist reorder operation
protocol FlatPlaylistReorderOperation {}

struct TrackRemovalOperation: FlatPlaylistReorderOperation {
    
    let index: Int
}

struct TrackInsertionOperation: FlatPlaylistReorderOperation {
    
    let srcTrack: Track
    let destIndex: Int
}

protocol GroupingPlaylistReorderOperation {}

struct GroupedTrackRemovalOperation: GroupingPlaylistReorderOperation {
    
    let group: Group
    let trackIndex: Int
}

struct GroupedTrackInsertionOperation: GroupingPlaylistReorderOperation {
    
    let group: Group
    let srcTrack: Track
    
    let srcIndex: Int
    let destIndex: Int
}

struct GroupRemovalOperation: GroupingPlaylistReorderOperation {
    
    let index: Int
}

struct GroupInsertionOperation: GroupingPlaylistReorderOperation {
    
    let srcGroup: Group
    
    let srcIndex: Int
    let destIndex: Int
}
