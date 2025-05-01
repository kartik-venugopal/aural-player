//
//  TrackList.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import OrderedCollections

class TrackList: TrackListProtocol {
    
    static let empty: TrackList = .init()
    
    /// A type representing the sequence's elements.
    typealias Element = Track
    
    /// Meant to be overriden
    var displayName: String {"Track List"}
    
    /// A map to quickly look up tracks by (absolute) file path (used when adding tracks, to prevent duplicates)
    lazy var _tracks: OrderedDictionary<URL, Track> = .init()
    lazy var tracksLock: ConcurrentQueueLock = .init(resourceName: self.displayName)
    
    var tracks: [Track] {
        
        tracksLock.read {
            Array(_tracks.values)
        }
    }

    var _isBeingModified: AtomicBool = AtomicBool(value: false)
    
    var isBeingModified: Bool {
        _isBeingModified.value
    }
    
    var trackLoadQoS: DispatchQoS.QoSClass {
        .utility
    }
    
    // Used when reading tracks from the file system.
    var session: TrackLoadSession!
    
    var size: Int {
        
        tracksLock.read {
            _tracks.count
        }
    }
    
    var indices: Range<Int> {
        
        tracksLock.read {
            _tracks.indices
        }
    }
    
    var duration: Double {
        
        tracksLock.read {
            _tracks.values.reduce(0.0, {(totalSoFar: Double, track: Track) -> Double in totalSoFar + track.duration})
        }
    }
    
    var summary: (size: Int, totalDuration: Double) {
        (size, duration)
    }
    
    var isEmpty: Bool {
        
        tracksLock.read {
            _tracks.isEmpty
        }
    }
    
    var isNonEmpty: Bool {
        !isEmpty
    }
    
    /// Safe array access.
    subscript(index: Int) -> Track? {
        
        tracksLock.read {
            
            guard index >= 0, index < _tracks.count else {return nil}
            return _tracks.elements[index].value
        }
    }
    
    subscript(indices: IndexSet) -> [Track] {

        tracksLock.read {
            indices.map {_tracks.elements[$0].value}
        }
    }
    
    func indexOfTrack(_ track: Track) -> Int?  {
        
        tracksLock.read {
            _tracks.index(forKey: track.file)
        }
    }
    
    func indexOfTrack(forFile file: URL) -> Int? {
        
        tracksLock.read {
            _tracks.index(forKey: file)
        }
    }
    
    func hasTrack(_ track: Track) -> Bool {
        
        tracksLock.read {
            _tracks[track.file] != nil
        }
    }
    
    func hasTrack(forFile file: URL) -> Bool {
        
        tracksLock.read {
            _tracks[file] != nil
        }
    }
    
    func findTrack(forFile file: URL) -> Track? {
        
        tracksLock.read {
            _tracks[file]
        }
    }

    @inlinable
    @inline(__always)
    func deDupeTracks(_ tracks: any Sequence<Track>) -> [Track] {
        tracks.filter {_tracks[$0.file] == nil}
    }
    
    @discardableResult func addTracks(_ newTracks: any Sequence<Track>) -> IndexSet {
        
        let sizeBeforeAdd = self.size
        let dedupedTracks = deDupeTracks(newTracks)
        let numTracksToAdd = dedupedTracks.count
        guard numTracksToAdd > 0 else {return .empty}
        
        let sizeAfterAdd = sizeBeforeAdd + numTracksToAdd
        self.doAddTracks(dedupedTracks)
        
        return IndexSet(sizeBeforeAdd..<sizeAfterAdd)
    }
    
    @inlinable
    @inline(__always)
    func doAddTracks(_ newTracks: any Sequence<Track>) {
        
        tracksLock.write {
            self._tracks.addMappings(newTracks.map {($0.file, $0)})
        }
    }
    
    func updateTracksIfPresent(_ tracks: any Sequence<Track>) {
        
        tracksLock.write {
            
            for track in tracks {
                
                if self._tracks[track.file] != nil {
                    self._tracks[track.file] = track
                }
            }
        }
    }
    
