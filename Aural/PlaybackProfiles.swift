import Foundation

// TODO: Code duplication with SoundProfiles
class PlaybackProfiles {
    
    // Track file -> Profile
    private static var map: [URL: PlaybackProfile] = [:]
    
    static func saveProfile(_ track: Track, _ lastPosition: Double) {
        saveProfile(track.file, lastPosition)
    }
    
    static func saveProfile(_ file: URL, _ lastPosition: Double) {
        
        let profile = PlaybackProfile(file)
        profile.lastPosition = lastPosition
        map[file] = profile
    }
    
    static func deleteProfile(_ track: Track) {
        map[track.file] = nil
    }
    
    static func profileForTrack(_ track: Track) -> PlaybackProfile? {
        return map[track.file]
    }
    
    static func removeAll() {
        map.removeAll()
    }
    
    static func getPersistentState() -> PlaybackProfilesState {

        let state = PlaybackProfilesState()
        state.profiles.append(contentsOf: map.values)

        return state
    }
}

class PlaybackProfile {
    
    let file: URL
    
    // Last playback position
    var lastPosition: Double = 0
    
    // TODO: Seek length ? Long for audiobooks, short for tracks
    init(_ file: URL) {
        self.file = file
    }
}
