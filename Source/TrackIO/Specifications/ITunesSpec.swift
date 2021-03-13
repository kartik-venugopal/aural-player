import AVFoundation

///
/// Specification for the iTunes metadata format.
///
class ITunesSpec {
    
    static let longForm_keySpaceID: String = "itlk"
    
    // TODO: Should there be a dot at the end of this prefix ???
    private static let iTunesPrefix: String = "com.apple.itunes"

    // @nam
    static let key_title = AVMetadataKey.iTunesMetadataKeySongName.rawValue
    
    // @ART
    static let key_artist = AVMetadataKey.iTunesMetadataKeyArtist.rawValue
    
    // aART
    static let key_albumArtist = AVMetadataKey.iTunesMetadataKeyAlbumArtist.rawValue
    
    // @ope
    static let key_originalArtist = AVMetadataKey.iTunesMetadataKeyOriginalArtist.rawValue
    static let key_originalArtist2 = "original artist"
    
    // @prf
    static let key_performer = AVMetadataKey.iTunesMetadataKeyPerformer.rawValue
    
    // @alb
    static let key_album = AVMetadataKey.iTunesMetadataKeyAlbum.rawValue
    static let key_originalAlbum = "original album"
    
    // @gen
    static let key_genre = AVMetadataKey.iTunesMetadataKeyUserGenre.rawValue
    
    // geID
    static let key_genreID = AVMetadataKey.iTunesMetadataKeyGenreID.rawValue
    
    // gnre
    static let key_predefGenre = AVMetadataKey.iTunesMetadataKeyPredefinedGenre.rawValue

    // trkn
    static let key_trackNumber = AVMetadataKey.iTunesMetadataKeyTrackNumber.rawValue
    
    // disk
    static let key_discNumber = AVMetadataKey.iTunesMetadataKeyDiscNumber.rawValue
    static let key_discNumber2 = "disc"
    
    // @day
    static let key_releaseDate = AVMetadataKey.iTunesMetadataKeyReleaseDate.rawValue
    
    static let key_releaseYear = "original year"
    
    static let key_lyrics = AVMetadataKey.iTunesMetadataKeyLyrics.rawValue
    static let key_art: String = AVMetadataKey.iTunesMetadataKeyCoverArt.rawValue

    static let key_language = "language"
    static let key_compilation = AVMetadataKey.iTunesMetadataKeyDiscCompilation.rawValue
    static let key_contentRating = AVMetadataKey.iTunesMetadataKeyContentRating.rawValue
    
    static let keys_mediaType: [String] = ["stik", "media", "media_type"]
    static let key_mediaType = "stik"
    static let key_isPodcast = "pcst"
    
    static let key_normalization = "itunnorm"
    static let key_soundCheck = "itunsmpb"
    
    // tmpo
    static let key_bpm = AVMetadataKey.iTunesMetadataKeyBeatsPerMin.rawValue
    
    static let key_duration = "length"
    
