import Foundation

class ApplyPlaybackProfileAction: PlaybackChainAction {
    
    private let profiles: PlaybackProfiles
    private let preferences: PlaybackPreferences
    
    init(_ profiles: PlaybackProfiles, _ preferences: PlaybackPreferences) {
        
        self.profiles = profiles
        self.preferences = preferences
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        if let newTrack = context.requestedTrack {
            
            let params = context.requestParams
            
            // Check for an existing playback profile for the requested track
            if preferences.rememberLastPosition, let profile = profiles.get(newTrack), params.startPosition == nil {
                
                // Apply playback profile for new track
                // Validate the playback profile before applying it
                params.startPosition = (profile.lastPosition >= newTrack.duration ? 0 : profile.lastPosition)
            }
        }
        
        chain.proceed(context)
    }
}
