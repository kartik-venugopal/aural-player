//
//  TrackNotPlayedNotification.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Signifies that an error was encountered while attempting to play back a track.
///
struct TrackNotPlayedNotification: NotificationPayload {
 
    let notificationName: Notification.Name = .player_trackNotPlayed
    
    // The track that was playing before this error occurred (used to refresh certain UI elements, eg. playlist).
    let oldTrack: Track?
    
    // The track that could not be played.
    let errorTrack: Track
    
    // An error object containing detailed information such as the failed track's file and the root cause.
    let error: DisplayableError
}
