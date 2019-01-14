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
fileprivate let key_discTotal = "disctotal"
fileprivate let key_track = "tracknumber"
fileprivate let key_track_zeroBased = "track"
fileprivate let key_trackTotal = "tracktotal"

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
    
    private let essentialKeys: Set<String> = [key_title, key_artist, key_album, key_genre, key_genreId, key_disc, key_discTotal, key_track, key_track_zeroBased, key_trackTotal, key_lyrics]
    
    private let ignoredKeys: Set<String> = ["wmfsdkneeded"]
    
    func mapTrack(_ mapForTrack: LibAVMetadata) {
        
        let metadata = LibAVParserMetadata()
        mapForTrack.wmMetadata = metadata
        
        for (key, value) in mapForTrack.map {
            
            let lcKey = key.lowercased().replacingOccurrences(of: keyPrefix, with: "").trim()
            
            if !ignoredKeys.contains(lcKey) {
                
                if essentialKeys.contains(lcKey) {
                    
                    metadata.essentialFields[lcKey] = value
                    mapForTrack.map.removeValue(forKey: key)
                    
                } else if genericKeys[lcKey] != nil {
                    
                    metadata.genericFields[lcKey] = value
                    mapForTrack.map.removeValue(forKey: key)
                }
                
            } else {
                mapForTrack.map.removeValue(forKey: key)
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
            return ParserUtils.parseID3GenreNumericString(genreId)
        }
        
        return nil
    }
    
    func getDiscNumber(_ mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)? {
        
        if let discNumStr = mapForTrack.wmMetadata?.essentialFields[key_disc] {
            return ParserUtils.parseDiscOrTrackNumberString(discNumStr)
        }
        
        return nil
    }
    
    func getTotalDiscs(_ mapForTrack: LibAVMetadata) -> Int? {
        
        if let totalDiscsStr = mapForTrack.wmMetadata?.essentialFields[key_discTotal]?.trim(), let totalDiscs = Int(totalDiscsStr) {
            return totalDiscs
        }
        
        return nil
    }
    
    func getTrackNumber(_ mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)? {
        
        if let trackNumStr = mapForTrack.wmMetadata?.essentialFields[key_track] {
            return ParserUtils.parseDiscOrTrackNumberString(trackNumStr)
        }
        
        // Zero-based track number
        if let trackNumStr = mapForTrack.wmMetadata?.essentialFields[key_track_zeroBased], let trackNum = ParserUtils.parseDiscOrTrackNumberString(trackNumStr) {
            
            // Offset the track number by 1
            if let number = trackNum.number {
                return (number + 1, trackNum.total)
            }
            
            return trackNum
        }
        
        return nil
    }
    
    func getTotalTracks(_ mapForTrack: LibAVMetadata) -> Int? {
        
        if let totalTracksStr = mapForTrack.wmMetadata?.essentialFields[key_trackTotal]?.trim(), let totalTracks = Int(totalTracksStr) {
            return totalTracks
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
                } else if key == key_language, let langName = LanguageMap.forCode(value.trim()) {
                    value = langName
                }
                
                value = StringUtils.cleanUpString(value)
                
                metadata[key] = MetadataEntry(.wma, readableKey(key), value)
            }
        }
        
        return metadata
    }
    
    private let genericKeys: [String: String] = {
        
        var map: [String: String] = [:]
        
        map["averagelevel"] = "Avg. Volume Level"
        
        map["peakvalue"] = "Peak Volume Level"
        
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
        
        map["albumartistsortorder"] = "Album Artist Sort Order"
        
        map["albumsortorder"] = "Album Sort Order"
        
        map["arranger"] = "Arranger"
        
        map["artistsortorder"] = "Artist Sort Order"
        
        map["asin"] = "ASIN"
        
        map["authorurl"] = "Official Artist Site Url"
        
        map["barcode"] = "Barcode"
        
        map["beatsperminute"] = "BPM (Beats Per Minute)"
        
        map["catalogno"] = "Catalog Number"
        
        map["comments"] = "Comment"
        
        map["iscompilation"] = "Part of a Compilation?"
        
        map["composer"] = "Composer"
        
        map["composersort"] = "Composer Sort Order"
        
        map["conductor"] = "Conductor"
        
        map["copyright"] = "Copyright"
        
        map["country"] = "Country"
        
        map["year"] = "Year"
        
        map["encodedby"] = "Encoded By"
        
        map["encodingsettings"] = "Encoder"
        
        map["engineer"] = "Engineer"
        
        map["fbpm"] = "Floating Point BPM"
        
        map["contentgroupdescription"] = "Grouping"
        
        map["isrc"] = "ISRC"
        
        map["initialkey"] = "Key"
        
        map["publisher"] = "Label"
        
        map["language"] = "Language"
        
        map["writer"] = "Writer"
        
        map["lyricsurl"] = "Lyrics Site Url"
        
        map["media"] = "Media"
        
        map["mediastationcallsign"] = "Service Provider"
        
        map["mediastationname"] = "Service Name"
        
        map["media"] = "Media"
        
        map["mixer"] = "Mixer"
        
        map["mood"] = "Mood"
        
        map["occasion"] = "Occasion"
        
        map["officialreleaseurl"] = "Official Release Site Url"
        
        map["originalalbumtitle"] = "Original Album"
        
        map["originalartist"] = "Original Artist"
        
        map["originalfilename"] = "Original Filename"
        
        map["originallyricist"] = "Original Lyricist"
        
        map["originalreleaseyear"] = "Original Release Year"
        
        map["url_official_artist_site"] = "Official Artist Website"
        
        map["producer"] = "Producer"
        
        map["quality"] = "Quality"
        
        map["shareduserrating"] = "Rating"
        
        map["modifiedby"] = "Remixer"
        
        map["script"] = "Script"
        
        map["tags"] = "Tags"
        
        map["tempo"] = "Tempo"
        
        map["titlesortorder"] = "Title Sort Order"
        
        map["tool"] = "Encoder"
        
        map["toolname"] = "Encoder"
        
        map["toolversion"] = "Encoder Version"
        
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
