import Cocoa
import AVFoundation

fileprivate let key_title = "title"
fileprivate let key_artist = "artist"
fileprivate let key_artists = "artists"
fileprivate let key_album = "album"
fileprivate let key_genre = "genre"

fileprivate let key_disc = "disc"
fileprivate let key_track = "track"
fileprivate let key_lyrics = "lyrics"

class ApeV2Parser: FFMpegMetadataParser {

    private let essentialKeys: Set<String> = [key_title, key_artist, key_artists, key_album, key_genre, key_disc, key_track, key_lyrics]

    private let key_language = "language"
    private let key_compilation = "compilation"
    
    func mapTrack(_ mapForTrack: LibAVMetadata) {
        
        let metadata = LibAVParserMetadata()
        mapForTrack.apeMetadata = metadata
        
        for (key, value) in mapForTrack.map {
            
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
        
        for key in [key_artist, key_artists] {
            
            if let artist = mapForTrack.apeMetadata?.essentialFields[key] {
                return artist
            }
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
    
    func getDiscNumber(_ mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)? {
        
        if let discNumStr = mapForTrack.apeMetadata?.essentialFields[key_disc] {
            return ParserUtils.parseDiscOrTrackNumberString(discNumStr)
        }
        
        return nil
    }
    
    func getTotalDiscs(_ mapForTrack: LibAVMetadata) -> Int? {
        return nil
    }
    
    func getTrackNumber(_ mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)? {
        
        if let trackNumStr = mapForTrack.apeMetadata?.essentialFields[key_track] {
            return ParserUtils.parseDiscOrTrackNumberString(trackNumStr)
        }
        
        return nil
    }
    
    func getTotalTracks(_ mapForTrack: LibAVMetadata) -> Int? {
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
                if key == key_language, let langName = LanguageMap.forCode(value.trim()) {
                    value = langName
                } else if key == key_compilation, let bVal = numericStringToBoolean(value) {
                    value = bVal ? "Yes" : "No"
                }
                
                value = StringUtils.cleanUpString(value)
                
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
        
        map["albumsort"] = "Album Sort Order"
        map["titlesort"] = "Title Sort Order"
        map["work"] = "Work Name"
        map["artistsort"] = "Artist Sort Order"
        map["albumartist"] = "Album Artist"
        map["albumartistsort"] = "Album Artist Sort Order"
        
        map["original artist"] = "Original Artist"
        map["originalyear"] = "Original Release Year"
        map["composersort"] = "Composer Sort Order"
        map["lyricist"] = "Original Lyricist"
        map["writer"] = "Writer"
        map["performer"] = "Performer"
        map["mixartist"] = "Remixer"
        map["arranger"] = "Arranger"
        map["engineer"] = "Engineer"
        map["producer"] = "Producer"
        map["djmixer"] = "DJ Mixer"
        map["mixer"] = "Mixer"
        map["label"] = "Label"
        map["movementname"] = "Movement Name"
        map["movement"] = "Movement"
        map["movementtotal"] = "Movement Count"
        map["showmovement"] = "Show Movement"
        map["grouping"] = "Grouping"
        map["discsubtitle"] = "Disc Subtitle"
        map["compilation"] = "Part of a Compilation?"
        map["bpm"] = "BPM"
        map["mood"] = "Mood"
        map["catalognumber"] = "Catalog Number"
        map["releasecountry"] = "Release Country"
        map["script"] = "Script"
        map["license"] = "License"
        map["encodedby"] = "Encoded By"
        map["encodersettings"] = "Encoder Settings"
        map["barcode"] = "Barcode"
        map["asin"] = "ASIN"
        map["weblink"] = "Official Artist Website"
        
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
