import Cocoa
import AVFoundation

fileprivate let key_title = "title"
fileprivate let key_artist = "artist"
fileprivate let key_album = "album"
fileprivate let key_genre = "genre"

fileprivate let key_disc = "discnumber"
fileprivate let key_discTotal = "disctotal"
fileprivate let key_totalDiscs = "totaldiscs"

fileprivate let key_track = "tracknumber"
fileprivate let key_trackTotal = "tracktotal"
fileprivate let key_totalTracks = "totaltracks"

fileprivate let key_lyrics = "lyrics"

fileprivate let key_encodingTime = "encodingtime"
fileprivate let key_language = "language"

class VorbisCommentParser: FFMpegMetadataParser {
    
    private let essentialKeys: Set<String> = [key_title, key_artist, key_album, key_genre, key_disc, key_totalDiscs, key_discTotal, key_track, key_trackTotal, key_totalTracks, key_lyrics]
    
    func mapTrack(_ mapForTrack: LibAVMetadata) {
        
        let map = mapForTrack.map
        
        let metadata = LibAVParserMetadata()
        mapForTrack.vorbisMetadata = metadata
        
        for (key, value) in map {
            
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
        
        if let artist = mapForTrack.vorbisMetadata?.essentialFields[key_artist] {
            return artist
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
    
    private func parseGenreNumericString(_ string: String) -> String {
        
        let decimalChars = CharacterSet.decimalDigits
        
        // TODO: Declare this char set as a global constant somewhere
        let alphaChars = CharacterSet.lowercaseLetters.union(CharacterSet.uppercaseLetters)
        
        // If no alphabetic characters are present, and numeric characters are present, treat this as a numerical genre code
        if string.rangeOfCharacter(from: alphaChars) == nil, string.rangeOfCharacter(from: decimalChars) != nil {
            
            // Need to parse the number
            let numberStr = string.trimmingCharacters(in: decimalChars.inverted)
            if let genreCode = Int(numberStr) {
                
                // Look up genreId in ID3 table
                return GenreMap.forID3Code(genreCode) ?? string
            }
        }
        
        return string
    }
    
    func getDiscNumber(_ mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)? {
        
        if let discNumStr = mapForTrack.vorbisMetadata?.essentialFields[key_disc] {
            return parseDiscOrTrackNumber(discNumStr)
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
            return parseDiscOrTrackNumber(trackNumStr)
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
                }
                
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
        map["encoding"] = "Encoder Settings"
        map["composer"] = "Composer"
        map["arranger"] = "Arranger"
        map["author"] = "Author"
        map["ensemble"] = "Ensemble"
        map["part"] = "Part"
        map["partnumber"] = "Part Number"
        map["date"] = "Date"
        map["location"] = "Location"
        
        map["acousticbrainz_data"] = "AcousticBrainz Data"
        
        map["acoustid data"] = "Acoustid Data"
        
        map["acoustid_fingerprint"] = "Acoustid Fingerprint"
        
        map["acoustid_fingerprint_fault"] = "Acoustid Fingerprint Fault"
        
        map["acoustid_id"] = "Acoustid Id"
        
        map["acoustid status"] = "Acoustid Status"
        
        map["apiseeds_artist"] = "APISEEDS Artist"
        
        map["apiseeds_probability"] = "APISEEDS Probability"
        
        map["apiseeds_status"] = "APISEEDS Status"
        
        map["apiseeds_text"] = "APISEEDS Text"
        
        map["apiseeds_title"] = "APISEEDS Title"
        
        map["autosearch_artwork_url"] = "Autosearch Artwork URL"
        
        map["barcode"] = "Barcode"
        
        map["beatport_album_url"] = "Beatport Album URL"
        
        map["beatport_artist_url{-n}"] = "Beatport Artist URLs"
        
        map["beatport_import_time"] = "Beatport Import Time"
        
        map["beatport_label_url"] = "Beatport Label URL"
        
        map["beatport_release_id"] = "Beatport Release Id"
        
        map["beatport_track_id"] = "Beatport Track Id"
        
        map["beatport_track_url"] = "Beatport Track URL"
        
        map["catalognumber"] = "Catalog Number"
        
        map["category"] = "Category"
        
        map["comment"] = "Comment"
        
        map["commercial_info_url"] = "Commercial Information Webpage"
        
        map["conductor"] = "Conductor"
        
        map["copyright url"] = "Copyright/Legal Information Webpage"
        
        map["country"] = "Country"
        
        map["cuesheet"] = "Cuesheet"
        
        map["user configurable"] = "Custom 0...99"
        
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
        
        map["discogs_album_releasecountry"] = "Discogs Release Country"
        
        map["discogs_release_id"] = "Discogs Release Id"
        
        map["discogs_release_notes"] = "Discogs Release Notes"
        
        map["discogs_release_ordinal_position"] = "Discogs Release Ordinal Position"
        
        map["discogs_release_url"] = "Discogs Release URL"
        
        map["encoding"] = "Encoder Settings"
        
        map["encodingtime"] = "Encoding Time"
        
        map["filetype"] = "File Type"
        
        map["fmps_playcount"] = "FMPS Play Count"
        
        map["fmps_rating_amarok_score"] = "FMPS Rating Amarok Score"
        
        map["key"] = "Initial Key"
        
        map["involvedpeople"] = "Involved People"
        
        map["djmixer"] = "DJ Mixer"
        
        map["engineer"] = "Engineer"
        
        map["mixer"] = "Mixer"
        
        map["producer"] = "Producer"
        
        map["yate-ip"] = "Involved People"
        
        map["instrumental"] = "Instrumental"
        
        map["isrc"] = "ISRC"
        
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
        
        map["musicbrainz_albumartistid"] = "MusicBrainz Album Artist Id"
        
        map["musicbrainz_albumartist_url{-n}"] = "MusicBrainz Album Artist URLs"
        
        map["musicbrainz_artistid"] = "MusicBrainz Artist Id"
        
        map["musicbrainz_artist_url{-n}"] = "MusicBrainz Artist URLs"
        
        map["musicbrainz_artwork_url_type{-n}"] = "MusicBrainz Artwork URLs"
        
        map["musicbrainz_catalog_number{-n}"] = "MusicBrainz Catalog Number"
        
        map["musicbrainz_discid"] = "MusicBrainz Disc Id"
        
        map["musicbrainz_exception_mask"] = "MusicBrainz Exception Mask"
        
        map["musicbrainz_import_settings"] = "MusicBrainz Import Settings"
        
        map["musicbrainz_import_time"] = "MusicBrainz Import Time"
        
        map["musicbrainz_label_url{-n}"] = "MusicBrainz label URLs"
        
        map["musicbrainz_originalalbumid"] = "MusicBrainz Original Album Id"
        
        map["musicbrainz_original_album_url"] = "MusicBrainz Original Album URL"
        
        map["musicbrainz_trackid"] = "MusicBrainz Recording Id"
        
        map["musicbrainz_relationship_url_name}"] = "MusicBrainz Relationship URLs"
        
        map["musicbrainz_album_releasecountry"] = "MusicBrainz Release Country"
        
        map["musicbrainz_release_groupid"] = "MusicBrainz Release Group Id"
        
        map["musicbrainz_release_group_url"] = "MusicBrainz Release Group URL"
        
        map["musicbrainz_albumid"] = "MusicBrainz Release Id"
        
        map["musicbrainz_albumstatus"] = "MusicBrainz Release Status"
        
        map["musicbrainz_releasetrackid"] = "MusicBrainz Release Track Id"
        
        map["musicbrainz_albumtype"] = "MusicBrainz Release Type"
        
        map["musicbrainz_album_url"] = "MusicBrainz Release URL"
        
        map["musicbrainz_trmid"] = "MusicBrainz TRM Id"
        
        map["script"] = "MusicBrainz Script"
        
        map["musicbrainz_workid"] = "MusicBrainz Work Id"
        
        map["performer (r/w)<sup>45</sup><br>musiciancredits (r/o)<br>yate-mc<sup>20</sup>"] = "Musician Credits"
        
        map["url_official_artist_site"] = "Official Artist/Performer Webpage"
        
        map["official_audio_file_url"] = "Official Audio File Webpage"
        
        map["official_audio_source_url"] = "Official Audio Source Webpage"
        
        map["official_radio_url"] = "Official Internet Radio Station Webpage"
        
        map["original album"] = "Original Album"
        
        map["original artist"] = "Original Artist"
        
        map["original filename"] = "Original Filename"
        
        map["original lyricist"] = "Original Lyricist"
        
        map["originaldate (r/w)<br>original year (r/o)<br>originalreleasedate (r/o&gt;)<br>original_year (r/o)"] = "Original Release Time"
        
        map["payment_url"] = "Payment Webpage"
        
        map["pricepaid"] = "Price Paid"
        
        map["produced_notice"] = "Produced Notice"
        
        map["publisher"] = "Publisher"
        
        map["label_url"] = "Publisher's Official Webpage"
        
        map["radio_station"] = "Radio Station"
        
        map["rating"] = "Rating"
        
        map["releasetime"] = "Release Time"
        
        map["remixer"] = "Remixer"
        
        map["replaygain_album_gain"] = "ReplayGain Album Gain"
        
        map["replaygain_album_peak"] = "ReplayGain Album Peak"
        
        map["replaygain_track_gain"] = "ReplayGain Track Gain"
        
        map["replaygain_track_peak"] = "ReplayGain Track Peak"
        
        map["set subtitle"] = "Set Subtitle"
        
        map["skipwhenshuffling"] = "Skip When Shuffling"
        
        map["source"] = "Source"
        
        map["sourcemedia"] = "Source Media"
        
        map["station_owner"] = "Station Owner"
        
        map["taggingtime"] = "Tagging Time"
        
        map["termsofuse"] = "Terms of Use"
        
        map["track_number_text"] = "Track Position"
        
        map["ufid"] = "Unique File Identifier"
        
        map["yate_album_id"] = "Yate Album ID"
        
        map["yate_track_id"] = "Yate Track ID"
        
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
