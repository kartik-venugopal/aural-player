import Cocoa
import AVFoundation

fileprivate let key_title = "title"

fileprivate let key_artist = "author"
fileprivate let key_originalArtist = "originalartist"
fileprivate let key_albumArtist = "albumartist"

fileprivate let keys_artist: [String] = [key_artist, key_albumArtist, key_originalArtist]

fileprivate let key_album = "albumtitle"
fileprivate let key_originalAlbum = "originalalbumtitle"

fileprivate let key_genre = "genre"
fileprivate let key_genreId = "genreid"

fileprivate let key_duration = "duration"
fileprivate let key_totalDuration = "totalduration"

fileprivate let key_disc = "partofset"
fileprivate let key_discTotal = "disctotal"

fileprivate let key_track = "tracknumber"
fileprivate let key_track_zeroBased = "track"
fileprivate let key_trackTotal = "tracktotal"

fileprivate let key_year = "year"
fileprivate let key_originalYear = "originalreleaseyear"

fileprivate let key_bpm = "beatsperminute"

fileprivate let key_lyrics = "lyrics"
fileprivate let key_syncLyrics = "lyrics_synchronised"

fileprivate let key_encodingTime = "encodingtime"
fileprivate let key_isVBR = "isvbr"
fileprivate let key_isCompilation = "iscompilation"

fileprivate let key_language = "language"

fileprivate let key_asfProtectionType = "asf_protection_type"

class WMParser: FFmpegMetadataParser {
    
    private let keyPrefix = "wm/"
    
    private let essentialKeys: Set<String> = Set([key_title, key_album, key_originalAlbum, key_genre, key_genreId,
        key_disc, key_discTotal, key_track, key_track_zeroBased, key_trackTotal, key_asfProtectionType] + keys_artist)
    
    private let ignoredKeys: Set<String> = ["wmfsdkneeded"]
    
    func mapMetadata(_ metadataMap: FFmpegMappedMetadata) {
        
        let metadata = metadataMap.wmMetadata
        
        for key in metadataMap.map.keys {
            
            let lcKey = key.lowercased().trim().replacingOccurrences(of: keyPrefix, with: "")
            
            if !ignoredKeys.contains(lcKey) {
                
                if essentialKeys.contains(lcKey) {
                    
                    metadata.essentialFields[lcKey] = metadataMap.map.removeValue(forKey: key)
                    
                } else if auxiliaryKeys[lcKey] != nil {
                    
                    metadata.auxiliaryFields[lcKey] = metadataMap.map.removeValue(forKey: key)
                }
                
            } else {
                metadataMap.map.removeValue(forKey: key)
            }
        }
    }
    
    func hasEssentialMetadataForTrack(_ metadataMap: FFmpegMappedMetadata) -> Bool {
        !metadataMap.wmMetadata.essentialFields.isEmpty
    }
    
    func hasGenericMetadataForTrack(_ metadataMap: FFmpegMappedMetadata) -> Bool {
        !metadataMap.wmMetadata.auxiliaryFields.isEmpty
    }
    
    func getTitle(_ metadataMap: FFmpegMappedMetadata) -> String? {
        metadataMap.wmMetadata.essentialFields[key_title]
    }
    
    func getArtist(_ metadataMap: FFmpegMappedMetadata) -> String? {
        keys_artist.firstNonNilMappedValue({metadataMap.wmMetadata.essentialFields[$0]})
    }
    
    func getAlbum(_ metadataMap: FFmpegMappedMetadata) -> String? {
        metadataMap.wmMetadata.essentialFields[key_album] ?? metadataMap.wmMetadata.essentialFields[key_originalAlbum]
    }
    
    func getGenre(_ metadataMap: FFmpegMappedMetadata) -> String? {
        
        if let genre = metadataMap.wmMetadata.essentialFields[key_genre] {
            return genre
        }
        
        if let genreId = metadataMap.wmMetadata.essentialFields[key_genreId]?.trim() {
            return ParserUtils.parseID3GenreNumericString(genreId)
        }
        
        return nil
    }
    
    func getDiscNumber(_ metadataMap: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let discNumStr = metadataMap.wmMetadata.essentialFields[key_disc] {
            return ParserUtils.parseDiscOrTrackNumberString(discNumStr)
        }
        
        return nil
    }
    
    func getTotalDiscs(_ metadataMap: FFmpegMappedMetadata) -> Int? {
        
        if let totalDiscsStr = metadataMap.wmMetadata.essentialFields[key_discTotal]?.trim(), let totalDiscs = Int(totalDiscsStr) {
            return totalDiscs
        }
        
        return nil
    }
    
    func getTrackNumber(_ metadataMap: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let trackNumStr = metadataMap.wmMetadata.essentialFields[key_track] {
            return ParserUtils.parseDiscOrTrackNumberString(trackNumStr)
        }
        
        // Zero-based track number
        if let trackNumStr = metadataMap.wmMetadata.essentialFields[key_track_zeroBased], let trackNum = ParserUtils.parseDiscOrTrackNumberString(trackNumStr) {
            
            // Offset the track number by 1
            if let number = trackNum.number {
                return (number + 1, trackNum.total)
            }
            
            return trackNum
        }
        
        return nil
    }
    
