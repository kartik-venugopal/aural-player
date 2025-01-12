//
//  TrackInfoUpdatedNotification.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Indicates that some new information has been loaded for a track (e.g. duration/display name/art, etc),
/// and that the UI should refresh itself to show the new information.
///
struct TrackInfoUpdatedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .Player.trackInfoUpdated
    
    // The track that has been updated
    let updatedTrack: Track
    
    // The track info fields that have been updated. Different UI components may display different fields.
    let updatedFields: Set<UpdatedTrackInfoField>
    
    init(updatedTrack: Track, updatedFields: UpdatedTrackInfoField...) {
        
        self.updatedTrack = updatedTrack
        self.updatedFields = Set(updatedFields)
    }
}

// An enumeration of different track info fields that can be updated
enum UpdatedTrackInfoField: CaseIterable {
    
    // Album art
    case art
    
    // Track duration
    case duration
    
    // External lyrics (LRC file or online lyrics)
    case lyrics
}
