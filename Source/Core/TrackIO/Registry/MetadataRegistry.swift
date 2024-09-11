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
    
    private let imageCache: ImageCache<URL> = ImageCache(baseDir: FilesAndPaths.metadataDir.appendingPathComponent("coverArt", isDirectory: true),
                                                         downscaledSize: NSMakeSize(30, 30),
                                                         persistOriginalImage: false)
    
    init(persistentState: MetadataPersistentState?) {
        
        for (file, state) in persistentState?.metadata ?? [:] {
            registry[file] = PrimaryMetadata(persistentState: state, persistentCoverArt: nil)
        }
    }
    
    func initializeImageCache(fromPersistentState persistentState: MetadataPersistentState?) {
        
        imageCache.initialize(fromPersistentState: persistentState?.coverArt)
        
        for (file, metadata) in registry.map {
            metadata.art = imageCache[file]
        }
    }
    
    func persistCoverArt() {
        imageCache.persist()
    }
    
    subscript(_ key: URL) -> PrimaryMetadata? {
        
        get {
            registry[key]
        }
        
        set {
            registry[key] = newValue
        }
    }
    
    func clearRegistry() {
        registry.removeAll()
    }
    
    var persistentState: MetadataPersistentState {
        
        var map: [URL: PrimaryMetadataPersistentState] = [:]
        
        for (file, metadata) in registry.map {
            map[file] = PrimaryMetadataPersistentState(metadata: metadata, coverArtMD5: imageCache.md5(forKey: file))
        }
        
        return MetadataPersistentState(metadata: map, coverArt: imageCache.persistentState)
    }
}
