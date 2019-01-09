import Cocoa
import AVFoundation

fileprivate let keySpace: String = AVMetadataKeySpace.iTunes.rawValue

fileprivate let key_title = String(format: "%@/%@", keySpace, AVMetadataKey.iTunesMetadataKeySongName.rawValue)
fileprivate let commonKey_title = String(format: "%@/%@", keySpace, AVMetadataKey.commonKeyTitle.rawValue)

fileprivate let key_artist = String(format: "%@/%@", keySpace, AVMetadataKey.iTunesMetadataKeyArtist.rawValue)
fileprivate let commonKey_artist = String(format: "%@/%@", keySpace, AVMetadataKey.commonKeyArtist.rawValue)

fileprivate let key_album = String(format: "%@/%@", keySpace, AVMetadataKey.iTunesMetadataKeyAlbum.rawValue)
fileprivate let commonKey_album = String(format: "%@/%@", keySpace, AVMetadataKey.commonKeyAlbumName.rawValue)

fileprivate let key_genre = String(format: "%@/%@", keySpace, AVMetadataKey.iTunesMetadataKeyUserGenre.rawValue)
fileprivate let commonKey_genre = String(format: "%@/%@", keySpace, AVMetadataKey.commonKeyType.rawValue)
fileprivate let key_predefGenre = String(format: "%@/%@", keySpace, AVMetadataKey.iTunesMetadataKeyPredefinedGenre.rawValue)

fileprivate let key_discNumber = String(format: "%@/%@", keySpace, AVMetadataKey.iTunesMetadataKeyDiscNumber.rawValue)
fileprivate let key_trackNumber = String(format: "%@/%@", keySpace, AVMetadataKey.iTunesMetadataKeyTrackNumber.rawValue)

fileprivate let key_lyrics = String(format: "%@/%@", keySpace, AVMetadataKey.iTunesMetadataKeyLyrics.rawValue)
fileprivate let key_art: String = String(format: "%@/%@", keySpace, AVMetadataKey.iTunesMetadataKeyCoverArt.rawValue)
fileprivate let commonKey_art: String = String(format: "%@/%@", keySpace, AVMetadataKey.commonKeyArtwork.rawValue)
fileprivate let id_art: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.iTunesMetadataKeyCoverArt.rawValue, keySpace: AVMetadataKeySpace.iTunes)!

fileprivate let key_language = "language"
fileprivate let key_compilation = AVMetadataKey.iTunesMetadataKeyDiscCompilation.rawValue

/*
 Specification for the iTunes metadata format.
 */
class ITunesParser: AVAssetParser {
    
    private let longForm_keySpaceID: String = "itlk"
    private let iTunesPrefix: String = "com.apple.itunes"
    
    private let essentialFieldKeys: [String] = [key_title, commonKey_title, key_artist, commonKey_artist, key_album, commonKey_album, key_genre, key_predefGenre, commonKey_genre, key_discNumber, key_trackNumber, key_lyrics, key_art, commonKey_art]
    
    private func readableKey(_ key: String) -> String {
        
        if let rKey = map[key] {
            return rKey
        }
        
        return readableKey_longForm(key)
    }
    
