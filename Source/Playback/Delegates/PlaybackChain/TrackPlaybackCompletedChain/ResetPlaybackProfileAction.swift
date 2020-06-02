import Foundation

class ResetPlaybackProfileAction: PlaybackChainAction {
    
    private let profiles: PlaybackProfiles
    
    init(_ profiles: PlaybackProfiles) {
        self.profiles = profiles
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        // Reset playback profile last position to 0 (if there is a profile for the track that completed)
        if let completedTrack = context.currentTrack, let profile = profiles.get(completedTrack) {
            profile.lastPosition = 0
        }
        
        chain.proceed(context)
    }
}
