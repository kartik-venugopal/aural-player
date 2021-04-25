import Foundation

class PlaybackProfiles: TrackKeyedMap<PlaybackProfile> {
    
    init(persistentState: [PlaybackProfilePersistentState]) {
        
        super.init()
        
        for profile in persistentState {
            self.add(profile.file, PlaybackProfile(profile.file, profile.lastPosition))
        }
    }
    
    init(_ profiles: [PlaybackProfile]) {
        
        super.init()
        
        for profile in profiles {
            self.add(profile.file, profile)
        }
    }
}

class PlaybackProfile {
    
    let file: URL
    
    // Last playback position
    var lastPosition: Double = 0
    
    init(_ file: URL, _ lastPosition: Double) {
        
        self.file = file
        self.lastPosition = lastPosition
    }
    
    init(_ track: Track, _ lastPosition: Double) {
        
        self.file = track.file
        self.lastPosition = lastPosition
    }
}
