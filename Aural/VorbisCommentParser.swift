import Cocoa
import AVFoundation

fileprivate let key_title = "title"
fileprivate let key_artist = "artist"
fileprivate let key_artists = "artists"
fileprivate let key_album = "album"
fileprivate let key_genre = "genre"

fileprivate let key_disc = "discnumber"
fileprivate let key_discTotal = "disctotal"
fileprivate let key_totalDiscs = "totaldiscs"

fileprivate let key_track = "tracknumber"
fileprivate let key_trackTotal = "tracktotal"
fileprivate let key_totalTracks = "totaltracks"

fileprivate let key_lyrics = "lyrics"

class VorbisCommentParser: FFMpegMetadataParser {
    
    private let key_encodingTime = "encodingtime"
    private let key_language = "language"
    private let key_compilation = "compilation"
    
    private let essentialKeys: Set<String> = [key_title, key_artist, key_artists, key_album, key_genre, key_disc, key_totalDiscs, key_discTotal, key_track, key_trackTotal, key_totalTracks, key_lyrics]
    
    func mapTrack(_ mapForTrack: LibAVMetadata) {
        
        let metadata = LibAVParserMetadata()
        mapForTrack.vorbisMetadata = metadata
        
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
        
        if let title = mapForTrack.vorbisMetadata?.essentialFields[key_title] {
            return title
        }
        
        return nil
    }
    
    func getArtist(_ mapForTrack: LibAVMetadata) -> String? {
        
        for key in [key_artist, key_artists] {
            
            if let artist = mapForTrack.vorbisMetadata?.essentialFields[key] {
                return artist
            }
        }
        
        return nil
    }
    
    func getAlbum(_ mapForTrack: LibAVMetadata) -> String? {
        
        if let album = mapForTrack.vorbisMetadata?.essentialFields[key_album] {
            return album
        }
        
        return nil
    }
    
    func getGenre(_ mapForTrack: LibAVMetadata) -> String? {
        
        if let genre = mapForTrack.vorbisMetadata?.essentialFields[key_genre] {
            return genre
        }
        
        return nil
    }
    
    func getDiscNumber(_ mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)? {
        
        if let discNumStr = mapForTrack.vorbisMetadata?.essentialFields[key_disc] {
            return ParserUtils.parseDiscOrTrackNumberString(discNumStr)
        }
        
        return nil
    }
    
    func getTotalDiscs(_ mapForTrack: LibAVMetadata) -> Int? {
        
        for key in [key_discTotal, key_totalDiscs] {
            
            if let totalDiscsStr = mapForTrack.vorbisMetadata?.essentialFields[key]?.trim(), let totalDiscs = Int(totalDiscsStr) {
                return totalDiscs
            }
        }
        
        return nil
    }
    
    func getTrackNumber(_ mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)? {
        
        if let trackNumStr = mapForTrack.vorbisMetadata?.essentialFields[key_track] {
            return ParserUtils.parseDiscOrTrackNumberString(trackNumStr)
        }
        
        return nil
    }
    
    func getTotalTracks(_ mapForTrack: LibAVMetadata) -> Int? {
        
        for key in [key_trackTotal, key_totalTracks] {

            if let totalTracksStr = mapForTrack.vorbisMetadata?.essentialFields[key]?.trim(), let totalTracks = Int(totalTracksStr) {
                return totalTracks
            }
        }
        
        return nil
    }
    
    func getLyrics(_ mapForTrack: LibAVMetadata) -> String? {
        
        if let lyrics = mapForTrack.vorbisMetadata?.essentialFields[key_lyrics] {
            return lyrics
        }
        
        return nil
    }
    
    func getGenericMetadata(_ mapForTrack: LibAVMetadata) -> [String : MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        if let fields = mapForTrack.vorbisMetadata?.genericFields {
            
            for (key, var value) in fields {
                
                // Check special fields
                if key == key_language, let langName = LanguageMap.forCode(value.trim()) {
                    value = langName
                } else if key == key_compilation, let bVal = numericStringToBoolean(value) {
                    value = bVal ? "Yes" : "No"
                }
                
                value = StringUtils.cleanUpString(value)
                
                metadata[key] = MetadataEntry(.vorbis, readableKey(key), value)
            }
        }
        
        return metadata
    }
    
