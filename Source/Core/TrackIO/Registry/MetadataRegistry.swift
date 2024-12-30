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
    
    private let registry: ConcurrentMap<URL, FileMetadata> = ConcurrentMap()
    private let opQueue: OperationQueue = .init(opCount: (Double(System.physicalCores) * 1.5).roundedInt, qos: .userInteractive)
    
    private let fileImageCache: ImageCache = ImageCache(baseDir: FilesAndPaths.metadataDir.appendingPathComponent("coverArt", isDirectory: true),
                                                         downscaledSize: NSMakeSize(30, 30),
                                                         persistOriginalImage: false)
    
    let initCache: Bool
    
    init(persistentState: MetadataPersistentState?) {
        
        var initCache: Bool = true
        
        if let appVersion = appPersistentState.appVersion, appVersion.contains("4.0.0-preview") {
            
            let previewVersion = appVersion.replacingOccurrences(of: "4.0.0-preview", with: "")
            if let version = Int(previewVersion) {
                
                if version < 23 {
                    initCache = false
                }
            }
        }
        
        self.initCache = initCache
        
        if initCache, let metadataPersistentState: [URL: FileMetadataPersistentState] = persistentState?.metadata {

            registry.bulkAddAndMap(map: metadataPersistentState) {(metadataState: FileMetadataPersistentState) in
                FileMetadata(persistentState: metadataState, persistentCoverArt: nil)
            }
        }
        
        fileImageCache.keyFunction = {track, coverArt in coverArt.originalImage?.imageData?.md5String}
    }
    
    func bulkAddMetadata(from tracks: [Track]) {
        
        var map: [URL: FileMetadata] = [:]
        
        for track in tracks {
            map[track.file] = track.metadata
        }
        
        registry.bulkAdd(map: map)
        persistCoverArt()
    }
    
    func initializeImageCache(fromPersistentState persistentState: MetadataPersistentState?) {
        
        guard initCache else {return}
        
        fileImageCache.initialize(fromPersistentState: persistentState?.coverArt)
        
        for (file, metadata) in registry.map {
            metadata.art = fileImageCache[file]
        }
    }
    
    func persistCoverArt() {
        fileImageCache.persistAllEntries()
    }
    
    subscript(_ track: Track) -> FileMetadata? {
        
        get {
            registry[track.file]
        }
        
        set {
            
            registry[track.file] = newValue
            
            // Don't add MusicBrainz art to the image cache.
            if let coverArt = newValue?.art, coverArt.source == .file {
                fileImageCache.addToCache(coverArt: coverArt, forTrack: track, persistNewEntry: false)
            }
        }
    }
    
    func clearRegistry() {
        
        registry.removeAll()
        fileImageCache.clearCache()
    }
    
    var persistentState: MetadataPersistentState {
        
        var map: [URL: FileMetadataPersistentState] = [:]
        
        for (file, metadata) in registry.map {
            map[file] = FileMetadataPersistentState(metadata: metadata)
        }
        
        return MetadataPersistentState(metadata: map, coverArt: fileImageCache.persistentState)
    }
}
