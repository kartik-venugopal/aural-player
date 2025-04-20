//
// PlayQueueTrackLoadParams.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

struct PlayQueueTrackLoadParams {
    
    let clearQueue: Bool
    let autoplayFirstAddedTrack: Bool
    let autoplayResumeSequence: Bool
    let markLoadedItemsForHistory: Bool
    
    init(clearQueue: Bool, autoplayFirstAddedTrack: Bool, autoplayResumeSequence: Bool, markLoadedItemsForHistory: Bool) {
        
        self.clearQueue = clearQueue
        self.autoplayFirstAddedTrack = autoplayFirstAddedTrack
        self.autoplayResumeSequence = autoplayResumeSequence
        self.markLoadedItemsForHistory = markLoadedItemsForHistory
    }
    
    init(autoplayFirstAddedTrack: Bool) {
        
        self.clearQueue = false
        self.autoplayFirstAddedTrack = autoplayFirstAddedTrack
        self.autoplayResumeSequence = false
        self.markLoadedItemsForHistory = true
    }
    
    init(autoplayFirstAddedTrack: Bool, markLoadedItemsForHistory: Bool) {
        
        self.clearQueue = false
        self.autoplayFirstAddedTrack = autoplayFirstAddedTrack
        self.autoplayResumeSequence = false
        self.markLoadedItemsForHistory = markLoadedItemsForHistory
    }
    
    init(autoplayResumeSequence: Bool, markLoadedItemsForHistory: Bool) {
        
        self.clearQueue = false
        self.autoplayFirstAddedTrack = false
        self.autoplayResumeSequence = autoplayResumeSequence
        self.markLoadedItemsForHistory = markLoadedItemsForHistory
    }
    
    init(clearQueue: Bool, autoplayFirstAddedTrack: Bool) {
        
        self.clearQueue = clearQueue
        self.autoplayFirstAddedTrack = autoplayFirstAddedTrack
        self.autoplayResumeSequence = false
        self.markLoadedItemsForHistory = true
    }
    
    static let defaultParams: PlayQueueTrackLoadParams = .init(clearQueue: false, autoplayFirstAddedTrack: false, autoplayResumeSequence: false, markLoadedItemsForHistory: true)
}
