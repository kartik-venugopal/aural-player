//
// History+PlayQueueObserver.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension History: PlayQueueObserver {
    
    var id: String {
        "History"
    }
    
    func startedAddingTracks() {}
    
    func addedTracks(at trackIndices: IndexSet) {}
    
    func doneAddingTracks(urls: [URL]) {
        
        for url in urls {
            
            if url.isSupportedAudioFile {
                
                if let track = playQueue.findTrack(forFile: url) {
                    markAddEventForTrack(track)
                }
                
            } else if url.isDirectory {
                markAddEventForFolder(url)
                
            } else if url.isSupportedPlaylistFile {
                markAddEventForPlaylistFile(url)
            }
        }
    }
}