    private func readableKey_longForm(_ key: String) -> String {
        
        let lcKey = key.lowercased()
        if lcKey.contains(iTunesPrefix) {
            
            if let trimmedKey = removeITunesPrefix(lcKey) {
                
                let finalKey = trimmedKey.trim().trimmingCharacters(in: CharacterSet(charactersIn: ":;|-."))
                
                if let rKey = map_longForm[finalKey] {
                    
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
    
    private func removeITunesPrefix(_ key: String) -> String? {
        
        let lastToken = key.replacingOccurrences(of: iTunesPrefix, with: "|").split(separator: "|").last
        return lastToken == nil ? nil : String(lastToken!)
    }
    
    func mapTrack(_ track: Track, _ mapForTrack: AVAssetMetadata) {
        
        let items = track.audioAsset!.metadata
        
        for item in items {
            
            if item.keySpace == AVMetadataKeySpace.iTunes, let key = item.keyAsString {
                
                let mapKey = String(format: "%@/%@", keySpace, key)
                
                if essentialFieldKeys.contains(mapKey) {
                    mapForTrack.map[mapKey] = item
                } else {
                    // Generic field
                    mapForTrack.genericMap[mapKey] = item
                }
                
            } else if item.keySpace?.rawValue == longForm_keySpaceID, let key = item.keyAsString { // Long form
                
                // Generic field
                mapForTrack.genericMap[key] = item
            }
            
//            if let attrs = item.extraAttributes, attrs.count > 0 {
//
//                for (a,v) in attrs {
//
//                    let s = String(describing: v)
//
//                    if !StringUtils.isStringEmpty(s) {
//                        print("Xtra for", item.keyAsString, a.rawValue, s)
//                    }
//                }
//            }
        }
    }
    
    func getDuration(_ mapForTrack: AVAssetMetadata) -> Double? {
        return nil
    }
    
    func getTitle(_ mapForTrack: AVAssetMetadata) -> String? {
        
        for key in [commonKey_title, key_title] {
            
            if let titleItem = mapForTrack.map[key] {
                return titleItem.stringValue
            }
        }
        
        return nil
    }
    
    func getArtist(_ mapForTrack: AVAssetMetadata) -> String? {
        
        for key in [commonKey_artist, key_artist] {
            
            if let artistItem = mapForTrack.map[key] {
                return artistItem.stringValue
            }
        }
        
        return nil
    }
    
    func getAlbum(_ mapForTrack: AVAssetMetadata) -> String? {
        
        for key in [commonKey_album, key_album] {
            
            if let albumItem = mapForTrack.map[key] {
                return albumItem.stringValue
            }
        }
        
        return nil
    }
    
    func getGenre(_ mapForTrack: AVAssetMetadata) -> String? {
        
        for key in [commonKey_genre, key_genre, key_predefGenre] {
            
            if let genreItem = mapForTrack.map[key] {
                
                if let str = genreItem.stringValue {
                    
                    return parseGenreNumericString(str)
                    
                } else if let data = genreItem.dataValue {
                    
                    // Parse as hex string
                    let code = Int(data.hexEncodedString(), radix: 16)!
                    return ID3Parser.genreForCode(code - 1)
                }
            }
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
                return ID3Parser.genreForCode(genreCode - 1) ?? string
            }
        }
        
        return string
    }
    
    func getDiscNumber(_ mapForTrack: AVAssetMetadata) -> (number: Int?, total: Int?)? {
        
        if let item = mapForTrack.map[key_discNumber] {
            return parseDiscOrTrackNumber(item)
        }
        
        return nil
    }
    
    func getTrackNumber(_ mapForTrack: AVAssetMetadata) -> (number: Int?, total: Int?)? {
        
        if let item = mapForTrack.map[key_trackNumber] {
            return parseDiscOrTrackNumber(item)
        }
        
        return nil
    }
    
    private func parseDiscOrTrackNumber(_ item: AVMetadataItem) -> (number: Int?, total: Int?)? {
        
        if let number = item.numberValue {
            return (number.intValue, nil)
        }
        
        if let stringValue = item.stringValue?.trim() {
            
            // Parse string (e.g. "2 / 13")
            
            if let num = Int(stringValue) {
                return (num, nil)
            }
            
            let tokens = stringValue.split(separator: "/")
            
            if !tokens.isEmpty {
                
                let s1 = tokens[0].trim()
                var s2: String?
                
                let n1: Int? = Int(s1)
                var n2: Int?
                
                if tokens.count > 1 {
                    s2 = tokens[1].trim()
                    n2 = Int(s2!)
                }
                
                return (n1, n2)
            }
            
        } else if let dataValue = item.dataValue {
            
            // Parse data
            let hexString = dataValue.hexEncodedString()
            
            if hexString.count >= 8 {
                
                let s1: String = hexString.substring(range: 4..<8)
                let n1: Int? = Int(s1, radix: 16)
                
                var s2: String?
                var n2: Int?
                
                if hexString.count >= 12 {
                    s2 = hexString.substring(range: 8..<12)
                    n2 = Int(s2!, radix: 16)
                }
                
                return (n1, n2)
                
            } else if hexString.count >= 4 {
                
                // Only one number
                
                let s1: String = String(hexString.prefix(4))
                let n1: Int? = Int(s1, radix: 16)
                return (n1, nil)
            }
        }
        
        return nil
    }
    
    func getArt(_ mapForTrack: AVAssetMetadata) -> NSImage? {
        
        for key in [commonKey_art, key_art] {
            
            if let item = mapForTrack.map[key], let imgData = item.dataValue {
                return NSImage(data: imgData)
            }
        }
        
        return nil
    }
    
    func getArt(_ asset: AVURLAsset) -> NSImage? {
        
        if let item = AVMetadataItem.metadataItems(from: asset.commonMetadata, filteredByIdentifier: id_art).first, let imgData = item.dataValue {
            return NSImage(data: imgData)
        }
        
        return nil
    }
    
    func getLyrics(_ mapForTrack: AVAssetMetadata) -> String? {
        
        if let lyricsItem = mapForTrack.map[key_lyrics] {
            return lyricsItem.stringValue
        }
        
        return nil
    }
    
    func getGenericMetadata(_ mapForTrack: AVAssetMetadata) -> [String: MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        for item in mapForTrack.genericMap.values.filter({item -> Bool in item.keySpace == .iTunes || item.keySpace?.rawValue == longForm_keySpaceID}) {
            
            if let key = item.keyAsString, var value = item.valueAsString {
                
                if key == key_language, let langName = LanguageCodes.languageNameForCode(value.trim()) {
                    value = langName
                } else if key == key_compilation, let numVal = item.numberValue {
                    // Number to boolean
                    value = numVal == 0 ? "No" : "Yes"
                }
                
                let rKey = readableKey(StringUtils.cleanUpString(key))
                metadata[key] = MetadataEntry(.iTunes, rKey, StringUtils.cleanUpString(value))
            }
        }
        
        return metadata
    }
    
    // ------------------------------------------ KEY MAPPINGS -------------------------------------------------
    
    // Mappings of format-specific keys to readable keys
    private var map: [String: String] = {
        
        var map: [String: String] = [String: String]()
        
        // @alb
        map[AVMetadataKey.iTunesMetadataKeyAlbum.rawValue] = "Album"
        
        // @ART
        map[AVMetadataKey.iTunesMetadataKeyArtist.rawValue] = "Artist"
        
        // @cmt
        map[AVMetadataKey.iTunesMetadataKeyUserComment.rawValue] = "User Comment"
        
        // covr
        map[AVMetadataKey.iTunesMetadataKeyCoverArt.rawValue] = "Cover Art"
        
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
        
        // @nam
        map[AVMetadataKey.iTunesMetadataKeySongName.rawValue] = "Song Name"
        
        // @st3
        map[AVMetadataKey.iTunesMetadataKeyTrackSubTitle.rawValue] = "Track Sub Title"
        
        // @too
        map[AVMetadataKey.iTunesMetadataKeyEncodingTool.rawValue] = "Encoding Tool"
        
        // @wrt
        map[AVMetadataKey.iTunesMetadataKeyComposer.rawValue] = "Composer"
        
        // aART
        map[AVMetadataKey.iTunesMetadataKeyAlbumArtist.rawValue] = "Album Artist"
        
        // akID
        map[AVMetadataKey.iTunesMetadataKeyAccountKind.rawValue] = "Account Kind"
        
        // apID
        map[AVMetadataKey.iTunesMetadataKeyAppleID.rawValue] = "Apple ID"
        
        // atID
        map[AVMetadataKey.iTunesMetadataKeyArtistID.rawValue] = "Artist ID"
        
        // cnID
        map[AVMetadataKey.iTunesMetadataKeySongID.rawValue] = "Song ID"
        
        // cpil
        map[AVMetadataKey.iTunesMetadataKeyDiscCompilation.rawValue] = "Is Compilation?"
        
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
        
        return map
    }()
    
    private var map_longForm: [String: String] = {
        
        var map: [String: String] = [:]
        
        //        map["itunsmpb"] = "Gapless Playback"
        //        map["itunnorm"] = "Sound Check"
        
        // TODO: Find a better way to exclude these 2 keys
        map["itunsmpb"] = ""
        map["itunnorm"] = ""
        map["itunpgap"] = "Playlist Delay"
        
        map["encodingparams"] = "Encoding Parameters"
        
        map["itunes_cddb_ids"] = "CDDB IDs"
        map["itunes_cddb_1"] = "CDDB 1"
        map["itunes_cddb_tracknumber"] = "CDDB Track Number"
        
        map["accurateripdiscid"] = "AccurateRip Disc ID"
        map["accurateripresult"] = "AccurateRip Result"
        
        map["musicippuid"] = "MusicIP PUID"
        map["musicbrainzartistId"] = "MusicBrainz Artist ID"
        map["musicbrainzalbumartistId"] = "MusicBrainz Album Artist ID"
        map["musicbrainzalbumid"] = "MusicBrainz Album ID"
        map["musicbrainztrackid"] = "MusicBrainz Track ID"
        map["musicbrainzalbumreleasecountry"] = "MusicBrainz Album Release Country"
        map["musicbrainzalbumtype"] = "MusicBrainz Album Type"
        map["musicbrainzalbumstatus"] = "MusicBrainz Album Status"
        
        map["source"] = "Source"
        map["asin"] = "ASIN"
        map["tool"] = "Tool"
        map["upc"] = "UPC"
        
        map["acousticbrainz data"] = "AcousticBrainz Data"
        
        map["acoustid data"] = "Acoustid Data"
        
        map["acoustid fingerprint"] = "Acoustid Fingerprint"
        
        map["acoustid fingerprint fault"] = "Acoustid Fingerprint Fault"
        
        map["acoustid id"] = "Acoustid Id"
        
        map["acoustid status"] = "Acoustid Status"
        
        map["apiseeds artist"] = "APISEEDS Artist"
        
        map["apiseeds probability"] = "APISEEDS Probability"
        
        map["apiseeds status"] = "APISEEDS Status"
        
        map["apiseeds text"] = "APISEEDS Text"
        
        map["apiseeds title"] = "APISEEDS Title"
        
        map["autosearch_artwork_url"] = "Autosearch Artwork URL"
        
        map["barcode"] = "Barcode"
        
        map["beatport_album_url"] = "Beatport Album URL"
        
        map["beatport_artist_url"] = "Beatport Artist URLs"
        
        map["beatport import time"] = "Beatport Import Time"
        
        map["beatport_label_url"] = "Beatport Label URL"
        
        map["beatport release id"] = "Beatport Release Id"
        
        map["beatport track id"] = "Beatport Track Id"
        
        map["ufid"] = "Beatport Track Id"
        
        map["beatport_track_url"] = "Beatport Track URL"
        
        map["catalognumber"] = "Catalog Number"
        
        map["category"] = "Category"
        
        map["itunextc"] = "Classification"
        
        map["commercial_info_url"] = "Commercial Information Webpage"
        
        map["conductor"] = "Conductor"
        
        map["copyright url"] = "Copyright/Legal Information Webpage"
        
        map["country"] = "Country"
        
        map["cuesheet"] = "Cuesheet"
        
        map["discogs_albumartist_url"] = "Discogs Album Artist URLs"
        
        map["discogs_artist_list"] = "Discogs Artist List"
        
        map["discogs_anv_list"] = "Discogs Artist Name Variations"
        
        map["discogs_artist_url"] = "Discogs Artist URLs"
        
        map["discogs_artwork_url"] = "Discogs Artwork URL"
        
        map["discogs_catalog_number"] = "Discogs Catalog Number"
        
        map["discogs_import_settings"] = "Discogs Import Settings"
        
        map["discogs_exception_mask"] = "Discogs Exception Mask"
        
        map["discogs_import_time"] = "Discogs Import Time"
        
        map["discogs_label_url"] = "Discogs Label URLs"
        
        map["discogs_master_id"] = "Discogs Master Id"
        
        map["discogs_master_url"] = "Discogs Master URL"
        
        map["discogs album release country"] = "Discogs Release Country"
        
        map["discogs_release_id"] = "Discogs Release Id"
        
        map["discogs release notes"] = "Discogs Release Notes"
        
        map["discogs release ordinal position"] = "Discogs Release Ordinal Position"
        
        map["discogs_release_url"] = "Discogs Release URL"
        
        map["encoding"] = "Encoder Settings"
        
        map["encodingtime"] = "Encoding Time"
        
        map["filetype"] = "File Type"
        
        map["imdb id"] = "IMDB ID"
        
        map["key"] = "Initial Key"
        
        map["involvedpeople"] = "Involved People"
        
        map["djmixer"] = "DJ Mixer"
        
        map["engineer"] = "Engineer"
        
        map["mixer"] = "Mixer"
        
        map["producer"] = "Producer"
        
        map["instrumental"] = "Instrumental"
        
        map["isrc"] = "ISRC"
        
        map["itunes pid"] = "iTunes PID"
        
        map["label"] = "Label"
        
        map["language"] = "Language"
        
        map["length"] = "Length (ms)"
        
        map["love-dislike rating"] = "Love"
        
        map["lyricist"] = "Lyricist"
        
        map["lyricwiki takedown status"] = "LyricWiki Takedown Status id"
        
        map["lyricwiki url"] = "LyricWiki URL"
        
        map["media"] = "Media Type"
        
        map["mood"] = "Mood"
        
        map["music_cd_identifier"] = "Music CD Identifier"
        
        map["musicbrainz album artist id"] = "MusicBrainz Album Artist Id"
        
        map["musicbrainz_albumartist_url"] = "MusicBrainz Album Artist URLs"
        
        map["musicbrainz artist id"] = "MusicBrainz Artist Id"
        
        map["musicbrainz_artist_url"] = "MusicBrainz Artist URLs"
        
        map["musicbrainz_artwork_url_type"] = "MusicBrainz Artwork URLs"
        
        map["musicbrainz_catalog_number"] = "MusicBrainz Catalog Number"
        
        map["musicbrainz disc id"] = "MusicBrainz Disc Id"
        
        map["musicbrainz_exception_mask"] = "MusicBrainz Exception Mask"
        
        map["musicbrainz_import_settings"] = "MusicBrainz Import Settings"
        
        map["musicbrainz_import_time"] = "MusicBrainz Import Time"
        
        map["musicbrainz_label_url"] = "MusicBrainz label URLs"
        
        map["musicbrainz original album id"] = "MusicBrainz Original Album Id"
        
        map["musicbrainz_original_album_url"] = "MusicBrainz Original Album URL"
        
        map["musicbrainz track id"] = "MusicBrainz Recording Id"
        
        map["musicbrainz_relationship_url_name}"] = "MusicBrainz Relationship URLs"
        
        map["musicbrainz album release country"] = "MusicBrainz Release Country"
        
        map["musicbrainz release group id"] = "MusicBrainz Release Group Id"
        
        map["musicbrainz_release_group_url"] = "MusicBrainz Release Group URL"
        
        map["musicbrainz album id"] = "MusicBrainz Release Id"
        
        map["musicbrainz album status"] = "MusicBrainz Release Status"
        
        map["musicbrainz release track id"] = "MusicBrainz Release Track Id"
        
        map["musicbrainz album type"] = "MusicBrainz Release Type"
        
        map["musicbrainz_album_url"] = "MusicBrainz Release URL"
        
        map["musicbrainz trm id"] = "MusicBrainz TRM Id"
        
        map["script"] = "MusicBrainz Script"
        
        map["musicbrainz work id"] = "MusicBrainz Work Id"
        
        map["musiciancredits"] = "Musician Credits"
        
        map["url_official_artist_site"] = "Official Artist/Performer Webpage"
        
        map["official_audio_file_url"] = "Official Audio File Webpage"
        
        map["official_audio_source_url"] = "Official Audio Source Webpage"
        
        map["official_radio_url"] = "Official Internet Radio Station Webpage"
        
        map["original album"] = "Original Album"
        
        map["original artist"] = "Original Artist"
        
        map["original filename"] = "Original Filename"
        
        map["original lyricist"] = "Original Lyricist"
        
        map["original year"] = "Original Release Time"
        
        map["payment_url"] = "Payment Webpage"
        
        map["playcount"] = "Play Count"
        
        map["pricepaid"] = "Price Paid"
        
        map["produced_notice"] = "Produced Notice"
        
        map["publisher"] = "Publisher"
        
        map["label_url"] = "Publisher's Official Webpage"
        
        map["radio_station"] = "Radio Station"
        
        map["rating"] = "Rating"
        
        map["releasetime"] = "Release Time"
        
        map["rememberplaybackposition"] = "Remember Position"
        
        map["remixer"] = "Remixer"
        
        map["replaygain_album_gain"] = "ReplayGain Album Gain"
        
        map["replaygain_album_peak"] = "ReplayGain Album Peak"
        
        map["replaygain_track_gain"] = "ReplayGain Track Gain"
        
        map["replaygain_track_peak"] = "ReplayGain Track Peak"
        
        map["set subtitle"] = "Set Subtitle"
        
        map["skipwhenshuffling"] = "Skip When Shuffling"
        
        map["itunes_start_time"] = "Start Time"
        
        map["station_owner"] = "Station Owner"
        
        map["itunes_stop_time"] = "Stop Time"
        
        map["taggingtime"] = "Tagging Time"
        
        map["termsofuse"] = "Terms of Use"
        
        map["tmdb adult content"] = "tMDb Adult Content"
        
        map["tmdb name url"] = "tMDb Artwork URLs"
        
        map["tmdb budget"] = "tMDb Budget"
        
        map["tmdb collection name"] = "tMDb Collection Name"
        
        map["commercial_info_url"] = "tMDb Homepage"
        
        map["tmdb movie id"] = "tMDb Movie ID"
        
        map["tmdb original language"] = "tMDb Original Language (ISO)"
        
        map["tmdb original language (iso)"] = "tMDb Original Language (ISO)"
        
        map["tmdb production countries"] = "tMDb Production Countries"
        
        map["tmdb production countries (iso)"] = "tMDb Production Countries (ISO)"
        
        map["tmdb revenue"] = "tMDb Revenue"
        
        map["tmdb spoken languages"] = "tMDb Spoken Languages"
        
        map["tmdb spoken languages (iso)"] = "tMDb Spoken Languages (ISO)"
        
        map["tmdb tv id"] = "tMDb TV ID"
        
        map["track number text"] = "Track Position"
        
        map["ufid"] = "Unique File Identifier"
        
        map["itunes_volume_adjustment"] = "Volume Adjustment"
        
        map["yate album id"] = "Yate Album ID"
        
        map["yate track id"] = "Yate Track ID"
        
        return map
    }()
}
