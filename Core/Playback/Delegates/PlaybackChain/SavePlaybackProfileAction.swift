//
//  SavePlaybackProfileAction.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Chain of responsibility action that saves a playback profile (i.e. current playback settings,
/// e.g. seek position) for a track before playback continues with another track (or stops).
///
/// This is done so that the next time this track plays, it can resume from the seek
/// position where it stopped now.
///
class SavePlaybackProfileAction: PlaybackChainAction {
    
    private let profiles: PlaybackProfiles
    private let preferences: PlaybackPreferences
    
    init(_ profiles: PlaybackProfiles, _ preferences: PlaybackPreferences) {
        
        self.profiles = profiles
        self.preferences = preferences
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        // Check if the player is currently playing/paused
        let isPlayingOrPaused = context.currentState.isPlayingOrPaused
        
        // Save playback profile if needed
        // Don't do this unless the preferences require it and the last track was actually playing/paused
        if isPlayingOrPaused, let currentTrack = context.currentTrack,
           preferences.rememberLastPositionOption.value == .allTracks || profiles.hasFor(currentTrack) {
            
            // Update last position for current track
            // If track finished playing, reset the last position to 0
            let lastPosition = (context.currentSeekPosition >= currentTrack.duration ? 0 : context.currentSeekPosition)
            
            // Save the profile
            profiles[currentTrack] = PlaybackProfile(currentTrack, lastPosition)
        }
        
        chain.proceed(context)
    }
}
