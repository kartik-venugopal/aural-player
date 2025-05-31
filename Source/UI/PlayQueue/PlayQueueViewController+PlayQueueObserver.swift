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

extension PlayQueueViewController {
    
    @objc func doStartedAddingTracks() {}
    
    @objc func doAddedTracks(at trackIndices: IndexSet) {
        tracksAdded(at: trackIndices)
    }
    
    @objc func doDoneAddingTracks() {}
}
