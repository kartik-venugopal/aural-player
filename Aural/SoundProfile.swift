import Foundation

class SoundProfiles {
    
    // Track file -> Profile
    private static var map: [URL: SoundProfile] = [:]
    
    static func saveProfile(_ track: Track, _ volume: Float, _ balance: Float, _ effects: MasterPreset) {
        map[track.file] = SoundProfile(file: track.file, volume: volume, balance: balance, effects: effects)
    }
    
    static func saveProfile(_ file: URL, _ volume: Float, _ balance: Float, _ effects: MasterPreset) {
        map[file] = SoundProfile(file: file, volume: volume, balance: balance, effects: effects)
    }
    
    static func deleteProfile(_ track: Track) {
        map[track.file] = nil
    }
    
    static func profileForTrack(_ track: Track) -> SoundProfile? {
        return map[track.file]
    }
    
    static func getPersistentState() -> SoundProfilesState {
        
        let state = SoundProfilesState()
        state.profiles.append(contentsOf: map.values)
        
        return state
    }
}

struct SoundProfile {
    
    let file: URL
    
    let volume: Float
    let balance: Float
    
    let effects: MasterPreset
}
