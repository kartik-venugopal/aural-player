import AVFoundation

class ITunesSpec {
    
    static let keySpace: String = AVMetadataKeySpace.iTunes.rawValue
    static let longForm_keySpaceID: String = "itlk"
    private static let iTunesPrefix: String = "com.apple.itunes"
    
    static let key_title = String(format: "%@/%@", keySpace, AVMetadataKey.iTunesMetadataKeySongName.rawValue)
    
    static let key_artist = String(format: "%@/%@", keySpace, AVMetadataKey.iTunesMetadataKeyArtist.rawValue)
    
    static let key_album = String(format: "%@/%@", keySpace, AVMetadataKey.iTunesMetadataKeyAlbum.rawValue)
    
    static let key_genre = String(format: "%@/%@", keySpace, AVMetadataKey.iTunesMetadataKeyUserGenre.rawValue)
    static let key_genreID = String(format: "%@/%@", keySpace, AVMetadataKey.iTunesMetadataKeyGenreID.rawValue)
    static let key_predefGenre = String(format: "%@/%@", keySpace, AVMetadataKey.iTunesMetadataKeyPredefinedGenre.rawValue)
    
    static let key_discNumber = String(format: "%@/%@", keySpace, AVMetadataKey.iTunesMetadataKeyDiscNumber.rawValue)
    static let key_discNumber2 = String(format: "%@/%@", keySpace, "disc")
    static let key_trackNumber = String(format: "%@/%@", keySpace, AVMetadataKey.iTunesMetadataKeyTrackNumber.rawValue)
    