    @discardableResult func insertTracks(_ newTracks: [Track], at insertionIndex: Int) -> IndexSet {
        
        let dedupedTracks = deDupeTracks(newTracks)
        guard dedupedTracks.isNonEmpty else {return .empty}
        
        tracksLock.write {
            
            // Need to insert in reverse order.
            for index in stride(from: dedupedTracks.lastIndex, through: 0, by: -1) {
                
                let track = dedupedTracks[index]
                self._tracks.insertItem(track, forKey: track.file, at: insertionIndex)
            }
        }
        
        return IndexSet(insertionIndex..<(insertionIndex + dedupedTracks.count))
    }
    
    @discardableResult func moveTracksUp(from indices: IndexSet) -> [TrackMoveResult] {
        _tracks.moveItemsUp(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    @discardableResult func moveTracksDown(from indices: IndexSet) -> [TrackMoveResult] {
        _tracks.moveItemsDown(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    @discardableResult func moveTracksToTop(from indices: IndexSet) -> [TrackMoveResult] {
        _tracks.moveItemsToTop(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    @discardableResult func moveTracksToBottom(from indices: IndexSet) -> [TrackMoveResult] {
        _tracks.moveItemsToBottom(from: indices).map {TrackMoveResult($0.key, $0.value)}
    }
    
    func removeAllTracks() {
        _tracks.removeAll()
    }
    
    @discardableResult func removeTracks(_ tracksToRemove: [Track]) -> IndexSet {
        
        let indices: [Int] = tracksToRemove.compactMap {_tracks.index(forKey: $0.file)}
        
        for track in tracksToRemove {
            
            // Add a mapping by track's file path.
            _tracks.removeValue(forKey: track.file)
        }
        
        return IndexSet(indices)
    }
    
    @discardableResult func removeTracks(at indices: IndexSet) -> [Track] {
        _tracks.removeItems(at: indices)
    }
    
    func cropTracks(at indices: IndexSet) {
        cropTracks(self[indices])
    }
    
    func cropTracks(_ tracks: [Track]) {
        
        let tracksToKeep: Set<Track> = Set(tracks)
        let tracksToRemove: [Track] = _tracks.values.filter {!tracksToKeep.contains($0)}
        removeTracks(tracksToRemove)
    }
    
    @discardableResult func moveTracks(from sourceIndices: IndexSet, to dropIndex: Int) -> [TrackMoveResult] {
        _tracks.dragAndDropItems(sourceIndices, dropIndex).map {TrackMoveResult($0.key, $0.value)}
    }
    
    // TODO:
    func search(_ searchQuery: SearchQuery) -> SearchResults {
        SearchResults(scope: .all, [])
    }

    func sort(_ sort: TrackListSort) {
        
        _tracks.sort(by: {m1, m2 in
            sort.comparator(m1.value, m2.value)
        })
    }

    func sort(by comparator: (Track, Track) -> Bool) {
        
        _tracks.sort(by: {m1, m2 in
            comparator(m1.value, m2.value)
        })
    }
    
    func exportToFile(_ file: URL) {
        
        // Perform asynchronously, to unblock the main thread
        DispatchQueue.global(qos: .userInitiated).async {
            PlaylistIO.savePlaylist(tracks: self.tracks, toFile: file)
        }
    }
    
    func loadTracks(from urls: [URL], atPosition position: Int?) {
        loadTracksAsync(from: urls, atPosition: position)
    }
    
    func acceptBatch(fromSession session: TrackLoadSession) -> IndexSet {
        
        let tracks = session.tracks.values.map {$0.track}
        
        let indices: IndexSet
        
        if let insertionIndex = session.insertionIndex {
            indices = insertTracks(tracks, at: insertionIndex)
            
        } else {
            indices = addTracks(tracks)
        }
        
        return indices
    }
    
    // Dummy impls - subclasses should override!
    
    func preTrackLoad() {}
    
    func postBatchLoad(indices: IndexSet) {}
    
    func postTrackLoad() {}
}

extension IndexSet {
    
    static let empty: IndexSet = IndexSet()
}
