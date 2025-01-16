//
// MetadataRegistry+AppInit.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension MetadataRegistry: AppInitializationComponent {
    
    var priority: DispatchQoS.QoSClass {
        .userInteractive
    }
    
    func initialize(onQueue queue: OperationQueue) {
        
        guard initCache else {return}
        
        if let metadataPersistentState: [URL: FileMetadataPersistentState] = metadataPersistentState?.metadata {

            registry.bulkAddAndMap(map: metadataPersistentState) {(metadataState: FileMetadataPersistentState) in
                FileMetadata(persistentState: metadataState, persistentCoverArt: nil)
            }
        }
        
        if let coverArtState = metadataPersistentState?.coverArt {
            fileImageCache.initialize(fromPersistentState: coverArtState, onQueue: queue)
        }
        
        queue.waitUntilAllOperationsAreFinished()
        
        for (file, metadata) in registry.map {
            metadata.art = fileImageCache[file]
        }
    }
}
