import Cocoa

class MusicBrainzCache: NotificationSubscriber {
    
    let preferences: MusicBrainzPreferences
    
    // For a given artist / release title combo, cache art for later use (other tracks from the same album).
    private var releasesCache: [String: [String: CoverArt]] = [:]
    private var recordingsCache: [String: [String: CoverArt]] = [:]
    
    var onDiskReleasesCache: [String: [String: URL]] = [:]
    var onDiskRecordingsCache: [String: [String: URL]] = [:]
    
    private let baseDir: URL = AppConstants.FilesAndPaths.baseDir.appendingPathComponent("musicBrainzCache", isDirectory: true)
    
    private let diskIOOpQueue: OperationQueue = {

        let queue = OperationQueue()
        queue.underlyingQueue = DispatchQueue.global(qos: .utility)
        queue.maxConcurrentOperationCount = 2
        
        return queue
    }()
    
    init(_ state: MusicBrainzCacheState, _ preferences: MusicBrainzPreferences) {
        
        self.preferences = preferences
        Messenger.subscribe(self, .application_exitRequest, self.onAppExit(_:))
        
        if !(preferences.enableCoverArtSearch || preferences.enableOnDiskCoverArtCache) {
            return
        }
        
        // Initialize the cache with entries that were previously persisted to disk.
        // Do it async so as not to block the main thread and delay app startup.
        DispatchQueue.global(qos: .utility).async {
            
            FileSystemUtils.createDirectory(self.baseDir)
            
            for entry in state.releases {
                
                // Ensure that the image file exists and that it contains a valid image.
                if FileSystemUtils.fileExists(entry.file), let coverArt = CoverArt(imageFile: entry.file) {
                    
                    // Now that the entry has been validated, add it to the cache.
                    
                    if self.releasesCache[entry.artist] == nil {
                        self.releasesCache[entry.artist] = [:]
                    }
                    
                    self.releasesCache[entry.artist]?[entry.title] = coverArt
                    
                    if self.onDiskReleasesCache[entry.artist] == nil {
                        self.onDiskReleasesCache[entry.artist] = [:]
                    }
                    
                    self.onDiskReleasesCache[entry.artist]?[entry.title] = entry.file
                }
            }
            
            for entry in state.recordings {
                
                // Ensure that the image file exists and that it contains a valid image.
                if FileSystemUtils.fileExists(entry.file), let coverArt = CoverArt(imageFile: entry.file) {
                    
                    // Now that the entry has been validated, add it to the cache.
                    
                    if self.recordingsCache[entry.artist] == nil {
                        self.recordingsCache[entry.artist] = [:]
                    }
                    
                    self.recordingsCache[entry.artist]?[entry.title] = coverArt
                    
                    if self.onDiskRecordingsCache[entry.artist] == nil {
                        self.onDiskRecordingsCache[entry.artist] = [:]
                    }
                    
                    self.onDiskRecordingsCache[entry.artist]?[entry.title] = entry.file
                }
            }
        }
    }
    
    func getForRelease(artist: String, title: String) -> CoverArt? {
        return releasesCache[artist]?[title]
    }
    
    func getForRecording(artist: String, title: String) -> CoverArt? {
        return recordingsCache[artist]?[title]
    }
    
    func putForRelease(artist: String, title: String, coverArt: CoverArt) {
        
        if releasesCache[artist] == nil {
            releasesCache[artist] = [:]
        }
        
        releasesCache[artist]?[title] = coverArt
        
        if !preferences.enableOnDiskCoverArtCache {return}
        
        // Write the file to disk (on-disk caching)
        diskIOOpQueue.addOperation {
            
            let nowString = Date().serializableString_hms()
            let randomNum = Int.random(in: 0..<10000)
            
            let outputFileName = String(format: "release-%@-%@-%@-%d.jpg", artist, title, nowString, randomNum)
            let file = self.baseDir.appendingPathComponent(outputFileName)
            
            do {
                
                try coverArt.image.writeToFile(fileType: .jpeg, file: file)
                
                if self.onDiskReleasesCache[artist] == nil {
                    self.onDiskReleasesCache[artist] = [:]
                }
                
                self.onDiskReleasesCache[artist]?[title] = file
                
            } catch {
                NSLog("Error writing image file \(file.path) to the MusicBrainz on-disk cache: \(error)")
            }
        }
    }
    
    func putForRecording(artist: String, title: String, coverArt: CoverArt) {
        
        if recordingsCache[artist] == nil {
            recordingsCache[artist] = [:]
        }
        
        recordingsCache[artist]?[title] = coverArt
        
        if !preferences.enableOnDiskCoverArtCache {return}
        
        // Write the file to disk (on-disk caching)
        diskIOOpQueue.addOperation {
            
            let nowString = Date().serializableString_hms()
            let randomNum = Int.random(in: 0..<10000)
            
            let outputFileName = String(format: "recording-%@-%@-%@-%d.jpg", artist, title, nowString, randomNum)
            let file = self.baseDir.appendingPathComponent(outputFileName)
            
            do {
                
                try coverArt.image.writeToFile(fileType: .jpeg, file: file)
                
                if self.onDiskRecordingsCache[artist] == nil {
                    self.onDiskRecordingsCache[artist] = [:]
                }
                
                self.onDiskRecordingsCache[artist]?[title] = file
                
            } catch {
                NSLog("Error writing image file \(file.path) to the MusicBrainz on-disk cache: \(error)")
            }
        }
    }
    
    // This function is invoked when the user attempts to exit the app. It checks if there
    // is a track playing and if playback settings for the track need to be remembered.
    func onAppExit(_ request: AppExitRequestNotification) {
        
        diskIOOpQueue.waitUntilAllOperationsAreFinished()
        
        if !(preferences.enableCoverArtSearch || preferences.enableOnDiskCoverArtCache) {
            
            print("CACHE disabled, DELETING baseDir ...")
//            FileSystemUtils.deleteDir(baseDir)
            
            onDiskReleasesCache.removeAll()
            onDiskRecordingsCache.removeAll()
            
        } else {
            
            // Clean up files that are unmapped
            
            print("CACHE enabled, cleaning up unmapped files ...")
            
            if let allFiles = FileSystemUtils.getContentsOfDirectory(baseDir) {
                
                var mappedFiles: Set<URL> = Set()
                
                for (_, artistCache) in onDiskReleasesCache {
                    mappedFiles = mappedFiles.union(artistCache.values)
                }
                
                for (_, artistCache) in onDiskRecordingsCache {
                    mappedFiles = mappedFiles.union(artistCache.values)
                }
                
                let unmappedFiles = allFiles.filter {!mappedFiles.contains($0)}
                
                // Delete unmapped files
                for file in unmappedFiles {
                    
                    print("UNMAPPED FILE: \(file.path)")
//                    FileSystemUtils.deleteFile(file.path)
                }
            }
        }
        
        // Proceed with exit
        request.acceptResponse(okToExit: true)
    }
}
