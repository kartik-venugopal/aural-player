import Cocoa
import AVFoundation

class WMParser: FFMpegMetadataParser {
    
    private let key_title = "title"
    
    private let key_author = "author"
    private let key_artist = "artist"
    private let key_artists = "artists"
    
    private let key_album = "album"
    private let key_albumTitle = "albumtitle"
    
    private let key_genre = "genre"
    private let key_genreId = "genreid"
    
    func getDuration(mapForTrack: LibAVMetadata) -> Double? {
        return 5
    }
    
    func getTitle(mapForTrack: LibAVMetadata) -> String? {
        
        for key in [key_title] {
            
            if let title = mapForTrack.map[key] {
                return title
            }
        }
        
        return nil
    }
    
    func getArtist(mapForTrack: LibAVMetadata) -> String? {
        
        for key in [key_author, key_artist, key_artists] {
            
            if let artist = mapForTrack.map[key] {
                return artist
            }
        }
        
        return nil
    }
    
    func getAlbum(mapForTrack: LibAVMetadata) -> String? {
        
        for key in [key_album, key_albumTitle] {
            
            if let album = mapForTrack.map[key] {
                return album
            }
        }
        
        return nil
    }
    
    func getGenre(mapForTrack: LibAVMetadata) -> String? {
        
        if let genre = mapForTrack.map[key_genre] {
            return genre
        }
        
        if let genreId = mapForTrack.map[key_genreId]?.trim() {
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
    
    func getLyrics(mapForTrack: LibAVMetadata) -> String? {
        return "Yay Muthu !"
    }
    
    func getDiscNumber(mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)? {
        return (2, 3)
    }
    
    func getTrackNumber(mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)? {
        return (13, 22)
    }
    
    func getArt(mapForTrack: LibAVMetadata) -> NSImage? {
        return nil
    }
    
    func getArt(_ asset: AVURLAsset) -> NSImage? {
        return nil
    }
    
    func getGenericMetadata(mapForTrack: LibAVMetadata) -> [String : MetadataEntry] {
        return [:]
    }
    
    private static var map: [String: String] = initMap()
    
    static func readableKey(_ key: String) -> String {
        
        let lcKey = key.lowercased()
        let trimmedKey = lcKey.replacingOccurrences(of: "wm/", with: "").trim()
        
        return map[trimmedKey] ?? key.replacingOccurrences(of: "wm/", with: "").trim().capitalizingFirstLetter()
    }
    
    static func initMap() -> [String: String] {
        
        var map: [String: String] = [:]
        
        map["title"] = "Title"
        
        map["author"] = "Artist"
        
        map["artists"] = "Artists"
        
        map["albumartist"] = "Album Artist"
        
        map["albumtitle"] = "Album"
        
        map["genre"] = "Genre"
        
        map["genreid"] = "Genre ID"
        
        map["track"] = "Track Number"    // Deprecated 0-based track number
        
        map["tracknumber"] = "Track Number"  // 1-based track number
        
        map["partofset"] = "Disc Number"
        
        map["tracktotal"] = "Total Tracks"
        
        map["disctotal"] = "Total Discs"
        
        map["lyrics"] = "Lyrics"
        
        map["picture"] = "Cover Art"
        
        // ----------
        
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
        
        map["barcode"] = "Barcode"
        
        map["beatsperminute"] = "BPM"
        
        map["catalogno"] = "Catalog Number"
        
        map["comments"] = "Comment"
        
        map["iscompilation"] = "Compilation"
        
        map["composer"] = "Composer"
        
        map["composersort"] = "Composer Sort Order"
        
        map["conductor"] = "Conductor"
        
        map["copyright"] = "Copyright"
        
        map["country"] = "Country"
        
        map["custom1"] = "Custom 1"
        
        map["custom2"] = "Custom 2"
        
        map["custom3"] = "Custom 3"
        
        map["custom4"] = "Custom 4"
        
        map["custom5"] = "Custom 5"
        
        map["year"] = "Year"
        
        map["discogsartisturl"] = "Discogs Artist Site Url"
        
        map["discogsreleaseurl"] = "Discogs Release Site Url"
        
        map["musicbrainz_albumstatus"] = "DJ Mixer"
        
        map["encodedby"] = "Encoded By"
        
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
        
        map["mixer"] = "Mixer"
        
        map["mood"] = "Mood"
        
        map["musicbrainz/artist id"] = "MusicBrainz Artist Id"
        
        map["musicbrainz/disc id"] = "MusicBrainz Disc Id"
        
        map["musicbrainz/original album id"] = "MusicBrainz Original Release Id"
        
        map["musicbrainz/album artist id"] = "MusicBrainz Release Artist Id"
        
        map["musicbrainz/release group id"] = "MusicBrainz Release Group Id"
        
        map["musicbrainz/album id"] = "MusicBrainz Release Id"
        
        map["musicbrainz/track id"] = "MusicBrainz Track Id"
        
        map["musicbrainz/work id"] = "MusicBrainz Work Id"
        
        map["occasion"] = "Occasion"
        
        map["authorurl"] = "Official Artist Site Url"
        
        map["officialreleaseurl"] = "Official Release Site Url"
        
        map["originalalbumtitle"] = "Original Album"
        
        map["originalartist"] = "Original Artist"
        
        map["originallyricist"] = "Original Lyricist"
        
        map["originalreleaseyear"] = "Original Release Date"
        
        map["url_wikipedia_release_site"] = "Podcast"
        
        map["url_official_artist_site"] = "Podcast URL"
        
        map["producer"] = "Producer"
        
        map["quality"] = "Quality"
        
        map["shareduserrating"] = "Rating"
        
        map["musicbrainz/album release country"] = "Release Country"
        
        map["musicbrainz/album status"] = "Release Status"
        
        map["musicbrainz/album type"] = "Release Type"
        
        map["modifiedby"] = "Remixer"
        
        map["script"] = "Script"
        
        map["tags"] = "Tags"
        
        map["tempo"] = "Tempo"
        
        map["titlesortorder"] = "Title Sort Order"
        
        map["wikipediaartisturl"] = "Wikipedia Artist Site Url"
        
        map["wikipediareleaseurl"] = "Wikipedia Release Site Url"

        return map
    }
}
