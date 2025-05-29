//
// PlayQueueViewController+PlayQueueObserver.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

extension PlayQueueViewController: PlayQueueObserver {
    
    var id: String {
        className
    }
    
    func startedAddingTracks(params: PlayQueueTrackLoadParams) {
        doStartedAddingTracks()
    }
    
    @objc func doStartedAddingTracks() {}
    
    func addedTracks(at trackIndices: IndexSet, params: PlayQueueTrackLoadParams) {
        doAddedTracks(at: trackIndices)
    }
    
    @objc func doAddedTracks(at trackIndices: IndexSet) {
        
        DispatchQueue.main.async {
            self.tracksAdded(at: trackIndices)
        }
    }
    
    func doneAddingTracks(urls: [URL], params: PlayQueueTrackLoadParams) {
        doDoneAddingTracks()
    }
    
    @objc func doDoneAddingTracks() {}
}
