/*
    Reads track info from the filesystem
 */

import Cocoa
import AVFoundation

class TrackIO {
    
    // Load display metadata (artist/title/art and all grouping info)
    static func loadPrimaryInfo(_ track: Track) {
        MetadataUtils.loadPrimaryMetadata(track)
    }
    
    static func loadSecondaryInfo(_ track: Track) {
        MetadataUtils.loadSecondaryMetadata(track)
    }

    // Load duration metadata
//    static func loadDuration(_ track: Track) {
//        MetadataUtils.loadDuration(track)
//    }
    
//    static func durationNotLoaded(_ track: Track, _ index: Int, _ retryCount: Int = 3) {
//
//        if retryCount > 0 {
//
//            DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 2, execute: {
//
//                NSLog("Retrying duration for %@ ... retryCount=%d", track.conciseDisplayName, retryCount)
//                print(String(format: "Retrying duration for %@ ... retryCount=%d", track.conciseDisplayName, retryCount))
//
//                MetadataUtils.loadDurationMetadata(track)
//
//                if track.duration > 0 {
//
//                    NSLog("Finally got duration %.2lf for %@ ... retryCount=%d", track.duration, track.conciseDisplayName, retryCount)
//                    print(String(format: "Finally got duration %.2lf for %@ ... retryCount=%d", track.duration, track.conciseDisplayName, retryCount))
//
//                    AsyncMessenger.publishMessage(TrackUpdatedAsyncMessage(index, [:]))
//
//                } else {
//
//                    // Recursive call
//                    durationNotLoaded(track, index, retryCount - 1)
//                }
//            })
//        }
//    }
    
    // Load all the information required to play this track
    static func prepareForPlayback(_ track: Track) {
        
        if track.displayInfo.art == nil {
            MetadataUtils.loadArt(track)
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
        
        // Track is valid, prepare it for playback
        AudioUtils.loadPlaybackInfo(track)
        if !lazyLoadInfo.preparedForPlayback && !lazyLoadInfo.needsTranscoding {
            
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
        MetadataUtils.loadAllMetadata(track)
        
        track.lazyLoadingInfo.detailedInfoLoaded = true
    }
}
