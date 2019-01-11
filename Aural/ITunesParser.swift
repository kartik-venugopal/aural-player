import Cocoa
import AVFoundation

/*
 Specification for the iTunes metadata format.
 */
class ITunesParser: AVAssetParser {
    
    private let essentialFieldKeys: Set<String> = [ITunesSpec.key_title, ITunesSpec.key_artist, ITunesSpec.key_album, ITunesSpec.key_genre, ITunesSpec.key_genreID, ITunesSpec.key_discNumber, ITunesSpec.key_discNumber2, ITunesSpec.key_trackNumber, ITunesSpec.key_lyrics, ITunesSpec.key_art]
    
    func mapTrack(_ track: Track, _ mapForTrack: AVAssetMetadata) {
        
        let items = track.audioAsset!.metadata
        
        for item in items {
            
            if item.keySpace == .iTunes, let key = item.keyAsString {
                
                let mapKey = String(format: "%@/%@", ITunesSpec.keySpace, key)
                
                if essentialFieldKeys.contains(mapKey) {
                    mapForTrack.map[mapKey] = item
                } else {
                    // Generic field
                    mapForTrack.genericItems.append(item)
                }
                
            } else if item.keySpace?.rawValue == ITunesSpec.longForm_keySpaceID, let key = item.keyAsString { // Long form
                
                let mapKey = String(format: "%@/%@", ITunesSpec.keySpace, key)
                
                if essentialFieldKeys.contains(mapKey) {
                    mapForTrack.map[mapKey] = item
                } else {
                    // Generic field
                    mapForTrack.genericItems.append(item)
                }
            }
            
//            if let attrs = item.extraAttributes, attrs.count > 0 {
//
//                for (a,v) in attrs {
//
//                    let s = String(describing: v)
//
//                    if !StringUtils.isStringEmpty(s) {
//                        print("Xtra for", item.keyAsString, a.rawValue, s)
//                    }
//                }
//            }
        }
    }
    
    func getDuration(_ mapForTrack: AVAssetMetadata) -> Double? {
        return nil
    }
    
    func getTitle(_ mapForTrack: AVAssetMetadata) -> String? {
        
        if let titleItem = mapForTrack.map[ITunesSpec.key_title] {
            return titleItem.stringValue
        }
        
        return nil
    }
    
    func getArtist(_ mapForTrack: AVAssetMetadata) -> String? {
        
        if let artistItem = mapForTrack.map[ITunesSpec.key_artist] {
            return artistItem.stringValue
        }
        
        return nil
    }
    
    func getAlbum(_ mapForTrack: AVAssetMetadata) -> String? {
        
            if let albumItem = mapForTrack.map[ITunesSpec.key_album] {
                return albumItem.stringValue
            }
        
        return nil
    }
    
    func getGenre(_ mapForTrack: AVAssetMetadata) -> String? {
        
        if let genreItem = mapForTrack.map[ITunesSpec.key_genre] {
            
            if let str = genreItem.stringValue {
                
                return parseID3GenreNumericString(str)
                
            } else if let data = genreItem.dataValue {
                
                // Parse as hex string
                if let code = Int(data.hexEncodedString(), radix: 16) {
                    return GenreMap.forID3Code(code - 1)
                }
            }
        }
        
        if let genreItem = mapForTrack.map[ITunesSpec.key_genreID] {
            
            if let str = genreItem.stringValue {
                
                return parseITunesGenreNumericString(str)
                
            } else if let data = genreItem.dataValue {
                
                // Parse as hex string
                if let code = Int(data.hexEncodedString(), radix: 16) {
                    return GenreMap.forITunesCode(code)
                }
            }
        }
        
        return nil
    }
    
