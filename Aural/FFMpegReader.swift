import Cocoa

class FFMpegReader: MetadataReader {
    
    private func ensureTrackAssetLoaded(_ track: Track) {
        
        if track.libAVInfo == nil {
            track.libAVInfo = FFMpegWrapper.getMetadata(track)
        }
    }

    func getPrimaryMetadata(_ track: Track) -> PrimaryMetadata {
        
        ensureTrackAssetLoaded(track)
        
        let libAVInfo = track.libAVInfo!
        
        let artist = libAVInfo.metadata["artist"]
        let title = libAVInfo.metadata["title"]
        let album = libAVInfo.metadata["album"]
        let genre = libAVInfo.metadata["genre"]
        
        let duration = libAVInfo.duration
        
        return PrimaryMetadata(title, artist, album, genre, duration)
    }
    
    func getSecondaryMetadata(_ track: Track) -> SecondaryMetadata {
        
        ensureTrackAssetLoaded(track)
        
        let art = FFMpegWrapper.getArt(track)
        
        let metadata = track.libAVInfo!.metadata
        
        let discNumber = Int(metadata["disc"] ?? "")
        let trackNumber = Int(metadata["track"] ?? "")
        
        return SecondaryMetadata(art, discNumber, trackNumber)
    }
    
    func getArt(_ track: Track) -> NSImage? {
        return FFMpegWrapper.getArt(track)
    }
    
    func getArt(_ file: URL) -> NSImage? {
        return FFMpegWrapper.getArt(file)
    }
    
    func getAllMetadata() -> [String: String] {
        return [:]
    }
    
    func getPlaybackInfo() -> PlaybackInfo {
        return PlaybackInfo()
    }
}
