//
//  TrackPlaybackCommandNotification.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// A command to initiate playback for a particular track / group.
///
struct TrackPlaybackCommandNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .player_playTrack
    
    // Type indicates whether the request parameter is an index, track, or group.
    // This is used to initialize the new playback sequence.
    let type: PlaybackCommandType
    
    // Only one of these 3 fields will be non-nil, depending on the command type
    var index: Int? = nil
    var track: Track? = nil
    var group: Group? = nil
    
    // Initialize the request with a track index. This will be done from the Tracks playlist.
    init(index: Int) {
        
        self.index = index
        self.type = .index
    }
    
    // Initialize the request with a track. This will be done from a grouping/hierarchical playlist.
    init(track: Track) {
        
        self.track = track
        self.type = .track
    }
    
    // Initialize the request with a group. This will be done from a grouping/hierarchical playlist.
    init(group: Group) {
        
        self.group = group
        self.type = .group
    }
}

// Enumerates all the possible playback command types. See PlaybackCommandNotification.
enum PlaybackCommandType {
    
    // Play the track with the given index
    case index
    
    // Play the given track
    case track
    
    // Play the given group
    case group
}
