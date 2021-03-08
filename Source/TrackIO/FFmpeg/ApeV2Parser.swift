import Cocoa
import AVFoundation

fileprivate let key_title = "title"

fileprivate let key_artist = "artist"
fileprivate let key_artists = "artists"
fileprivate let key_albumArtist = "albumartist"
fileprivate let key_albumArtist2 = "album_artist"
fileprivate let key_originalArtist = "original artist"
fileprivate let key_performer = "performer"

fileprivate let keys_artist: [String] = [key_artist, key_albumArtist, key_albumArtist2, key_originalArtist, key_artists, key_performer]

fileprivate let key_album = "album"
fileprivate let key_originalAlbum = "original album"

fileprivate let key_genre = "genre"

fileprivate let key_disc = "disc"
fileprivate let key_track = "track"
fileprivate let key_lyrics = "lyrics"

fileprivate let keys_year: [String] = ["year", "originaldate", "originalyear", "original year", "originalreleasedate", "original_year"]

fileprivate let key_bpm: String = "bpm"

class ApeV2Parser: FFmpegMetadataParser {

    private let essentialKeys: Set<String> = Set([key_title, key_album, key_originalAlbum, key_genre,
                                                  key_disc, key_track] + keys_artist)

    private let key_language = "language"
    private let key_compilation = "compilation"
    
    func mapTrack(_ meta: FFmpegMappedMetadata) {
        
        let metadata = meta.apeMetadata
        
        for key in meta.map.keys {
            
            let lcKey = key.lowercased().trim()
            
            if essentialKeys.contains(lcKey) {
                
                metadata.essentialFields[lcKey] = meta.map.removeValue(forKey: key)
                
            } else if genericKeys[lcKey] != nil {
                
                metadata.genericFields[lcKey] = meta.map.removeValue(forKey: key)
            }
        }
    }
    
    func hasEssentialMetadataForTrack(_ meta: FFmpegMappedMetadata) -> Bool {
        !meta.apeMetadata.essentialFields.isEmpty
    }
    
    func hasGenericMetadataForTrack(_ meta: FFmpegMappedMetadata) -> Bool {
        !meta.apeMetadata.genericFields.isEmpty
    }
    
    func getTitle(_ meta: FFmpegMappedMetadata) -> String? {
        meta.apeMetadata.essentialFields[key_title]
    }
    
    func getArtist(_ meta: FFmpegMappedMetadata) -> String? {
        keys_artist.firstNonNilMappedValue({meta.apeMetadata.essentialFields[$0]})
    }
    
    func getAlbum(_ meta: FFmpegMappedMetadata) -> String? {
        meta.apeMetadata.essentialFields[key_album] ?? meta.apeMetadata.essentialFields[key_originalAlbum]
    }
    
    func getGenre(_ meta: FFmpegMappedMetadata) -> String? {
        meta.apeMetadata.essentialFields[key_genre]
    }
    
    func getDiscNumber(_ meta: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let discNumStr = meta.apeMetadata.essentialFields[key_disc] {
            return ParserUtils.parseDiscOrTrackNumberString(discNumStr)
        }
        
        return nil
    }
    
    func getTrackNumber(_ meta: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let trackNumStr = meta.apeMetadata.essentialFields[key_track] {
            return ParserUtils.parseDiscOrTrackNumberString(trackNumStr)
        }
        
        return nil
    }
    
    func getYear(_ meta: FFmpegMappedMetadata) -> Int? {
        
        if let yearString = keys_year.firstNonNilMappedValue({meta.apeMetadata.genericFields[$0]}) {
            return ParserUtils.parseYear(yearString)
        }
        
        return nil
    }
    
    func getBPM(_ meta: FFmpegMappedMetadata) -> Int? {
        
        if let bpmString = meta.apeMetadata.genericFields[key_bpm] {
            return ParserUtils.parseBPM(bpmString)
        }
        
        return nil
    }
    
    func getLyrics(_ meta: FFmpegMappedMetadata) -> String? {
        meta.apeMetadata.genericFields[key_lyrics]
    }
    
    private let genericKeys: [String: String] = {
        
        var map: [String: String] = [:]
        
        map["lyrics"] = "Lyrics"
        
        map["year"] = "Year"
        map["originaldate"] = "Original Date"
        map["originalreleasedate"] = "Original Release Date"
        ["originalyear", "original year", "original_year"].forEach {map[$0] = "Year"}

        map["bpm"] = "BPM"
        
        map["composer"] = "Composer"
        map["conductor"] = "Conductor"
        map["lyricist"] = "Lyricist"
        map["original lyricist"] = "Original Lyricist"
        
        map["subtitle"] = "Subtitle"
        map["debut album"] = "Debut Album"
        
        map["comment"] = "Comment"
        map["copyright"] = "Copyright"
        map["publicationright"] = "Publication Right"
        map["file"] = "File"
        map["ean/upc"] = "EAN/UPC"
        map["isbn"] = "ISBN"
        map["catalog"] = "Catalog"
        map["lc"] = "Label Code"
        
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
        
        map["albumartistsort"] = "Album Artist Sort Order"
        
        map["composersort"] = "Composer Sort Order"
        
        map["writer"] = "Writer"
        map["mixartist"] = "Remixer"
        map["arranger"] = "Arranger"
        map["engineer"] = "Engineer"
        map["producer"] = "Producer"
        map["publisher"] = "Publisher"
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
        map["mood"] = "Mood"
        map["catalognumber"] = "Catalog Number"
        map["releasecountry"] = "Release Country"
        map["record date"] = "Record Date"
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
    
    func getGenericMetadata(_ meta: FFmpegMappedMetadata) -> [String : MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        for (key, var value) in meta.apeMetadata.genericFields {
            
            // Check special fields
            if key == key_language, let langName = LanguageMap.forCode(value.trim()) {
                value = langName
            } else if key == key_compilation, let bVal = numericStringToBoolean(value) {
                value = bVal ? "Yes" : "No"
            }
            
            value = StringUtils.cleanUpString(value)
            
            metadata[key] = MetadataEntry(.ape, readableKey(key), value)
        }
        
        return metadata
    }
}
