//
// TrackInitializer.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

class TrackInitializer: AppInitializationComponent {
    
    private let components: [TrackInitComponent]
    
    var priority: DispatchQoS.QoSClass {
        .userInteractive
    }
    
    private let urls: Set<URL>
    private var tracks: [URL: Track] = [:]
    private var tracksForComponent: [URL: Track] = [:]
    private var batch: [Track] = []
    
    init(components: [TrackInitComponent]) {
        
        self.components = components
        self.urls = Set(components.flatMap {$0.urlsForTrackInit})
    }
    
    func initialize(onQueue queue: OperationQueue) {
        
        for component in components {
            initializeComponent(component, onQueue: queue)
        }
    }
    
    private func initializeComponent(_ component: TrackInitComponent, onQueue queue: OperationQueue) {
        
        tracksForComponent = [:]
        batch = []
        
        readURLs(component.urlsForTrackInit, onQueue: queue)
        component.initialize(withTracks: tracksForComponent)
    }
    
    private func readURLs(_ urls: [URL], onQueue queue: OperationQueue) {
        
        for url in urls {
            
            // Always resolve sym links and aliases before reading the file
            let resolvedURL = url.resolvedURL
            
            if resolvedURL.isSupportedAudioFile {
                
                // Track
                readTrack(forFile: resolvedURL, onQueue: queue)
                
            } else if resolvedURL.isDirectory {
                
                // Directory
                
                if let dirContents = resolvedURL.children {
                    readURLs(dirContents.sorted(by: {$0.lastPathComponent < $1.lastPathComponent}), onQueue: queue)
                }
                
            } else if resolvedURL.isSupportedPlaylistFile,
                      let loadedPlaylist = PlaylistIO.loadPlaylist(fromFile: resolvedURL) {
                
                // Playlist
                
                loadedPlaylist.tracks.forEach {
                    readTrack(forFile: $0.file, withCueSheetMetadata: $0.cueSheetMetadata, onQueue: queue)
                }
            }
        }
    }
    
    private func readTrack(forFile file: URL, withCueSheetMetadata metadata: CueSheetMetadata? = nil, onQueue queue: OperationQueue) {
        
        if let existingTrack = tracks[file] {
            
            tracksForComponent[file] = existingTrack
            return
        }
        
        // TODO: Check TrackRegistry (via TrackReader) for the Track
        // TODO: Can TrackReader create the Track ?
        let track = Track(file, cueSheetMetadata: metadata)
        
        tracks[file] = track
        tracksForComponent[file] = track
        batch.append(track)
        
        if batch.count == queue.maxConcurrentOperationCount {
            
            for track in batch {
                trackReader.loadMetadataAsync(for: track, onQueue: queue)
            }
            
            queue.waitUntilAllOperationsAreFinished()
            batch.removeAll()
        }
    }
}

protocol TrackInitComponent {
    
    var urlsForTrackInit: [URL] {get}
    
    func preInitialize()
    
    func initialize(withTracks tracks: [URL: Track])
}

enum TrackInitPriority: Int {
    
    case trackList = 0
    case menu = 1
}
