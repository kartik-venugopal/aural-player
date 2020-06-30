import Foundation

class PlaybackProfiles: TrackKeyedMap<PlaybackProfile> {}

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
    
    static func deserialize(_ map: NSDictionary) -> PlaybackProfile? {
        
        var profileFile: URL?
        var profileLastPosition: Double = AppDefaults.lastTrackPosition
        
        if let file = map["file"] as? String {
            profileFile = URL(fileURLWithPath: file)
            profileLastPosition = mapNumeric(map, "lastPosition", AppDefaults.lastTrackPosition)
            return PlaybackProfile(profileFile!, profileLastPosition)
        }
        
        return nil
    }
}
