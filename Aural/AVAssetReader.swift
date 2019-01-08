import Cocoa
import AVFoundation

class AVAssetReader: MetadataReader {
    
//    private let parsers: [MetadataParser] = [ObjectGraph.commonMetadataParser, ObjectGraph.id3Parser, ObjectGraph.iTunesParser]
    private let parsers: [MetadataParser] = [ObjectGraph.id3Parser, ObjectGraph.iTunesParser]
    
    private var metadataMap: ConcurrentMap<Track, MappedMetadata> = ConcurrentMap<Track, MappedMetadata>("metadataMap")
    
    private lazy var muxer: MuxerProtocol = ObjectGraph.muxer
    
    // Helper function that ensures that a track's AVURLAsset has been initialized
    private func ensureTrackAssetLoaded(_ track: Track) {
        
        if (track.audioAsset == nil) {
            
            track.audioAsset = AVURLAsset(url: track.file, options: nil)
            mapMetadata(track)
        }
    }
    
    private func mapMetadata(_ track: Track) {
        
        let mapForTrack = MappedMetadata()
        parsers.forEach({$0.mapTrack(track, mapForTrack)})
        metadataMap.put(track, mapForTrack)
    }
    
    func getPrimaryMetadata(_ track: Track) -> PrimaryMetadata {
        
        ensureTrackAssetLoaded(track)
        
        let title = nilIfEmpty(getTitle(track)?.trim())
        let artist = nilIfEmpty(getArtist(track)?.trim())
        let album = nilIfEmpty(getAlbum(track)?.trim())
        let genre = nilIfEmpty(getGenre(track)?.trim())
        
//        print("Genre for", track.file.lastPathComponent, "=", genre != nil ? genre! : "nil")
        
        let duration = getDuration(track)
        
        return PrimaryMetadata(title, artist, album, genre, duration)
    }
    
    private func nilIfEmpty(_ string: String?) -> String? {
        return StringUtils.isStringEmpty(string) ? nil : string
    }
    
    private func getTitle(_ track: Track) -> String? {
        
        if let map = metadataMap.getForKey(track) {
        
            for parser in parsers {
                
                if let title = parser.getTitle(mapForTrack: map) {
                    return title
                }
            }
        }
        
        return nil
    }
    
    private func getArtist(_ track: Track) -> String? {
        
        if let map = metadataMap.getForKey(track) {
            
            for parser in parsers {
                
                if let artist = parser.getArtist(mapForTrack: map) {
                    return artist
                }
            }
        }
        
        return nil
    }
    
    private func getAlbum(_ track: Track) -> String? {
        
        if let map = metadataMap.getForKey(track) {
            
            for parser in parsers {
                
                if let album = parser.getAlbum(mapForTrack: map) {
                    return album
                }
            }
        }
        
        return nil
    }
    
    private func getGenre(_ track: Track) -> String? {
        
        if let map = metadataMap.getForKey(track) {
            
            for parser in parsers {
                
                if let genre = parser.getGenre(mapForTrack: map) {
                    return genre
                }
            }
        }
        
        return nil
    }
    
    func getSecondaryMetadata(_ track: Track) -> SecondaryMetadata {
        
        ensureTrackAssetLoaded(track)
        
        let discInfo = getDiscNumber(track)
        let trackInfo = getTrackNumber(track)
        let lyrics = nilIfEmpty(getLyrics(track))
        
        return SecondaryMetadata(discInfo?.number, discInfo?.total, trackInfo?.number, trackInfo?.total, lyrics)
    }
    
    // Loads duration metadata for a track, if available
    func getDuration(_ track: Track) -> Double {
        
        // Mux raw streams into containers to get accurate duration data (necessary for proper playback)
        if muxer.trackNeedsMuxing(track), let trackDuration = muxer.muxForDuration(track) {
            return trackDuration
        }
        
//        var tlenDuration: Double = 0
//
//        if let map = metadataMap.getForKey(track)?.map, let tlenItem = map[id3Key_duration], let tlenValue = tlenItem.stringValue, let durationMsecs = Double(tlenValue) {
//            tlenDuration = durationMsecs / 1000
//        }
//
//        let assetDuration = track.audioAsset!.duration.seconds
//
//        return max(tlenDuration, assetDuration)
        
        return 5
    }
    
