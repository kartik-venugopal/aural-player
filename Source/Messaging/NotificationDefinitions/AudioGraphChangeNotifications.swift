//
//  AudioGraphChangeNotifications.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

class AudioGraphChangeContext {
    
    var playbackSession: PlaybackSession?
    
    // The player node's seek position captured before the audio graph change.
    // This can be used by notification subscribers when responding to the change.
    var seekPosition: Double?
    
    var isPlaying: Bool = true
}

struct AudioGraphChangedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .audioGraph_graphChanged
    
    let context: AudioGraphChangeContext
}

struct PreAudioGraphChangeNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .audioGraph_preGraphChange

    let context: AudioGraphChangeContext
}