    // Mappings of format-specific keys to readable keys
    static let keys: [String: String] = {
        
        var map: [String: String] = [:]
        
        // @lyr
        map[AVMetadataKey.iTunesMetadataKeyLyrics.rawValue] = "Lyrics"
        
        // @wrt
        map[AVMetadataKey.iTunesMetadataKeyComposer.rawValue] = "Composer"
        
        // @con
        map[AVMetadataKey.iTunesMetadataKeyConductor.rawValue] = "Conductor"
        map["conductor"] = "Conductor"
        
        map["lyricist"] = "Lyricist"
        map["original lyricist"] = "Original Lyricist"
        
        // @day
        map[AVMetadataKey.iTunesMetadataKeyReleaseDate.rawValue] = "Original Release Date"
        
        map["original year"] = "Year"
        
        // @cmt
        map[AVMetadataKey.iTunesMetadataKeyUserComment.rawValue] = "Comment"
        
        // cprt
        map[AVMetadataKey.iTunesMetadataKeyCopyright.rawValue] = "Copyright"
        
        // @enc
        map[AVMetadataKey.iTunesMetadataKeyEncodedBy.rawValue] = "Encoded By"
        
        // @st3
        map[AVMetadataKey.iTunesMetadataKeyTrackSubTitle.rawValue] = "Track Sub Title"
        
        // @too
        map[AVMetadataKey.iTunesMetadataKeyEncodingTool.rawValue] = "Encoding Tool"
        
        // akID
        map[AVMetadataKey.iTunesMetadataKeyAccountKind.rawValue] = "Account Type"
        
        // apID
        map[AVMetadataKey.iTunesMetadataKeyAppleID.rawValue] = "Apple ID"
        
        // atID
        map[AVMetadataKey.iTunesMetadataKeyArtistID.rawValue] = "Artist ID"
        
        // cnID
        map[AVMetadataKey.iTunesMetadataKeySongID.rawValue] = "Catalog ID"
        
        // cpil
        map[AVMetadataKey.iTunesMetadataKeyDiscCompilation.rawValue] = "Part of a Compilation?"
        
        // geID
        map[AVMetadataKey.iTunesMetadataKeyGenreID.rawValue] = "Genre ID"
        
        // grup
        map[AVMetadataKey.iTunesMetadataKeyGrouping.rawValue] = "Grouping"
        
        // plID
        map[AVMetadataKey.iTunesMetadataKeyPlaylistID.rawValue] = "Playlist ID"
        
        // rtng
        map[AVMetadataKey.iTunesMetadataKeyContentRating.rawValue] = "Content Rating"
        
        // @ard
        map[AVMetadataKey.iTunesMetadataKeyArtDirector.rawValue] = "Art Director"
        
        // @arg
        map[AVMetadataKey.iTunesMetadataKeyArranger.rawValue] = "Arranger"
        
        // @aut
        map[AVMetadataKey.iTunesMetadataKeyAuthor.rawValue] = "Author"
        
        // @cak
        map[AVMetadataKey.iTunesMetadataKeyAcknowledgement.rawValue] = "Acknowledgement"
        
        // @des
        map[AVMetadataKey.iTunesMetadataKeyDescription.rawValue] = "Description"
        
        // @dir
        map[AVMetadataKey.iTunesMetadataKeyDirector.rawValue] = "Director"
        
        // @equ
        map[AVMetadataKey.iTunesMetadataKeyEQ.rawValue] = "EQ"
        
        // @lnt
        map[AVMetadataKey.iTunesMetadataKeyLinerNotes.rawValue] = "Liner Notes"
        
        // @mak
        map[AVMetadataKey.iTunesMetadataKeyRecordCompany.rawValue] = "Record Company"
        
        // @phg
        map[AVMetadataKey.iTunesMetadataKeyPhonogramRights.rawValue] = "Phonogram Rights"
        
        // @prd
        map[AVMetadataKey.iTunesMetadataKeyProducer.rawValue] = "Producer"
        
        // @pub
        map[AVMetadataKey.iTunesMetadataKeyPublisher.rawValue] = "Publisher"
        
        // @sne
        map[AVMetadataKey.iTunesMetadataKeySoundEngineer.rawValue] = "Sound Engineer"
        
        // @sol
        map[AVMetadataKey.iTunesMetadataKeySoloist.rawValue] = "Soloist"
        
        // @src
        map[AVMetadataKey.iTunesMetadataKeyCredits.rawValue] = "Credits"
        
        // @thx
        map[AVMetadataKey.iTunesMetadataKeyThanks.rawValue] = "Thanks"
        
        // @url
        map[AVMetadataKey.iTunesMetadataKeyOnlineExtras.rawValue] = "Online Extras"
        
        // @xpd
        map[AVMetadataKey.iTunesMetadataKeyExecProducer.rawValue] = "Exec Producer"
        
        // ---------------------------
        
        map["@grp"] = "Grouping"
        
        map["@mvc"] = "Movement Count"
        
        map["@mvi"] = "Movement Number"
        
        map["@mvn"] = "Movement Name"
        
        map["@wrk"] = "Work Name"
        
        map["apid"] = "Owner"
        
        map["asin"] = "ASIN"
        
        map["barcode"] = "Barcode"
        
        map["catalognumber"] = "Catalog Number"
        
        map["category"] = "Category"
        
        map["commercial_info_url"] = "Commercial Information Webpage"
        
        map["commercial_info_url"] = "tMDb Homepage"
        
        map["copyright url"] = "Copyright/Legal Information Webpage"
        
        map["country"] = "Country"
        
        map["cuesheet"] = "Cuesheet"
        
        map["desc"] = "Description"
        
        map["ldes"] = "Long Description"
        
        map["djmixer"] = "DJ Mixer"
        
        map["encoding"] = "Encoder Settings"
        
        map["encodingparams"] = "Encoding Parameters"
        
        map["encoding params"] = "Encoding Parameters"
        
        map["encodingtime"] = "Encoding Time"
        
        map["engineer"] = "Engineer"
        
        map["filetype"] = "File Type"
        
        map["instrumental"] = "Instrumental"
        
        map["involvedpeople"] = "Involved People"
        
        map["isrc"] = "ISRC"
        
        map["itunes pid"] = "iTunes PID"
        
        map["itunes_cddb_1"] = "CDDB 1"
        
        map["itunes_cddb_ids"] = "CDDB IDs"
        
        map["itunes_cddb_tracknumber"] = "CDDB Track Number"
        
        map["itunes_start_time"] = "Start Time"
        
        map["itunes_stop_time"] = "Stop Time"
        
        map["itunes_volume_adjustment"] = "Volume Adjustment"
        
        map["itunextc"] = "Classification"
        
        map["itunpgap"] = "Playlist Delay"
        
        map["key"] = "Initial Key"
        
        map["label"] = "Label"
        
        map["label_url"] = "Publisher's Official Webpage"
        
        map["language"] = "Language"
        
        map["length"] = "Duration (ms)"
        
        map["love-dislike rating"] = "Love"
        
        map["media"] = "Media Type"
        
        map["media_type"] = "Media Type"
        
        map["mixer"] = "Mixer"
        
        map["mood"] = "Mood"
        
        map["music_cd_identifier"] = "Music CD Identifier"
        
        map["musiciancredits"] = "Musician Credits"
        
        map["official_audio_file_url"] = "Official Audio File Webpage"
        
        map["official_audio_source_url"] = "Official Audio Source Webpage"
        
        map["official_radio_url"] = "Official Internet Radio Station Webpage"
        
        map["original filename"] = "Original Filename"
        
        map["ownr"] = "Owner"
        
        map["payment_url"] = "Payment Webpage"
        
        map["pcst"] = "Is Podcast?"
        
        map["playcount"] = "Play Count"
        
        map["pricepaid"] = "Price Paid"
        
        map["produced_notice"] = "Produced Notice"
        
        map["producer"] = "Producer"
        
        map["publisher"] = "Publisher"
        
        map["keyw"] = "Keywords"
        
        map["catg"] = "Category"
        
        map["purd"] = "Purchase Date"
        
        map["purl"] = "Podcast URL"
        
        map["radio_station"] = "Radio Station"
        
        map["rate"] = "Rating"
        
        map["rating"] = "Rating"
        
        map["releasetime"] = "Release Time"
        
        map["rememberplaybackposition"] = "Remember Position"
        
        map["remixer"] = "Remixer"
        
        map["replaygain_album_gain"] = "ReplayGain Album Gain"
        
        map["replaygain_album_peak"] = "ReplayGain Album Peak"
        
        map["replaygain_track_gain"] = "ReplayGain Track Gain"
        
        map["replaygain_track_peak"] = "ReplayGain Track Peak"
        
        map["script"] = "Script"
        
        map["sdes"] = "Show Description"
        
        map["set subtitle"] = "Set Subtitle"
        
        map["sfid"] = "Apple Storefront ID"
        
        map["shwm"] = "Show Work Name"
        
        map["skipwhenshuffling"] = "Skip When Shuffling"
        
        map["soaa"] = "Sort Album Artist"
        
        map["soal"] = "Sort Album"
        
        map["soar"] = "Sort Artist"
        
        map["soco"] = "Sort Composer"
        
        map["sonm"] = "Sort Title"
        
        map["sosn"] = "Sort Show Name"
        
        map["source"] = "Source"
        
        map["station_owner"] = "Station Owner"
        
        map["stik"] = "Media Type"
        
        map["taggingtime"] = "Tagging Time"
        
        map["termsofuse"] = "Terms of Use"
        
        map["tool"] = "Tool"
        
        map["track number text"] = "Track Position"
        
        map["ufid"] = "Unique File Identifier"
        
        map["upc"] = "UPC"
        
        map["url_official_artist_site"] = "Official Artist Wesbite"
        
        map["xid"] = "Seller"
        
        return map
    }()
    
