import Cocoa

fileprivate let key_title = "title"

fileprivate let key_artist = "artist"
fileprivate let key_albumArtist = "albumartist"
fileprivate let key_albumArtist2 = "album_artist"
fileprivate let key_originalArtist = "original artist"
fileprivate let key_artists = "artists"
fileprivate let key_performer = "performer"

fileprivate let keys_artist: [String] = [key_artist, key_albumArtist, key_albumArtist2, key_originalArtist, key_artists, key_performer]

fileprivate let key_album = "album"
fileprivate let key_originalAlbum = "original album"

fileprivate let key_genre = "genre"

fileprivate let key_disc = "discnumber"
fileprivate let key_discTotal = "disctotal"
fileprivate let key_totalDiscs = "totaldiscs"

fileprivate let keys_totalDiscs: [String] = [key_discTotal, key_totalDiscs]

fileprivate let key_track = "tracknumber"
fileprivate let key_trackTotal = "tracktotal"
fileprivate let key_totalTracks = "totaltracks"

fileprivate let keys_totalTracks: [String] = [key_trackTotal, key_totalTracks]

fileprivate let key_lyrics = "lyrics"

fileprivate let keys_year: [String] = ["year", "date", "originaldate", "originalyear", "original year", "originalreleasedate", "original_year"]

fileprivate let key_bpm: String = "bpm"

fileprivate let key_duration: String = "length"

class VorbisCommentParser: FFmpegMetadataParser {
    
    private let key_encodingTime = "encodingtime"
    private let key_language = "language"
    private let key_compilation = "compilation"
    
    private let essentialKeys: Set<String> = Set([key_title, key_album, key_originalAlbum, key_genre, key_performer,
    key_disc, key_totalDiscs, key_discTotal, key_track, key_trackTotal, key_totalTracks] + keys_artist)
    
    func mapMetadata(_ metadataMap: FFmpegMappedMetadata) {
        
        let metadata = metadataMap.vorbisMetadata
        
        for key in metadataMap.map.keys {
            
            let lcKey = key.lowercased().trim()
            
            if essentialKeys.contains(lcKey) {
                
                metadata.essentialFields[lcKey] = metadataMap.map.removeValue(forKey: key)
                
            } else if auxiliaryKeys[lcKey] != nil {
                
                metadata.auxiliaryFields[lcKey] = metadataMap.map.removeValue(forKey: key)
            }
        }
    }
    
    func hasEssentialMetadataForTrack(_ metadataMap: FFmpegMappedMetadata) -> Bool {
        !metadataMap.vorbisMetadata.essentialFields.isEmpty
    }
    
    func hasAuxiliaryMetadataForTrack(_ metadataMap: FFmpegMappedMetadata) -> Bool {
        !metadataMap.vorbisMetadata.auxiliaryFields.isEmpty
    }
    
    func getTitle(_ metadataMap: FFmpegMappedMetadata) -> String? {
        metadataMap.vorbisMetadata.essentialFields[key_title]
    }
    
    func getArtist(_ metadataMap: FFmpegMappedMetadata) -> String? {
        keys_artist.firstNonNilMappedValue({metadataMap.vorbisMetadata.essentialFields[$0]})
    }
    
    func getAlbum(_ metadataMap: FFmpegMappedMetadata) -> String? {
        metadataMap.vorbisMetadata.essentialFields[key_album] ?? metadataMap.vorbisMetadata.essentialFields[key_originalAlbum]
    }
    
    func getGenre(_ metadataMap: FFmpegMappedMetadata) -> String? {
        metadataMap.vorbisMetadata.essentialFields[key_genre]
    }
    
    func getDiscNumber(_ metadataMap: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let discNumStr = metadataMap.vorbisMetadata.essentialFields[key_disc] {
            return ParserUtils.parseDiscOrTrackNumberString(discNumStr)
        }
        
        return nil
    }
    
    func getTotalDiscs(_ metadataMap: FFmpegMappedMetadata) -> Int? {
        
        if let totalDiscsStr = keys_totalDiscs.firstNonNilMappedValue({metadataMap.vorbisMetadata.essentialFields[$0]?.trim()}),
            let totalDiscs = Int(totalDiscsStr) {
            
            return totalDiscs
        }
        
        return nil
    }
    
