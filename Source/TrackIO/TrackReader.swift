//
//  TrackReader.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Handles loading of metadata for a track.
///
class TrackReader {
    
    // The delegate object that this object defers all read operations to.
    private var fileReader: FileReaderProtocol
    
    private var coverArtReader: CoverArtReaderProtocol
    
    private lazy var messenger = Messenger(for: self)
    
    init(_ fileReader: FileReaderProtocol, _ coverArtReader: CoverArtReaderProtocol) {
        
        self.fileReader = fileReader
        self.coverArtReader = coverArtReader
    }
    
    ///
    /// Loads the essential metadata fields that are required for a track to be loaded into the playlist.
    ///
    func loadPlaylistMetadata(for track: Track) {
        
        var fileMetadata = FileMetadata()
        var durationIsAccurate: Bool = true
        
        do {
            
            let playlistMetadata = try fileReader.getPlaylistMetadata(for: track.file)
            fileMetadata.playlist = playlistMetadata
            
            durationIsAccurate = playlistMetadata.durationIsAccurate
            
        } catch {
            
            fileMetadata.validationError = (error as? DisplayableError) ?? InvalidTrackError(track.file, "Track is not playable.")
        }
        
        track.setPlaylistMetadata(from: fileMetadata)
        
        // For non-native tracks that don't have accurate duration, compute duration async.
        
        if !track.isNativelySupported, track.isPlayable, track.duration <= 0 || !durationIsAccurate {
            
            DispatchQueue.global(qos: .userInitiated).async {
                
                if let duration = self.fileReader.computeAccurateDuration(for: track.file), duration > 0 {
                    
                    track.duration = duration
                    track.durationIsAccurate = true
                    
                    self.messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .duration))
                }
            }
        }
    }
    
    private func computePlaybackContext(for track: Track) throws {
        
        track.playbackContext = try fileReader.getPlaybackMetadata(for: track.file)
        
        // If duration has changed as a result of precise computation, set it in the track and send out an update notification
        if !track.durationIsAccurate, let playbackContext = track.playbackContext, track.duration != playbackContext.duration {
            
            track.duration = playbackContext.duration
            messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .duration))
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
                self.messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .art))
            }
        }
    }
    
    ///
    /// Loads all non-essential ("auxiliary") metadata associated with a track, for display in the "Detailed track info" view.
    ///
    func loadAuxiliaryMetadata(for track: Track) {
        
        if track.auxMetadataLoaded {return}
        
        let auxMetadata = fileReader.getAuxiliaryMetadata(for: track.file,
                                                          loadingAudioInfoFrom: track.playbackContext)
        track.setAuxiliaryMetadata(auxMetadata)
        loadArtAsync(for: track)
    }
}
