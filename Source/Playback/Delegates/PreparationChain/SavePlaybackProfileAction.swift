import Foundation

class SavePlaybackProfileAction: PlaybackChainAction {
    
    var nextAction: PlaybackChainAction?
    
    private let profiles: PlaybackProfiles
    private let preferences: PlaybackPreferences
    
    init(_ profiles: PlaybackProfiles, _ preferences: PlaybackPreferences) {
        
        self.profiles = profiles
        self.preferences = preferences
    }
    
    func execute(_ context: PlaybackRequestContext) {
        
        let isPlayingOrPaused = context.currentState.isPlayingOrPaused
        let curTrack = context.currentTrack
        let curPosn = context.currentSeekPosition
        
        // Save playback profile if needed
        // Don't do this unless the preferences require it and the lastTrack was actually playing/paused
        if preferences.rememberLastPosition && isPlayingOrPaused, let actualTrack = curTrack?.track,
            preferences.rememberLastPositionOption == .allTracks || profiles.hasFor(actualTrack) {
            
            // Update last position for current track
            let trackDuration = actualTrack.duration
            
            // If track finished playing the last time, reset the last position to 0
            let lastPosn = (curPosn >= trackDuration ? 0 : curPosn)
            
            profiles.add(actualTrack, PlaybackProfile(actualTrack.file, lastPosn))
        }
        
        nextAction?.execute(context)
    }
}
