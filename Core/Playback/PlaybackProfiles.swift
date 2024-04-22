//
//  PlaybackProfiles.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    
    init(persistentState: [PlaybackProfilePersistentState]?) {
        
        super.init()
        
        for profile in persistentState ?? [] {
            
            guard let url = profile.file, let lastPosition = profile.lastPosition else {continue}
            
            self[url] = PlaybackProfile(url, lastPosition)
        }
    }
    
    init(_ profiles: [PlaybackProfile]) {
        
        super.init()
        
        for profile in profiles {
            self[profile.file] = profile
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
