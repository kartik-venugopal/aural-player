//
//  TrackListProtocol.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

protocol TrackListProtocol {
    
    var displayName: String {get}
    
    // MARK: Read-only functions ------------------------------------------------------------------------
    
    var tracks: [Track] {get}
    var size: Int {get}
    var duration: Double {get}
    
    // Whether or not tracks are being added to the track list (which could be time consuming)
    var isBeingModified: Bool {get}
    
    func indexOfTrack(_ track: Track) -> Int?
    
    func hasTrack(_ track: Track) -> Bool
    
    func hasTrack(forFile file: URL) -> Bool
    
    func findTrack(forFile file: URL) -> Track?
    
    subscript(_ index: Int) -> Track? {get}
    
    subscript(indices: IndexSet) -> [Track] {get}
    
    var summary: (size: Int, totalDuration: Double) {get}
    
    func search(_ searchQuery: SearchQuery) -> SearchResults
    
    // MARK: Add and remove ------------------------------------------------------------------------
    
    func loadTracks(from urls: [URL], atPosition position: Int?)
    
    @discardableResult func addTracks(_ newTracks: any Sequence<Track>) -> IndexSet
    
    // Inserts tracks from an external source (eg. saved playlist) at a given insertion index.
    func insertTracks(_ tracks: [Track], at insertionIndex: Int) -> IndexSet
    
    func removeTracks(at indices: IndexSet) -> [Track]
    
    func cropTracks(at indices: IndexSet)
    
    func cropTracks(_ tracks: [Track])
    
    func removeAllTracks()
    
    func updateTracksIfPresent(_ tracks: any Sequence<Track>)
    
    // MARK: Reordering ------------------------------------------------------------------------

    func moveTracksUp(from indices: IndexSet) -> [TrackMoveResult]
    
    func moveTracksToTop(from indices: IndexSet) -> [TrackMoveResult]
    
    func moveTracksDown(from indices: IndexSet) -> [TrackMoveResult]
    
    func moveTracksToBottom(from indices: IndexSet) -> [TrackMoveResult]
    
    func moveTracks(from sourceIndices: IndexSet, to dropIndex: Int) -> [TrackMoveResult]
    
    func sort(_ sort: TrackListSort)

    func sort(by comparator: (Track, Track) -> Bool)
    
    // MARK: Miscellaneous ------------------------------------------------------------------------
    
    func exportToFile(_ file: URL)
}

extension TrackListProtocol {
    
    func loadTracks(from urls: [URL]) {
        loadTracks(from: urls, atPosition: nil)
    }
}

protocol TrackListFileSystemLoadingProtocol {
    
    // MARK: Loading tracks from the file system ------------------------------------------------------------------------
    
    func preTrackLoad()
    
    func findTrack(forFile file: URL) -> Track?
    
    func indexOfTrack(_ track: Track) -> Int?
    
    func acceptBatch(fromSession session: TrackLoadSession) -> IndexSet
    
    func postBatchLoad(indices: IndexSet)
    
    func postTrackLoad()
}

protocol SortedTrackListProtocol: TrackListProtocol {
    
    var sortOrder: TrackListSort {get set}
}

//protocol GroupedSortedTrackListProtocol: SortedTrackListProtocol {
//    
//    func remove(tracks: [GroupedTrack], andGroups groups: [Group], from grouping: Grouping) -> IndexSet
//    
//    func sort(grouping: Grouping, by sort: GroupedTrackListSort)
//}
