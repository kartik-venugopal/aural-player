//
//  PlaybackProfiles.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A mapped collection of playback profiles.
///
/// - SeeAlso: `PlaybackProfile`
///
class PlaybackProfiles: TrackKeyedMap<PlaybackProfile> {
    
    private let player: PlayerProtocol
    private let playQueue: PlayQueueProtocol
    private let preferences: PlaybackPreferences
    
    init(player: PlayerProtocol, playQueue: PlayQueueProtocol,
         preferences: PlaybackPreferences, persistentState: [PlaybackProfilePersistentState]?) {
        
        self.player = player
        self.playQueue = playQueue
        self.preferences = preferences
        
        super.init()
        
        for profile in persistentState ?? [] {
            
            guard let url = profile.file, let lastPosition = profile.lastPosition else {continue}
            
            self[url] = PlaybackProfile(url, lastPosition)
        }
    }
    
    init(player: PlayerProtocol, playQueue: PlayQueueProtocol,
         preferences: PlaybackPreferences, _ profiles: [PlaybackProfile]) {
        
        self.player = player
        self.playQueue = playQueue
        self.preferences = preferences
        
        super.init()
        
        for profile in profiles {
            self[profile.file] = profile
        }
    }
    
    func savePlaybackProfileForPlayingTrack() {
        
        if let track = playQueue.currentTrack {
            self[track] = PlaybackProfile(track, player.seekPosition.timeElapsed)
        }
    }
    
    func deletePlaybackProfileForPlayingTrack() {
        
        if let track = playQueue.currentTrack {
            self.removeFor(track)
        }
    }
    
    func savePlaybackProfileIfNeeded(for track: Track, _ position: Double? = nil) {
        
        // Save playback settings if the option either requires saving settings for all tracks, or if
        // the option has been set for this particular playing track.
        if preferences.rememberLastPositionForAllTracks || self.hasFor(track) {
            
            // Remember the current playback settings the next time this track plays.
            // Update the profile with the latest settings for this track.
            
            // If a specific position has been specified, use it. Otherwise, use the current seek position.
            // NOTE - If the seek position has reached the end of the track, the profile position will be reset to 0.
            let seekPosition = player.seekPosition
            let lastPosition = position ?? (seekPosition.timeElapsed >= track.duration ? 0 : seekPosition.timeElapsed)
            self[track] = PlaybackProfile(track, lastPosition)
        }
    }
    
    func onAppExit() {
        
        if let track = playQueue.currentTrack {
            savePlaybackProfileIfNeeded(for: track)
        }
    }
}

///
/// A playback profile is an encapsulation of all playback settings for a particular track,
/// that is captured and saved for the purpose of restoring those settings when that
/// track is played again at a later time.
///
/// By capturing a playback profile, and mapping it to a track, the app can "remember"
/// playback settings on a per-track basis.
///
/// For example, if the user is listening to a lengthy audiobook and saves a playback
/// profile for the track and then exits the app ... when the user plays that audiobook again,
/// it will resume playing from the last playback position, so the user can continue
/// listening to it without having to remember the last playback position.
///
class PlaybackProfile {
    
    let file: URL
    
    // Last playback position
    var lastPosition: Double = 0
    
    init(_ file: URL, _ lastPosition: Double) {
        
        self.file = file
        self.lastPosition = lastPosition
    }
    
    init(_ track: Track, _ lastPosition: Double) {
        
        self.file = track.file
        self.lastPosition = lastPosition
    }
}
