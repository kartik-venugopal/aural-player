import Cocoa

class FFMpegReader: MetadataReader {
    
    private let genericMetadata_ignoreKeys: [String] = ["title", "artist", "duration", "disc", "track", "album", "genre"]
    
    private func ensureTrackAssetLoaded(_ track: Track) {
        
        if track.libAVInfo == nil {
            track.libAVInfo = FFMpegWrapper.getMetadata(track)
        }
    }

    func getPrimaryMetadata(_ track: Track) -> PrimaryMetadata {
        
        ensureTrackAssetLoaded(track)
        
        let libAVInfo = track.libAVInfo!
        
        let artist = libAVInfo.metadata["artist"]?.trim()
        let title = libAVInfo.metadata["title"]?.trim()
        let album = libAVInfo.metadata["album"]?.trim()
        let genre = libAVInfo.metadata["genre"]?.trim()
        
        let duration = libAVInfo.duration
        
        return PrimaryMetadata(title, artist, album, genre, duration)
    }
    
    func getSecondaryMetadata(_ track: Track) -> SecondaryMetadata {
        
        ensureTrackAssetLoaded(track)
        
        var art: NSImage? = nil
        
        let cachedArt = AlbumArtCache.forFile(track.file)
        
        if let cachedArtImg = cachedArt.art {
            
            art = cachedArtImg
            
        } else if !cachedArt.fileHasNoArt {
            
            // File may have art, need to read it
            art = FFMpegWrapper.getArt(track)
            AlbumArtCache.addEntry(track.file, art)
        }
        
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
    
    func getAllMetadata(_ track: Track) -> [String: MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        let rawMetadata = track.libAVInfo!.metadata.filter({!genericMetadata_ignoreKeys.contains($0.key)})
        
        for (key, value) in rawMetadata {
            
            let capitalizedKey = key.capitalized
            metadata[capitalizedKey] = MetadataEntry(.other, capitalizedKey, value)
        }
        
        return metadata
    }
    
    func getDurationForFile(_ file: URL) -> Double {
        
        // TODO (not needed yet)
        return 0
    }
}
