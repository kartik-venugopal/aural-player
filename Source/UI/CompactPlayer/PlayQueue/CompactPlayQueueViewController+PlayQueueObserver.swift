//
// CompactPlayQueueViewController+PlayQueueObserver.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

extension CompactPlayQueueViewController: PlayQueueUIObserver {
    
    var id: String {
        className
    }
    
    func startedAddingTracks(params: PlayQueueTrackLoadParams, completionHandler: @escaping () -> Void) {
        
        DispatchQueue.main.async {
            self.progressSpinner.animate()
        }
    }
    
    func addedTracks(_ tracks: [Track], at trackIndices: IndexSet, params: PlayQueueTrackLoadParams, completionHandler: @escaping () -> Void) {
        
        DispatchQueue.main.async {
            
            self.tracksAdded(at: trackIndices)
            self.updateSummary()
        }
    }
    
    func doneAddingTracks(urls: [URL], params: PlayQueueTrackLoadParams, completionHandler: @escaping () -> Void) {
        
        DispatchQueue.main.async {
            self.progressSpinner.dismiss()
        }
    }
}
