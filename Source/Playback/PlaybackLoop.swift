import Foundation

// A->B track segment playback loop defined on a particular track (the currently playing track)
struct PlaybackLoop: Equatable {
    
    // Starting point for the playback loop, expressed in seconds relative to the start of a track
    var startTime: Double
    
    // End point for the playback loop, expressed in seconds relative to the start of a track
    var endTime: Double? {
        
        didSet {
            correctTimesIfNecessary()
        }
    }
    
    init(_ startTime: Double) {
        self.startTime = startTime
    }
    
    init(_ startTime: Double, _ endTime: Double) {
        
        self.startTime = startTime
        self.endTime = endTime
        
        correctTimesIfNecessary()
    }
    
    // Determines if this loop is complete (i.e. both start time and end time are defined)
    var isComplete: Bool {
        return endTime != nil
    }
    
    // Calculates the duration of this loop (if end time is defined)
    var duration: Double {
        
        if let theEndTime = endTime {
            return theEndTime - startTime
        }
        
        return 0
    }
    
    private mutating func correctTimesIfNecessary() {
        
        // Because of floating-point precision, this may be necessary.
        if let theEndTime = endTime, startTime > theEndTime {
            self.startTime = theEndTime
        }
    }
    
    // Determines whether or not this loop contains a given time position.
    func containsPosition(_ timePosn: Double) -> Bool {
        
        // If the loop is complete, simply check if the time position is contained within the loop's bounds.
        if let theEndTime = endTime {
            return timePosn >= startTime && timePosn <= theEndTime
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
