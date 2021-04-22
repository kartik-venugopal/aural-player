import Foundation

class FileSystem {
    
    private let opQueue: OperationQueue = OperationQueue()
    private let concurrentOpCount = roundedInt(Double(SystemUtils.numberOfActiveCores) * 1.5)
    
    private lazy var playlist: PlaylistAccessorDelegateProtocol = ObjectGraph.playlistAccessorDelegate
    private lazy var fileReader: FileReaderProtocol = ObjectGraph.fileReader
    
    var root: FileSystemItem = FileSystemItem.create(forURL: AppConstants.FilesAndPaths.musicDir) {
        
        didSet {
            loadMetadata(forChildrenOf: root)
        }
    }
    
    var rootURL: URL {
        
        get {root.url}
        set(newURL) {root = FileSystemItem.create(forURL: newURL)}
    }
    
    init() {
        
        opQueue.maxConcurrentOperationCount = concurrentOpCount
        opQueue.underlyingQueue = DispatchQueue.global(qos: .userInteractive)
        opQueue.qualityOfService = .userInteractive
    }
    
    func loadMetadata(forChildrenOf item: FileSystemItem) {
        
        if item.metadataLoadedForChildren {
            return
        }
        
        item.metadataLoadedForChildren = true
        
        // We need to load metadata only for supported tracks (ignore folders, playlists, or unsupported files).
        for child in item.children.filter({$0.isTrack}) {
            
            if let track = playlist.findFile(child.url) {
                
                let metadata = FileMetadata()
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
                        metadata.auxiliary = self?.fileReader.getAuxiliaryMetadata(for: theChild.url, loadingAudioInfoFrom: track.playbackContext)
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
                    
                    opQueue.addOperation {[weak child] in
                        
                        guard let theChild = child else {return}
                        
                        var needToNotify: Bool = false
                        
                        for op in concurrentAsyncOps {
                            needToNotify = needToNotify || op()
                        }
                        
                        if needToNotify {
                            Messenger.publish(FileSystemFileMetadataLoadedNotification(file: theChild))
                        }
                    }
                    
                } else {
                    Messenger.publish(FileSystemFileMetadataLoadedNotification(file: child))
                }
                
                continue
            }
            
            opQueue.addOperation {[weak self, weak child] in
                
                guard let theChild = child else {return}
                
                theChild.metadata = self?.fileReader.getAllMetadata(for: theChild.url)
                Messenger.publish(FileSystemFileMetadataLoadedNotification(file: theChild))
            }
        }
    }
}