    func getTotalTracks(_ metadataMap: FFmpegMappedMetadata) -> Int? {
        
        if let totalTracksStr = metadataMap.wmMetadata.essentialFields[key_trackTotal]?.trim(), let totalTracks = Int(totalTracksStr) {
            return totalTracks
        }
        
        return nil
    }
    
    func getYear(_ metadataMap: FFmpegMappedMetadata) -> Int? {
        
        if let yearString = metadataMap.wmMetadata.auxiliaryFields[key_year] ?? metadataMap.wmMetadata.auxiliaryFields[key_originalYear] {
            return ParserUtils.parseYear(yearString)
        }
        
        return nil
    }
    
    func getBPM(_ metadataMap: FFmpegMappedMetadata) -> Int? {
        
        if let bpmString = metadataMap.wmMetadata.auxiliaryFields[key_bpm] {
            return ParserUtils.parseBPM(bpmString)
        }
        
        return nil
    }
    
    func getLyrics(_ metadataMap: FFmpegMappedMetadata) -> String? {
        [key_lyrics, key_syncLyrics].firstNonNilMappedValue({metadataMap.wmMetadata.auxiliaryFields[$0]})
    }
    
    func isDRMProtected(_ metadataMap: FFmpegMappedMetadata) -> Bool? {
        metadataMap.wmMetadata.essentialFields[key_asfProtectionType] != nil
    }
    
    private let auxiliaryKeys: [String: String] = {
        
        var map: [String: String] = [:]
        
        map["lyrics"] = "Lyrics"
        map["lyrics_synchronised"] = "Lyrics"
        
        map["year"] = "Year"
        map["originalreleaseyear"] = "Original Release Year"
        
        map["beatsperminute"] = "BPM"
        
        map["composer"] = "Composer"
        map["conductor"] = "Conductor"

        map["originallyricist"] = "Lyricist"
        map["writer"] = "Writer"
        
        map["averagelevel"] = "Avg. Volume Level"
        
        map["peakvalue"] = "Peak Volume Level"
        
        map["description"] = "Comment"
        
        map["provider"] = "Provider"
        
        map["publisher"] = "Publisher"
        
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
        
        map["setsubtitle"] = "Disc Subtitle"
        
        map["contentgroupdescription"] = "Grouping"
        
        map["albumartistsortorder"] = "Album Artist Sort Order"
        
        map["albumsortorder"] = "Album Sort Order"
        
        map["arranger"] = "Arranger"
        
        map["artistsortorder"] = "Artist Sort Order"
        
        map["asin"] = "ASIN"
        
        map["authorurl"] = "Official Artist Site Url"
        
        map["barcode"] = "Barcode"
        
        map["catalogno"] = "Catalog Number"
        
        map["comments"] = "Comment"
        
        map["iscompilation"] = "Part of a Compilation?"
        
        map["composersort"] = "Composer Sort Order"
        
        map["copyright"] = "Copyright"
        
        map["country"] = "Country"
        
        map["encodedby"] = "Encoded By"
        
        map["encodingsettings"] = "Encoder"
        
        map["engineer"] = "Engineer"
        
        map["fbpm"] = "Floating Point BPM"
        
        map["contentgroupdescription"] = "Grouping"
        
        map["isrc"] = "ISRC"
        
        map["initialkey"] = "Key"
        
        map["language"] = "Language"
        
        map["lyricsurl"] = "Lyrics Site Url"
        
        map["media"] = "Media"
        
        map["mediastationcallsign"] = "Service Provider"
        
        map["mediastationname"] = "Service Name"
        
        map["media"] = "Media"
        
        map["mixer"] = "Mixer"
        
        map["mood"] = "Mood"
        
        map["occasion"] = "Occasion"
        
        map["officialreleaseurl"] = "Official Release Site Url"
        
        map["originalfilename"] = "Original Filename"
        
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
        
        if let rKey = auxiliaryKeys[trimmedKey] {
            
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
    
    func getAuxiliaryMetadata(_ metadataMap: FFmpegMappedMetadata) -> [String : MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        for (key, var value) in metadataMap.wmMetadata.auxiliaryFields {
            
            // TODO: Check special fields (e.g. encoding time)
            
            if key == key_isVBR || key == key_isCompilation, let boolVal = numericStringToBoolean(value) {
                value = boolVal ? "Yes" : "No"
            } else if key == key_language, let langName = LanguageMap.forCode(value.trim()) {
                value = langName
            }
            
            value = StringUtils.cleanUpString(value)
            
            metadata[key] = MetadataEntry(.wma, readableKey(key), value)
        }
        
        return metadata
    }
}

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
