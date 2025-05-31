//
// MetadataRegistry+PlayQueueObserver.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension MetadataRegistry: PlayQueueObserver {
    
    var id: String {
        "MetadataRegistry"
    }
    
    var observerPriority: Int {2}
    
    func startedAddingTracks(params: PlayQueueTrackLoadParams) {}
    
    func addedTracks(_ tracks: [Track], at trackIndices: IndexSet, params: PlayQueueTrackLoadParams) {}
    
    func doneAddingTracks(urls: [URL], params: PlayQueueTrackLoadParams) {
        
        if preferences.metadataPreferences.cacheTrackMetadata {
            persistCoverArt()
        }
    }
}
