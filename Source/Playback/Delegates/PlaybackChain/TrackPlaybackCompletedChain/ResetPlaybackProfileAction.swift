import Foundation

class ResetPlaybackProfileAction: PlaybackChainAction {
    
    private let profiles: PlaybackProfiles
    
    var nextAction: PlaybackChainAction?
    
    init(_ profiles: PlaybackProfiles) {
        self.profiles = profiles
    }
    
    func execute(_ context: PlaybackRequestContext) {
        
        guard let completedTrack = context.currentTrack else {return}
        
        // Reset playback profile last position to 0 (if there is a profile for the track that completed)
        if let profile = profiles.get(completedTrack) {
            profile.lastPosition = 0
        }
        
        nextAction?.execute(context)
    }
}
