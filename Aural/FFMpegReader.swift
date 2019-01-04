import Cocoa

class FFMpegReader: MetadataReader {
    
    private let genericMetadata_ignoreKeys: [String] = ["title", "artist", "duration", "disc", "track", "album", "genre"]
    
    private lazy var muxer: MuxerProtocol = ObjectGraph.muxer
    
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
        
        let duration = getDuration(track)
        
        return PrimaryMetadata(title, artist, album, genre, duration)
    }
    
    func getDuration(_ track: Track) -> Double {
        
        if muxer.trackNeedsMuxing(track), let trackDuration = muxer.muxForDuration(track) {
            return trackDuration
        }
        
        return track.libAVInfo!.duration
    }
    
    func getSecondaryMetadata(_ track: Track) -> SecondaryMetadata {
        
        ensureTrackAssetLoaded(track)
        
        let metadata = track.libAVInfo!.metadata
        
        let discNumMapValue = metadata["disc"]
        let discNumber = discNumMapValue != nil ? parseDiscOrTrackNumber(discNumMapValue!) : nil
        
        let trackNumMapValue = metadata["track"]
        let trackNumber = trackNumMapValue != nil ? parseDiscOrTrackNumber(trackNumMapValue!) : nil

        let lyrics = metadata["lyrics"]
        
        return SecondaryMetadata(discNumber?.number, discNumber?.total, trackNumber?.number, trackNumber?.total, lyrics)
    }
    
    private func parseDiscOrTrackNumber(_ string: String) -> (number: Int?, total: Int?)? {
        
        // Parse string (e.g. "2 / 13")
        
        if let num = Int(string) {
            return (num, nil)
        }
        
        let tokens = string.split(separator: "/")
        
        if !tokens.isEmpty {
            
            let s1 = tokens[0].trim()
            var s2: String?
            
            let n1: Int? = Int(s1)
            var n2: Int?
            
            if tokens.count > 1 {
                s2 = tokens[1].trim()
                n2 = Int(s2!)
            }
            
            return (n1, n2)
        }
        
        return nil
    }
    
    func getArt(_ track: Track) -> NSImage? {
        
        ensureTrackAssetLoaded(track)
        
        if let avInfo = track.libAVInfo {
        
            if avInfo.hasArt {
                return FFMpegWrapper.getArt(track)
            }
        }
        
        return nil
    }
    
    func getArt(_ file: URL) -> NSImage? {
        return FFMpegWrapper.getArt(file)
    }
    
    func getAllMetadata(_ track: Track) -> [String: MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        let rawMetadata = track.libAVInfo!.metadata.filter({!genericMetadata_ignoreKeys.contains($0.key)})
        
        for (key, value) in rawMetadata {
            
            let capitalizedKey = key.capitalized
            metadata[capitalizedKey] = MetadataEntry(.other, .key, capitalizedKey, value)
        }
        
        return metadata
    }
    
    func getDurationForFile(_ file: URL) -> Double {
        
        // TODO (not needed yet)
        return 0
    }
}
