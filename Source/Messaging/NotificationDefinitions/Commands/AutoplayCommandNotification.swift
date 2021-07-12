//
//  AutoplayCommandNotification.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

// A command issued to the player to begin playback in response to tracks being added to the playlist
// (either automatically on startup, or manually by the user)
struct AutoplayCommandNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .player_autoplay
    
    // See AutoplayCommandType
    let type: AutoplayCommandType
    
    // Whether it is ok to interrupt playback (if a track is currently playing)
    // NOTE - This value is irrelevant for commands of type beginPlayback
    let interruptPlayback: Bool
    
    // The (optional) track that was chosen by the playlist as a potential candidate for playback.
    // NOTE - This value is irrelevant for commands of type beginPlayback.
    let candidateTrack: Track?
    
    init(type: AutoplayCommandType, interruptPlayback: Bool = true, candidateTrack: Track? = nil) {
        
        self.type = type
        self.interruptPlayback = interruptPlayback
        self.candidateTrack = candidateTrack
    }
}

enum AutoplayCommandType {
    
    // The player will begin a new playback sequence (assumes no track is currently playing).
    // i.e. the track to play is not known when the autoplay command is issued and is determined on demand by the sequencer.
    // This is usually done on app startup.
    case beginPlayback
    
    // The player will play a specific track.
    // This is usually done when the user adds files to the playlist.
    case playSpecificTrack
}
