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
    
    let autoplayCandidates: [URL]?
    
    init(clearQueue: Bool, autoplayFirstAddedTrack: Bool, autoplayResumeSequence: Bool, markLoadedItemsForHistory: Bool, autoplayCandidates: [URL]? = nil) {
        
        self.clearQueue = clearQueue
        self.autoplayFirstAddedTrack = autoplayFirstAddedTrack
        self.autoplayResumeSequence = autoplayResumeSequence
        self.markLoadedItemsForHistory = markLoadedItemsForHistory
        self.autoplayCandidates = autoplayCandidates
    }
    
    init(autoplayFirstAddedTrack: Bool, autoplayCandidates: [URL]? = nil) {
        
        self.clearQueue = false
        self.autoplayFirstAddedTrack = autoplayFirstAddedTrack
        self.autoplayResumeSequence = false
        self.markLoadedItemsForHistory = true
        self.autoplayCandidates = autoplayCandidates
    }
    
    init(autoplayFirstAddedTrack: Bool, markLoadedItemsForHistory: Bool, autoplayCandidates: [URL]? = nil) {
        
        self.clearQueue = false
        self.autoplayFirstAddedTrack = autoplayFirstAddedTrack
        self.autoplayResumeSequence = false
        self.markLoadedItemsForHistory = markLoadedItemsForHistory
        self.autoplayCandidates = autoplayCandidates
    }
    
    init(autoplayResumeSequence: Bool, markLoadedItemsForHistory: Bool) {
        
        self.clearQueue = false
        self.autoplayFirstAddedTrack = false
        self.autoplayResumeSequence = autoplayResumeSequence
        self.markLoadedItemsForHistory = markLoadedItemsForHistory
        self.autoplayCandidates = nil
    }
    
    init(clearQueue: Bool, autoplayFirstAddedTrack: Bool, autoplayCandidates: [URL]? = nil) {
        
        self.clearQueue = clearQueue
        self.autoplayFirstAddedTrack = autoplayFirstAddedTrack
        self.autoplayResumeSequence = false
        self.markLoadedItemsForHistory = true
        self.autoplayCandidates = autoplayCandidates
    }
    
    static let defaultParams: PlayQueueTrackLoadParams = .init(clearQueue: false, autoplayFirstAddedTrack: false, autoplayResumeSequence: false, markLoadedItemsForHistory: true, autoplayCandidates: nil)
}
