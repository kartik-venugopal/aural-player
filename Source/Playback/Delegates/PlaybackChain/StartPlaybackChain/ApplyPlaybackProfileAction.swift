import Foundation

class ApplyPlaybackProfileAction: PlaybackChainAction {
    
    private let profiles: PlaybackProfiles
    private let preferences: PlaybackPreferences
    
    var nextAction: PlaybackChainAction?
    
    init(_ profiles: PlaybackProfiles, _ preferences: PlaybackPreferences) {
        
        self.profiles = profiles
        self.preferences = preferences
    }
    
    func execute(_ context: PlaybackRequestContext) {
        
        guard let newTrack = context.requestedTrack else {return}
        
        let params = context.requestParams
        
        // Check for playback profile
        if params.startPosition == nil, preferences.rememberLastPosition, let profile = profiles.get(newTrack) {
        
            // Apply playback profile for new track
            // Validate the playback profile before applying it
            params.startPosition = (profile.lastPosition >= newTrack.duration ? 0 : profile.lastPosition)
        }
        
        nextAction?.execute(context)
    }
}
