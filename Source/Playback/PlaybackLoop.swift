import Foundation

// A->B track segment playback loop defined on a particular track (the currently playing track)
struct PlaybackLoop: Equatable {
    
    // Starting point for the playback loop, expressed in seconds relative to the start of a track
    let startTime: Double
    
    // End point for the playback loop, expressed in seconds relative to the start of a track
    var endTime: Double?
    
    init(_ startTime: Double) {
        self.startTime = startTime
    }
    
    init(_ startTime: Double, _ endTime: Double) {
        self.startTime = startTime
        self.endTime = endTime
    }
    
    // Determines if this loop is complete (i.e. both start time and end time are defined)
    var isComplete: Bool {
        return endTime != nil
    }
    
    // Calculates the duration of this loop (if end time is defined)
    var duration: Double {
        
        if let end = endTime {
            return end - startTime
        }
        
        return 0
    }
    
    // Determines whether or not this loop contains a given time position.
    func containsPosition(_ timePosn: Double) -> Bool {
        
        // If the loop is complete, simply check if the time position is contained within the loop's bounds.
        if let end = endTime {
            return timePosn >= startTime && timePosn <= end
        }
        
        // If the loop is not complete, but the time position is greater than the start time, we can say that this loop contains
        // the time position.
        return timePosn >= startTime
    }
    
    // Compares two loop objects for equality (start time and end time).
    static func ==(lhs: PlaybackLoop, rhs: PlaybackLoop) -> Bool {
        return (lhs.startTime == rhs.startTime) && (lhs.endTime == rhs.endTime)
    }
}
