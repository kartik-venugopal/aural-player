//
//  SequencerNotifications.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

extension Notification.Name {
    
    // MARK: Notifications published by the sequencer.
    
    // Signifies that the currently playing track has been removed from the playlist, suggesting
    // that playback should stop.
    static let sequencer_playingTrackRemoved = Notification.Name("sequencer_playingTrackRemoved")
}
