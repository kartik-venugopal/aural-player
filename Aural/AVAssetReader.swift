import Cocoa
import AVFoundation

class AVAssetReader: MetadataReader {
    
    // Title
    private let commonId_title: AVMetadataIdentifier = AVMetadataIdentifier.commonIdentifierTitle
    private let iTunesId_title: AVMetadataIdentifier = AVMetadataIdentifier.iTunesMetadataSongName
    private let id3Id_title: AVMetadataIdentifier = AVMetadataIdentifier.id3MetadataTitleDescription
    
    // Artist
    private let commonId_artist: AVMetadataIdentifier = AVMetadataIdentifier.commonIdentifierArtist
    private let iTunesId_artist: AVMetadataIdentifier = AVMetadataIdentifier.iTunesMetadataArtist
    private let iTunesId_albumArtist: AVMetadataIdentifier = AVMetadataIdentifier.iTunesMetadataAlbumArtist
    private let id3Id_artist: AVMetadataIdentifier = AVMetadataIdentifier.id3MetadataOriginalArtist
    private let id3Id_band: AVMetadataIdentifier = AVMetadataIdentifier.id3MetadataBand
    
    // Album
    private let commonId_album: AVMetadataIdentifier = AVMetadataIdentifier.commonIdentifierAlbumName
    private let iTunesId_album: AVMetadataIdentifier = AVMetadataIdentifier.iTunesMetadataAlbum
    private let id3Id_album: AVMetadataIdentifier = AVMetadataIdentifier.id3MetadataAlbumTitle
    private let id3Id_origAlbum: AVMetadataIdentifier = AVMetadataIdentifier.id3MetadataOriginalAlbumTitle
    
    // Genre
    private let commonId_genre: AVMetadataIdentifier = AVMetadataIdentifier.commonIdentifierType
    private let iTunesId_genre: AVMetadataIdentifier = AVMetadataIdentifier.iTunesMetadataUserGenre
    private let iTunesId_predefinedGenre: AVMetadataIdentifier = AVMetadataIdentifier.iTunesMetadataPredefinedGenre
    private let id3Id_genre: AVMetadataIdentifier = AVMetadataIdentifier.id3MetadataContentType
    
