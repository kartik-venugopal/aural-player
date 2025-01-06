//
//  TrackReader.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//

import Foundation
import LyricsCore

typealias TrackIOCompletionHandler = () -> Void

///
/// Handles loading of metadata for a track.
///
class TrackReader {
    
#if DEBUG
        static let highPriorityQueue: OperationQueue = .init(opCount: max(4, System.physicalCores), qos: .utility)
#else
        static let highPriorityQueue: OperationQueue = .init(opCount: max(4, System.physicalCores), qos: .userInitiated)
#endif
    
    static let mediumPriorityQueue: OperationQueue = .init(opCount: max(2, System.physicalCores / 2), qos: .utility)
    static let lowPriorityQueue: OperationQueue = .init(opCount: max(2, System.physicalCores / 2), qos: .background)
    
    private lazy var logger: Logger = .init(for: self)
    
    ///
    /// Loads the essential metadata fields that are required for a track to be loaded into the playlist.
    ///
    func loadMetadataAsync(for track: Track, onQueue opQueue: OperationQueue) {
        
        let metadataCacheEnabled = preferences.metadataPreferences.cacheTrackMetadata.value
        
        if metadataCacheEnabled, let cachedMetadata = metadataRegistry[track] {
            
            track.metadata = cachedMetadata
            
            loadExternalLyrics(for: track, onQueue: opQueue, metadataCacheEnabled: true)
            
            doLoadMetadata(for: track, onQueue: opQueue,
                                  metadataCacheEnabled: metadataCacheEnabled)
            return
        }
        
        opQueue.addOperation {
            
            do {
                
                let primaryMetadata = try fileReader.getPrimaryMetadata(for: track.file)
                track.metadata.updatePrimaryMetadata(with: primaryMetadata)
                
                self.doLoadMetadata(for: track, onQueue: opQueue,
                                    metadataCacheEnabled: metadataCacheEnabled)
                
                self.loadExternalLyrics(for: track, onQueue: opQueue, metadataCacheEnabled: metadataCacheEnabled)
                
                if metadataCacheEnabled {
                    metadataRegistry[track] = track.metadata
                }
                
            } catch {
                
                track.metadata.validationError = (error as? DisplayableError) ?? InvalidTrackError(track.file, "Track is not playable.")
                self.logger.error("Failed to read metadata for track: '\(track.file.path)'. Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func doLoadMetadata(for track: Track, onQueue opQueue: OperationQueue, metadataCacheEnabled: Bool) {
        
        let metadata = track.metadata
        
        if metadata.art == nil {
            metadata.art = musicBrainzCache.getCoverArt(forTrack: track)
        }
        
        let durationIsAccurate = metadata.durationIsAccurate
        
        // For non-native tracks that don't have accurate duration, compute duration async.
        
        if !track.isNativelySupported, track.isPlayable, track.duration <= 0 || !durationIsAccurate {
            computeAccurateDuration(forTrack: track, onQueue: opQueue, metadataCacheEnabled: metadataCacheEnabled)
        }
    }
    
    private func loadExternalLyrics(for track: Track, onQueue opQueue: OperationQueue, metadataCacheEnabled: Bool) {
        
        print("BEFORE - In cache, it's: \(metadataRegistry[track]?.externalTimedLyrics != nil)")
        
        opQueue.addOperation {
            
            // Load lyrics from previously assigned external file
            if let externalLyricsFile = track.metadata.externalLyricsFile, externalLyricsFile.exists,
               let lyrics = self.loadLyricsFromFile(at: externalLyricsFile) {
                
                track.metadata.externalTimedLyrics = TimedLyrics(from: lyrics, trackDuration: track.duration)
                print("AFTER In cache, it's: \(metadataRegistry[track]?.externalTimedLyrics != nil)")
                return
            }
            
            // Look for lyrics in candidate directories
            let lyricsFolder = preferences.metadataPreferences.lyrics.lyricsFilesDirectory.value
            
            for dir in [lyricsFolder, track.file.parentDir, FilesAndPaths.lyricsDir].compactMap({$0}) {
                
                if self.loadLyricsFromDirectory(dir, for: track) {
                    
                    print("AFTER In cache, it's: \(metadataRegistry[track]?.externalTimedLyrics != nil) for \(track)")
                    
                    if metadataCacheEnabled {
                        metadataRegistry[track]?.externalTimedLyrics = track.externalTimedLyrics
                    }
                    
                    return
                }
            }
        }
    }
    
    /// Loads lyrics from a specified directory by searching for .lrc or .lrcx files
    ///
    /// - Parameter directory: The directory to search for lyrics files
    /// - Returns: A Lyrics object if found and successfully loaded, nil otherwise
    ///
    private func loadLyricsFromDirectory(_ directory: URL, for track: Track) -> Bool {
        
        let possibleFiles = SupportedTypes.lyricsFileExtensions.map {
            directory.appendingPathComponent(track.defaultDisplayName).appendingPathExtension($0)
        }
        
        if let lyricsFile = possibleFiles.first(where: {$0.exists}) {
            return loadTimedLyricsFromFile(at: lyricsFile, for: track)
        }
        
        return false
    }
    
    func loadTimedLyricsFromFile(at url: URL, for track: Track) -> Bool {
        
        if let lyrics = loadLyricsFromFile(at: url) {
            
            track.metadata.externalTimedLyrics = TimedLyrics(from: lyrics, trackDuration: track.duration)
            track.metadata.externalLyricsFile = url
            return true
        }
        
        return false
    }

    /// Loads lyrics content from a file at the specified URL
    ///
    /// - Parameter url: The URL of the lyrics file
    /// - Returns: A Lyrics object if successfully loaded, nil otherwise
    ///
    private func loadLyricsFromFile(at url: URL) -> LyricsCore.Lyrics? {
        
        do {
            
            let lyricsText = try String(contentsOf: url, encoding: .utf8)
            return LyricsCore.Lyrics(lyricsText)
            
        } catch {
            
            print("Failed to read lyrics file at \(url.path): \(error.localizedDescription)")
            return nil
        }
    }
    
    func computeAccurateDuration(forTrack track: Track, onQueue opQueue: OperationQueue, metadataCacheEnabled: Bool) {
        
        opQueue.addOperation {
            
            guard let duration = fileReader.computeAccurateDuration(for: track.file), duration > 0 else {return}
            
            track.metadata.duration = duration
            track.metadata.durationIsAccurate = true
            
            if metadataCacheEnabled, let metadataInCache = metadataRegistry[track] {

//                let diff = (abs(metadataInCache.duration - duration) / metadataInCache.duration) * 100.0
//                print("Updating duration from \(metadataInCache.duration) -> \(duration), diff = \(diff)")
                metadataInCache.duration = duration
                metadataInCache.durationIsAccurate = true
            }
            
            Messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .duration))
        }
    }
    
    func computePlaybackContext(for track: Track) throws {
        
        track.playbackContext = try fileReader.getPlaybackMetadata(for: track.file)
        
        if let updatedFrameCount = track.playbackContext?.frameCount {
            track.audioInfo.frames = updatedFrameCount
        }
        
        // If duration has changed as a result of precise computation, set it in the track and send out an update notification
        if !track.durationIsAccurate, let playbackContext = track.playbackContext, track.duration != playbackContext.duration {
            
            track.metadata.duration = playbackContext.duration
            track.metadata.durationIsAccurate = true
            
            Messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .duration))
            
            // Update the metadata cache with the updated duration.
            let metadataCacheEnabled = preferences.metadataPreferences.cacheTrackMetadata.value
            if metadataCacheEnabled, let metadataInCache = metadataRegistry[track] {
                
                metadataInCache.duration = playbackContext.duration
                metadataInCache.durationIsAccurate = true
            }
        }
    }
    
    ///
    /// Loads all metadata and resources that are required for track playback.
    ///
    func prepareForPlayback(track: Track, immediate: Bool = true) throws {
        
        // Make sure track is valid before trying to prep it for playback.
        if let prepError = track.metadata.preparationError {
            throw prepError
            
        } else if let validationError = track.metadata.validationError {
            
            track.metadata.preparationError = validationError
            throw validationError
        }
        
        do {
            
            // If a playback context has been previously computed, just open it.
            if let theContext = track.playbackContext {
                try theContext.open()
                
            } else {
                
                // No playback context was previously computed, so compute it and open it.
                
                try computePlaybackContext(for: track)
                try track.playbackContext?.open()
            }
            
            // Load cover art for display in the player.
            loadArtAsync(for: track, immediate: immediate)
            
        } catch {
            
            NSLog("Unable to prepare track \(track.displayName) for playback. Error: \(error)")
            
            track.metadata.preparationFailed = true
            
            if let prepError = error as? DisplayableError {
                track.metadata.preparationError = prepError
            }
            
            throw error
        }
    }
    
    ///
    /// Loads all metadata and resources that are required for track playback.
    ///
    func prepareForGaplessPlayback(track: Track) throws {
        
        // Make sure track is valid before trying to prep it for playback.
        if let prepError = track.metadata.preparationError {
            throw prepError
            
        } else if let validationError = track.metadata.validationError {
            
            track.metadata.preparationError = validationError
            throw validationError
        }
        
        do {
            
            // If a playback context has been previously computed, just open it.
            if track.playbackContext == nil {
                
                // No playback context was previously computed, so compute it and open it.
                try computePlaybackContext(for: track)
            }
            
        } catch {
            
            track.metadata.preparationFailed = true
            
            if let prepError = error as? DisplayableError {
                track.metadata.preparationError = prepError
            }
            
            throw error
        }
    }
    
    ///
    /// Loads cover art for a track, asynchronously. This is useful when
    /// cover art is not required immediately, and a short delay is acceptable.
    /// (eg. when preparing for playback)
    ///
    func loadArtAsync(for track: Track, immediate: Bool = true) {
        
        if track.art?.originalImage != nil {return}
        
        DispatchQueue.global(qos: immediate ? .userInteractive : .utility).async {
            
            guard let art = coverArtReader.getCoverArt(forTrack: track) else {return}
            
            if let existingArt = track.art {
                existingArt.merge(withOther: art)
            } else {
                track.metadata.art = art
            }
            
            Messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .art))
        }
    }
    
    ///
    /// Loads all non-essential ("auxiliary") metadata associated with a track, for display in the "Detailed track info" view.
    ///
    func loadAuxiliaryMetadata(for track: Track) {
        
            
            track.audioInfo.replayGainFromMetadata = track.replayGain
            loadArtAsync(for: track)
        
        track.audioInfo.replayGainFromAnalysis = replayGainScanner.cachedReplayGainData(forTrack: track)
    }
}
