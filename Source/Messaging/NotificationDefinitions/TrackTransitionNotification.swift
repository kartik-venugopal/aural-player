//
//  TrackTransitionNotification.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Signifies that a track transition has occurred, i.e. either the playback state, the current
/// track, or both, have changed. eg. when changing tracks or when a playing track is stopped.
///
/// Contains information required for UI elements to update themselves to reflect the new state.
///
struct TrackTransitionNotification: NotificationPayload {

    let notificationName: Notification.Name = .player_trackTransitioned
    
    // The track that was playing before the transition (may be nil, meaning no track was playing)
    let beginTrack: Track?
    
    // Playback state before the track transition
    let beginState: PlaybackState
    
    // The track that is now current, after the transition (may be nil, meaning that playback was stopped)
    let endTrack: Track?
    
    // Playback state before the track transition
    let endState: PlaybackState
    
    // Whether or not the current track has changed as a result of this transition.
    var trackChanged: Bool {
        beginTrack != endTrack
    }
    
    // Whether or not playback has started as a result of this transition.
    var playbackStarted: Bool {
        endState == .playing
    }
    
    // Whether or not the playback state has changed as a result of this transition.
    var stateChanged: Bool {
        beginState != endState
    }
}
