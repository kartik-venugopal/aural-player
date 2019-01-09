import Cocoa
import AVFoundation

fileprivate let key_title = "title"
fileprivate let key_artist = "author"
fileprivate let key_album = "albumtitle"
fileprivate let key_genre = "genre"
fileprivate let key_genreId = "genreid"

fileprivate let key_duration = "duration"
fileprivate let key_totalDuration = "totalduration"

fileprivate let key_disc = "partofset"
fileprivate let key_track = "tracknumber"
fileprivate let key_track_zeroBased = "track"
fileprivate let key_lyrics = "lyrics"
fileprivate let key_syncLyrics = "lyrics_synchronised"

fileprivate let key_encodingTime = "encodingtime"
fileprivate let key_isVBR = "isvbr"
fileprivate let key_isCompilation = "iscompilation"

fileprivate let key_language = "language"

// Used for parsing "Encoding time" field
//fileprivate let fileTime_baseTime: Date = {
//
//    var calendar = Calendar(identifier: .gregorian)
//    let components = DateComponents(year: 1601, month: 1, day: 1, hour: 0, minute: 0, second: 0)
//    return calendar.date(from: components)!
//}()

//fileprivate let dateFormatter: DateFormatter = {
//   
//    let formatter = DateFormatter()
//    formatter.dateFormat = "MMMM dd, yyyy  'at'  hh:mm:ss a"
//    return formatter
//}()

class WMParser: FFMpegMetadataParser {
    
    private let keyPrefix = "wm/"
    
    private let essentialKeys: [String: String] = [
        
        key_title: "Title",
        key_artist: "Artist",
        key_album: "Album",
        key_genre: "Genre",
        key_disc: "Disc#",
        key_track: "Track#",
        key_lyrics: "Lyrics"
    ]
    
    func mapTrack(_ mapForTrack: LibAVMetadata) {
        
        var map = mapForTrack.map
        
        let metadata = LibAVParserMetadata()
        mapForTrack.wmMetadata = metadata
        
        for (key, value) in map {
            
            let lcKey = key.lowercased().replacingOccurrences(of: keyPrefix, with: "").trim()
            
            if essentialKeys[lcKey] != nil {
                
                metadata.essentialFields[lcKey] = value
                map.removeValue(forKey: key)
                
            } else if genericKeys[lcKey] != nil {
                
                metadata.genericFields[lcKey] = value
                map.removeValue(forKey: key)
            }
        }
    }
    
    func getTitle(_ mapForTrack: LibAVMetadata) -> String? {
        
        if let title = mapForTrack.wmMetadata?.essentialFields[key_title] {
            return title
        }
        
        return nil
    }
    
    func getArtist(_ mapForTrack: LibAVMetadata) -> String? {
        
        if let artist = mapForTrack.wmMetadata?.essentialFields[key_artist] {
            return artist
        }
        
        return nil
    }
    
    func getAlbum(_ mapForTrack: LibAVMetadata) -> String? {
        
        if let album = mapForTrack.wmMetadata?.essentialFields[key_album] {
            return album
        }
        
        return nil
    }
    
    func getGenre(_ mapForTrack: LibAVMetadata) -> String? {
        
        if let genre = mapForTrack.wmMetadata?.essentialFields[key_genre] {
            return genre
        }
        
        if let genreId = mapForTrack.wmMetadata?.essentialFields[key_genreId]?.trim() {
            return parseGenreNumericString(genreId)
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
                return ID3Parser.genreForCode(genreCode) ?? string
            }
        }
        
