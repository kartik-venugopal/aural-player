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
    
    var observerPriority: Int {0}
    
    private var autoplayFirstAddedTrack: Bool = false
    
    func startedAddingTracks(params: PlayQueueTrackLoadParams) {
        autoplayFirstAddedTrack = params.autoplayFirstAddedTrack
    }
    
    func addedTracks(_ tracks: [Track], at trackIndices: IndexSet, params: PlayQueueTrackLoadParams) {
        
        // TODO: [?] Case when "Open with"
        
        guard autoplayFirstAddedTrack else {return}
        
        if playQueue.shuffleMode == .off {
            
            if let autoplayCandidates = params.autoplayCandidates {
                
                for candidate in autoplayCandidates {
                    
                    if let track = playQueue.findTrack(forFile: candidate) {
                        
                        player.play(track: track)
                        autoplayFirstAddedTrack = false
                        return
                    }
                }
                
            } else if let firstIndex = trackIndices.first {
                
                player.play(trackAtIndex: firstIndex)
                autoplayFirstAddedTrack = false
                return
            }

        } else if let autoplayCandidates = params.autoplayCandidates {      // Shuffle ON
            
            var addedURLs: Set<URL> = Set()
            tracks.forEach {addedURLs.insert($0.file)}
            
            let intersection = addedURLs.intersection(autoplayCandidates)
            
            if intersection.isNonEmpty, let randomURL = intersection.randomElement(), let track = playQueue.findTrack(forFile: randomURL) {
                
                player.play(track: track)
                autoplayFirstAddedTrack = false
                return
            }
            
        } else if let randomFirstIndex = trackIndices.randomElement() {     // Shuffle ON
            
            player.play(trackAtIndex: randomFirstIndex)
            autoplayFirstAddedTrack = false
            return
        }
    }
    
    func doneAddingTracks(urls: [URL], params: PlayQueueTrackLoadParams) {
        autoplayFirstAddedTrack = false
    }
}
