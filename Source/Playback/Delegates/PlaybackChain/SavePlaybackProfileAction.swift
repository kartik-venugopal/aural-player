import Foundation

class SavePlaybackProfileAction: PlaybackChainAction {
    
    private let profiles: PlaybackProfiles
    private let preferences: PlaybackPreferences
    
    init(_ profiles: PlaybackProfiles, _ preferences: PlaybackPreferences) {
        
        self.profiles = profiles
        self.preferences = preferences
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        let isPlayingOrPaused = context.currentState.isPlayingOrPaused
        
        // Save playback profile if needed
        // Don't do this unless the preferences require it and the lastTrack was actually playing/paused
        if preferences.rememberLastPosition && isPlayingOrPaused, let currentTrack = context.currentTrack,
            preferences.rememberLastPositionOption == .allTracks || profiles.hasFor(currentTrack) {
            
            // Update last position for current track
            let trackDuration = currentTrack.duration
            let currentSeekPosition = context.currentSeekPosition
            
            // If track finished playing the last time, reset the last position to 0
            let lastPosition = (currentSeekPosition >= trackDuration ? 0 : currentSeekPosition)
            
            profiles.add(currentTrack, PlaybackProfile(currentTrack, lastPosition))
        }
        
        chain.proceed(context)
    }
}
