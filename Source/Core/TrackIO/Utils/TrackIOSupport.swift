//
//  TrackIOSupport.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import OrderedCollections

class TrackLoadSession {
    
    private let loader: TrackListFileSystemLoadingProtocol
    let urls: [URL]
    private(set) var tracks: OrderedDictionary<URL, TrackRead> = OrderedDictionary()
    private(set) var insertionIndex: Int?
    
    private let queue: OperationQueue
    private let batchSize: Int
    
    // Progress
    private(set) var errors: [DisplayableError] = []
    
    var playQueuePersistentState: PlayQueuePersistentState?
    
    init(forLoader loader: TrackListFileSystemLoadingProtocol, withPriority priority: DispatchQoS.QoSClass, urls: [URL], insertionIndex: Int?) {
        
        self.loader = loader
        self.urls = urls
        self.insertionIndex = insertionIndex
        
        switch priority {
            
        case .userInitiated, .userInteractive:
            self.queue = TrackReader.highPriorityQueue
            
        case .utility:
            self.queue = TrackReader.mediumPriorityQueue
            
        case .background:
            self.queue = TrackReader.lowPriorityQueue
            
        default:
            self.queue = TrackReader.mediumPriorityQueue
        }
        
        self.batchSize = self.queue.maxConcurrentOperationCount
        
        self.playQueuePersistentState = appPersistentState.playQueue
        
        loader.preTrackLoad()
    }
    
    var trackListIndices: ClosedRange<Int> {
        
        if let startIndex = insertionIndex {
            return startIndex...(startIndex + tracks.count - 1)
        }
        
        return 0...(tracks.count - 1)
    }
    
    var tracksCount: Int {tracks.count}
    
    func readTrack(forFile file: URL, withCueSheetMetadata metadata: CueSheetMetadata? = nil) {
        
        guard tracks[file] == nil else {return}
        
        var result: TrackReadResult = .addedToTrackList
        let trackInList: Track? = loader.findTrack(forFile: file)
        
        // TODO: Only read Cue Sheet Metadata for the PQ, not the Library or other TrackLists
        
        var trackFind: (track: Track, trackCreated: Bool)! = nil
        
        if trackInList == nil {
            
            trackFind = trackReader.findOrCreateTrack(at: file, withCueSheetMetadata: metadata ?? playQueuePersistentState?.cueSheetMetadata(forFile: file))
            
            if !trackFind.trackCreated {
                result = .existsInTrackRegistry
            }
            
        } else {
            result = .existsInTrackList
        }
        
        let track = trackInList ?? trackFind.track
        let trackRead: TrackRead = TrackRead(track: track, result: result)
        
        tracks[trackRead.track.file] = trackRead
        
        if tracks.count == batchSize {
            processBatch()
        }
    }
    
    func processBatch() {
        
        let tracksToRead = tracks.values.filter {$0.result != .existsInTrackList}.map {$0.track}
        
        for track in tracksToRead {
            trackReader.loadMetadataAsync(for: track, onQueue: queue)
        }
        
        queue.waitUntilAllOperationsAreFinished()
        markBatchReadErrors()
        
        let newTrackIndices = loader.acceptBatch(fromSession: self)
        loader.postBatchLoad(indices: newTrackIndices)
        
        clearBatch(numTracksAdded: newTrackIndices.count)
    }
    
    func addError(_ error: DisplayableError) {
        errors.append(error)
    }
    
    private func markBatchReadErrors() {
        
        for trackRead in self.tracks.values {
            
            if trackRead.track.metadata.validationError != nil {
                trackRead.result = .error
            }
        }
    }
    
    func clearBatch(numTracksAdded: Int) {
        
        if let index = self.insertionIndex {
            self.insertionIndex = index + numTracksAdded
        }
        
        tracks.removeAll()
    }
    
    func allTracksRead() {
        
        if !tracks.isEmpty {
            processBatch()
        }
        
        loader.postTrackLoad()
    }
}

class TrackRead {
    
    let track: Track
    var result: TrackReadResult
    
    init(track: Track, result: TrackReadResult) {
        
        self.track = track
        self.result = result
    }
}

enum TrackReadResult {
    
    case existsInTrackList, existsInTrackRegistry, addedToTrackList, error
}
