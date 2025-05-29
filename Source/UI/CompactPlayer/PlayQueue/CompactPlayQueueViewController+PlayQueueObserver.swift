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

extension CompactPlayQueueViewController {
    
    override func doStartedAddingTracks() {
        
        DispatchQueue.main.async {
            self.progressSpinner.animate()
        }
    }
    
    override func doAddedTracks(at trackIndices: IndexSet) {
        
        DispatchQueue.main.async {
            
            self.tracksAdded(at: trackIndices)
            self.updateSummary()
        }
    }
    
    override func doDoneAddingTracks() {
        
        DispatchQueue.main.async {
            self.progressSpinner.dismiss()
        }
    }
}