    private let genericKeys: [String: String] = {
        
        var map: [String: String] = [:]
        
        map["copyright"] = "Copyright"
        map["ean/upn"] = "EAN / UPN"
        map["labelno"] = "Catalog Number"
        map["license"] = "License"
        map["opus"] = "Opus Number"
        map["version"] = "Version"
        map["encoded-by"] = "Encoded By"
        map["encodedby"] = "Encoded By"
        map["encoding"] = "Encoder Settings"
        map["encodedusing"] = "EncodedUsing"
        map["encoderoptions"] = "EncoderOptions"
        map["encodersettings"] = "Encoder Settings"
        map["encodingtime"] = "Encoding Time"
        map["encoder"] = "Encoder"
        map["composer"] = "Composer"
        map["arranger"] = "Arranger"
        map["author"] = "Author"
        map["writer"] = "Writer"
        map["ensemble"] = "Ensemble"
        map["part"] = "Part"
        map["partnumber"] = "Part Number"
        map["date"] = "Date"
        map["location"] = "Location"
        map["albumartist"] = "Album Artist"
        
        map["actor"] = "Actor"
        map["director"] = "Director"
        
        map["replaygainalbumgain"] = "ReplayGain Album Gain"
        map["replaygainalbumpeak"] = "ReplayGain Album Peak"
        map["replaygaintrackgain"] = "ReplayGain Track Gain"
        map["replaygaintrackpeak"] = "ReplayGain Track Peak"
        map["vendor"] = "Vendor"
        
        map["grouping"] = "Grouping"
        
        map["albumartistsort"] = "Album Artist Sort Order"
        map["artistsort"] = "Artist Sort Order"
        map["albumsort"] = "Album Sort Order"
        map["titlesort"] = "Title Sort Order"
        
        map["subtitle"] = "Track Subtitle"
        
        map["upc"] = "UPC"
        
        map["barcode"] = "Barcode"
        
        map["catalognumber"] = "Catalog Number"
        
        map["category"] = "Category"
        
        map["description"] = "Description"
        
        map["contact"] = "Contact"
        
        map["comment"] = "Comment"
        
        map["commercial_info_url"] = "Commercial Information Webpage"
        
        map["conductor"] = "Conductor"
        
        map["copyright_url"] = "Copyright/Legal Information Webpage"
        
        map["country"] = "Country"
        
        map["cuesheet"] = "Cuesheet"
        
        map["user configurable"] = "Custom 0...99"
        
        map["filetype"] = "File Type"
        
        map["key"] = "Initial Key"
        
        map["involvedpeople"] = "Involved People"
        
        map["djmixer"] = "DJ Mixer"
        
        map["engineer"] = "Engineer"
        
        map["mixer"] = "Mixer"
        
        map["producer"] = "Producer"
        
        map["productnumber"] = "Product Number"
        
        map["organization"] = "Organization"
        
        map["instrumental"] = "Instrumental"
        
        map["instrument"] = "Instrument"
        
        map["isrc"] = "ISRC"
        
        map["label"] = "Label"
        
        map["language"] = "Language"
        
        map["length"] = "Length (ms)"
        
        map["love-dislike rating"] = "Love"
        
        map["lyricist"] = "Lyricist"
        
        map["media"] = "Media Type"
        
        map["mood"] = "Mood"
        map["style"] = "Style"
        map["bpm"] = "BPM (Beats Per Minute)"
        
        map["music_cd_identifier"] = "Music CD Identifier"
        
        map["script"] = "Script"
        
        map["performer"] = "Performer"
        map["musiciancredits"] = "Musician Credits"
        
        map["url_official_artist_site"] = "Official Artist/Performer Webpage"
        
        map["official_audio_file_url"] = "Official Audio File Webpage"
        
        map["official_audio_source_url"] = "Official Audio Source Webpage"
        
        map["official_radio_url"] = "Official Internet Radio Station Webpage"
        
        map["original album"] = "Original Album"
        
        map["original artist"] = "Original Artist"
        
        map["original filename"] = "Original Filename"
        
        map["original lyricist"] = "Original Lyricist"
        
        map["originaldate"] = "Original Release Date"
        map["original year"] = "Original Release Year"
        map["originalreleasedate"] = "Original Release Year"
        map["original_year"] = "Original Release Year"
        
        map["period"] = "Period"
        
        map["payment_url"] = "Payment Webpage"
        
        map["pricepaid"] = "Price Paid"
        
        map["produced_notice"] = "Produced Notice"
        
        map["publisher"] = "Publisher"
        
        map["label_url"] = "Publisher's Official Webpage"
        
        map["radio_station"] = "Radio Station"
        
        map["rating"] = "Rating"
        
        map["rights"] = "Rights"
        
        map["releasetime"] = "Release Time"
        
        map["remixer"] = "Remixer"
        
        map["soloists"] = "Soloists"
        
        map["replaygain_album_gain"] = "ReplayGain Album Gain"
        
        map["replaygain_album_peak"] = "ReplayGain Album Peak"
        
        map["replaygain_track_gain"] = "ReplayGain Track Gain"
        
        map["replaygain_track_peak"] = "ReplayGain Track Peak"
        
        map["set subtitle"] = "Set Subtitle"
        
        map["discsubtitle"] = "Disc Subtitle"
        
        map["skipwhenshuffling"] = "Skip When Shuffling"
        
        map["source"] = "Source"
        
        map["sourcemedia"] = "Source Media"
        
        map["station_owner"] = "Station Owner"
        
        map["taggingtime"] = "Tagging Time"
        
        map["termsofuse"] = "Terms of Use"
        
        map["track_number_text"] = "Track Position"
        
        map["ufid"] = "Unique File Identifier"
        
        map["work"] = "Work"
        
        map["originalyear"] = "Original Release Year"
        map["composersort"] = "Composer Sort Order"
        map["movementname"] = "Movement Name"
        map["movement"] = "Movement"
        map["movementtotal"] = "Movement Total"
        map["showmovement"] = "Show Movement"
        map["compilation"] = "Part of a Compilation?"
        map["releasestatus"] = "Release Status"
        map["releasetype"] = "Release Type"
        map["releasecountry"] = "Release Country"
        map["asin"] = "ASIN"
        map["website"] = "Official Artist Website"
        
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