    static let key_lyrics = String(format: "%@/%@", keySpace, AVMetadataKey.iTunesMetadataKeyLyrics.rawValue)
    static let key_art: String = String(format: "%@/%@", keySpace, AVMetadataKey.iTunesMetadataKeyCoverArt.rawValue)
    static let id_art: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.iTunesMetadataKeyCoverArt.rawValue, keySpace: AVMetadataKeySpace.iTunes)!

    static let key_language = "language"
    static let key_compilation = AVMetadataKey.iTunesMetadataKeyDiscCompilation.rawValue
    static let key_contentRating = AVMetadataKey.iTunesMetadataKeyContentRating.rawValue
    
    static let key_mediaType = "stik"
    static let key_isPodcast = "pcst"
    
    static let key_normalization = "itunnorm"
    static let key_soundCheck = "itunsmpb"
    
    static let key_duration = String(format: "%@/%@", keySpace, "length")
    
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
    
    // Mappings of format-specific keys to readable keys
    static let keys: [String: String] = {
        
        var map: [String: String] = [String: String]()
        
        // @alb
        map[AVMetadataKey.iTunesMetadataKeyAlbum.rawValue] = "Album"
        
        // @ART
        map[AVMetadataKey.iTunesMetadataKeyArtist.rawValue] = "Artist"
        
        // @cmt
        map[AVMetadataKey.iTunesMetadataKeyUserComment.rawValue] = "Comment"
        
        // cprt
        map[AVMetadataKey.iTunesMetadataKeyCopyright.rawValue] = "Copyright"
        
        // @day
        map[AVMetadataKey.iTunesMetadataKeyReleaseDate.rawValue] = "Release Date"
        
        // @enc
        map[AVMetadataKey.iTunesMetadataKeyEncodedBy.rawValue] = "Encoded By"
        
        // gnre
        map[AVMetadataKey.iTunesMetadataKeyPredefinedGenre.rawValue] = "Predefined Genre"
        
        // @gen
        map[AVMetadataKey.iTunesMetadataKeyUserGenre.rawValue] = "User Genre"
        
        // @st3
        map[AVMetadataKey.iTunesMetadataKeyTrackSubTitle.rawValue] = "Track Sub Title"
        
        // @too
        map[AVMetadataKey.iTunesMetadataKeyEncodingTool.rawValue] = "Encoding Tool"
        
        // @wrt
        map[AVMetadataKey.iTunesMetadataKeyComposer.rawValue] = "Composer"
        
        // aART
        map[AVMetadataKey.iTunesMetadataKeyAlbumArtist.rawValue] = "Album Artist"
        
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
        
        // disk
        map[AVMetadataKey.iTunesMetadataKeyDiscNumber.rawValue] = "Disc Number"
        
        // geID
        map[AVMetadataKey.iTunesMetadataKeyGenreID.rawValue] = "Genre ID"
        
        // grup
        map[AVMetadataKey.iTunesMetadataKeyGrouping.rawValue] = "Grouping"
        
        // plID
        map[AVMetadataKey.iTunesMetadataKeyPlaylistID.rawValue] = "Playlist ID"
        
        // rtng
        map[AVMetadataKey.iTunesMetadataKeyContentRating.rawValue] = "Content Rating"
        
        // tmpo
        map[AVMetadataKey.iTunesMetadataKeyBeatsPerMin.rawValue] = "Beats Per Min"
        
        // trkn
        map[AVMetadataKey.iTunesMetadataKeyTrackNumber.rawValue] = "Track Number"
        
        // @ard
        map[AVMetadataKey.iTunesMetadataKeyArtDirector.rawValue] = "Art Director"
        
        // @arg
        map[AVMetadataKey.iTunesMetadataKeyArranger.rawValue] = "Arranger"
        
        // @aut
        map[AVMetadataKey.iTunesMetadataKeyAuthor.rawValue] = "Author"
        
        // @lyr
        map[AVMetadataKey.iTunesMetadataKeyLyrics.rawValue] = "Lyrics"
        
        // @cak
        map[AVMetadataKey.iTunesMetadataKeyAcknowledgement.rawValue] = "Acknowledgement"
        
        // @con
        map[AVMetadataKey.iTunesMetadataKeyConductor.rawValue] = "Conductor"
        
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
        
        // @ope
        map[AVMetadataKey.iTunesMetadataKeyOriginalArtist.rawValue] = "Original Artist"
        
        // @phg
        map[AVMetadataKey.iTunesMetadataKeyPhonogramRights.rawValue] = "Phonogram Rights"
        
        // @prd
        map[AVMetadataKey.iTunesMetadataKeyProducer.rawValue] = "Producer"
        
        // @prf
        map[AVMetadataKey.iTunesMetadataKeyPerformer.rawValue] = "Performer"
        
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
        
        map["accurateripdiscid"] = "AccurateRip Disc ID"
        
        map["accurateripresult"] = "AccurateRip Result"
        
        map["acousticbrainz data"] = "AcousticBrainz Data"
        
        map["acoustid data"] = "Acoustid Data"
        
        map["acoustid fingerprint fault"] = "Acoustid Fingerprint Fault"
        
        map["acoustid fingerprint"] = "Acoustid Fingerprint"
        
        map["acoustid id"] = "Acoustid Id"
        
        map["acoustid status"] = "Acoustid Status"
        
        map["apid"] = "Owner"
        
        map["apiseeds artist"] = "APISEEDS Artist"
        
        map["apiseeds probability"] = "APISEEDS Probability"
        
        map["apiseeds status"] = "APISEEDS Status"
        
        map["apiseeds text"] = "APISEEDS Text"
        
        map["apiseeds title"] = "APISEEDS Title"
        
        map["asin"] = "ASIN"
        
        map["autosearch_artwork_url"] = "Autosearch Artwork URL"
        
        map["barcode"] = "Barcode"
        
        map["beatport import time"] = "Beatport Import Time"
        
        map["beatport release id"] = "Beatport Release Id"
        
        map["beatport track id"] = "Beatport Track Id"
        
        map["beatport_album_url"] = "Beatport Album URL"
        
        map["beatport_artist_url"] = "Beatport Artist URLs"
        
        map["beatport_label_url"] = "Beatport Label URL"
        
        map["beatport_track_url"] = "Beatport Track URL"
        
        map["catalognumber"] = "Catalog Number"
        
        map["category"] = "Category"
        
        map["commercial_info_url"] = "Commercial Information Webpage"
        
        map["commercial_info_url"] = "tMDb Homepage"
        
        map["conductor"] = "Conductor"
        
        map["copyright url"] = "Copyright/Legal Information Webpage"
        
        map["country"] = "Country"
        
        map["cuesheet"] = "Cuesheet"
        
        map["desc"] = "Description"
        
        map["ldes"] = "Long Description"
        
        map["discogs album release country"] = "Discogs Release Country"
        
        map["discogs release notes"] = "Discogs Release Notes"
        
        map["discogs release ordinal position"] = "Discogs Release Ordinal Position"
        
        map["discogs_albumartist_url"] = "Discogs Album Artist URLs"
        
        map["discogs_anv_list"] = "Discogs Artist Name Variations"
        
        map["discogs_artist_list"] = "Discogs Artist List"
        
        map["discogs_artist_url"] = "Discogs Artist URLs"
        
        map["discogs_artwork_url"] = "Discogs Artwork URL"
        
        map["discogs_catalog_number"] = "Discogs Catalog Number"
        
        map["discogs_exception_mask"] = "Discogs Exception Mask"
        
        map["discogs_import_settings"] = "Discogs Import Settings"
        
        map["discogs_import_time"] = "Discogs Import Time"
        
        map["discogs_label_url"] = "Discogs Label URLs"
        
        map["discogs_master_id"] = "Discogs Master Id"
        
        map["discogs_master_url"] = "Discogs Master URL"
        
        map["discogs_release_id"] = "Discogs Release Id"
        
        map["discogs_release_url"] = "Discogs Release URL"
        
        map["djmixer"] = "DJ Mixer"
        
        map["encoding"] = "Encoder Settings"
        
        map["encodingparams"] = "Encoding Parameters"
        
        map["encodingtime"] = "Encoding Time"
        
        map["engineer"] = "Engineer"
        
        map["filetype"] = "File Type"
        
        map["imdb id"] = "IMDB ID"
        
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
        
        // TODO: Use this field to compute duration
        map["length"] = "Duration (ms)"
        
        map["love-dislike rating"] = "Love"
        
        map["lyricist"] = "Lyricist"
        
        map["lyricwiki takedown status"] = "LyricWiki Takedown Status id"
        
        map["lyricwiki url"] = "LyricWiki URL"
        
        map["media"] = "Media Type"
        
        map["mixer"] = "Mixer"
        
        map["mood"] = "Mood"
        
        map["music_cd_identifier"] = "Music CD Identifier"
        
        map["musicbrainz album artist id"] = "MusicBrainz Album Artist Id"
        
        map["musicbrainz album id"] = "MusicBrainz Release Id"
        
        map["musicbrainz album release country"] = "MusicBrainz Release Country"
        
        map["musicbrainz album status"] = "MusicBrainz Release Status"
        
        map["musicbrainz album type"] = "MusicBrainz Release Type"
        
        map["musicbrainz artist id"] = "MusicBrainz Artist Id"
        
        map["musicbrainz disc id"] = "MusicBrainz Disc Id"
        
        map["musicbrainz original album id"] = "MusicBrainz Original Album Id"
        
        map["musicbrainz release group id"] = "MusicBrainz Release Group Id"
        
        map["musicbrainz release track id"] = "MusicBrainz Release Track Id"
        
        map["musicbrainz track id"] = "MusicBrainz Recording Id"
        
        map["musicbrainz trm id"] = "MusicBrainz TRM Id"
        
        map["musicbrainz work id"] = "MusicBrainz Work Id"
        
        map["musicbrainz_album_url"] = "MusicBrainz Release URL"
        
        map["musicbrainz_albumartist_url"] = "MusicBrainz Album Artist URLs"
        
        map["musicbrainz_artist_url"] = "MusicBrainz Artist URLs"
        
        map["musicbrainz_artwork_url_type"] = "MusicBrainz Artwork URLs"
        
        map["musicbrainz_catalog_number"] = "MusicBrainz Catalog Number"
        
        map["musicbrainz_coverart_url"] = "MusicBrainz Cover Art URL"
        
        map["musicbrainz_exception_mask"] = "MusicBrainz Exception Mask"
        
        map["musicbrainz_import_settings"] = "MusicBrainz Import Settings"
        
        map["musicbrainz_import_time"] = "MusicBrainz Import Time"
        
        map["musicbrainz_label_url"] = "MusicBrainz label URLs"
        
        map["musicbrainz_original_album_url"] = "MusicBrainz Original Album URL"
        
        map["musicbrainz_relationship_url_name}"] = "MusicBrainz Relationship URLs"
        
        map["musicbrainz_release_group_url"] = "MusicBrainz Release Group URL"
        
        map["musicbrainzalbumartistId"] = "MusicBrainz Album Artist ID"
        
        map["musicbrainzalbumid"] = "MusicBrainz Album ID"
        
        map["musicbrainzalbumreleasecountry"] = "MusicBrainz Album Release Country"
        
        map["musicbrainzalbumstatus"] = "MusicBrainz Album Status"
        
        map["musicbrainzalbumtype"] = "MusicBrainz Album Type"
        
        map["musicbrainzartistId"] = "MusicBrainz Artist ID"
        
        map["musicbrainztrackid"] = "MusicBrainz Track ID"
        
        map["musiciancredits"] = "Musician Credits"
        
        map["musicippuid"] = "MusicIP PUID"
        
        map["official_audio_file_url"] = "Official Audio File Webpage"
        
        map["official_audio_source_url"] = "Official Audio Source Webpage"
        
        map["official_radio_url"] = "Official Internet Radio Station Webpage"
        
        map["original album"] = "Original Album"
        
        map["original artist"] = "Original Artist"
        
        map["original filename"] = "Original Filename"
        
        map["original lyricist"] = "Original Lyricist"
        
        map["original year"] = "Original Release Time"
        
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
        
        map["script"] = "MusicBrainz Script"
        
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
        
        map["tmdb adult content"] = "tMDb Adult Content"
        
        map["tmdb budget"] = "tMDb Budget"
        
        map["tmdb collection name"] = "tMDb Collection Name"
        
        map["tmdb movie id"] = "tMDb Movie ID"
        
        map["tmdb name url"] = "tMDb Artwork URLs"
        
        map["tmdb original language (iso)"] = "tMDb Original Language (ISO)"
        
        map["tmdb original language"] = "tMDb Original Language (ISO)"
        
        map["tmdb production countries (iso)"] = "tMDb Production Countries (ISO)"
        
        map["tmdb production countries"] = "tMDb Production Countries"
        
        map["tmdb revenue"] = "tMDb Revenue"
        
        map["tmdb spoken languages (iso)"] = "tMDb Spoken Languages (ISO)"
        
        map["tmdb spoken languages"] = "tMDb Spoken Languages"
        
        map["tmdb tv id"] = "tMDb TV ID"
        
        map["tool"] = "Tool"
        
        map["track number text"] = "Track Position"
        
        map["ufid"] = "Beatport Track Id"
        
        map["ufid"] = "Unique File Identifier"
        
        map["upc"] = "UPC"
        
        map["url_official_artist_site"] = "Official Artist/Performer Webpage"
        
        map["xid"] = "Seller"
        
        map["yate album id"] = "Yate Album ID"
        
        map["yate track id"] = "Yate Track ID"
        
        /*
         
         */
        
        return map
    }()
    
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