    private let commonId_art: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.commonKeyArtwork.rawValue, keySpace: AVMetadataKeySpace.common)!
    
    // Identifier for ID3 TLEN metadata item
    private let id3Id_TLEN: AVMetadataIdentifier = AVMetadataIdentifier(rawValue: AVMetadataKey.id3MetadataKeyLength.rawValue)
    
    private let id3Id_discNum: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.id3MetadataKeyPartOfASet.rawValue, keySpace: AVMetadataKeySpace.id3)!

    private let id3Id_trackNum: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.id3MetadataKeyTrackNumber.rawValue, keySpace: AVMetadataKeySpace.id3)!
    
        private let id3Id_lyrics: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.id3MetadataKeyUnsynchronizedLyric.rawValue, keySpace: AVMetadataKeySpace.id3)!
    
    private let id3Id_syncLyrics: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.id3MetadataKeySynchronizedLyric.rawValue, keySpace: AVMetadataKeySpace.id3)!
    
    private let iTunesId_lyrics: AVMetadataIdentifier = AVMetadataIdentifier.iTunesMetadataLyrics
    
    private let iTunesId_discNum: AVMetadataIdentifier = AVMetadataIdentifier(rawValue: AVMetadataKey.iTunesMetadataKeyDiscNumber.rawValue)
    private let iTunesId_trackNum: AVMetadataIdentifier = AVMetadataIdentifier(rawValue: AVMetadataKey.iTunesMetadataKeyTrackNumber.rawValue)
    
    private let genericMetadata_ignoreKeys: [String] = [AVMetadataKey.commonKeyTitle.rawValue, AVMetadataKey.commonKeyArtist.rawValue, AVMetadataKey.commonKeyArtwork.rawValue, AVMetadataKey.commonKeyAlbumName.rawValue, AVMetadataKey.commonKeyType.rawValue, AVMetadataKey.iTunesMetadataKeyDiscNumber.rawValue, AVMetadataKey.iTunesMetadataKeyTrackNumber.rawValue, AVMetadataKey.id3MetadataKeyPartOfASet.rawValue, AVMetadataKey.id3MetadataKeyTrackNumber.rawValue, AVMetadataKey.iTunesMetadataKeyLyrics.rawValue, AVMetadataKey.id3MetadataKeyUnsynchronizedLyric.rawValue, AVMetadataKey.id3MetadataKeySynchronizedLyric.rawValue]
    
    private let genericMetadata_ignoreIDs: [String] = [AVMetadataIdentifier.commonIdentifierTitle.rawValue, AVMetadataIdentifier.commonIdentifierArtist.rawValue, AVMetadataIdentifier.commonIdentifierArtwork.rawValue, AVMetadataIdentifier.commonIdentifierAlbumName.rawValue, AVMetadataIdentifier.commonIdentifierType.rawValue, AVMetadataIdentifier.iTunesMetadataDiscNumber.rawValue, AVMetadataIdentifier.iTunesMetadataTrackNumber.rawValue, AVMetadataIdentifier.id3MetadataPartOfASet.rawValue, AVMetadataIdentifier.id3MetadataTrackNumber.rawValue, AVMetadataIdentifier.iTunesMetadataAlbumArtist.rawValue, AVMetadataIdentifier.iTunesMetadataUserGenre.rawValue, AVMetadataIdentifier.iTunesMetadataLyrics.rawValue, AVMetadataIdentifier.id3MetadataUnsynchronizedLyric.rawValue, AVMetadataIdentifier.id3MetadataSynchronizedLyric.rawValue]
    
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
        
        let items = track.audioAsset!.metadata
        
        var map: [String: AVMetadataItem] = [:]
        
        for item in items {
            
            if let mapKey = mapKeyForItem(item) {
                map[mapKey] = item
            }
            
            let mapForTrack = MappedMetadata()
            mapForTrack.map = map
            
            metadataMap.put(track, mapForTrack)
        }
    }
    
    private func mapKeyForItem(_ item: AVMetadataItem) -> String? {
        
        if let ckey = item.commonKey?.rawValue {
            
            return String(format: "%@/%@", AVMetadataKeySpace.common.rawValue, ckey)
            
        } else if let skey = item.key as? String, let itemKeySpace = item.keySpace {
            
            return String(format: "%@/%@", itemKeySpace.rawValue, skey)
            
        } else if let ikey = item.key as? Int, let itemKeySpace = item.keySpace, let id = AVMetadataItem.identifier(forKey: ikey, keySpace: itemKeySpace) {
            
            return id.rawValue.replacingOccurrences(of: "%A9", with: "@")
        }
        
        return nil
    }
    
    // Retrieves the common metadata entry for the given track, with the given metadata key, if there is one
    private func getMetadataForId(_ asset: AVURLAsset, _ id: AVMetadataIdentifier) -> String? {
        
        let items = AVMetadataItem.metadataItems(from: asset.metadata, filteredByIdentifier: id)
        
        if let first = items.first {
            
            if !StringUtils.isStringEmpty(first.stringValue) {
                return first.stringValue
            } else {
                return String(describing: first.value)
            }
        }
        
        return nil
    }
    
    // Retrieves artwork for a given track, if available
    private func getArt(_ asset: AVURLAsset) -> NSImage? {
        
        let items = AVMetadataItem.metadataItems(from: asset.commonMetadata, filteredByIdentifier: commonId_art)
        
        if let first = items.first, let imgData = first.dataValue {
            return NSImage(data: imgData)
        }
        
        return nil
    }
    
    func getPrimaryMetadata(_ track: Track) -> PrimaryMetadata {
        
        ensureTrackAssetLoaded(track)
        
        let title = getTitle(track)?.trim()
        let artist = getArtist(track)?.trim()
        let album = getAlbum(track)?.trim()
        let genre = getGenre(track)?.trim()
        
        let duration = getDuration(track)
        
        return PrimaryMetadata(title, artist, album, genre, duration)
    }
    
    private func getArtist(_ track: Track) -> String? {
     
        if let map = metadataMap.getForKey(track)?.map {
            
            // Common
            
            let commonKey = String(format: "%@/%@", AVMetadataKeySpace.common.rawValue, AVMetadataKey.commonKeyArtist.rawValue)
            
            if let artistItem = map[commonKey], let str = artistItem.stringValue {
                return str
            }
            
            // iTunes
            
            var iTunesKey = String(format: "%@/%@", AVMetadataKeySpace.iTunes.rawValue, AVMetadataKey.iTunesMetadataKeyArtist.rawValue)
            
            if let artistItem = map[iTunesKey], let str = artistItem.stringValue {
                return str
            }
            
            iTunesKey = String(format: "%@/%@", AVMetadataKeySpace.iTunes.rawValue, AVMetadataKey.iTunesMetadataKeyAlbumArtist.rawValue)
            
            if let artistItem = map[iTunesKey], let str = artistItem.stringValue {
                return str
            }
            
            // ID3
            
            var id3Key = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, AVMetadataKey.id3MetadataKeyOriginalArtist.rawValue)
            
            if let artistItem = map[id3Key], let str = artistItem.stringValue {
                return str
            }
            
            id3Key = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, AVMetadataKey.id3MetadataKeyBand.rawValue)
            
            if let artistItem = map[id3Key], let str = artistItem.stringValue {
                return str
            }
        }
        
        return nil
    }
    
    private func getTitle(_ track: Track) -> String? {
        
        if let map = metadataMap.getForKey(track)?.map {
            
            let commonKey = String(format: "%@/%@", AVMetadataKeySpace.common.rawValue, AVMetadataKey.commonKeyTitle.rawValue)
            
            if let titleItem = map[commonKey], let str = titleItem.stringValue {
                return str
            }
            
            let iTunesKey = String(format: "%@/%@", AVMetadataKeySpace.iTunes.rawValue, AVMetadataKey.iTunesMetadataKeySongName.rawValue)
            
            if let titleItem = map[iTunesKey], let str = titleItem.stringValue {
                return str
            }
            
            let id3Key = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, AVMetadataKey.id3MetadataKeyTitleDescription.rawValue)
            
            if let titleItem = map[id3Key], let str = titleItem.stringValue {
                return str
            }
        }
        
        return nil
    }
    
    private func getAlbum(_ track: Track) -> String? {
        
        if let map = metadataMap.getForKey(track)?.map {
            
            let commonKey = String(format: "%@/%@", AVMetadataKeySpace.common.rawValue, AVMetadataKey.commonKeyAlbumName.rawValue)
            
            if let albumItem = map[commonKey], let str = albumItem.stringValue {
                return str
            }
            
            let iTunesKey = String(format: "%@/%@", AVMetadataKeySpace.iTunes.rawValue, AVMetadataKey.iTunesMetadataKeyAlbum.rawValue)
            
            if let albumItem = map[iTunesKey], let str = albumItem.stringValue {
                return str
            }
            
            var id3Key = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, AVMetadataKey.id3MetadataKeyAlbumTitle.rawValue)
            
            if let albumItem = map[id3Key], let str = albumItem.stringValue {
                return str
            }
            
            id3Key = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, AVMetadataKey.id3MetadataKeyOriginalAlbumTitle.rawValue)
            
            if let albumItem = map[id3Key], let str = albumItem.stringValue {
                return str
            }
        }
        
        return nil
    }
    
    private func getGenre(_ track: Track) -> String? {
        
        if let map = metadataMap.getForKey(track)?.map {
            
            let commonKey = String(format: "%@/%@", AVMetadataKeySpace.common.rawValue, AVMetadataKey.commonKeyType.rawValue)
            
            if let genreItem = map[commonKey], let str = genreItem.stringValue {
                return str
            }
            
            var iTunesKey = String(format: "%@/%@", AVMetadataKeySpace.iTunes.rawValue, AVMetadataKey.iTunesMetadataKeyUserGenre.rawValue)
            
            if let genreItem = map[iTunesKey], let str = genreItem.stringValue {
                return str
            }
            
            iTunesKey = String(format: "%@/%@", AVMetadataKeySpace.iTunes.rawValue, AVMetadataKey.iTunesMetadataKeyPredefinedGenre.rawValue)
            
            if let genreItem = map[iTunesKey], let str = genreItem.stringValue {
                return str
            }
            
            let id3Key = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, AVMetadataKey.id3MetadataKeyContentType.rawValue)
            
            if let genreItem = map[id3Key], let str = genreItem.stringValue {
                return str
            }
            
            // TODO: If ID3 genre is numerical (data value), map it to a string (need to define genres in ID3 spec)
        }
        
        return nil
    }
    
    func getSecondaryMetadata(_ track: Track) -> SecondaryMetadata {
        
        ensureTrackAssetLoaded(track)
        
        let discInfo = getDiscNumber(track)
        let trackInfo = getTrackNumber(track)
        
        return SecondaryMetadata(discInfo?.number, discInfo?.total, trackInfo?.number, trackInfo?.total, getLyrics(track))
    }
    
    // Loads duration metadata for a track, if available
    func getDuration(_ track: Track) -> Double {
        
        // Mux raw streams into containers to get accurate duration data (necessary for proper playback)
        if muxer.trackNeedsMuxing(track), let trackDuration = muxer.muxForDuration(track) {
            return trackDuration
        }
        
        var tlenDuration: Double = 0
        
        if let tlenValue = getMetadataForId(track.audioAsset!, id3Id_TLEN) {
            
            if let durationMsecs = Double(tlenValue) {
                tlenDuration = durationMsecs / 1000
            }
        }
        
        let assetDuration = track.audioAsset!.duration.seconds
        
        return max(tlenDuration, assetDuration)
    }
    
    func getArt(_ track: Track) -> NSImage? {
        
        ensureTrackAssetLoaded(track)
        return getArt(track.audioAsset!)
    }
    
    func getArt(_ file: URL) -> NSImage? {
        return getArt(AVURLAsset(url: file, options: nil))
    }
    
    func getAllMetadata(_ track: Track) -> [String: MetadataEntry] {
        
        ensureTrackAssetLoaded(track)
        
        var metadata: [String: MetadataEntry] = [:]

        // Check which metadata formats are available
        let formats = track.audioAsset!.availableMetadataFormats

        // Iterate through the formats and collect metadata for each one
        for format in formats {

            let metadataType: MetadataType
            
            switch format.rawValue {

            case AVMetadataFormat.iTunesMetadata.rawValue: metadataType = .iTunes

            case AVMetadataFormat.id3Metadata.rawValue: metadataType = .id3
                
            case ITunesLongFormSpec.formatID:   metadataType = .iTunesLongForm

            default: metadataType = .other

            }

            let items = track.audioAsset!.metadata(forFormat: format)

            // Iterate through all metadata for this format
            for item in items {
                
                let stringValue = item.stringValue?.trim()

                if let key = item.commonKey?.rawValue {

                    // Ignore the display metadata keys (that have already been loaded)
                    if !genericMetadata_ignoreKeys.contains(key) && !StringUtils.isStringEmpty(stringValue) {
                        metadata[key] = MetadataEntry(.common, .key, key, stringValue!)
                    }

                } else if let key = item.key as? String, !genericMetadata_ignoreKeys.contains(key), !StringUtils.isStringEmpty(stringValue) {

                    metadata[key] = MetadataEntry(metadataType, .key, key, stringValue!)

                } else if let key = item.key as? Int, let keySpace = item.keySpace, !StringUtils.isStringEmpty(stringValue), let id = AVMetadataItem.identifier(forKey: key, keySpace: keySpace), !genericMetadata_ignoreIDs.contains(id.rawValue) {
                    
                    metadata[id.rawValue] = MetadataEntry(metadataType, .id, id.rawValue, stringValue!)
                }
            }
        }
        
        return metadata
    }
    
    private func getDiscNumber(_ track: Track) -> (number: Int?, total: Int?)? {
        
        if let map = metadataMap.getForKey(track)?.map {
            
            let iTunesKey = String(format: "%@/%@", AVMetadataKeySpace.iTunes.rawValue, AVMetadataKey.iTunesMetadataKeyDiscNumber.rawValue)
            
            if let item = map[iTunesKey], let discNum = parseDiscOrTrackNumber(item) {
                return discNum
            }
            
            let id3Key = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, AVMetadataKey.id3MetadataKeyPartOfASet.rawValue)
            
            if let item = map[id3Key], let discNum = parseDiscOrTrackNumber(item) {
                return discNum
            }
        }
        
        return nil
    }
    
    private func getTrackNumber(_ track: Track) -> (number: Int?, total: Int?)? {
        
        if let map = metadataMap.getForKey(track)?.map {
            
            let iTunesKey = String(format: "%@/%@", AVMetadataKeySpace.iTunes.rawValue, AVMetadataKey.iTunesMetadataKeyTrackNumber.rawValue)
            
            if let item = map[iTunesKey], let trackNum = parseDiscOrTrackNumber(item) {
                return trackNum
            }
            
            let id3Key = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, AVMetadataKey.id3MetadataKeyTrackNumber.rawValue)
            
            if let item = map[id3Key], let trackNum = parseDiscOrTrackNumber(item) {
                return trackNum
            }
        }
        
        return nil
    }
    
    private func parseDiscOrTrackNumber(_ item: AVMetadataItem) -> (number: Int?, total: Int?)? {
        
        if let stringValue = item.stringValue {
            
            // Parse string (e.g. "2 / 13")
            
            if let num = Int(stringValue) {
                return (num, nil)
            }
            
            let tokens = stringValue.split(separator: "/")
            
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
            
        } else if let dataValue = item.dataValue {
            
            // Parse data
            let hexString = dataValue.hexEncodedString()
            
            if hexString.count >= 8 {
            
                let s1: String = hexString.substring(range: 4..<8)
                let n1: Int? = Int(s1, radix: 16)
                
                var s2: String?
                var n2: Int?
                
                if hexString.count >= 12 {
                    s2 = hexString.substring(range: 8..<12)
                    n2 = Int(s2!, radix: 16)
                }
                
                return (n1, n2)
            }
        }
        
        return nil
    }
    
    private func getLyrics(_ track: Track) -> String? {
        
        if let map = metadataMap.getForKey(track)?.map {
            
            let iTunesKey = String(format: "%@/%@", AVMetadataKeySpace.iTunes.rawValue, AVMetadataKey.iTunesMetadataKeyLyrics.rawValue)
            
            if let genreItem = map[iTunesKey], let str = genreItem.stringValue {
                return str
            }
            
            var id3Key = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, AVMetadataKey.id3MetadataKeyUnsynchronizedLyric.rawValue)
            
            if let genreItem = map[id3Key], let str = genreItem.stringValue {
                return str
            }
            
            id3Key = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, AVMetadataKey.id3MetadataKeySynchronizedLyric.rawValue)
            
            if let genreItem = map[id3Key], let str = genreItem.stringValue {
                return str
            }
        }
        
        return nil
    }
    
    func getDurationForFile(_ file: URL) -> Double {
        
        let asset = AVURLAsset(url: file, options: nil)
        return asset.duration.seconds
    }
}

extension String {
    
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }
        
        return String(data: data, encoding: .utf8)
    }
    
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }
}

extension Data {
    
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

class MappedMetadata {
    
    var map: [String: AVMetadataItem] = [:]
}