    static func readableKey(_ key: String) -> String {
        
        if let rKey = keys[key] {
            return rKey
        }
        
        if let rKey = keys[key.lowercased()] {
            return rKey
        }
        
        return readableKey_longForm(key)
    }
    
    private static func readableKey_longForm(_ key: String) -> String {
        
        let lcKey = key.lowercased()
        if lcKey.contains(iTunesPrefix) {
            
            if let trimmedKey = removePrefix(lcKey) {
                
                let finalKey = trimmedKey.trim().trimmingCharacters(in: CharacterSet(charactersIn: ":;|-."))
                
                if let rKey = keys[finalKey] {
                    
                    return rKey
                    
                } else {
                    
                    // Return trimmed key, properly capitalized
                    if let range = lcKey.range(of: finalKey) {
                        return String(key[range.lowerBound..<range.upperBound]).capitalizingFirstLetter()
                    }
                }
            }
        }
        
        return key.capitalizingFirstLetter()
    }
    
    private static func removePrefix(_ key: String) -> String? {
        
        if let lastToken = key.replacingOccurrences(of: iTunesPrefix, with: "|").split(separator: "|").last {
            return String(lastToken)
        }
        
        return nil
    }
    
    static let mediaTypes: [Int: String] = [
        
        0: "Movie",
        1: "Music",
        2: "Audiobook",
        5: "Whacked Bookmark",
        6: "Music Video",
        9: "Movie",
        10: "TV Show",
        11: "Booklet",
        14: "Ringtone",
        21: "Podcast",
        23: "iTunes U"
    ]
    
    static let contentRating: [Int: String] = [
        
        0: "None",
        1: "Explicit",
        2: "Clean",
        4: "Explicit"
    ]
}
