//
//  LibraryDelegate.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

protocol LibraryDelegateProtocol: GroupedSortedTrackListProtocol {
    
    var isBuilt: Bool {get}
    
    var buildProgress: LibraryBuildProgress {get}
    
    func buildLibraryIfNotBuilt(immediate: Bool)
    
    var sourceFolders: [URL] {get}
    
    var fileSystemTrees: [FileSystemTree] {get}
    
    // TODO:
    var playlists: [ImportedPlaylist] {get}
    
    func findGroup(named groupName: String, ofType groupType: GroupType) -> Group?
    
    func findFileSystemFolder(atLocation location: URL) -> FileSystemFolderItem?
    
    func findImportedPlaylist(atLocation location: URL) -> ImportedPlaylist?
}

class LibraryDelegate: LibraryDelegateProtocol {
    
    var sortOrder: TrackListSort {
        
        get {library.sortOrder}
        set {library.sortOrder = newValue}
    }
    
    var displayName: String {library.displayName}
    
    private lazy var messenger: Messenger = .init(for: self)
    
    var isBuilt: Bool {
        library.isBuilt
    }
    
    var buildProgress: LibraryBuildProgress {
        library.buildProgress
    }
    
    init() {
        libraryMonitor.startMonitoring()
    }
    
    var tracks: [Track] {library.tracks}
    
    var sourceFolders: [URL] {
        Array(library.sourceFolders)
    }
    
    var fileSystemTrees: [FileSystemTree] {
        library.fileSystemTrees
    }
    
    var playlists: [ImportedPlaylist] {library.playlists}
    
    var size: Int {library.size}
    
    var duration: Double {library.duration}
    
    var isBeingModified: Bool {library.isBeingModified}
    
    subscript(index: Int) -> Track? {
        library[index]
    }
    
    subscript(indices: IndexSet) -> [Track] {
        library[indices]
    }
    
    var summary: (size: Int, totalDuration: Double) {
        library.summary
    }
    
    func buildLibraryIfNotBuilt(immediate: Bool) {
        
        if !(isBuilt || isBeingModified) {
            
            print("In app mode (\(appModeManager.currentMode)), building library: immediate ? \(immediate)")
            library.buildLibrary(immediate: immediate)
            
        } else {
            print("In app mode (\(appModeManager.currentMode)), ALREADY BUILT library")
        }
    }
    
    func indexOfTrack(_ track: Track) -> Int? {
        library.indexOfTrack(track)
    }
    
    func hasTrack(_ track: Track) -> Bool {
        library.hasTrack(track)
    }
    
    func hasTrack(forFile file: URL) -> Bool {
        library.hasTrack(forFile: file)
    }
    
    func findTrack(forFile file: URL) -> Track? {
        library.findTrack(forFile: file)
    }
    
    // Not a valid user action
    func loadTracks(from urls: [URL], atPosition position: Int?) {
    }
    
    func search(_ searchQuery: SearchQuery) -> SearchResults {
        SearchResults(scope: .library, [])
    }
    
    func addTracks(_ newTracks: [Track]) -> IndexSet {
        
        let indices = library.addTracks(newTracks)
        messenger.publish(LibraryTracksAddedNotification(trackIndices: indices))
        return indices
    }
    
    func insertTracks(_ tracks: [Track], at insertionIndex: Int) -> IndexSet {
        
        let indices = library.insertTracks(tracks, at: insertionIndex)
        messenger.publish(LibraryTracksAddedNotification(trackIndices: indices))
        return indices
    }
    
    func removeTracks(at indices: IndexSet) -> [Track] {
        
        let removedTracks = library.removeTracks(at: indices)
        messenger.publish(LibraryTracksRemovedNotification(trackIndices: indices))
        return removedTracks
    }
    
    func remove(tracks: [GroupedTrack], andGroups groups: [Group], from grouping: Grouping) -> IndexSet {
        
        let indices = library.remove(tracks: tracks, andGroups: groups, from: grouping)
        messenger.publish(LibraryTracksRemovedNotification(trackIndices: indices))
        return indices
    }
    
    func cropTracks(at indices: IndexSet) {
        library.cropTracks(at: indices)
    }
    
    func cropTracks(_ tracks: [Track]) {
        library.cropTracks(tracks)
    }
    
    func removeAllTracks() {
        library.removeAllTracks()
    }
    
    func moveTracksUp(from indices: IndexSet) -> [TrackMoveResult] {[]}
    
    func moveTracksToTop(from indices: IndexSet) -> [TrackMoveResult] {[]}
    
    func moveTracksDown(from indices: IndexSet) -> [TrackMoveResult] {[]}
    
    func moveTracksToBottom(from indices: IndexSet) -> [TrackMoveResult] {[]}
    
    func moveTracks(from sourceIndices: IndexSet, to dropIndex: Int) -> [TrackMoveResult] {[]}
    
    func sort(_ sort: TrackListSort) {
        library.sortOrder = sort
    }
    
    func sort(by comparator: (Track, Track) -> Bool) {}
    
    func sort(grouping: Grouping, by sort: GroupedTrackListSort) {
        library.sort(grouping: grouping, by: sort)
    }
    
    func findGroup(named groupName: String, ofType groupType: GroupType) -> Group? {
        library.findGroup(named: groupName, ofType: groupType)
    }
    
    func findFileSystemFolder(atLocation location: URL) -> FileSystemFolderItem? {
        library.findFileSystemFolder(atLocation: location)
    }
    
    func findImportedPlaylist(atLocation location: URL) -> ImportedPlaylist? {
        library.findImportedPlaylist(atLocation: location)
    }
    
    func exportToFile(_ file: URL) {
        library.exportToFile(file)
    }
}
