//
//  MetadataRegistry.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class MetadataRegistry: PersistentRootObject {
    
    var filename: String {
        "metadata"
    }
    
    let registry: ConcurrentMap<URL, FileMetadata> = ConcurrentMap()
    
    let fileImageCache: ImageCache = ImageCache(baseDir: FilesAndPaths.metadataDir.appendingPathComponent("coverArt", isDirectory: true),
                                                         downscaledSize: NSMakeSize(30, 30),
                                                         persistOriginalImage: false)
    
    let initCache: Bool
    
    private lazy var messenger = Messenger(for: self)
    
    init(persistentState: MetadataPersistentState?) {
        
        // TODO: Remove this when partial is released.
        var initCache: Bool = true
        
        if let appVersion = appPersistentState.appVersion, appVersion.contains("4.0.0-preview") {
            
            let previewVersion = appVersion.replacingOccurrences(of: "4.0.0-preview", with: "")
            if let version = Int(previewVersion) {
                initCache = version >= 24
            }
        }
        
        self.initCache = initCache
        
        fileImageCache.keyFunction = {track, coverArt in coverArt.originalImage?.imageData?.md5String}
        
//        messenger.subscribe(to: .PlayQueue.doneAddingTracks, handler: persistCoverArt,
//                            filter: {preferences.metadataPreferences.cacheTrackMetadata})
        
        playQueue.registerObserver(self)
    }
    
    func bulkAddMetadata(from tracks: [Track]) {
        
        var map: [URL: FileMetadata] = [:]
        
        for track in tracks {
            map[track.file] = track.metadata
        }
        
        registry.bulkAdd(map: map)
        persistCoverArt()
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
