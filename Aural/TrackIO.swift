/*
    Reads track info from the filesystem
 */

import Cocoa
import AVFoundation

class TrackIO {
    
    // Load duration and display metadata (artist/title/art)
    static func loadDisplayInfo(_ track: Track) {
        
        track.audioAsset = AVURLAsset(url: track.file, options: nil)
        MetadataReader.loadDisplayMetadata(track)
        MetadataReader.loadGroupingMetadata(track)
    }
    
    static func loadDuration(_ track: Track) {
        MetadataReader.loadDurationMetadata(track)
    }
    
    // Load all the information required to play this track
    static func prepareForPlayback(_ track: Track) {
        
        let lazyLoadInfo = track.lazyLoadingInfo
        
        if (lazyLoadInfo.preparedForPlayback || lazyLoadInfo.preparationFailed) {
            return
        }
        
        if let prepError = AudioUtils.validateTrack(track) {
            
            lazyLoadInfo.preparationFailed(prepError)
            return
        }
        
        if let playbackInfo = AudioUtils.getPlaybackInfo(track) {
            
            track.playbackInfo = playbackInfo
            lazyLoadInfo.preparedForPlayback = true
            
        } else {
            lazyLoadInfo.preparationFailed(TrackNotPlayableError(track.file))
        }
    }
    
    // Load detailed track info
    static func loadDetailedTrackInfo(_ track: Track) {
        
        let lazyLoadInfo = track.lazyLoadingInfo
        
        if (lazyLoadInfo.detailedInfoLoaded) {
            return
        }
        
        track.audioInfo = AudioUtils.getAudioInfo(track)
        track.fileSystemInfo.size = FileSystemUtils.sizeOfFile(path: track.file.path)
        
        MetadataReader.loadAllMetadata(track)
        
        lazyLoadInfo.detailedInfoLoaded = true
    }
}
