//
//  TrackAddedNotification.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

// Indicates that a new track has been added to the playlist, and that the UI should refresh itself to show the new information.
struct TrackAddedNotification: NotificationPayload {
    
    let notificationName: Notification.Name = .playlist_trackAdded
    
    // The index of the newly added track
    let trackIndex: Int
    
    // Grouping info (parent groups) for the newly added track
    let groupingInfo: [GroupType: GroupedTrackAddResult]
    
    // The current progress of the track add operation (See TrackAddOperationProgress)
    let addOperationProgress: TrackAddOperationProgress
}

// Indicates current progress associated with a TrackAddedNotification.
struct TrackAddOperationProgress {
    
    // Number of tracks added so far
    let tracksAdded: Int
    
    // Total number of tracks to add
    let totalTracks: Int
    
    // Percentage of tracks added (computed)
    var percentage: Double {totalTracks > 0 ? Double(tracksAdded) * 100 / Double(totalTracks) : 0}
}
