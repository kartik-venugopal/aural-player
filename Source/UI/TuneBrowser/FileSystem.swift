//
//  FileSystem.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

class FileSystem {
    
    private let opQueue: OperationQueue = OperationQueue()
    private let concurrentOpCount = (Double(SystemUtils.numberOfActiveCores) * 1.5).roundedInt
    
    private lazy var playlist: PlaylistAccessorDelegateProtocol = objectGraph.playlistAccessorDelegate
    private lazy var fileReader: FileReaderProtocol = objectGraph.fileReader
    
    var root: FileSystemItem = FileSystemItem.create(forURL: FilesAndPaths.musicDir) {
        
        didSet {
            loadMetadata(forChildrenOf: root)
        }
    }
    
    var rootURL: URL {
        
        get {root.url}
        set(newURL) {root = FileSystemItem.create(forURL: newURL)}
    }
    
    private lazy var messenger = Messenger(for: self)
    
    init() {
        
        opQueue.maxConcurrentOperationCount = concurrentOpCount
        opQueue.underlyingQueue = DispatchQueue.global(qos: .utility)
        opQueue.qualityOfService = .utility
    }
    
    func loadMetadata(forChildrenOf item: FileSystemItem) {
        
        if item.metadataLoadedForChildren {
            return
        }
        
        DispatchQueue.global(qos: .userInitiated).async {

            item.metadataLoadedForChildren = true

            // We need to load metadata only for supported tracks (ignore folders, playlists, or unsupported files).
            for child in item.children.filter({$0.isTrack}) {

                if let track = self.playlist.findFile(child.url) {

                    var metadata = FileMetadata()
                    child.metadata = metadata

                    var playlistMetadata = PlaylistMetadata()

                    playlistMetadata.title = track.title

                    playlistMetadata.artist = track.artist
                    playlistMetadata.albumArtist = track.albumArtist
                    playlistMetadata.performer = track.performer

                    playlistMetadata.album = track.album
                    playlistMetadata.genre = track.genre

                    playlistMetadata.duration = track.duration

                    playlistMetadata.trackNumber = track.trackNumber
                    playlistMetadata.totalTracks = track.totalTracks
                    playlistMetadata.discNumber = track.discNumber
                    playlistMetadata.totalDiscs = track.totalDiscs

                    metadata.playlist = playlistMetadata

                    // Bool return value indicates whether any metadata was loaded.
                    var concurrentAsyncOps: [() -> Bool] = []

                    if track.auxMetadataLoaded {

                        var auxMetadata = AuxiliaryMetadata()

                        auxMetadata.audioInfo = track.audioInfo
                        auxMetadata.fileSystemInfo = track.fileSystemInfo
                        auxMetadata.year = track.year
                        auxMetadata.auxiliaryMetadata = track.auxiliaryMetadata

                        metadata.auxiliary = auxMetadata

                    } else {

                        concurrentAsyncOps.append {[weak self, weak child] in

                            guard let theChild = child else {return false}
                            metadata.auxiliary = self?.fileReader.getAuxiliaryMetadata(for: theChild.url,
                                                                                       loadingAudioInfoFrom: track.playbackContext)
                            return true
                        }
                    }

                    if let coverArt = track.art?.image {
                        child.metadata?.coverArt = coverArt

                    } else {

                        concurrentAsyncOps.append {[weak self, weak child] in

                            guard let theChild = child else {return false}
                            metadata.coverArt = self?.fileReader.getArt(for: theChild.url)?.image
                            return metadata.coverArt != nil
                        }
                    }

                    if concurrentAsyncOps.isNonEmpty {

                        self.opQueue.addOperation {[weak child] in

                            guard let theChild = child else {return}

                            var needToNotify: Bool = false

                            for op in concurrentAsyncOps {
                                needToNotify = op() || needToNotify
                            }

                            if needToNotify {
                                self.messenger.publish(.fileSystem_fileMetadataLoaded, payload: theChild)
                            }
                        }

                    } else {
                        self.messenger.publish(.fileSystem_fileMetadataLoaded, payload: child)
                    }

                    continue
                }

                self.opQueue.addOperation {[weak self, weak child] in

                    guard let theChild = child else {return}

                    theChild.metadata = self?.fileReader.getAllMetadata(for: theChild.url)
                    self?.messenger.publish(.fileSystem_fileMetadataLoaded, payload: theChild)
                }
            }
        }
    }
    
    func sort(by sortField: FileSystemSortField, ascending: Bool) {
        root.sort(by: sortField, ascending: ascending)
    }
}

enum FileSystemSortField {
    
    case name, title, artist, album, genre, format, duration, year, type
}
