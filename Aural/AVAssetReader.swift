import Cocoa
import AVFoundation

class AVAssetReader: MetadataReader, AsyncMessageSubscriber {
    
    private let parsers: [AVAssetParser] = {
        
        // Audio Toolbox metadata is available >= macOS 10.13
        
        let osVersion = SystemUtils.osVersion
        
        if (osVersion.majorVersion == 10 && osVersion.minorVersion >= 13) || osVersion.majorVersion > 10 {
            return [ObjectGraph.commonAVAssetParser, ObjectGraph.id3Parser, ObjectGraph.iTunesParser, ObjectGraph.audioToolboxParser]
        } else {
            return [ObjectGraph.commonAVAssetParser, ObjectGraph.id3Parser, ObjectGraph.iTunesParser]
        }
    }()
    
    private var metadataMap: ConcurrentMap<Track, AVAssetMetadata> = ConcurrentMap<Track, AVAssetMetadata>("metadataMap")
    
    private lazy var muxer: MuxerProtocol = ObjectGraph.muxer
    
    let subscriberId: String = "AVAssetReader"
    
    init() {
        AsyncMessenger.subscribe([.tracksRemoved], subscriber: self, dispatchQueue: DispatchQueue.global(qos: .background))
    }
    
    // Helper function that ensures that a track's AVURLAsset has been initialized
    private func ensureTrackAssetLoaded(_ track: Track) {
        
        if (track.audioAsset == nil) {
            
            track.audioAsset = AVURLAsset(url: track.file, options: nil)
            mapMetadata(track)
        }
    }
    
    private func mapMetadata(_ track: Track) {
        
        let mapForTrack = AVAssetMetadata()
        parsers.forEach({$0.mapTrack(track, mapForTrack)})
        metadataMap.put(track, mapForTrack)
    }
    
    func getPrimaryMetadata(_ track: Track) -> PrimaryMetadata {
        
        ensureTrackAssetLoaded(track)
        
        let title = nilIfEmpty(getTitle(track))
        let artist = nilIfEmpty(getArtist(track))
        let album = nilIfEmpty(getAlbum(track))
        let genre = nilIfEmpty(getGenre(track))
        
        let duration = getDuration(track)
        
        return PrimaryMetadata(title, artist, album, genre, duration)
    }
    
    private func nilIfEmpty(_ string: String?) -> String? {
        return StringUtils.isStringEmpty(string) ? nil : string
    }
    
    func getDuration(_ track: Track) -> Double {
        
        // Mux raw streams into containers to get accurate duration data (necessary for proper playback)
        if muxer.trackNeedsMuxing(track), let trackDuration = muxer.muxForDuration(track) {
            return trackDuration
        }
        
        var maxDuration: Double = track.audioAsset!.duration.seconds
        
        for parser in parsers {
            
            if let map = metadataMap.getForKey(track), let duration = parser.getDuration(map), duration > maxDuration {
                maxDuration = duration
            }
        }
        
        return maxDuration
    }
    
    private func getTitle(_ track: Track) -> String? {
        
        if let map = metadataMap.getForKey(track) {
        
            for parser in parsers {
                
                if let title = parser.getTitle(map) {
                    return title
                }
            }
        }
        
        return nil
    }
    
    private func getArtist(_ track: Track) -> String? {
        
        if let map = metadataMap.getForKey(track) {
            
            for parser in parsers {
                
                if let artist = parser.getArtist(map) {
                    return artist
                }
            }
        }
        
        return nil
    }
    
    private func getAlbum(_ track: Track) -> String? {
        
        if let map = metadataMap.getForKey(track) {
            
            for parser in parsers {
                
                if let album = parser.getAlbum(map) {
                    return album
                }
            }
        }
        
        return nil
    }
    
    private func getGenre(_ track: Track) -> String? {
        
        if let map = metadataMap.getForKey(track) {
            
            for parser in parsers {
                
                if let genre = parser.getGenre(map) {
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
    
    private func getDiscNumber(_ track: Track) -> (number: Int?, total: Int?)? {
        
        if let map = metadataMap.getForKey(track) {
            
            for parser in parsers {
                
                if let discNum = parser.getDiscNumber(map) {
                    return discNum
                }
            }
        }
        
        return nil
    }
    
    private func getTrackNumber(_ track: Track) -> (number: Int?, total: Int?)? {
        
        if let map = metadataMap.getForKey(track) {
            
            for parser in parsers {
                
                if let trackNum = parser.getTrackNumber(map) {
                    return trackNum
                }
            }
        }
        
        return nil
    }
    
    private func getLyrics(_ track: Track) -> String? {
        
        if let lyrics = track.audioAsset?.lyrics {
            return lyrics
        }
        
        if let map = metadataMap.getForKey(track) {
            
            for parser in parsers {
                
                if let lyrics = parser.getLyrics(map) {
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
    
    func getAllMetadata(_ track: Track) -> [String: MetadataEntry] {
        
        ensureTrackAssetLoaded(track)
        
        var metadata: [String: MetadataEntry] = [:]
        
        if let map = metadataMap.getForKey(track) {
            
            for parser in parsers {
                
                let parserMetadata = parser.getGenericMetadata(map)
                parserMetadata.forEach({(k,v) in metadata[k] = v})
            }
        }
        
        return metadata
    }
    
    func getArt(_ track: Track) -> CoverArt? {
        
        ensureTrackAssetLoaded(track)
        
        if let map = metadataMap.getForKey(track) {
            
            for parser in parsers {
                
                if let art = parser.getArt(map) {
                    return art
                }
            }
        }
        
        return nil
    }
    
    func getArt(_ file: URL) -> CoverArt? {
        return getArt(AVURLAsset(url: file, options: nil))
    }
    
    // Retrieves artwork for a given track, if available
    private func getArt(_ asset: AVURLAsset) -> CoverArt? {
        
        for parser in parsers {
            
            if let art = parser.getArt(asset) {
                return art
            }
        }
        
        return nil
    }
    
    func consumeAsyncMessage(_ message: AsyncMessage) {
        
        if message.messageType == .tracksRemoved {
            
            let msg = message as! TracksRemovedAsyncMessage
            for track in msg.results.tracks {
                metadataMap.remove(track)
            }
        }
    }
}

extension Data {
    
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

class AVAssetMetadata {
    
    var map: [String: AVMetadataItem] = [:]
    var genericItems: [AVMetadataItem] = []
}

extension AVMetadataItem {
    
    var commonKeyAsString: String? {
        return commonKey?.rawValue ?? nil
    }
    
    var keyAsString: String? {
        
        if let key = self.key as? String {
            return StringUtils.cleanUpString(key).trim()
        }
        
        if let id = self.identifier {
            
            let tokens = id.rawValue.split(separator: "/")
            if tokens.count == 2 {
                return StringUtils.cleanUpString(String(tokens[1].trim().replacingOccurrences(of: "%A9", with: "@"))).trim()
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
    
    var valueAsNumericalString: String {
        
        if !StringUtils.isStringEmpty(self.stringValue), let num = Int(self.stringValue!) {
            return String(describing: num)
        }
        
        if let number = self.numberValue {
            return String(describing: number)
        }
        
        if let data = self.dataValue, let num = Int(data.hexEncodedString(), radix: 16) {
            return String(describing: num)
        }
        
        return "0"
    }
}
