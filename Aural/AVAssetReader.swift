import Cocoa
import AVFoundation

// Duration
fileprivate let id3Key_duration: String = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, AVMetadataKey.id3MetadataKeyLength.rawValue)

// Title
fileprivate let commonKey_title = String(format: "%@/%@", AVMetadataKeySpace.common.rawValue, AVMetadataKey.commonKeyTitle.rawValue)
fileprivate let iTunesKey_title = String(format: "%@/%@", AVMetadataKeySpace.iTunes.rawValue, AVMetadataKey.iTunesMetadataKeySongName.rawValue)
fileprivate let id3Key_title = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, AVMetadataKey.id3MetadataKeyTitleDescription.rawValue)

// Artist
fileprivate let commonKey_artist = String(format: "%@/%@", AVMetadataKeySpace.common.rawValue, AVMetadataKey.commonKeyArtist.rawValue)
fileprivate let iTunesKey_artist = String(format: "%@/%@", AVMetadataKeySpace.iTunes.rawValue, AVMetadataKey.iTunesMetadataKeyArtist.rawValue)
fileprivate let id3Key_artist = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, AVMetadataKey.id3MetadataKeyOriginalArtist.rawValue)
fileprivate let id3Key_band = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, AVMetadataKey.id3MetadataKeyBand.rawValue)

// Album
fileprivate let commonKey_album = String(format: "%@/%@", AVMetadataKeySpace.common.rawValue, AVMetadataKey.commonKeyAlbumName.rawValue)
fileprivate let iTunesKey_album = String(format: "%@/%@", AVMetadataKeySpace.iTunes.rawValue, AVMetadataKey.iTunesMetadataKeyAlbum.rawValue)
fileprivate let id3Key_album = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, AVMetadataKey.id3MetadataKeyAlbumTitle.rawValue)
fileprivate let id3Key_origAlbum = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, AVMetadataKey.id3MetadataKeyOriginalAlbumTitle.rawValue)

// Genre
fileprivate let commonKey_genre = String(format: "%@/%@", AVMetadataKeySpace.common.rawValue, AVMetadataKey.commonKeyType.rawValue)
fileprivate let iTunesKey_genre = String(format: "%@/%@", AVMetadataKeySpace.iTunes.rawValue, AVMetadataKey.iTunesMetadataKeyUserGenre.rawValue)
fileprivate let iTunesKey_predefGenre = String(format: "%@/%@", AVMetadataKeySpace.iTunes.rawValue, AVMetadataKey.iTunesMetadataKeyPredefinedGenre.rawValue)
fileprivate let id3Key_genre = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, AVMetadataKey.id3MetadataKeyContentType.rawValue)

// Disc number
fileprivate let iTunesKey_discNumber = String(format: "%@/%@", AVMetadataKeySpace.iTunes.rawValue, AVMetadataKey.iTunesMetadataKeyDiscNumber.rawValue)
fileprivate let id3Key_discNumber = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, AVMetadataKey.id3MetadataKeyPartOfASet.rawValue)

// Track number
fileprivate let iTunesKey_trackNumber = String(format: "%@/%@", AVMetadataKeySpace.iTunes.rawValue, AVMetadataKey.iTunesMetadataKeyTrackNumber.rawValue)
fileprivate let id3Key_trackNumber = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, AVMetadataKey.id3MetadataKeyTrackNumber.rawValue)

// Lyrics
fileprivate let iTunesKey_lyrics = String(format: "%@/%@", AVMetadataKeySpace.iTunes.rawValue, AVMetadataKey.iTunesMetadataKeyLyrics.rawValue)
fileprivate let id3Key_lyrics = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, AVMetadataKey.id3MetadataKeyUnsynchronizedLyric.rawValue)
fileprivate let id3Key_syncLyrics = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, AVMetadataKey.id3MetadataKeySynchronizedLyric.rawValue)

// Art
fileprivate let commonKey_art: String = String(format: "%@/%@", AVMetadataKeySpace.common.rawValue, AVMetadataKey.commonKeyArtwork.rawValue)
fileprivate let iTunesKey_art: String = String(format: "%@/%@", AVMetadataKeySpace.iTunes.rawValue, AVMetadataKey.iTunesMetadataKeyCoverArt.rawValue)
fileprivate let id3Key_art: String = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, AVMetadataKey.id3MetadataKeyAttachedPicture.rawValue)

