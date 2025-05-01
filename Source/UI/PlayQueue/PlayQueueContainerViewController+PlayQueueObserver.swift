//
// PlayQueueContainerViewController+PlayQueueObserver.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

extension PlayQueueContainerViewController: PlayQueueObserver {
    
    var id: String {
        className
    }
    
    func startedAddingTracks(params: PlayQueueTrackLoadParams) {
        doStartedAddingTracks()
    }
    
    func doStartedAddingTracks() {
        
        DispatchQueue.main.async {
            self.progressSpinner.animate()
        }
    }
    
    func addedTracks(at trackIndices: IndexSet) {
        
        DispatchQueue.main.async {
            self.updateSummary()
        }
    }
    
    func doneAddingTracks(urls: [URL]) {
        
        DispatchQueue.main.async {
            self.progressSpinner.dismiss()
        }
    }
}
