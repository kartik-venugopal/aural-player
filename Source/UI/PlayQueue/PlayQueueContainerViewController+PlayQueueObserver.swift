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

extension PlayQueueContainerViewController: PlayQueueUIObserver {
    
    var id: String {
        className
    }
    
    func startedAddingTracks(params: PlayQueueTrackLoadParams, completionHandler: @escaping () -> Void) {
        
        DispatchQueue.main.async {
            
            self.doStartedAddingTracks()
            completionHandler()
        }
    }
    
    func doStartedAddingTracks() {
        progressSpinner.animate()
    }
    
    func addedTracks(_ tracks: [Track], at trackIndices: IndexSet, params: PlayQueueTrackLoadParams, completionHandler: @escaping () -> Void) {
        
        DispatchQueue.main.async {
            
            self.currentViewController.tracksAdded(at: trackIndices)
            self.updateSummary()
            
            self.nonCurrentViewControllers.forEach {
                $0.tracksAdded(at: trackIndices)
            }
            
            completionHandler()
        }
    }
    
    func doneAddingTracks(urls: [URL], params: PlayQueueTrackLoadParams, completionHandler: @escaping () -> Void) {
        
        DispatchQueue.main.async {
            
            self.progressSpinner.dismiss()
            completionHandler()
        }
    }
}
