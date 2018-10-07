import Foundation

class PlaybackProfiles {
    
    // Track file -> Profile
    private static var map: [URL: PlaybackProfile] = [:]
    
    static func saveProfile(_ track: Track, _ lastPosition: Double) {
        map[track.file] = PlaybackProfile(lastPosition: lastPosition)
    }
    
    static func saveProfile(_ file: URL, _ lastPosition: Double) {
        map[file] = PlaybackProfile(lastPosition: lastPosition)
    }
    
    static func deleteProfile(_ track: Track) {
        map[track.file] = nil
    }
    
    static func profileForTrack(_ track: Track) -> PlaybackProfile? {
        return map[track.file]
    }
    
//    static func getPersistentState() -> SoundProfilesState {
//
//        let state = SoundProfilesState()
//        state.profiles.append(contentsOf: map.values)
//
//        return state
//    }
}

struct PlaybackProfile {
    
    // Last playback position
    let lastPosition: Double
}