        return string
    }
    
    func getDiscNumber(_ mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)? {
        
        if let discNumStr = mapForTrack.wmMetadata?.essentialFields[key_disc] {
            return parseDiscOrTrackNumber(discNumStr)
        }
        
        return nil
    }
    
    func getTrackNumber(_ mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)? {
        
        if let trackNumStr = mapForTrack.wmMetadata?.essentialFields[key_track] {
            return parseDiscOrTrackNumber(trackNumStr)
        }
        
        // TODO: Check if total present, if not, check for tracktotal or totaltracks field
        
        // Zero-based track number
        if let trackNumStr = mapForTrack.wmMetadata?.essentialFields[key_track_zeroBased] {
            return parseDiscOrTrackNumber(trackNumStr, 1)
        }
        
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
        
        if let lyrics = mapForTrack.wmMetadata?.essentialFields[key_lyrics] {
            return lyrics
        }
        
        if let lyrics = mapForTrack.wmMetadata?.essentialFields[key_syncLyrics] {
            return lyrics
        }
        
        return nil
    }
    
    func getGenericMetadata(_ mapForTrack: LibAVMetadata) -> [String : MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        if let fields = mapForTrack.wmMetadata?.genericFields {
            
            for (key, var value) in fields {
                
                // Check special fields (TODO: Check special fields (e.g. encoding time))
                
                if key == key_isVBR || key == key_isCompilation, let boolVal = numericStringToBoolean(value) {
                    value = boolVal ? "Yes" : "No"
                } else if key == key_language, let langName = LanguageCodes.languageNameForCode(value.trim()) {
                    value = langName
                }
                
                metadata[key] = MetadataEntry(.wma, readableKey(key), value)
            }
        }
        
        return metadata
    }
    
    private let genericKeys: [String: String] = {
        
        var map: [String: String] = [:]
        
        map["description"] = "Comment"
        
        map["albumartist"] = "Album Artist"
        
        map["provider"] = "Provider"
        
        map["providerrating"] = "Provider Rating"
        
        map["providerstyle"] = "Provider Style"
        
        map["contentdistributor"] = "Content Distributor"
        
        map["wmfsdkversion"] = "Windows Media Format Version"

        map["encodingtime"] = "Encoding Timestamp"
        
        map["wmadrcpeakreference"] = "DRC Peak Reference"
        
        map["wmadrcaveragereference"] = "DRC Average Reference"
        
        map["uniquefileidentifier"] = "Unique File Identifier"
        
        map["modifiedby"] = "Remixer"
        
        map["subtitle"] = "Subtitle"
        
        map["setsubtitle"] = "Dics Subtitle"
        
        map["contentgroupdescription"] = "Grouping"
        
        map["acoustid/fingerprint"] = "AcoustId Fingerprint"
        
        map["acoustid/id"] = "AcoustId Id"
        
        map["albumartistsortorder"] = "Album Artist Sort Order"
        
        map["albumsortorder"] = "Album Sort Order"
        
        map["arranger"] = "Arranger"
        
        map["artistsortorder"] = "Artist Sort Order"
        
        map["asin"] = "ASIN"
        
        map["authorurl"] = "Official Artist Site Url"
        
        map["barcode"] = "Barcode"
        
        map["beatsperminute"] = "BPM"
        
        map["catalogno"] = "Catalog Number"
        
        map["comments"] = "Comment"
        
        map["iscompilation"] = "Is Compilation?"
        
        map["composer"] = "Composer"
        
        map["composersort"] = "Composer Sort Order"
        
        map["conductor"] = "Conductor"
        
        map["copyright"] = "Copyright"
        
        map["country"] = "Country"
        
        map["year"] = "Year"
        
        map["discogsartisturl"] = "Discogs Artist Site Url"
        
        map["discogsreleaseurl"] = "Discogs Release Site Url"
        
        map["musicbrainz_albumstatus"] = "MusicBrainz Album Status"
        
        map["encodedby"] = "Encoded By"
        
        map["encodingsettings"] = "Encoder"
        
        map["engineer"] = "Engineer"
        
        map["fbpm"] = "Floating Point BPM"
        
        map["contentgroupdescription"] = "Grouping"
        
        map["isrc"] = "ISRC"
        
        map["initialkey"] = "Key"
        
        map["publisher"] = "Label"
        
        map["language"] = "Language"
        
        map["writer"] = "Lyricist"
        
        map["lyricsurl"] = "Lyrics Site Url"
        
        map["media"] = "Media"
        
        map["mediastationcallsign"] = "Service Provider"
        
        map["mediastationname"] = "Service Name"
        
        map["media"] = "Media"
        
        map["mixer"] = "Mixer"
        
        map["mood"] = "Mood"
        
        map["musicbrainz/artist id"] = "MusicBrainz Artist Id"
        
        map["musicbrainz/disc id"] = "MusicBrainz Disc Id"
        
        map["musicbrainz/original album id"] = "MusicBrainz Original Release Id"
        
        map["musicbrainz/album artist id"] = "MusicBrainz Release Artist Id"
        
        map["musicbrainz/release group id"] = "MusicBrainz Release Group Id"
        
        map["musicbrainz/album id"] = "MusicBrainz Release Id"
        
        map["musicbrainz/album release country"] = "MusicBrainz Release Country"
        
        map["musicbrainz/album status"] = "MusicBrainz Release Status"
        
        map["musicbrainz/album type"] = "MusicBrainz Release Type"
        
        map["musicbrainz/track id"] = "MusicBrainz Track Id"
        
        map["musicbrainz/work id"] = "MusicBrainz Work Id"
        
        map["occasion"] = "Occasion"
        
        map["officialreleaseurl"] = "Official Release Site Url"
        
        map["originalalbumtitle"] = "Original Album"
        
        map["originalartist"] = "Original Artist"
        
        map["originalfilename"] = "Original Filename"
        
        map["originallyricist"] = "Original Lyricist"
        
        map["originalreleaseyear"] = "Original Release Date"
        
        map["url_wikipedia_release_site"] = "Podcast"
        
        map["url_official_artist_site"] = "Podcast URL"
        
        map["producer"] = "Producer"
        
        map["quality"] = "Quality"
        
        map["shareduserrating"] = "Rating"
        
        map["modifiedby"] = "Remixer"
        
        map["script"] = "Script"
        
        map["tags"] = "Tags"
        
        map["tempo"] = "Tempo"
        
        map["titlesortorder"] = "Title Sort Order"
        
        map["tool"] = "Encoder"
        
        map["wikipediaartisturl"] = "Wikipedia Artist Site Url"
        
        map["wikipediareleaseurl"] = "Wikipedia Release Site Url"
        
        map["deviceconformancetemplate"] = "Device Conformance Template"
        
        map["isvbr"] = "Is VBR?"
        
        map["mediaprimaryclassid"] = "Primary Media Class ID"
        
        map["codec"] = "Codec"
        
        map["category"] = "Category"
        
        return map
    }()
    
    private func readableKey(_ key: String) -> String {
        
        let lcKey = key.lowercased()
        let trimmedKey = lcKey.replacingOccurrences(of: keyPrefix, with: "").trim()
        
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
