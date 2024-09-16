//
//  MetadataRegistry.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class MetadataRegistry: PersistentRootObject {
    
    var filename: String {
        "metadata"
    }
    
    private let registry: ConcurrentMap<URL, PrimaryMetadata> = ConcurrentMap()
    private let opQueue: OperationQueue = .init(opCount: (Double(System.physicalCores) * 1.5).roundedInt, qos: .userInteractive)
    
    private let fileImageCache: ImageCache = ImageCache(baseDir: FilesAndPaths.metadataDir.appendingPathComponent("coverArt", isDirectory: true),
                                                         downscaledSize: NSMakeSize(30, 30),
                                                         persistOriginalImage: false)
    
    init(persistentState: MetadataPersistentState?) {
        
        if let metadataPersistentState: [URL: PrimaryMetadataPersistentState] = persistentState?.metadata {
            
            registry.bulkAddAndMap(map: metadataPersistentState) {(metadataState: PrimaryMetadataPersistentState) in
                PrimaryMetadata(persistentState: metadataState, persistentCoverArt: nil)
            }
        }
        
        fileImageCache.keyFunction = {track, coverArt in coverArt.originalImage?.imageData?.md5String}
    }
    
    func initializeImageCache(fromPersistentState persistentState: MetadataPersistentState?) {
        
        fileImageCache.initialize(fromPersistentState: persistentState?.coverArt)
        
        for (file, metadata) in registry.map {
            metadata.art = fileImageCache[file]
        }
        
        print("Image cache now has: \(fileImageCache.imageCount) images for \(fileImageCache.keysCount) files")
    }
    
    func persistCoverArt() {
        fileImageCache.persistAllEntries()
    }
    
    subscript(_ track: Track) -> PrimaryMetadata? {
        
        get {
            registry[track.file]
        }
        
        set {
            
            registry[track.file] = newValue
            
            if let coverArt = newValue?.art {
                fileImageCache.addToCache(coverArt: coverArt, forTrack: track, persistNewEntry: false)
            }
        }
    }
    
    func clearRegistry() {
        registry.removeAll()
    }
    
    var persistentState: MetadataPersistentState {
        
        var map: [URL: PrimaryMetadataPersistentState] = [:]
        
        for (file, metadata) in registry.map {
            map[file] = PrimaryMetadataPersistentState(metadata: metadata)
        }
        
        return MetadataPersistentState(metadata: map, coverArt: fileImageCache.persistentState)
    }
}
