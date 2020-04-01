/*
    Reads track info from the filesystem
 */

import Cocoa
import AVFoundation

class TrackIO {
    
    // Load display metadata (artist/title/art and all grouping info)
    static func loadPrimaryInfo(_ track: Track) {
        
        MetadataUtils.loadPrimaryMetadata(track)
        track.lazyLoadingInfo.primaryInfoLoaded = true
    }
    
    static func loadSecondaryInfo(_ track: Track) {
        
        MetadataUtils.loadSecondaryMetadata(track)
        track.lazyLoadingInfo.secondaryInfoLoaded = true
    }

    // Load all the information required to play this track
    static func prepareForPlayback(_ track: Track) {
        
        // Art
        if track.displayInfo.art == nil {
            
            DispatchQueue.global(qos: .userInteractive).async {
                
                MetadataUtils.loadArt(track)
                
                // Only do this if there is art to show
                if track.displayInfo.art != nil {
                    AsyncMessenger.publishMessage(TrackUpdatedAsyncMessage(track))
                }
            }
        }
        
        let lazyLoadInfo = track.lazyLoadingInfo
        
        if (lazyLoadInfo.preparedForPlayback || lazyLoadInfo.preparationFailed) {
            return
        }
        
        // Track is valid, prepare it for playback
        AudioUtils.loadPlaybackInfo(track)
        if !lazyLoadInfo.preparedForPlayback && !lazyLoadInfo.needsTranscoding {
            
            // If track couldn't be prepared, mark it as not playable
            lazyLoadInfo.preparationFailed(TrackNotPlayableError(track))
        }
    }
    
    static func prepareForInfo(_ track: Track) {
        
        // Art
        if track.displayInfo.art == nil {
            
            DispatchQueue.global(qos: .userInteractive).async {
                
                MetadataUtils.loadArt(track)
                
                // Only do this if there is art to show
                if track.displayInfo.art != nil {
                    AsyncMessenger.publishMessage(TrackUpdatedAsyncMessage(track))
                }
            }
        }
        
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
        
        // Track is valid, prepare it for displaying info
        AudioUtils.loadPlaybackInfo_noPlayback(track)
    }
    
    // Load detailed track info
    static func loadDetailedInfo(_ track: Track) {
        
        if track.lazyLoadingInfo.detailedInfoLoaded {
            return
        }
        
        if !track.lazyLoadingInfo.preparedForPlayback {
            prepareForInfo(track)
        }
        
        // Audio info
        AudioUtils.loadAudioInfo(track)
        
        let attrs = FileSystemUtils.fileAttributes(path: track.file.path)
        
        // Filesystem info
        track.fileSystemInfo.size = attrs.size
        track.fileSystemInfo.creationDate = attrs.creationDate
        track.fileSystemInfo.kindOfFile = attrs.kindOfFile
        track.fileSystemInfo.lastModified = attrs.lastModified
        track.fileSystemInfo.lastOpened = attrs.lastOpened
        
        // ID3 / ITunes / other metadata
        MetadataUtils.loadAllMetadata(track)
        
        track.lazyLoadingInfo.detailedInfoLoaded = true
    }
}