fileprivate let commonId_art: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.commonKeyArtwork.rawValue, keySpace: AVMetadataKeySpace.common)!
fileprivate let iTunesId_art: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.iTunesMetadataKeyCoverArt.rawValue, keySpace: AVMetadataKeySpace.iTunes)!
fileprivate let id3Id_art: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.id3MetadataKeyAttachedPicture.rawValue, keySpace: AVMetadataKeySpace.id3)!

class AVAssetReader: MetadataReader {
    
    private let genericMetadata_ignoreKeys: Set<String> = [commonKey_title, commonKey_artist, commonKey_art, commonKey_album, commonKey_genre, iTunesKey_title, iTunesKey_artist, iTunesKey_album, iTunesKey_genre, iTunesKey_predefGenre, iTunesKey_discNumber, iTunesKey_trackNumber, iTunesKey_lyrics, id3Key_title, id3Key_artist, id3Key_album, id3Key_genre, id3Key_discNumber, id3Key_trackNumber, id3Key_lyrics, id3Key_syncLyrics]
    
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
        print(track.conciseDisplayName, items.count)
        let mapForTrack = MappedMetadata()
        
        for item in items {
            
            if let mapKey = mapKeyForItem(item) {
                
                if genericMetadata_ignoreKeys.contains(mapKey) {
                    mapForTrack.map[mapKey] = item
                } else {
                    mapForTrack.genericMap[mapKey] = item
                }
            }
        }
        
