//
//  MusicBrainzCache.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class MusicBrainzCache: PersistentModelObject {
    
    let preferences: MusicBrainzPreferences
    
    // For a given artist / release title combo, cache art for later use (other tracks from the same album).
    private var releasesCache: ConcurrentCompositeKeyMap<String, CachedCoverArtResult> = ConcurrentCompositeKeyMap()
    private var recordingsCache: ConcurrentCompositeKeyMap<String, CachedCoverArtResult> = ConcurrentCompositeKeyMap()
    
    var onDiskReleasesCache: ConcurrentCompositeKeyMap<String, URL> = ConcurrentCompositeKeyMap()
    var onDiskRecordingsCache: ConcurrentCompositeKeyMap<String, URL> = ConcurrentCompositeKeyMap()
    
    private let baseDir: URL = FilesAndPaths.baseDir.appendingPathComponent("musicBrainzCache", isDirectory: true)
    
    private let diskIOOpQueue: OperationQueue = {

        let queue = OperationQueue()
        queue.underlyingQueue = DispatchQueue.global(qos: .utility)
        queue.maxConcurrentOperationCount = SystemUtils.numberOfPhysicalCores
        
        return queue
    }()
    
    private lazy var messenger = Messenger(for: self)
    
    init(state: MusicBrainzCachePersistentState?, preferences: MusicBrainzPreferences) {
        
        self.preferences = preferences
        messenger.subscribe(to: .application_exitRequest, handler: onAppExit(_:))
        
        guard preferences.enableCoverArtSearch && preferences.enableOnDiskCoverArtCache else {
            
            self.baseDir.delete()
            return
        }
        
        self.baseDir.createDirectory()
        
        // Initialize the cache with entries that were previously persisted to disk.
            
        for entry in state?.releases ?? [] {
            
            guard let path = entry.file, let artist = entry.artist,
                  let title = entry.title else {continue}
            
            diskIOOpQueue.addOperation {
                
                let file = URL(fileURLWithPath: path)
                
                // Ensure that the image file exists and that it contains a valid image.
                if file.exists, let coverArt = CoverArt(imageFile: file) {
                    
                    // Entry is valid, enter it into the cache.
                    
                    self.releasesCache[artist, title] = CachedCoverArtResult(art: coverArt)
                    self.onDiskReleasesCache[artist, title] = file
                }
            }
        }
            
        for entry in state?.recordings ?? [] {
            
            guard let path = entry.file, let artist = entry.artist,
                  let title = entry.title else {continue}
            
            diskIOOpQueue.addOperation {
                
                let file = URL(fileURLWithPath: path)
                
                // Ensure that the image file exists and that it contains a valid image.
                if file.exists, let coverArt = CoverArt(imageFile: file) {
                    
                    // Entry is valid, enter it into the cache.
                    
                    self.recordingsCache[artist, title] = CachedCoverArtResult(art: coverArt)
                    self.onDiskRecordingsCache[artist, title] = file
                }
            }
        }
        
        // Read all the cached image files concurrently and wait till all the concurrent ops are finished.
        diskIOOpQueue.waitUntilAllOperationsAreFinished()
            
        self.cleanUpUnmappedFiles()
    }
    
    func getForRelease(artist: String, title: String) -> CachedCoverArtResult? {
        releasesCache[artist, title]
    }
    
    func getForRecording(artist: String, title: String) -> CachedCoverArtResult? {
        recordingsCache[artist, title]
    }
    
    func putForRelease(artist: String, title: String, coverArt: CoverArt?) {
        
        releasesCache[artist, title] = coverArt != nil ? CachedCoverArtResult(art: coverArt) : .noArt
        
        if preferences.enableOnDiskCoverArtCache, let foundArt = coverArt {
            persistForRelease(artist: artist, title: title, coverArt: foundArt)
        }
    }
    
    func persistForRelease(artist: String, title: String, coverArt: CoverArt) {
        
        // Write the file to disk (on-disk caching)
        diskIOOpQueue.addOperation {
            
            self.baseDir.createDirectory()
            
            let nowString = Date().serializableString_hms()
            let randomNum = Int.random(in: 0..<10000)
            
            let outputFileName = String(format: "release-%@-%@-%@-%d.jpg", artist, title, nowString, randomNum)
            let file = self.baseDir.appendingPathComponent(outputFileName)
            
            do {
                
                try coverArt.image.writeToFile(fileType: .jpeg, file: file)
                self.onDiskReleasesCache[artist, title] = file
                
            } catch {
                NSLog("Error writing image file \(file.path) to the MusicBrainz on-disk cache: \(error)")
            }
        }
    }
    
    func putForRecording(artist: String, title: String, coverArt: CoverArt?) {
        
        recordingsCache[artist, title] = coverArt != nil ? CachedCoverArtResult(art: coverArt) : .noArt
        
        if preferences.enableOnDiskCoverArtCache, let foundArt = coverArt {
            persistForRecording(artist: artist, title: title, coverArt: foundArt)
        }
    }
    
    func persistForRecording(artist: String, title: String, coverArt: CoverArt) {
        
        // Write the file to disk (on-disk caching)
        diskIOOpQueue.addOperation {
            
            self.baseDir.createDirectory()
            
            let nowString = Date().serializableString_hms()
            let randomNum = Int.random(in: 0..<10000)
            
            let outputFileName = String(format: "recording-%@-%@-%@-%d.jpg", artist, title, nowString, randomNum)
            let file = self.baseDir.appendingPathComponent(outputFileName)
            
            do {
                
                try coverArt.image.writeToFile(fileType: .jpeg, file: file)
                self.onDiskRecordingsCache[artist, title] = file
                
            } catch {
                NSLog("Error writing image file \(file.path) to the MusicBrainz on-disk cache: \(error)")
            }
        }
    }
    
    func onDiskCachingEnabled() {
        
        // Go through the in-memory cache. For all entries that have not been persisted to disk, persist them.
        
        for (artist, releaseTitle, coverArtResult) in releasesCache.entries {
                
            if let coverArt = coverArtResult.art, onDiskReleasesCache[artist, releaseTitle] == nil {
                persistForRelease(artist: artist, title: releaseTitle, coverArt: coverArt)
            }
        }
        
        for (artist, recordingTitle, coverArtResult) in recordingsCache.entries {
            
            if let coverArt = coverArtResult.art, onDiskRecordingsCache[artist, recordingTitle] == nil {
                persistForRecording(artist: artist, title: recordingTitle, coverArt: coverArt)
            }
        }
    }
    
    func onDiskCachingDisabled() {
        
        // Caching is disabled
        
        onDiskReleasesCache.removeAll()
        onDiskRecordingsCache.removeAll()
        
        diskIOOpQueue.addOperation {
            self.baseDir.delete()
        }
    }
    
    func cleanUpUnmappedFiles() {
        
        diskIOOpQueue.addOperation {
            
            // Clean up files that are unmapped.
            
            if let allFiles = self.baseDir.children {
                
                let mappedFiles: Set<URL> = Set(self.onDiskReleasesCache.entries.map {$0.2} + self.onDiskRecordingsCache.entries.map {$0.2})
                
                let unmappedFiles = allFiles.filter {!mappedFiles.contains($0)}
                
                // Delete unmapped files.
                for file in unmappedFiles {
                    file.delete(recursive: false)
                }
            }
        }
    }
    
    // This function is invoked when the user attempts to exit the app.
    func onAppExit(_ request: AppExitRequestNotification) {
        
        // Wait till all disk I/O operations have completed, before allowing
        // the app to exit.
        diskIOOpQueue.waitUntilAllOperationsAreFinished()
        
        // Proceed with exit
        request.acceptResponse(okToExit: true)
    }
    
    var persistentState: MusicBrainzCachePersistentState {
        
        var releases: [MusicBrainzCacheEntryPersistentState] = []
        var recordings: [MusicBrainzCacheEntryPersistentState] = []
        
        for (artist, title, file) in self.onDiskReleasesCache.entries {
            releases.append(MusicBrainzCacheEntryPersistentState(artist: artist, title: title, file: file.path))
        }
        
        for (artist, title, file) in self.onDiskRecordingsCache.entries {
            recordings.append(MusicBrainzCacheEntryPersistentState(artist: artist, title: title, file: file.path))
        }
        
        return MusicBrainzCachePersistentState(releases: releases, recordings: recordings)
    }
}

struct CachedCoverArtResult {
    
    let art: CoverArt?
    var hasArt: Bool {art != nil}
    
    static let noArt: CachedCoverArtResult = CachedCoverArtResult(art: nil)
}
