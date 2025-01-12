//
//  LibraryProtocols.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import OrderedCollections

protocol LibraryProtocol: TuneBrowserProtocol {
    
    func buildLibrary(immediate: Bool)
    
    var buildProgress: LibraryBuildProgress {get}
    
    var isBuilt: Bool {get}
    
    // TODO:
    var playlists: [ImportedPlaylist] {get}
    
    var numberOfPlaylists: Int {get}
    
    var numberOfTracksInPlaylists: Int {get}
    
    var durationOfTracksInPlaylists: Double {get}
    
    func addPlaylists(_ playlists: [ImportedPlaylist])
    
    func playlist(atIndex index: Int) -> ImportedPlaylist?
    
    func findGroup(named groupName: String, ofType groupType: GroupType) -> Group?
    
    func findFileSystemFolder(atLocation location: URL) -> FileSystemFolderItem?
    
    func findImportedPlaylist(atLocation location: URL) -> ImportedPlaylist?
}

protocol TuneBrowserProtocol {
    
    var sourceFolders: OrderedSet<URL> {get}
    
    func addSourceFolder(url: URL)
    
    func removeSourceFolder(url: URL)
    
    var fileSystemTrees: [FileSystemTree] {get}
}

struct LibraryBuildProgress {
    
    let isBeingModified: Bool
    let startedReadingFiles: Bool
    let buildStats: LibraryBuildStats?
}