        metadataMap.put(track, mapForTrack)
    }
    
    private func mapKeyForItem(_ item: AVMetadataItem) -> String? {
        
        if let ckey = item.commonKeyAsString {
            
            return String(format: "%@/%@", AVMetadataKeySpace.common.rawValue, ckey)
            
        } else if let skey = item.key as? String, let itemKeySpace = item.keySpace {
            
            return String(format: "%@/%@", itemKeySpace.rawValue, skey)
            
        } else if let id = item.identifier {
            
            return id.rawValue.replacingOccurrences(of: "%A9", with: "@")
            
        } else if item.key != nil {
            
            print("\nWeird item key is:", String(describing: item.key))
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
        
        for id in [commonId_art, iTunesId_art, id3Id_art] {

            if let item = AVMetadataItem.metadataItems(from: asset.commonMetadata, filteredByIdentifier: id).first, let imgData = item.dataValue {
                return NSImage(data: imgData)
            }
        }
        
        return nil
    }
    
    func getPrimaryMetadata(_ track: Track) -> PrimaryMetadata {
        
        ensureTrackAssetLoaded(track)
        
        let title = getTitle(track)?.trim()
        let artist = getArtist(track)?.trim()
        let album = getAlbum(track)?.trim()
        let genre = getGenre(track)?.trim()
        
//        print("Genre for", track.file.lastPathComponent, "=", genre != nil ? genre! : "nil")
        
        let duration = getDuration(track)
        
        return PrimaryMetadata(title, artist, album, genre, duration)
    }
    
    private func stringValueForKeys(_ track: Track, _ keys: [String]) -> String? {
        
        if let map = metadataMap.getForKey(track)?.map {
            
            for key in keys {
                
                if let item = map[key], let str = item.stringValue {
                    return str
                }
            }
        }
        
        return nil
    }
    
    private func getArtist(_ track: Track) -> String? {
        return stringValueForKeys(track, [commonKey_artist, iTunesKey_artist, id3Key_artist, id3Key_band])
    }
    
    private func getTitle(_ track: Track) -> String? {
        return stringValueForKeys(track, [commonKey_title, iTunesKey_title, id3Key_title])
    }
    
    private func getAlbum(_ track: Track) -> String? {
        return stringValueForKeys(track, [commonKey_album, iTunesKey_album, id3Key_album, id3Key_origAlbum])
    }
    
    private func getGenre(_ track: Track) -> String? {
        
        if let map = metadataMap.getForKey(track)?.map {
            
            for key in [commonKey_genre, iTunesKey_genre, iTunesKey_predefGenre] {
            
                if let genreItem = map[key] {
                    
                    if let str = genreItem.stringValue {
                        
                        return parseGenreNumericString(str)
                        
                    } else if let number = genreItem.numberValue {
                        
                        print("\n*** Number !!!", number, "for track", track.conciseDisplayName)
                        return ID3Spec.genreForCode(number.intValue)
                        
                    } else if let data = genreItem.dataValue {
                        
                        let code = Int(data.hexEncodedString(), radix: 16)!
                        return ID3Spec.genreForCode(code - 1)
                    }
                }
            }
            
            if let genreItem = map[id3Key_genre] {
                
                if let str = genreItem.stringValue {
                    
                    return parseGenreNumericString(str)
                    
                } else if let number = genreItem.numberValue {
                    
                    print("\n*** Number !!!", number, "for track", track.conciseDisplayName)
                    return ID3Spec.genreForCode(number.intValue)
                    
                }  else if let data = genreItem.dataValue {
                    
                    print("\n *** ID3 DATA value for Genre !!! ***", track.conciseDisplayName, data.hexEncodedString())
                    let code = Int(data.hexEncodedString(), radix: 16)!
                    return ID3Spec.genreForCode(code)
                }
            }
        }
        
        return nil
    }
    
    private func parseGenreNumericString(_ string: String) -> String {
        
        let decimalChars = CharacterSet.decimalDigits
        let alphaChars = CharacterSet.lowercaseLetters.union(CharacterSet.uppercaseLetters)
        
        // If no alphabetic characters are present, and numeric characters are present, treat this as a numerical genre code
        if string.rangeOfCharacter(from: alphaChars) == nil, string.rangeOfCharacter(from: decimalChars) != nil {
            
            // Need to parse the number
            let numberStr = string.trimmingCharacters(in: decimalChars.inverted)
            if let genreCode = Int(numberStr) {
                
                // Look up genreId in ID3 table
                return ID3Spec.genreForCode(genreCode) ?? string
            }
        }
        
        return string
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
        
        if let map = metadataMap.getForKey(track)?.map, let tlenItem = map[id3Key_duration], let tlenValue = tlenItem.stringValue, let durationMsecs = Double(tlenValue) {
            tlenDuration = durationMsecs / 1000
        }
        
        let assetDuration = track.audioAsset!.duration.seconds
        
        return max(tlenDuration, assetDuration)
    }
    
    func getArt(_ track: Track) -> NSImage? {
        
        ensureTrackAssetLoaded(track)
        
        if let map = metadataMap.getForKey(track)?.map {
            
            for key in [commonKey_art, iTunesKey_art, id3Key_art] {
                
                if let artItem = map[key], let data = artItem.dataValue {
                    return NSImage(data: data)
                }
            }
        }
        
        return nil
    }
    
    func getArt(_ file: URL) -> NSImage? {
        return getArt(AVURLAsset(url: file, options: nil))
    }
    
    func getAllMetadata(_ track: Track) -> [String: MetadataEntry] {
        
        ensureTrackAssetLoaded(track)
        
        var metadata: [String: MetadataEntry] = [:]

        if let map = metadataMap.getForKey(track)?.genericMap {

            // Iterate through all metadata for this format
            for (_, item) in map {
                
                if let key = item.keyAsString, let value = item.valueAsString {
                    metadata[key] = MetadataEntry(item.metadataType, .key, key, value)
                }
            }
        }
        
        return metadata
    }
    
    private func getDiscNumber(_ track: Track) -> (number: Int?, total: Int?)? {
        
        if let map = metadataMap.getForKey(track)?.map {
            
            for key in [iTunesKey_discNumber, id3Key_discNumber] {
            
                if let item = map[key], let discNum = parseDiscOrTrackNumber(item) {
                    return discNum
                }
            }
        }
        
        return nil
    }
    
    private func getTrackNumber(_ track: Track) -> (number: Int?, total: Int?)? {
        
        if let map = metadataMap.getForKey(track)?.map {
            
            for key in [iTunesKey_trackNumber, id3Key_trackNumber] {
                
                if let item = map[key], let trackNum = parseDiscOrTrackNumber(item) {
                    return trackNum
                }
            }
        }
        
        return nil
    }
    
    private func parseDiscOrTrackNumber(_ item: AVMetadataItem) -> (number: Int?, total: Int?)? {
        
        if let number = item.numberValue {
            return (number.intValue, nil)
        }
        
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
        return stringValueForKeys(track, [iTunesKey_lyrics, id3Key_lyrics, id3Key_syncLyrics])
    }
    
    func getDurationForFile(_ file: URL) -> Double {
        return AVURLAsset(url: file, options: nil).duration.seconds
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
        
        if let keySpace = self.keySpace, let id = AVMetadataItem.identifier(forKey: key as Any, keySpace: keySpace) {
            
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
                
            case AVMetadataKeySpace.iTunes.rawValue:     return .iTunes
                
            case ITunesLongFormSpec.keySpaceID:     return .iTunesLongForm
                
            case AVMetadataKeySpace.id3.rawValue:        return .id3
                
            default:    return .other
                
            }
        }
        
        return .other
    }
}
