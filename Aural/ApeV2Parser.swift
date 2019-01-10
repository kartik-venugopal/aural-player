import Cocoa
import AVFoundation

fileprivate let key_title = "title"
fileprivate let key_artist = "artist"
fileprivate let key_album = "album"
fileprivate let key_genre = "genre"

fileprivate let key_disc = "disc"
fileprivate let key_track = "track"
fileprivate let key_lyrics = "lyrics"

fileprivate let key_language = "language"

class ApeV2Parser: FFMpegMetadataParser {
    
    private let essentialKeys: Set<String> = [key_title, key_artist, key_album, key_genre, key_disc, key_track, key_lyrics]
    
    func mapTrack(_ mapForTrack: LibAVMetadata) {
        
        let map = mapForTrack.map
        
        let metadata = LibAVParserMetadata()
        mapForTrack.apeMetadata = metadata
        
        for (key, value) in map {
            
            let lcKey = key.lowercased().trim()
            
            if essentialKeys.contains(lcKey) {
                
                metadata.essentialFields[lcKey] = value
                mapForTrack.map.removeValue(forKey: key)
                
            } else if genericKeys[lcKey] != nil {
                
                metadata.genericFields[lcKey] = value
                mapForTrack.map.removeValue(forKey: key)
            }
        }
    }
    
    func getTitle(_ mapForTrack: LibAVMetadata) -> String? {
        
        if let title = mapForTrack.apeMetadata?.essentialFields[key_title] {
            return title
        }
        
        return nil
    }
    
    func getArtist(_ mapForTrack: LibAVMetadata) -> String? {
        
        if let artist = mapForTrack.apeMetadata?.essentialFields[key_artist] {
            return artist
        }
        
        return nil
    }
    
    func getAlbum(_ mapForTrack: LibAVMetadata) -> String? {
        
        if let album = mapForTrack.apeMetadata?.essentialFields[key_album] {
            return album
        }
        
        return nil
    }
    
    func getGenre(_ mapForTrack: LibAVMetadata) -> String? {
        
        if let genre = mapForTrack.apeMetadata?.essentialFields[key_genre] {
            return genre
        }
        
        return nil
    }
    
    private func parseGenreNumericString(_ string: String) -> String {
        
        let decimalChars = CharacterSet.decimalDigits
        
        // TODO: Declare this char set as a global constant somewhere
        let alphaChars = CharacterSet.lowercaseLetters.union(CharacterSet.uppercaseLetters)
        
        // If no alphabetic characters are present, and numeric characters are present, treat this as a numerical genre code
        if string.rangeOfCharacter(from: alphaChars) == nil, string.rangeOfCharacter(from: decimalChars) != nil {
            
            // Need to parse the number
            let numberStr = string.trimmingCharacters(in: decimalChars.inverted)
            if let genreCode = Int(numberStr) {
                
                // Look up genreId in ID3 table
                return ID3Parser.genreForCode(genreCode) ?? string
            }
        }
        
        return string
    }
    
    func getDiscNumber(_ mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)? {
        
        if let discNumStr = mapForTrack.apeMetadata?.essentialFields[key_disc] {
            return parseDiscOrTrackNumber(discNumStr)
        }
        
        // TODO: Check if total present, if not, check for tracktotal or totaltracks field
        
        return nil
    }
    
    func getTotalDiscs(_ mapForTrack: LibAVMetadata) -> Int? {
        return nil
    }
    
    func getTrackNumber(_ mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)? {
        
        if let trackNumStr = mapForTrack.apeMetadata?.essentialFields[key_track] {
            return parseDiscOrTrackNumber(trackNumStr)
        }
        
        return nil
    }
    
    func getTotalTracks(_ mapForTrack: LibAVMetadata) -> Int? {
        return nil
    }
    
    private func parseDiscOrTrackNumber(_ _string: String, _ offset: Int = 0) -> (number: Int?, total: Int?)? {
        
        // Parse string (e.g. "2 / 13")
        
        let string = _string.trim()
        
        if let num = Int(string) {
            return (num, nil)
        }
        
        let tokens = string.split(separator: "/")
        
        if !tokens.isEmpty {
            
            let s1 = tokens[0].trim()
            var s2: String?
            
            var n1: Int? = Int(s1)
            if n1 != nil {
                n1! += offset
            }
            
            var n2: Int?
            
            if tokens.count > 1 {
                s2 = tokens[1].trim()
                n2 = Int(s2!)
            }
            
            return (n1, n2)
        }
        
        return nil
    }
    
    func getLyrics(_ mapForTrack: LibAVMetadata) -> String? {
        
        if let lyrics = mapForTrack.apeMetadata?.essentialFields[key_lyrics] {
            return lyrics
        }
        
        return nil
    }
    
    func getGenericMetadata(_ mapForTrack: LibAVMetadata) -> [String : MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        if let fields = mapForTrack.apeMetadata?.genericFields {
            
            for (key, var value) in fields {
                
                // Check special fields
                if key == key_language, let langName = LanguageCodes.languageNameForCode(value.trim()) {
                    value = langName
                }
                
                metadata[key] = MetadataEntry(.ape, readableKey(key), value)
            }
        }
        
        return metadata
    }
    
    private let genericKeys: [String: String] = {
        
        var map: [String: String] = [:]
        
        map["subtitle"] = "Subtitle"
        map["debut album"] = "Debut Album"
        map["publisher"] = "Publisher"
        map["conductor"] = "Conductor"
        map["composer"] = "Composer"
        map["comment"] = "Comment"
        map["copyright"] = "Copyright"
        map["publicationright"] = "Publication Right"
        map["file"] = "File"
        map["ean/upc"] = "EAN/UPC"
        map["isbn"] = "ISBN"
        map["catalog"] = "Catalog"
        map["lc"] = "Label Code"
        map["year"] = "Year"
        map["record date"] = "Record Date"
        map["record location"] = "Record Location"
        map["media"] = "Media"
        map["index"] = "Index"
        map["related"] = "Related"
        map["isrc"] = "ISRC"
        map["abstract"] = "Abstract"
        map["language"] = "Language"
        map["bibliography"] = "Bibliography"
        map["introplay"] = "Introplay"
        map["tool name"] = "Tool Name"
        map["tool version"] = "Tool Version"
        
        return map
    }()
    
    private func readableKey(_ key: String) -> String {
        
        let lcKey = key.lowercased()
        let trimmedKey = lcKey.trim()
        
        if let rKey = genericKeys[trimmedKey] {
            
            return rKey
            
        } else if let range = lcKey.range(of: trimmedKey) {
            
            return String(key[range.lowerBound..<range.upperBound]).capitalizingFirstLetter()
        }
        
        return key.capitalizingFirstLetter()
    }
    
    private func numericStringToBoolean(_ string: String) -> Bool? {
        
        if let num = Int(string.trim()) {
            return num != 0
        }
        
        return nil
    }
}
