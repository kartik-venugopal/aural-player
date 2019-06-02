import Cocoa
import AVFoundation

class AudioToolboxParser: AVAssetParser {
    
    @available(OSX 10.13, *)
    static let keySpace: String = AVMetadataKeySpace.audioFile.rawValue
    
    @available(OSX 10.13, *)
    static let key_title: String = String(format: "%@/%@", AVMetadataKeySpace.audioFile.rawValue, "info-title")
    
    @available(OSX 10.13, *)
    static let key_artist: String = String(format: "%@/%@", AVMetadataKeySpace.audioFile.rawValue, "info-artist")
    
    @available(OSX 10.13, *)
    static let key_album: String = String(format: "%@/%@", AVMetadataKeySpace.audioFile.rawValue, "info-album")
    
    @available(OSX 10.13, *)
    static let key_genre: String = String(format: "%@/%@", AVMetadataKeySpace.audioFile.rawValue, "info-genre")
    
    @available(OSX 10.13, *)
    static let key_trackNumber: String = String(format: "%@/%@", AVMetadataKeySpace.audioFile.rawValue, "info-track number")
    
    @available(OSX 10.13, *)
    static let key_duration: String = String(format: "%@/%@", AVMetadataKeySpace.audioFile.rawValue, "info-approximate duration in seconds")
    
    private static let readableKeys: [String: String] = [
        "info-comments" : "Comment",
        "info-year" : "Year"
    ]
    
    private static let essentialFieldKeys: Set<String> = {
        
        if #available(OSX 10.13, *) {
            return [key_title, key_artist, key_album, key_genre, key_duration, key_trackNumber]
        }
        
        return []
    }()
    
    func mapTrack(_ track: Track, _ mapForTrack: AVAssetMetadata) {
        
        if #available(OSX 10.13, *) {
            
            for item in track.audioAsset!.metadata {
                
                if item.keySpace == .audioFile, let key = item.keyAsString?.removingPercentEncoding {
                    
                    let mapKey = String(format: "%@/%@", AVMetadataKeySpace.audioFile.rawValue, key)
                    
                    if AudioToolboxParser.essentialFieldKeys.contains(mapKey) {
                        mapForTrack.map[mapKey] = item
                    } else {
                        // Generic field
                        mapForTrack.genericItems.append(item)
                    }
                }
            }
        }
    }
    
    func getDuration(_ mapForTrack: AVAssetMetadata) -> Double? {
        
        if #available(OSX 10.13, *), let item = mapForTrack.map[AudioToolboxParser.key_duration], let durationStr = item.stringValue, let durationSecs = Double(durationStr) {
            
            return durationSecs
        }
        
        return nil
    }
    
    func getTitle(_ mapForTrack: AVAssetMetadata) -> String? {
        
        if #available(OSX 10.13, *), let titleItem = mapForTrack.map[AudioToolboxParser.key_title] {
            return titleItem.stringValue
        }
        
        return nil
    }
    
    func getArtist(_ mapForTrack: AVAssetMetadata) -> String? {
        
        if #available(OSX 10.13, *), let artistItem = mapForTrack.map[AudioToolboxParser.key_artist] {
            return artistItem.stringValue
        }
        
        return nil
    }
    
    func getAlbum(_ mapForTrack: AVAssetMetadata) -> String? {
        
        if #available(OSX 10.13, *), let albumItem = mapForTrack.map[AudioToolboxParser.key_album] {
            return albumItem.stringValue
        }
        
        return nil
    }
    
    func getGenre(_ mapForTrack: AVAssetMetadata) -> String? {
        
        if #available(OSX 10.13, *), let genreItem = mapForTrack.map[AudioToolboxParser.key_genre] {
            return genreItem.stringValue
        }
        
        return nil
    }
    
    func getDiscNumber(_ mapForTrack: AVAssetMetadata) -> (number: Int?, total: Int?)? {
        return nil
    }
    
    func getTrackNumber(_ mapForTrack: AVAssetMetadata) -> (number: Int?, total: Int?)? {
        
        if #available(OSX 10.13, *), let trackNumItem = mapForTrack.map[AudioToolboxParser.key_trackNumber] {
            return parseDiscOrTrackNumber(trackNumItem)
        }
        
        return nil
    }
    
    private func parseDiscOrTrackNumber(_ item: AVMetadataItem) -> (number: Int?, total: Int?)? {
        
        if let number = item.numberValue {
            return (number.intValue, nil)
        }
        
        if let stringValue = item.stringValue?.trim() {
            
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
                
            } else if hexString.count >= 4 {
                
                // Only one number
                
                let s1: String = String(hexString.prefix(4))
                let n1: Int? = Int(s1, radix: 16)
                return (n1, nil)
            }
        }
        
        return nil
    }
    
    func getArt(_ mapForTrack: AVAssetMetadata) -> CoverArt? {
        
//        if let item = mapForTrack.map[key_art], let imgData = item.dataValue {
//            return NSImage(data: imgData)
//        }
        
        return nil
    }
    
    func getArt(_ asset: AVURLAsset) -> CoverArt? {
        
//        if let item = AVMetadataItem.metadataItems(from: asset.commonMetadata, filteredByIdentifier: id_art).first, let imgData = item.dataValue {
//            return NSImage(data: imgData)
//        }
        
        return nil
    }
    
    func getArtMetadata(_ mapForTrack: AVAssetMetadata) -> NSDictionary? {
        return nil
    }
    
    func getLyrics(_ mapForTrack: AVAssetMetadata) -> String? {
        return nil
    }
    
    func getGenericMetadata(_ mapForTrack: AVAssetMetadata) -> [String: MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        if #available(OSX 10.13, *) {
            
            for item in mapForTrack.genericItems.filter({item -> Bool in item.keySpace == .audioFile}) {
                
                if let key = item.keyAsString, let value = item.valueAsString {
                    
//                    if key == key_language, let langName = LanguageMap.forCode(value.trim()) {
//                        value = langName
//                    }
                    let rKey = AudioToolboxParser.readableKeys[key] ?? key.replacingOccurrences(of: "info-", with: "").capitalizingFirstLetter()
                    
                    metadata[key] = MetadataEntry(.audioToolbox, rKey, value)
                }
            }
        }
        
        return metadata
    }
}
