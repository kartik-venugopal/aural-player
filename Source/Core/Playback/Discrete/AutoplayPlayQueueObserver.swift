//
// AutoplayPlayQueueObserver.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

class AutoplayPlayQueueObserver: PlayQueueObserver {
    
    var id: String {
        "AutoplayPlayQueueObserver"
    }
    
    private var firstBatch: Bool = false
    private var autoplayFirstAddedTrack: Bool = false
    
    func startedAddingTracks(params: PlayQueueTrackLoadParams) {
        
        NSLog("Yazhik !!! \(params.autoplayFirstAddedTrack)")
        
        autoplayFirstAddedTrack = params.autoplayFirstAddedTrack
        firstBatch = true
    }
    
    func addedTracks(at trackIndices: IndexSet, params: PlayQueueTrackLoadParams) {
        
        // TODO: Add appDelegate.filesToOpen to parms so only those tracks are played.
        // Revisit autoplay params model
        
        NSLog("AYYAPPA !!! \(autoplayFirstAddedTrack) | \(firstBatch) | \(params.autoplayFirstAddedTrack)")
        
        guard autoplayFirstAddedTrack && firstBatch else {return}
        firstBatch = false
        
        if playQueue.shuffleMode == .off {

            if let firstIndex = trackIndices.first {
                player.play(trackAtIndex: firstIndex)
            }

        } else if let randomFirstIndex = trackIndices.randomElement() {
            player.play(trackAtIndex: randomFirstIndex)
        }
    }
    
    func doneAddingTracks(urls: [URL], params: PlayQueueTrackLoadParams) {

        autoplayFirstAddedTrack = false
        firstBatch = false
    }
}