    func getTrackNumber(_ metadataMap: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let trackNumStr = metadataMap.vorbisMetadata.essentialFields[key_track] {
            return ParserUtils.parseDiscOrTrackNumberString(trackNumStr)
        }
        
        return nil
    }
    
    func getTotalTracks(_ metadataMap: FFmpegMappedMetadata) -> Int? {
        
        if let totalTracksStr = keys_totalTracks.firstNonNilMappedValue({metadataMap.vorbisMetadata.essentialFields[$0]?.trim()}),
            let totalTracks = Int(totalTracksStr) {
            
            return totalTracks
        }
        
        return nil
    }
    
    func getYear(_ metadataMap: FFmpegMappedMetadata) -> Int? {
        
        if let yearString = keys_year.firstNonNilMappedValue({metadataMap.vorbisMetadata.auxiliaryFields[$0]}) {
            return ParserUtils.parseYear(yearString)
        }
        
        return nil
    }
    
    func getBPM(_ metadataMap: FFmpegMappedMetadata) -> Int? {
        
        if let bpmString = metadataMap.vorbisMetadata.auxiliaryFields[key_bpm] {
            return ParserUtils.parseBPM(bpmString)
        }
        
        return nil
    }
    
    func getLyrics(_ metadataMap: FFmpegMappedMetadata) -> String? {
        return metadataMap.vorbisMetadata.auxiliaryFields[key_lyrics]
    }
    
    func getDuration(_ metadataMap: FFmpegMappedMetadata) -> Double? {
        
        if let durationStr = metadataMap.vorbisMetadata.essentialFields[key_duration] {
            return ParserUtils.parseDuration(durationStr)
        }
        
        return nil
    }

    private let auxiliaryKeys: [String: String] = {
        
        var map: [String: String] = [:]
        
        map["lyrics"] = "Lyrics"
        
        map["composer"] = "Composer"
        map["conductor"] = "Conductor"
        map["lyricist"] = "Lyricist"
        map["original lyricist"] = "Original Lyricist"
        
        map["year"] = "Year"
        map["date"] = "Date"
        map["originaldate"] = "Original Date"
        map["originalreleasedate"] = "Original Release Date"
        ["originalyear", "original year", "original_year"].forEach {map[$0] = "Original Year"}

        map["bpm"] = "BPM"
        
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
        map["arranger"] = "Arranger"
        map["author"] = "Author"
        map["writer"] = "Writer"
        map["publisher"] = "Publisher"
        map["ensemble"] = "Ensemble"
        map["part"] = "Part"
        map["partnumber"] = "Part Number"
        map["location"] = "Location"
        
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
        
        map["love-dislike rating"] = "Love"
        
        map["media"] = "Media Type"
        
        map["mood"] = "Mood"
        map["style"] = "Style"
        
        map["music_cd_identifier"] = "Music CD Identifier"
        
        map["script"] = "Script"
        
        map["musiciancredits"] = "Musician Credits"
        
        map["url_official_artist_site"] = "Official Artist/Performer Webpage"
        
        map["official_audio_file_url"] = "Official Audio File Webpage"
        
        map["official_audio_source_url"] = "Official Audio Source Webpage"
        
        map["official_radio_url"] = "Official Internet Radio Station Webpage"
        
        map["original filename"] = "Original Filename"
        
        map["period"] = "Period"
        
        map["payment_url"] = "Payment Webpage"
        
        map["pricepaid"] = "Price Paid"
        
        map["produced_notice"] = "Produced Notice"
        
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
        
        for (key, var value) in metadataMap.vorbisMetadata.auxiliaryFields {
            
            // Check special fields
            if key == key_language, let langName = LanguageMap.forCode(value.trim()) {
                value = langName
            } else if key == key_compilation, let bVal = numericStringToBoolean(value) {
                value = bVal ? "Yes" : "No"
            }
            
            value = value.withEncodingAndNullsRemoved()
            
            metadata[key] = MetadataEntry(.vorbis, readableKey(key), value)
        }
        
        return metadata
    }
}
