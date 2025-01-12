//
//  Library.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import OrderedCollections

class Library: GroupedSortedTrackList, LibraryProtocol {
    
    override var displayName: String {"The Library"}
    
    var _isBuilt: AtomicBool = .init()
    var isBuilt: Bool {
        _isBuilt.value
    }
    
    var sourceFolders: OrderedSet<URL>
    
    func addSourceFolder(url: URL) {
        sourceFolders.append(url)
    }
    
    func removeSourceFolder(url: URL) {
        sourceFolders.remove(url)
    }
    
    var fileSystemTrees: [FileSystemTree] {
        Array(_fileSystemTrees.values)
    }
    
    var _fileSystemTrees: OrderedDictionary<URL, FileSystemTree> = OrderedDictionary()
    
    /// A map to quickly look up playlists by (absolute) file path (used when adding playlists, to prevent duplicates)
    /// // TODO:
    var _playlists: OrderedDictionary<URL, ImportedPlaylist> = OrderedDictionary()
    
    var playlists: [ImportedPlaylist] {
        Array(_playlists.values)
    }
    
    var numberOfPlaylists: Int {
        _playlists.count
    }
    
    var numberOfTracksInPlaylists: Int {
        _playlists.values.reduce(0, {(totalSoFar: Int, playlist: ImportedPlaylist) -> Int in totalSoFar + playlist.size})
    }
    
    var durationOfTracksInPlaylists: Double {
        _playlists.values.reduce(0.0, {(totalSoFar: Double, playlist: ImportedPlaylist) -> Double in totalSoFar + playlist.duration})
    }
    
    func addPlaylists(_ playlists: [ImportedPlaylist]) {
        
        for playlist in playlists {
            _playlists[playlist.file] = playlist
        }
    }
    
    func playlist(atIndex index: Int) -> ImportedPlaylist? {
        
        guard (0..._playlists.lastIndex).contains(index) else {return nil}
        return _playlists.elements.values[index]
    }
    
    init(persistentState: LibraryPersistentState?) {
        
//        self.sourceFolders = OrderedSet(persistentState?.sourceFolders ?? [FilesAndPaths.musicDir])
        self.sourceFolders = [FilesAndPaths.musicDir]
        
        super.init(sortOrder: TrackListSort(fields: [.artist, .album, .discNumberAndTrackNumber], order: .ascending),
                   withGroupings: [ArtistsGrouping(), AlbumsGrouping(), GenresGrouping(), DecadesGrouping()])
    }
    
    lazy var messenger = Messenger(for: self)
    
    var buildProgress: LibraryBuildProgress {
        
        if !_isBeingModified.value {
            return .init(isBeingModified: false, startedReadingFiles: false, buildStats: nil)
        }
        
        let buildStats = self.buildStats
        return .init(isBeingModified: true, startedReadingFiles: buildStats != nil, buildStats: buildStats)
    }
    
    var artistsGrouping: ArtistsGrouping {
        groupings[0] as! ArtistsGrouping
    }
    
    var albumsGrouping: AlbumsGrouping {
        groupings[1] as! AlbumsGrouping
    }
    
    var genresGrouping: GenresGrouping {
        groupings[2] as! GenresGrouping
    }
    
    var decadesGrouping: DecadesGrouping {
        groupings[3] as! DecadesGrouping
    }
    
    override func loadTracks(from urls: [URL], atPosition position: Int?) {
        // DO NOTHING (User cannot load tracks from the FS into the Library)
    }
    
    func findGroup(named groupName: String, ofType groupType: GroupType) -> Group? {
        
        switch groupType {
            
        case .artist:
            return artistsGrouping.group(named: groupName)
            
        case .album:
            return albumsGrouping.group(named: groupName)
            
        case .genre:
            return genresGrouping.group(named: groupName)
            
        case .decade:
            return decadesGrouping.group(named: groupName)
            
        default:
            return nil
        }
    }
    
    func findFileSystemFolder(atLocation location: URL) -> FileSystemFolderItem? {
        (fileSystemTrees.firstNonNilMappedValue {$0.item(forURL: location)}) as? FileSystemFolderItem
    }
    
    func findImportedPlaylist(atLocation location: URL) -> ImportedPlaylist? {
        _playlists[location]
    }
}

extension Library: PersistentModelObject {
    
    var persistentState: LibraryPersistentState {
        .init(sourceFolders: Array(self.sourceFolders))
    }
}