    private func parseITunesGenreNumericString(_ string: String) -> String {
        
        let decimalChars = CharacterSet.decimalDigits
        let alphaChars = CharacterSet.lowercaseLetters.union(CharacterSet.uppercaseLetters)
        
        // If no alphabetic characters are present, and numeric characters are present, treat this as a numerical genre code
        if string.rangeOfCharacter(from: alphaChars) == nil, string.rangeOfCharacter(from: decimalChars) != nil {
            
            // Need to parse the number
            let numberStr = string.trimmingCharacters(in: decimalChars.inverted)
            if let genreCode = Int(numberStr) {
                
                // Look up genreId in ID3 table
                return GenreMap.forITunesCode(genreCode) ?? string
            }
        }
        
        return string
    }
    
    private func parseID3GenreNumericString(_ string: String) -> String {
        
        let decimalChars = CharacterSet.decimalDigits
        let alphaChars = CharacterSet.lowercaseLetters.union(CharacterSet.uppercaseLetters)
        
        // If no alphabetic characters are present, and numeric characters are present, treat this as a numerical genre code
        if string.rangeOfCharacter(from: alphaChars) == nil, string.rangeOfCharacter(from: decimalChars) != nil {
            
            // Need to parse the number
            let numberStr = string.trimmingCharacters(in: decimalChars.inverted)
            if let genreCode = Int(numberStr) {
                
                // Look up genreId in ID3 table
                return GenreMap.forID3Code(genreCode - 1) ?? string
            }
        }
        
        return string
    }
    
    func getDiscNumber(_ mapForTrack: AVAssetMetadata) -> (number: Int?, total: Int?)? {
        
        if let item = mapForTrack.map[ITunesSpec.key_discNumber] {
            return parseDiscOrTrackNumber(item)
        }
        
        return nil
    }
    
    func getTrackNumber(_ mapForTrack: AVAssetMetadata) -> (number: Int?, total: Int?)? {
        
        if let item = mapForTrack.map[ITunesSpec.key_trackNumber] {
            return parseDiscOrTrackNumber(item)
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
    
    func getArt(_ mapForTrack: AVAssetMetadata) -> NSImage? {
        
        if let item = mapForTrack.map[ITunesSpec.key_art], let imgData = item.dataValue {
            return NSImage(data: imgData)
        }
        
        return nil
    }
    
    func getArt(_ asset: AVURLAsset) -> NSImage? {
        
        if let item = AVMetadataItem.metadataItems(from: asset.commonMetadata, filteredByIdentifier: ITunesSpec.id_art).first, let imgData = item.dataValue {
            return NSImage(data: imgData)
        }
        
        return nil
    }
    
    func getLyrics(_ mapForTrack: AVAssetMetadata) -> String? {
        
        if let lyricsItem = mapForTrack.map[ITunesSpec.key_lyrics] {
            return lyricsItem.stringValue
        }
        
        return nil
    }
    
    func getGenericMetadata(_ mapForTrack: AVAssetMetadata) -> [String: MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        for item in mapForTrack.genericItems.filter({item -> Bool in item.keySpace == .iTunes || item.keySpace?.rawValue == ITunesSpec.longForm_keySpaceID}) {
            
            if let key = item.keyAsString, var value = item.valueAsString {
                
                if key == ITunesSpec.key_language, let langName = LanguageMap.forCode(value.trim()) {
                    
                    value = langName
                    
                } else if key == ITunesSpec.key_compilation, let numVal = item.numberValue {
                    
                    // Number to boolean
                    value = numVal == 0 ? "No" : "Yes"
                    
                } else if key == ITunesSpec.key_predefGenre {
                    
                    // Parse genre
                    if let str = item.stringValue {
                        
                        value = parseID3GenreNumericString(str)
                        
                    } else if let data = item.dataValue {
                        
                        // Parse as hex string
                        if let code = Int(data.hexEncodedString(), radix: 16) {
                            value = GenreMap.forID3Code(code - 1) ?? value
                        }
                    }
                }
                
                let rKey = ITunesSpec.readableKey(StringUtils.cleanUpString(key))
                metadata[key] = MetadataEntry(.iTunes, rKey, StringUtils.cleanUpString(value))
            }
        }
        
        return metadata
    }
}
