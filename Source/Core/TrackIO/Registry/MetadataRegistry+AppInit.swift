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
        
        queue.addOperation {
            
            if let metadataPersistentState: [URL: FileMetadataPersistentState] = metadataPersistentState?.metadata {

                self.registry.bulkAddAndMap(map: metadataPersistentState) {(metadataState: FileMetadataPersistentState) in
                    FileMetadata(persistentState: metadataState, persistentCoverArt: nil)
                }
            }
            
            if let coverArtState = metadataPersistentState?.coverArt {
                self.fileImageCache.initialize(fromPersistentState: coverArtState, onQueue: queue)
            }
            
            for (file, metadata) in self.registry.map {
                metadata.art = self.fileImageCache[file]
            }
        }
    }
}
