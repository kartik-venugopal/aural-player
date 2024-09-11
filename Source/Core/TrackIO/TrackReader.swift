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
    func loadPrimaryMetadataAsync(for track: Track, onQueue opQueue: OperationQueue, completionHandler: TrackIOCompletionHandler? = nil) {
        
        if preferences.metadataPreferences.cacheTrackMetadata.value,
            let cachedMetadata = metadataRegistry[track.file] {

            doLoadPrimaryMetadata(for: track, with: cachedMetadata, completionHandler: completionHandler)
            return
        }
        
        opQueue.addOperation {
            
            do {
                
                let primaryMetadata = try fileReader.getPrimaryMetadata(for: track.file)
                self.doLoadPrimaryMetadata(for: track, with: primaryMetadata, completionHandler: completionHandler)
                
            } catch {
                
                track.metadata.validationError = (error as? DisplayableError) ?? InvalidTrackError(track.file, "Track is not playable.")
                self.logger.error("Failed to read metadata for track: '\(track.file.path)'. Error: \(error.localizedDescription)")
            }
        }
    }
    
    private func doLoadPrimaryMetadata(for track: Track, with metadata: PrimaryMetadata, completionHandler: TrackIOCompletionHandler?) {
        
        track.metadata.primary = metadata
        
        if metadata.art == nil {
            metadata.art = musicBrainzCache.getCoverArt(forTrack: track)
        }
        
        let durationIsAccurate = metadata.durationIsAccurate
        
        // For non-native tracks that don't have accurate duration, compute duration async.
        
        if !track.isNativelySupported, track.isPlayable, track.duration <= 0 || !durationIsAccurate {
            computeAccurateDuration(forTrack: track)
        }
        
        completionHandler?()
    }
    
    func computeAccurateDuration(forTrack track: Track) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            
            guard let duration = fileReader.computeAccurateDuration(for: track.file), duration > 0 else {return}
            
            track.metadata.primary?.duration = duration
            track.metadata.primary?.durationIsAccurate = true
            
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
            
            track.metadata.primary?.duration = playbackContext.duration
            Messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .duration))
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
    /// Loads cover art for a track, asynchronously. This is useful when
    /// cover art is not required immediately, and a short delay is acceptable.
    /// (eg. when preparing for playback)
    ///
    func loadArtAsync(for track: Track, immediate: Bool = true) {
        
        if track.art?.originalImage != nil {print("Has Art !!!"); return}
        
        DispatchQueue.global(qos: immediate ? .userInteractive : .utility).async {
            
            guard let art = coverArtReader.getCoverArt(forTrack: track) else {return}
            
            if let existingArt = track.art {
                existingArt.merge(withOther: art)
                print("Merged Art !!!")
            } else {
                track.metadata.primary?.art = art
            }
            
            Messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .art))
        }
    }
    
    ///
    /// Loads all non-essential ("auxiliary") metadata associated with a track, for display in the "Detailed track info" view.
    ///
    func loadAuxiliaryMetadata(for track: Track) {
        
        if track.audioInfo == nil {
            
            var audioInfo = fileReader.getAudioInfo(for: track.file, loadingAudioInfoFrom: track.playbackContext)
            audioInfo.replayGainFromMetadata = track.replayGain
            track.metadata.audioInfo = audioInfo
            
            loadArtAsync(for: track)
        }
        
        track.metadata.audioInfo?.replayGainFromAnalysis = replayGainScanner.cachedReplayGainData(forTrack: track)
    }
}
