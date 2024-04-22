//
//  Library+Build.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import OrderedCollections

fileprivate var totalFiles: Int = 0
fileprivate var totalPlaylists: Int = 0

fileprivate var filesRead: AtomicIntCounter = .init()
fileprivate var playlistsRead: AtomicIntCounter = .init()
fileprivate var startedReadingFiles: Bool = false

fileprivate var tracksArr: [Track] = []
fileprivate var playlistsArr: [ImportedPlaylist] = []

fileprivate var metadata: ConcurrentMap<URL, FileMetadata> = ConcurrentMap()
fileprivate var fileSystemPlaylists: ConcurrentMap<URL, FileSystemPlaylist> = ConcurrentMap()
fileprivate var fsItems: OrderedDictionary<URL, FileSystemItem> = OrderedDictionary()

fileprivate var blockOpFunction: ((URL) -> BlockOperation)!

fileprivate var chosenQueue: OperationQueue!

extension Library {
    
    var buildStats: LibraryBuildStats? {
        
        startedReadingFiles ?
            .init(filesToRead: totalFiles, playlistsToRead: totalPlaylists, filesRead: filesRead.value, playlistsRead: playlistsRead.value) :
        nil
    }
    
    func buildLibrary(immediate: Bool) {
        
        // TODO: Reset all state variables each time!
        
        // TODO: Temporarily disabling Library building. Remove this !!!
//        return
        
        let start = Date()
        
        chosenQueue = immediate ? TrackReader.highPriorityQueue : TrackReader.lowPriorityQueue
        
        DispatchQueue.global(qos: immediate ? .userInitiated : .utility).async {
            
            self._isBeingModified.setTrue()
            
            self.removeAllTracks()
            self._playlists.removeAll()
            self._fileSystemTrees.removeAll()
            
            self.messenger.publish(.Library.startedReadingFileSystem)
            
            for folder in self.sourceFolders {
                self.buildTree(forSourceFolder: folder)
            }
            
            startedReadingFiles = true
            self.messenger.publish(.Library.startedAddingTracks)
            
            chosenQueue.waitUntilAllOperationsAreFinished()
            
            self.addTracks(tracksArr)
            self.addPlaylists(playlistsArr)
            
            for playlist in self.playlists {
                
                guard let fsPlaylist = fileSystemPlaylists[playlist.file] else {continue}
                
                var tracksToAdd: [Track] = []
                var trackItemsToAdd: [FileSystemTrackItem] = []
                
                for file in fsPlaylist.tracks {
                    
                    let trackForFile: Track
                    
                    if let track = self._tracks[file] {
                        
                        trackForFile = track
                        tracksToAdd.append(track)
                        
                    } else {
                        
                        let newTrack = Track(file)
                        trackForFile = newTrack
                        tracksToAdd.append(newTrack)
                        
                        chosenQueue.addOperation {
                            trackReader.loadPrimaryMetadata(for: newTrack)
                        }
                    }
                    
                    if let trackItem = fsItems[file] as? FileSystemTrackItem {
                        trackItemsToAdd.append(trackItem)
                        
                    } else {
                        
                        let newTrackItem = FileSystemTrackItem(track: trackForFile)
                        trackItemsToAdd.append(newTrackItem)
                    }
                }
                
                playlist.addTracks(tracksToAdd)
                
                if let fsItemForPlaylist = fsItems[playlist.file] as? FileSystemPlaylistItem {
                    
                    for trackItem in trackItemsToAdd {
                        fsItemForPlaylist.addChild(trackItem)
                    }
                }
            }
            
            if let tbUserFolders = appPersistentState.ui?.tuneBrowser?.sidebar?.userFolders {
                
                for folder in tbUserFolders {
                    
                    guard let treeURL = folder.treeURL, let folderURL = folder.folderURL, let tree = self._fileSystemTrees[treeURL] else {continue}
                    
                    var pathComponents: [String] = tree.relativePathComponents(forFolderURL: folderURL)
                    guard pathComponents.isNonEmpty else {continue}
                    
                    pathComponents.remove(at: 0)
                    
                    if let theFolder = tree.folderForPathComponents(pathComponents) {
                        tuneBrowserUIState.addUserFolder(theFolder, inTree: tree)
                    }
                }
            }
            
            chosenQueue.waitUntilAllOperationsAreFinished()
            
            self._isBeingModified.setFalse()
            self._isBuilt.setTrue()
            
            self.messenger.publish(.Library.doneAddingTracks)
            
            let end = Date()
            print("\nTime taken to build Library: \(end.timeIntervalSince(start)) secs.")
        }
    }
    
    fileprivate func buildTree(forSourceFolder folder: URL) {
        
        guard let tree = FileSystemTree(sourceFolderURL: folder) else {return}
        _fileSystemTrees[folder] = tree
        
        buildFolder(tree.root, inTree: tree)
    }
    
    fileprivate func buildFolder(_ folder: FileSystemFolderItem, inTree tree: FileSystemTree) {
        
        for child in folder.url.children ?? [] {
            
            if child.isDirectory {
                
                let childFolder = FileSystemFolderItem(url: child)
                tree.updateCache(withItem: childFolder)
                
                folder.addChild(childFolder)
                
                buildFolder(childFolder, inTree: tree)
                
            } else if child.isSupportedAudioFile {
                
                totalFiles.increment()
                readAudioFile(child, under: folder, inTree: tree)
                
            } else if child.isSupportedPlaylistFile {
                
                totalPlaylists.increment()
                readPlaylistFile(child, under: folder, inTree: tree)
            }
        }
        
        folder.sortChildren(by: .name, ascending: true)
    }
    
    fileprivate func readAudioFile(_ file: URL, under folder: FileSystemFolderItem, inTree tree: FileSystemTree) {
        
        let newTrack = Track(file)
        tracksArr.append(newTrack)
        
        let childTrack = FileSystemTrackItem(track: newTrack)
        tree.updateCache(withItem: childTrack)
        
        folder.addChild(childTrack)
        fsItems[file] = childTrack
        
        chosenQueue.addOperation {
            
            trackReader.loadPrimaryMetadata(for: newTrack)
            filesRead.increment()
        }
    }
    
    fileprivate func readPlaylistFile(_ file: URL, under folder: FileSystemFolderItem, inTree tree: FileSystemTree) {
        
        let newPlaylist = ImportedPlaylist(file: file, tracks: [])
        playlistsArr.append(newPlaylist)
        
        let childPlaylist = FileSystemPlaylistItem(playlist: newPlaylist)
        tree.updateCache(withItem: childPlaylist)
        
        folder.addChild(childPlaylist)
        fsItems[file] = childPlaylist
        
        chosenQueue.addOperation {
            
            if let loadedPlaylist = PlaylistIO.loadPlaylist(fromFile: file) {
                fileSystemPlaylists[file] = loadedPlaylist
            }
            
            playlistsRead.increment()
        }
    }
}

struct LibraryBuildStats {

    let filesToRead: Int
    let playlistsToRead: Int

    let filesRead: Int
    let playlistsRead: Int

    var progressPercentage: Double {
        Double(filesRead + playlistsRead) * 100 / Double(filesToRead + playlistsToRead)
    }
}
