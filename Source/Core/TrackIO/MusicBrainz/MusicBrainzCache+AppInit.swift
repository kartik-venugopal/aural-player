//
// MusicBrainzCache+AppInit.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension MusicBrainzCache: AppInitializationComponent {
    
    var priority: DispatchQoS.QoSClass {
        .userInteractive
    }
    
    func initialize(onQueue queue: OperationQueue) {
        
        guard preferences.cachingEnabled else {
            
            self.baseDir.delete()
            return
        }
        
        self.baseDir.createDirectory()
        
        // Initialize the cache with entries that were previously persisted to disk.
        
        let state = appPersistentState.musicBrainzCache
        
        let ops = (state?.releases ?? []).map {entry in
            
            BlockOperation {
                
                guard let file = entry.file, let artist = entry.artist,
                      let title = entry.title else {return}
                
                // Ensure that the image file exists and that it contains a valid image.
                if file.exists, let coverArt = CoverArt(source: .musicBrainz, originalImageFile: file) {
                    
                    // Entry is valid, enter it into the cache.
                    
                    self.releasesCache[artist, title] = CachedCoverArtResult(art: coverArt)
                    self.onDiskReleasesCache[artist, title] = file
                }
            }
            
        } + (state?.recordings ?? []).map {entry in
            
            BlockOperation {
                
                guard let file = entry.file, let artist = entry.artist,
                      let title = entry.title else {return}
                
                // Ensure that the image file exists and that it contains a valid image.
                if file.exists, let coverArt = CoverArt(source: .musicBrainz, originalImageFile: file) {
                    
                    // Entry is valid, enter it into the cache.
                    
                    self.recordingsCache[artist, title] = CachedCoverArtResult(art: coverArt)
                    self.onDiskRecordingsCache[artist, title] = file
                }
            }
        }
        
        // Read all the cached image files concurrently and wait till all the concurrent ops are finished.
        queue.addOperations(ops, waitUntilFinished: true)
        self.cleanUpUnmappedFiles()
    }
}
