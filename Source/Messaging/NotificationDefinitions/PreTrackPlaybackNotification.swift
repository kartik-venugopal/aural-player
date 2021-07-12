//
//  PreTrackPlaybackNotification.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

/*
    Signifies that track playback is about to occur. Gives observers a chance to perform some
    computation/processing before track playback starts (eg. saving/applying audio settings).
*/
struct PreTrackPlaybackNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .player_preTrackPlayback
    
    // The track that was playing before the track change (may be nil, meaning no track was playing)
    let oldTrack: Track?
    
    // Playback state before the track change
    let oldState: PlaybackState
    
    // The track that is now playing (may be nil, meaning no track playing)
    let newTrack: Track?
}
