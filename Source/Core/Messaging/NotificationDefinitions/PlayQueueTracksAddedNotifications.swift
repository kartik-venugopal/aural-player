//
//  PlayQueueTracksAddedNotifications.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class TracksAddedNotification: NotificationPayload {

    let notificationName: Notification.Name
    
    // The indices of the newly added tracks
    let trackIndices: IndexSet
    
    fileprivate init(notificationName: Notification.Name, trackIndices: IndexSet) {
        
        self.notificationName = notificationName
        self.trackIndices = trackIndices
    }
}

class TracksRemovedNotification: NotificationPayload {

    let notificationName: Notification.Name
    
    // The indices of the newly added tracks
    let trackIndices: IndexSet
    
    init(notificationName: Notification.Name, trackIndices: IndexSet) {
        
        self.notificationName = notificationName
        self.trackIndices = trackIndices
    }
}

class PlayQueueTracksAddedNotification: TracksAddedNotification {
    
    init(trackIndices: IndexSet) {
        super.init(notificationName: .PlayQueue.tracksAdded, trackIndices: trackIndices)
    }
}

//class LibraryTracksAddedNotification: TracksAddedNotification {
//    
//    init(trackIndices: IndexSet) {
//        super.init(notificationName: .Library.tracksAdded, trackIndices: trackIndices)
//    }
//}
//
//class LibraryTracksRemovedNotification: TracksAddedNotification {
//    
//    init(trackIndices: IndexSet) {
//        super.init(notificationName: .Library.tracksRemoved, trackIndices: trackIndices)
//    }
//}

//class PlaylistTracksAddedNotification: TracksAddedNotification {
//    
//    let playlistName: String
//    
//    init(playlistName: String, trackIndices: IndexSet) {
//        
//        self.playlistName = playlistName
//        super.init(notificationName: .playlist_tracksAdded, trackIndices: trackIndices)
//    }
//}
