//
//  SortedTrackList.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

class SortedTrackList: TrackList, SortedTrackListProtocol {
    
    var sortOrder: TrackListSort {
        
        didSet {
            maintainSortOrder()
        }
    }
    
    init(sortOrder: TrackListSort) {
        self.sortOrder = sortOrder
    }
    
    @inlinable
    @inline(__always)
    func maintainSortOrder() {
        
        _tracks.sort(by: {m1, m2 in
            sortOrder.comparator(m1.value, m2.value)
        })
    }
    
    @discardableResult override func addTracks(_ newTracks: any Sequence<Track>) -> IndexSet {
        
        let dedupedTracks = deDupeTracks(newTracks)
        guard dedupedTracks.isNonEmpty else {return .empty}
        
        doAddTracks(dedupedTracks)
        
        maintainSortOrder()
        
        return IndexSet(dedupedTracks.compactMap {_tracks.index(forKey: $0.file)})
    }
    
    @discardableResult override func insertTracks(_ newTracks: [Track], at insertionIndex: Int) -> IndexSet {
        addTracks(newTracks)
    }
    
    @discardableResult override func moveTracksUp(from indices: IndexSet) -> [TrackMoveResult] {
        []
    }
    
    @discardableResult override func moveTracksDown(from indices: IndexSet) -> [TrackMoveResult] {
        []
    }
    
    @discardableResult override func moveTracksToTop(from indices: IndexSet) -> [TrackMoveResult] {
        []
    }
    
    @discardableResult override func moveTracksToBottom(from indices: IndexSet) -> [TrackMoveResult] {
        []
    }
}
