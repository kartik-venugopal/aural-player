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
    
    // The delegate object that this object defers all read operations to.
    private var fileReader: FileReaderProtocol
    
    private var coverArtReader: CoverArtReaderProtocol
    
    private lazy var logger: Logger = .init(for: self)
    
    init(_ fileReader: FileReaderProtocol, _ coverArtReader: CoverArtReaderProtocol) {
        
        self.fileReader = fileReader
        self.coverArtReader = coverArtReader
    }
    
    ///
    /// Loads the essential metadata fields that are required for a track to be loaded into the playlist.
    ///
    func loadPrimaryMetadataAsync(for track: Track, onQueue opQueue: OperationQueue, completionHandler: () -> Void) {
        
        if preferences.metadataPreferences.cacheTrackMetadata.value,
            let cachedMetadata = metadataRegistry[track.file] {

            var fileMetadata = FileMetadata(primary: cachedMetadata)
            fileMetadata.primary = cachedMetadata
        }
        
        var fileMetadata: FileMetadata!
        
        do {
            
            let primaryMetadata = try fileReader.getPrimaryMetadata(for: track.file)
            var fileMetadata = FileMetadata(primary: primaryMetadata)
            
//            if !track.file.isNativelySupported {
//                
//                if !durationIsAccurate {
//                    print("For file: \(track.file.path), duration \(primaryMetadata.duration) is inaccurate.")
//                }
//            }
            
        } catch {
            
            fileMetadata.validationError = (error as? DisplayableError) ?? InvalidTrackError(track.file, "Track is not playable.")
            logger.error("Failed to read metadata for track: '\(track.file.path)'. Error: \(error.localizedDescription)")
        }
        
        
    }
    
    private func doLoadPrimaryMetadata(for track: Track, with metadata: FileMetadata, completionHandler: () -> Void) {
        
        track.setPrimaryMetadata(from: metadata)
        
        if track.art == nil {
            track.art = musicBrainzCache.getCoverArt(forTrack: track)
        }
        
        // For non-native tracks that don't have accurate duration, compute duration async.
        
        if !track.isNativelySupported, track.isPlayable, track.duration <= 0 || !metadata.primary.durationIsAccurate {
            computeAccurateDuration(forTrack: track)
        }
        
        
    }
    
    func computeAccurateDuration(forTrack track: Track) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            guard let duration = self.fileReader.computeAccurateDuration(for: track.file), duration > 0 else {return}
            
            track.duration = duration
            track.durationIsAccurate = true
            
            let isCacheEnabled: Bool = preferences.metadataPreferences.cacheTrackMetadata.value
            
            if isCacheEnabled, let metadataInCache = metadataRegistry[track.file] {

                let diff = (abs(metadataInCache.duration - duration) / metadataInCache.duration) * 100.0
                print("Updating duration from \(metadataInCache.duration) -> \(duration), diff = \(diff)")
                metadataInCache.duration = duration
                metadataInCache.durationIsAccurate = true
            }
            
            Messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .duration))
        }
    }
    
    func computePlaybackContext(for track: Track) throws {
        
        track.playbackContext = try fileReader.getPlaybackMetadata(for: track.file)
        
        // If duration has changed as a result of precise computation, set it in the track and send out an update notification
        if !track.durationIsAccurate, let playbackContext = track.playbackContext, track.duration != playbackContext.duration {
            
            track.duration = playbackContext.duration
            Messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .duration))
        }
    }
    
    ///
    /// Loads all metadata and resources that are required for track playback.
    ///
    func prepareForPlayback(track: Track, immediate: Bool = true) throws {
        
        // Make sure track is valid before trying to prep it for playback.
        if let prepError = track.preparationError {
            throw prepError
            
        } else if let validationError = track.validationError {
            
            track.preparationError = validationError
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
            
            track.preparationFailed = true
            
            if let prepError = error as? DisplayableError {
                track.preparationError = prepError
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
        
        if track.art != nil {return}
        
        DispatchQueue.global(qos: immediate ? .userInteractive : .utility).async {
            
            if let art = self.coverArtReader.getCoverArt(forTrack: track) {
                
                track.art = art
                Messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .art))
            }
        }
    }
    
    ///
    /// Loads all non-essential ("auxiliary") metadata associated with a track, for display in the "Detailed track info" view.
    ///
    func loadAuxiliaryMetadata(for track: Track) {
        
        if track.audioInfo == nil {
            
            var audioInfo = fileReader.getAudioInfo(for: track.file, loadingAudioInfoFrom: track.playbackContext)
            audioInfo.replayGainFromMetadata = track.replayGain
            track.setAudioInfo(audioInfo)
            
            loadArtAsync(for: track)
        }
        
        track.audioInfo?.replayGainFromAnalysis = replayGainScanner.cachedReplayGainData(forTrack: track)
    }
}