    func getAllMetadata(_ track: Track) -> [String: MetadataEntry] {
        
        ensureTrackAssetLoaded(track)
        
        var metadata: [String: MetadataEntry] = [:]

        if let map = metadataMap.getForKey(track)?.genericMap {

//            for (_, item) in map {
//
//                if let key = item.keyAsString, let value = item.valueAsString {
//                    metadata[key] = MetadataEntry(item.metadataType, key, value)
//                }
//
//                if let extras = item.extraAttributes, !extras.isEmpty {
//
//                    print("\nTrack", track.conciseDisplayName, item.keyAsString, "has", extras.count, "EXTRAS !!!")
//                    for (k, v) in extras {
//                        print("\tEXTRA:", k.rawValue, v)
//                    }
//                }
//            }
        }
        
        return metadata
    }
    
    private func getDiscNumber(_ track: Track) -> (number: Int?, total: Int?)? {
        
        if let map = metadataMap.getForKey(track) {
            
            for parser in parsers {
                
                if let discNum = parser.getDiscNumber(mapForTrack: map) {
                    return discNum
                }
            }
        }
        
        return nil
    }
    
    private func getTrackNumber(_ track: Track) -> (number: Int?, total: Int?)? {
        
        if let map = metadataMap.getForKey(track) {
            
            for parser in parsers {
                
                if let trackNum = parser.getTrackNumber(mapForTrack: map) {
                    return trackNum
                }
            }
        }
        
        return nil
    }
    
    private func getLyrics(_ track: Track) -> String? {
        
        if let map = metadataMap.getForKey(track) {
            
            for parser in parsers {
                
                if let lyrics = parser.getLyrics(mapForTrack: map) {
                    return lyrics
                }
            }
        }
        
        return nil
    }
    
    // TODO: Revisit this func and the use cases needing it
    func getDurationForFile(_ file: URL) -> Double {
        return AVURLAsset(url: file, options: nil).duration.seconds
    }
    
    func getArt(_ track: Track) -> NSImage? {
        
        ensureTrackAssetLoaded(track)
        
        if let map = metadataMap.getForKey(track) {
            
            for parser in parsers {
                
                if let art = parser.getArt(mapForTrack: map) {
                    return art
                }
            }
        }
        
        return nil
    }
    
    func getArt(_ file: URL) -> NSImage? {
        return getArt(AVURLAsset(url: file, options: nil))
    }
    
    // Retrieves artwork for a given track, if available
    private func getArt(_ asset: AVURLAsset) -> NSImage? {
        
        for parser in parsers {
            
            if let art = parser.getArt(asset) {
                return art
            }
        }
        
        return nil
    }
}

extension Data {
    
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

class MappedMetadata {
    
    var map: [String: AVMetadataItem] = [:]
    var genericMap: [String: AVMetadataItem] = [:]
}

extension AVMetadataItem {
    
    var commonKeyAsString: String? {
        return commonKey?.rawValue ?? nil
    }
    
    var keyAsString: String? {
        
        if let key = commonKeyAsString {
            return key
        }
        
        if let key = self.key as? String {
            return key
        }
        
        if let _ = self.keySpace, let id = self.identifier {
            
            let tokens = id.rawValue.split(separator: "/")
            if tokens.count == 2 {
                return String(tokens[1].trim().replacingOccurrences(of: "%A9", with: "@"))
            }
        }
        
        return nil
    }
    
    var valueAsString: String? {

        if !StringUtils.isStringEmpty(self.stringValue) {
            return self.stringValue
        }
        
        if let number = self.numberValue {
            return String(describing: number)
        }
        
        if let data = self.dataValue {
            return String(data: data, encoding: .utf8)
        }
        
        if let date = self.dateValue {
            return String(describing: date)
        }
        
        return nil
    }
    
    var metadataType: MetadataType {
        
        if commonKey != nil {
            return .common
        }
        
        if let keyspace = self.keySpace {
            
            switch keyspace.rawValue {
                
            case AVMetadataKeySpace.common.rawValue:     return .common
                
            case AVMetadataKeySpace.iTunes.rawValue, ITunesLongFormSpec.keySpaceID:     return .iTunes
                
            case AVMetadataKeySpace.id3.rawValue:        return .id3
                
            default:    return .other
                
            }
        }
        
        return .other
    }
}
