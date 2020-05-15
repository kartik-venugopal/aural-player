import Foundation

class ApplyPlaybackProfileAction: PlaybackPreparationAction {
    
    private let profiles: PlaybackProfiles
    private let preferences: PlaybackPreferences
    
    init(_ profiles: PlaybackProfiles, _ preferences: PlaybackPreferences) {
        
        self.profiles = profiles
        self.preferences = preferences
    }
    
    func execute(_ context: PlaybackRequestContext) -> Bool {
        
        let params = context.requestParams
        
        // Check for playback profile
        if let newTrack = context.requestedTrack, params.startPosition == nil, preferences.rememberLastPosition, let profile = profiles.get(newTrack.track) {
        
            // Apply playback profile for new track
            // Validate the playback profile before applying it
            params.startPosition = (profile.lastPosition >= newTrack.track.duration ? 0 : profile.lastPosition)
        }
        
        return true
    }
}
