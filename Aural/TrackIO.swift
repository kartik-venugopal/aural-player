/*
    Reads track info from the filesystem
 */

import Cocoa
import AVFoundation

class TrackIO {
    
    // Load display metadata (artist/title/art and all grouping info)
    static func loadDisplayInfo(_ track: Track) {
        
        let fileExtension = track.file.pathExtension.lowercased()
        
        if !track.nativelySupported || fileExtension == "flac" {
            track.libAVInfo = LibAVWrapper.getMetadata(track.file)
        } else {
            track.audioAsset = AVURLAsset(url: track.file, options: nil)
        }
        
        MetadataReader.loadDisplayMetadata(track)
        MetadataReader.loadGroupingMetadata(track)
    }
    
    // Load duration metadata
    static func loadDuration(_ track: Track) {
        MetadataReader.loadDurationMetadata(track)
    }
    
    // Load all the information required to play this track
    static func prepareForPlayback(_ track: Track) {
        
        let lazyLoadInfo = track.lazyLoadingInfo
        
        if (lazyLoadInfo.preparedForPlayback || lazyLoadInfo.preparationFailed) {
            return
        }
        
        // Validate the audio track
        if let prepError = AudioUtils.validateTrack(track) {
            
            // Note any error encountered
            lazyLoadInfo.preparationFailed(prepError)
            return
        }
        
        // Track is valid, prepare it for playback
        if AudioUtils.loadPlaybackInfo(track) {
            
            lazyLoadInfo.preparedForPlayback = true
            
        } else {
            
            // If track couldn't be prepared, mark it as not playable
            lazyLoadInfo.preparationFailed(TrackNotPlayableError(track))
        }
    }
    
    // Load detailed track info
    static func loadDetailedInfo(_ track: Track) {
        
        if (track.lazyLoadingInfo.detailedInfoLoaded) {
            return
        }
        
        if (!track.lazyLoadingInfo.preparedForPlayback) {
            prepareForPlayback(track)
        }
        
        // Audio info
        AudioUtils.loadAudioInfo(track)
        
        // Filesystem info
        track.fileSystemInfo.size = FileSystemUtils.sizeOfFile(path: track.file.path)
        
        // ID3 / ITunes / other metadata
        MetadataReader.loadAllMetadata(track)
        
        track.lazyLoadingInfo.detailedInfoLoaded = true
    }
}
