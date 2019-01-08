import Foundation

class WMSpec {
    
    private static var map: [String: String] = initMap()
    
    static func readableKey(_ key: String) -> String {
        return map[key] ?? key.capitalizingFirstLetter()
    }
    
    static func initMap() -> [String: String] {
        
        var map: [String: String] = [:]
        
        map["title"] = "Title"
        
        map["author"] = "Artist"
        
        map["wm/albumtitle"] = "Album"
        
        map["wm/genre"] = "Genre"
        
        map["wm/genreid"] = "Genre ID"
        
        map["wm/track"] = "Track Number"    // Deprecated 0-based track number
        
        map["wm/tracknumber"] = "Track Number"  // 1-based track number
        
        map["wm/partofset"] = "Disc Number"
        
        map["wm/tracktotal"] = "Total Tracks"
        
        map["wm/disctotal"] = "Total Discs"
        
        map["wm/lyrics"] = "Lyrics"
        
        map["wm/artists"] = "Artists"
        
        map["wm/albumartist"] = "Album Artist"
        
        map["wm/picture"] = "Cover Art"
        
        // ----------
        
        map["wm/provider"] = "Provider"
        
        map["wm/providerrating"] = "Provider Rating"
        
        map["wm/providerstyle"] = "Provider Style"
        
        map["wm/contentdistributor"] = "Content Distributor"
        
        map["wmfsdkversion"] = "Windows Media Format Version"

        map["wm/encodingtime"] = "Encoding Timestamp"
        
        map["wm/wmadrcpeakreference"] = "DRC Peak Reference"
        
        map["wm/wmadrcaveragereference"] = "DRC Average Reference"
        
        map["wm/uniquefileidentifier"] = "Unique File Identifier"
        
        map["wm/modifiedby"] = "Remixer"
        
        map["wm/subtitle"] = "Subtitle"
        
        map["wm/setsubtitle"] = "Dics Subtitle"
        
        map["wm/contentgroupdescription"] = "Grouping"
        
        map["acoustid/fingerprint"] = "AcoustId Fingerprint"
        
        map["acoustid/id"] = "AcoustId Id"
        
        map["wm/albumartistsortorder"] = "Album Artist Sort Order"
        
        map["wm/albumsortorder"] = "Album Sort Order"
        
        map["wm/arranger"] = "Arranger"
        
        map["wm/artistsortorder"] = "Artist Sort Order"
        
        map["asin"] = "ASIN"
        
        map["wm/barcode"] = "Barcode"
        
        map["wm/beatsperminute"] = "BPM"
        
        map["wm/catalogno"] = "Catalog Number"
        
        map["wm/comments"] = "Comment"
        
        map["wm/iscompilation"] = "Compilation"
        
        map["wm/composer"] = "Composer"
        
        map["wm/composersort"] = "Composer Sort Order"
        
        map["wm/conductor"] = "Conductor"
        
        map["copyright"] = "Copyright"
        
        map["wm/country"] = "Country"
        
        map["custom1"] = "Custom 1"
        
        map["custom2"] = "Custom 2"
        
        map["custom3"] = "Custom 3"
        
        map["custom4"] = "Custom 4"
        
        map["custom5"] = "Custom 5"
        
        map["wm/year"] = "Year"
        
        map["wm/discogsartisturl"] = "Discogs Artist Site Url"
        
        map["wm/discogsreleaseurl"] = "Discogs Release Site Url"
        
        map["musicbrainz_albumstatus"] = "DJ Mixer"
        
        map["wm/encodedby"] = "Encoded By"
        
        map["wm/engineer"] = "Engineer"
        
        map["fbpm"] = "Floating Point BPM"
        
        map["wm/contentgroupdescription"] = "Grouping"
        
        map["wm/isrc"] = "ISRC"
        
        map["wm/initialkey"] = "Key"
        
        map["wm/publisher"] = "Label"
        
        map["wm/language"] = "Language"
        
        map["wm/writer"] = "Lyricist"
        
        map["wm/lyricsurl"] = "Lyrics Site Url"
        
        map["wm/media"] = "Media"
        
        map["wm/mixer"] = "Mixer"
        
        map["wm/mood"] = "Mood"
        
        map["musicbrainz/artist id"] = "MusicBrainz Artist Id"
        
        map["musicbrainz/disc id"] = "MusicBrainz Disc Id"
        
        map["musicbrainz/original album id"] = "MusicBrainz Original Release Id"
        
        map["musicbrainz/album artist id"] = "MusicBrainz Release Artist Id"
        
        map["musicbrainz/release group id"] = "MusicBrainz Release Group Id"
        
        map["musicbrainz/album id"] = "MusicBrainz Release Id"
        
        map["musicbrainz/track id"] = "MusicBrainz Track Id"
        
        map["musicbrainz/work id"] = "MusicBrainz Work Id"
        
        map["occasion"] = "Occasion"
        
        map["wm/authorurl"] = "Official Artist Site Url"
        
        map["wm/officialreleaseurl"] = "Official Release Site Url"
        
        map["wm/originalalbumtitle"] = "Original Album"
        
        map["wm/originalartist"] = "Original Artist"
        
        map["wm/originallyricist"] = "Original Lyricist"
        
        map["wm/originalreleaseyear"] = "Original Release Date"
        
        map["url_wikipedia_release_site"] = "Podcast"
        
        map["url_official_artist_site"] = "Podcast URL"
        
        map["wm/producer"] = "Producer"
        
        map["quality"] = "Quality"
        
        map["wm/shareduserrating"] = "Rating"
        
        map["musicbrainz/album release country"] = "Release Country"
        
        map["musicbrainz/album status"] = "Release Status"
        
        map["musicbrainz/album type"] = "Release Type"
        
        map["wm/modifiedby"] = "Remixer"
        
        map["wm/script"] = "Script"
        
        map["wm/tags"] = "Tags"
        
        map["tempo"] = "Tempo"
        
        map["wm/titlesortorder"] = "Title Sort Order"
        
        map["wm/wikipediaartisturl"] = "Wikipedia Artist Site Url"
        
        map["wm/wikipediareleaseurl"] = "Wikipedia Release Site Url"

        return map
    }
}
