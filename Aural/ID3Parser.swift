import Cocoa
import AVFoundation

fileprivate let keySpace: String = AVMetadataKeySpace.id3.rawValue

fileprivate let key_duration: String = String(format: "%@/%@", keySpace, AVMetadataKey.id3MetadataKeyLength.rawValue)

fileprivate let key_title = String(format: "%@/%@", keySpace, AVMetadataKey.id3MetadataKeyTitleDescription.rawValue)
fileprivate let commonKey_title = String(format: "%@/%@", keySpace, AVMetadataKey.commonKeyTitle.rawValue)

fileprivate let key_artist = String(format: "%@/%@", keySpace, AVMetadataKey.id3MetadataKeyOriginalArtist.rawValue)
fileprivate let commonKey_artist = String(format: "%@/%@", keySpace, AVMetadataKey.commonKeyArtist.rawValue)
fileprivate let key_band = String(format: "%@/%@", keySpace, AVMetadataKey.id3MetadataKeyBand.rawValue)

fileprivate let key_album = String(format: "%@/%@", keySpace, AVMetadataKey.id3MetadataKeyAlbumTitle.rawValue)
fileprivate let commonKey_album = String(format: "%@/%@", keySpace, AVMetadataKey.commonKeyAlbumName.rawValue)

fileprivate let key_genre = String(format: "%@/%@", keySpace, AVMetadataKey.id3MetadataKeyContentType.rawValue)
fileprivate let commonKey_genre = String(format: "%@/%@", keySpace, AVMetadataKey.commonKeyType.rawValue)

fileprivate let key_discNumber = String(format: "%@/%@", keySpace, AVMetadataKey.id3MetadataKeyPartOfASet.rawValue)
fileprivate let key_trackNumber = String(format: "%@/%@", keySpace, AVMetadataKey.id3MetadataKeyTrackNumber.rawValue)

fileprivate let key_lyrics = String(format: "%@/%@", keySpace, AVMetadataKey.id3MetadataKeyUnsynchronizedLyric.rawValue)
fileprivate let key_syncLyrics = String(format: "%@/%@", keySpace, AVMetadataKey.id3MetadataKeySynchronizedLyric.rawValue)

fileprivate let key_art: String = String(format: "%@/%@", keySpace, AVMetadataKey.id3MetadataKeyAttachedPicture.rawValue)
fileprivate let commonKey_art: String = String(format: "%@/%@", keySpace, AVMetadataKey.commonKeyArtwork.rawValue)
fileprivate let id_art: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.id3MetadataKeyAttachedPicture.rawValue, keySpace: AVMetadataKeySpace.id3)!

fileprivate let essentialFieldKeys: [String] = [key_duration, key_title, commonKey_title, key_artist, commonKey_artist, key_album, commonKey_album, key_genre, commonKey_genre, key_discNumber, key_trackNumber, key_lyrics, key_syncLyrics, key_art, commonKey_art]

/*  
 Specification for the ID3 metadata format. Versions 2.3 and 2.4 are supported.
 
 See http://id3.org/id3v2.3.0 and http://id3.org/id3v2.4.0-frames
 */
class ID3Parser: MetadataParser {
    
    fileprivate let id_art: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.id3MetadataKeyAttachedPicture.rawValue, keySpace: AVMetadataKeySpace.id3)!
    
    // Mappings of format-specific keys to readable keys
    private static var map: [String: String] = initMap()
    private static var genresMap: [Int: String] = initGenresMap()
    
    static func readableKey(_ key: String) -> String {
        return map[key] ?? key.capitalizingFirstLetter()
    }
    
    static func genreForCode(_ code: Int) -> String? {
        return genresMap[code]
    }
    
    private static func initMap() -> [String: String] {
        
        var map: [String: String] = [String: String]()
        
        // AENC
        map[AVMetadataKey.id3MetadataKeyAudioEncryption.rawValue] = "Audio Encryption"
        
        // APIC
        map[AVMetadataKey.id3MetadataKeyAttachedPicture.rawValue] = "Attached Picture"
        
        // ASPI
        map[AVMetadataKey.id3MetadataKeyAudioSeekPointIndex.rawValue] = "Audio Seek Point Index"
        
        // COMM
        map[AVMetadataKey.id3MetadataKeyComments.rawValue] = "Comments"
        
        // COMR
        map[AVMetadataKey.id3MetadataKeyCommercial.rawValue] = "Commercial Frame"
        
        // ENCR
        map[AVMetadataKey.id3MetadataKeyEncryption.rawValue] = "Encryption Method Registration"
        
        // EQU2
        map[AVMetadataKey.id3MetadataKeyEqualization2.rawValue] = "Equalization"
        
        // EQUA
        map[AVMetadataKey.id3MetadataKeyEqualization.rawValue] = "Equalization"
        
        // ETCO
        map[AVMetadataKey.id3MetadataKeyEventTimingCodes.rawValue] = "Event Timing Codes"
        
        // GEOB
        map[AVMetadataKey.id3MetadataKeyGeneralEncapsulatedObject.rawValue] = "General Encapsulated Object"
        
        // GRID
        map[AVMetadataKey.id3MetadataKeyGroupIdentifier.rawValue] = "Group Identification Registration"
        
        // IPLS
        map[AVMetadataKey.id3MetadataKeyInvolvedPeopleList_v23.rawValue] = "Involved People List"
        
        // LINK
        map[AVMetadataKey.id3MetadataKeyLink.rawValue] = "Linked Information"
        
        // MCDI
        map[AVMetadataKey.id3MetadataKeyMusicCDIdentifier.rawValue] = "Music CD Identifier"
        
        // MLLT
        map[AVMetadataKey.id3MetadataKeyMPEGLocationLookupTable.rawValue] = "MPEG Location Lookup Table"
        
        // OWNE
        map[AVMetadataKey.id3MetadataKeyOwnership.rawValue] = "Ownership Frame"
        
        // PCNT
        map[AVMetadataKey.id3MetadataKeyPlayCounter.rawValue] = "Play Counter"
        
        // POPM
        map[AVMetadataKey.id3MetadataKeyPopularimeter.rawValue] = "Popularimeter"
        
        // POSS
        map[AVMetadataKey.id3MetadataKeyPositionSynchronization.rawValue] = "Position Synchronisation Frame"
        
        // PRIV
        //        map[AVMetadataKey.id3MetadataKeyPrivate.rawValue] = "Private Frame"
        map[AVMetadataKey.id3MetadataKeyPrivate.rawValue] = ""
        
        // RBUF
        map[AVMetadataKey.id3MetadataKeyRecommendedBufferSize.rawValue] = "Recommended Buffer Size"
        
        // RVA2
        map[AVMetadataKey.id3MetadataKeyRelativeVolumeAdjustment2.rawValue] = "Relative Volume Adjustment"
        
        // RVAD
        map[AVMetadataKey.id3MetadataKeyRelativeVolumeAdjustment.rawValue] = "Relative Volume Adjustment"
        
        // RVRB
        map[AVMetadataKey.id3MetadataKeyReverb.rawValue] = "Reverb"
        
        // SEEK
        map[AVMetadataKey.id3MetadataKeySeek.rawValue] = "Seek"
        
        // SIGN
        map[AVMetadataKey.id3MetadataKeySignature.rawValue] = "Signature"
        
        // SYLT
        map[AVMetadataKey.id3MetadataKeySynchronizedLyric.rawValue] = "Synchronized Lyrics"
        
        // SYTC
        map[AVMetadataKey.id3MetadataKeySynchronizedTempoCodes.rawValue] = "Synchronized Tempo Codes"
        
        // TALB
        map[AVMetadataKey.id3MetadataKeyAlbumTitle.rawValue] = "Album"
        
        // TBPM
        map[AVMetadataKey.id3MetadataKeyBeatsPerMinute.rawValue] = "BPM (Beats Per Minute)"
        
        // TCOM
        map[AVMetadataKey.id3MetadataKeyComposer.rawValue] = "Composer"
        
        // TCON
        map[AVMetadataKey.id3MetadataKeyContentType.rawValue] = "Genre"
        
        // TCOP
        map[AVMetadataKey.id3MetadataKeyCopyright.rawValue] = "Copyright Message"
        
        // TDAT
        map[AVMetadataKey.id3MetadataKeyDate.rawValue] = "Date"
        
        // TDEN
        map[AVMetadataKey.id3MetadataKeyEncodingTime.rawValue] = "Encoding Time"
        
        // TDLY
        map[AVMetadataKey.id3MetadataKeyPlaylistDelay.rawValue] = "Playlist Delay"
        
        // TDOR
        map[AVMetadataKey.id3MetadataKeyOriginalReleaseTime.rawValue] = "Original Release Time"
        
        // TDRC
        map[AVMetadataKey.id3MetadataKeyRecordingTime.rawValue] = "Recording Time"
        
        // TDRL
        map[AVMetadataKey.id3MetadataKeyReleaseTime.rawValue] = "Release Time"
        
        // TDTG
        map[AVMetadataKey.id3MetadataKeyTaggingTime.rawValue] = "Tagging Time"
        
        // TENC
        map[AVMetadataKey.id3MetadataKeyEncodedBy.rawValue] = "Encoded By"
        
        // TEXT
        map[AVMetadataKey.id3MetadataKeyLyricist.rawValue] = "Lyricist"
        
        // TFLT
        map[AVMetadataKey.id3MetadataKeyFileType.rawValue] = "File Type"
        
        // TIME
        map[AVMetadataKey.id3MetadataKeyTime.rawValue] = "Time"
        
        // TIPL
        map[AVMetadataKey.id3MetadataKeyInvolvedPeopleList_v24.rawValue] = "Involved People List"
        
        // TIT1
        map[AVMetadataKey.id3MetadataKeyContentGroupDescription.rawValue] = "Content Group Description"
        
        // TIT2
        map[AVMetadataKey.id3MetadataKeyTitleDescription.rawValue] = "Title"
        
        // TIT3
        map[AVMetadataKey.id3MetadataKeySubTitle.rawValue] = "Subtitle"
        
        // TKEY
        map[AVMetadataKey.id3MetadataKeyInitialKey.rawValue] = "Initial Key"
        
        // TLAN
        map[AVMetadataKey.id3MetadataKeyLanguage.rawValue] = "Language(s)"
        
        // TLEN
        map[AVMetadataKey.id3MetadataKeyLength.rawValue] = "Length"
        
        // TMCL
        map[AVMetadataKey.id3MetadataKeyMusicianCreditsList.rawValue] = "Musician Credits List"
        
        // TMED
        map[AVMetadataKey.id3MetadataKeyMediaType.rawValue] = "Media Type"
        
        // TMOO
        map[AVMetadataKey.id3MetadataKeyMood.rawValue] = "Mood"
        
        // TOAL
        map[AVMetadataKey.id3MetadataKeyOriginalAlbumTitle.rawValue] = "Original Album Title"
        
        // TOFN
        map[AVMetadataKey.id3MetadataKeyOriginalFilename.rawValue] = "Original Filename"
        
        // TOLY
        map[AVMetadataKey.id3MetadataKeyOriginalLyricist.rawValue] = "Original Lyricist(s)"
        
        // TOPE
        map[AVMetadataKey.id3MetadataKeyOriginalArtist.rawValue] = "Artist"
        
        // TORY
        map[AVMetadataKey.id3MetadataKeyOriginalReleaseYear.rawValue] = "Original Release Year"
        
        // TOWN
        map[AVMetadataKey.id3MetadataKeyFileOwner.rawValue] = "File Owner"
        
        // TPE1
        map[AVMetadataKey.id3MetadataKeyLeadPerformer.rawValue] = "Lead Performer(s)"
        
        // TPE2
        map[AVMetadataKey.id3MetadataKeyBand.rawValue] = "Band"
        
        // TPE3
        map[AVMetadataKey.id3MetadataKeyConductor.rawValue] = "Conductor"
        
        // TPE4
        map[AVMetadataKey.id3MetadataKeyModifiedBy.rawValue] = "Interpreted, Remixed, Or Otherwise Modified By"
        
        // TPOS
        map[AVMetadataKey.id3MetadataKeyPartOfASet.rawValue] = "Part Of A Set"
        
        // TPRO
        map[AVMetadataKey.id3MetadataKeyProducedNotice.rawValue] = "Produced Notice"
        
        // TPUB
        map[AVMetadataKey.id3MetadataKeyPublisher.rawValue] = "Publisher"
        
        // TRCK
        map[AVMetadataKey.id3MetadataKeyTrackNumber.rawValue] = "Track Number"
        
        // TRDA
        map[AVMetadataKey.id3MetadataKeyRecordingDates.rawValue] = "Recording Dates"
        
        // TRSN
        map[AVMetadataKey.id3MetadataKeyInternetRadioStationName.rawValue] = "Internet Radio Station Name"
        
        // TRSO
        map[AVMetadataKey.id3MetadataKeyInternetRadioStationOwner.rawValue] = "Internet Radio Station Owner"
        
        // TSIZ
        map[AVMetadataKey.id3MetadataKeySize.rawValue] = "Size"
        
        // TSOA
        map[AVMetadataKey.id3MetadataKeyAlbumSortOrder.rawValue] = "Album Sort Order"
        
        // TSOP
        map[AVMetadataKey.id3MetadataKeyPerformerSortOrder.rawValue] = "Performer Sort Order"
        
        // TSOT
        map[AVMetadataKey.id3MetadataKeyTitleSortOrder.rawValue] = "Title Sort Order"
        
        // TSRC
        map[AVMetadataKey.id3MetadataKeyInternationalStandardRecordingCode.rawValue] = "ISRC (International Standard Recording Code)"
        
        // TSSE
        map[AVMetadataKey.id3MetadataKeyEncodedWith.rawValue] = "Encoding Software / Hardware"
        
        // TSST
        map[AVMetadataKey.id3MetadataKeySetSubtitle.rawValue] = "Set Subtitle"
        
        // TODO: Use extra attributes to elaborate on TXXX fields (e.g. ALBUMARTIST)
        // TXXX
        map[AVMetadataKey.id3MetadataKeyUserText.rawValue] = "User Defined Text Information Frame"
        
        // TYER
        map[AVMetadataKey.id3MetadataKeyYear.rawValue] = "Year"
        
        // UFID
        map[AVMetadataKey.id3MetadataKeyUniqueFileIdentifier.rawValue] = "Unique File Identifier"
        
        // USER
        map[AVMetadataKey.id3MetadataKeyTermsOfUse.rawValue] = "Terms Of Use"
        
        // USLT
        map[AVMetadataKey.id3MetadataKeyUnsynchronizedLyric.rawValue] = "Lyrics"
        
        // WCOM
        map[AVMetadataKey.id3MetadataKeyCommercialInformation.rawValue] = "Commercial Information"
        
        // WCOP
        map[AVMetadataKey.id3MetadataKeyCopyrightInformation.rawValue] = "Copyright Information"
        
        // WOAF
        map[AVMetadataKey.id3MetadataKeyOfficialAudioFileWebpage.rawValue] = "Official Audio File Webpage"
        
        // WOAR
        map[AVMetadataKey.id3MetadataKeyOfficialArtistWebpage.rawValue] = "Official Artist Webpage"
        
        // WOAS
        map[AVMetadataKey.id3MetadataKeyOfficialAudioSourceWebpage.rawValue] = "Official Audio Source Webpage"
        
        // WORS
        map[AVMetadataKey.id3MetadataKeyOfficialInternetRadioStationHomepage.rawValue] = "Official Internet Radio Station Homepage"
        
        // WPAY
        map[AVMetadataKey.id3MetadataKeyPayment.rawValue] = "Payment"
        
        // WPUB
        map[AVMetadataKey.id3MetadataKeyOfficialPublisherWebpage.rawValue] = "Publishers Official Webpage"
        
        // WXXX
        map[AVMetadataKey.id3MetadataKeyUserURL.rawValue] = "User Defined URL Link Frame"
        
        return map
    }
    
    private static func initGenresMap() -> [Int: String] {
        
        var map: [Int: String] = [:]
        
        map[0] = "Blues"
        map[1] = "Classic Rock"
        map[2] = "Country"
        map[3] = "Dance"
        map[4] = "Disco"
        map[5] = "Funk"
        map[6] = "Grunge"
        map[7] = "Hip"
        map[8] = "Jazz"
        map[9] = "Metal"
        map[10] = "New Age"
        map[11] = "Oldies"
        map[12] = "Other"
        map[13] = "Pop"
        map[14] = "R&B"
        map[15] = "Rap"
        map[16] = "Reggae"
        map[17] = "Rock"
        map[18] = "Techno"
        map[19] = "Industrial"
        map[20] = "Alternative"
        map[21] = "Ska"
        map[22] = "Death Metal"
        map[23] = "Pranks"
        map[24] = "Soundtrack"
        map[25] = "Euro"
        map[26] = "Ambient"
        map[27] = "Trip"
        map[28] = "Vocal"
        map[29] = "Jazz & Funk"
        map[30] = "Fusion"
        map[31] = "Trance"
        map[32] = "Classical"
        map[33] = "Instrumental"
        map[34] = "Acid"
        map[35] = "House"
        map[36] = "Game"
        map[37] = "Sound Clip"
        map[38] = "Gospel"
        map[39] = "Noise"
        map[40] = "Alternative Rock"
        map[41] = "Bass"
        map[42] = "Soul"
        map[43] = "Punk"
        map[44] = "Space"
        map[45] = "Meditative"
        map[46] = "Instrumental Pop"
        map[47] = "Instrumental Rock"
        map[48] = "Ethnic"
        map[49] = "Gothic"
        map[50] = "Darkwave"
        map[51] = "Techno"
        map[52] = "Electronic"
        map[53] = "Pop"
        map[54] = "Eurodance"
        map[55] = "Dream"
        map[56] = "Southern Rock"
        map[57] = "Comedy"
        map[58] = "Cult"
        map[59] = "Gangsta"
        map[60] = "Top 40"
        map[61] = "Christian Rap"
        map[62] = "Pop/Funk"
        map[63] = "Jungle"
        map[64] = "Native US"
        map[65] = "Cabaret"
        map[66] = "New Wave"
        map[67] = "Psychadelic"
        map[68] = "Rave"
        map[69] = "Showtunes"
        map[70] = "Trailer"
        map[71] = "Lo"
        map[72] = "Tribal"
        map[73] = "Acid Punk"
        map[74] = "Acid Jazz"
        map[75] = "Polka"
        map[76] = "Retro"
        map[77] = "Musical"
        map[78] = "Rock & Roll"
        map[79] = "Hard Rock"
        map[80] = "Folk"
        map[81] = "Folk"
        map[82] = "National Folk"
        map[83] = "Swing"
        map[84] = "Fast Fusion"
        map[85] = "Bebob"
        map[86] = "Latin"
        map[87] = "Revival"
        map[88] = "Celtic"
        map[89] = "Bluegrass"
        map[90] = "Avantgarde"
        map[91] = "Gothic Rock"
        map[92] = "Progressive Rock"
        map[93] = "Psychedelic Rock"
        map[94] = "Symphonic Rock"
        map[95] = "Slow Rock"
        map[96] = "Big Band"
        map[97] = "Chorus"
        map[98] = "Easy Listening"
        map[99] = "Acoustic"
        map[100] = "Humour"
        map[101] = "Speech"
        map[102] = "Chanson"
        map[103] = "Opera"
        map[104] = "Chamber Music"
        map[105] = "Sonata"
        map[106] = "Symphony"
        map[107] = "Booty Bass"
        map[108] = "Primus"
        map[109] = "Porn Groove"
        map[110] = "Satire"
        map[111] = "Slow Jam"
        map[112] = "Club"
        map[113] = "Tango"
        map[114] = "Samba"
        map[115] = "Folklore"
        map[116] = "Ballad"
        map[117] = "Power Ballad"
        map[118] = "Rhythmic Soul"
        map[119] = "Freestyle"
        map[120] = "Duet"
        map[121] = "Punk Rock"
        map[122] = "Drum Solo"
        map[123] = "Acapella"
        map[124] = "Euro"
        map[125] = "Dance Hall"
        map[126] = "Goa"
        map[127] = "Drum & Bass"
        map[128] = "Club"
        map[129] = "Hardcore"
        map[130] = "Terror"
        map[131] = "Indie"
        map[132] = "BritPop"
        map[133] = "Negerpunk"
        map[134] = "Polsk Punk"
        map[135] = "Beat"
        map[136] = "Christian Gangsta Rap"
        map[137] = "Heavy Metal"
        map[138] = "Black Metal"
        map[139] = "Crossover"
        map[140] = "Contemporary Christian"
        map[141] = "Christian Rock"
        map[142] = "Merengue"
        map[143] = "Salsa"
        map[144] = "Thrash Metal"
        map[145] = "Anime"
        map[146] = "JPop"
        map[147] = "Synthpop"
        map[148] = "Unknown"
        
        return map
    }
    
    func mapTrack(_ track: Track, _ mapForTrack: MappedMetadata) {
        
        let items = track.audioAsset!.metadata
        
        for item in items {
            
            if item.keySpace == AVMetadataKeySpace.id3, let key = item.keyAsString {
                
                let mapKey = String(format: "%@/%@", keySpace, key)
                
                if essentialFieldKeys.contains(mapKey) {
                    mapForTrack.map[mapKey] = item
                } else {
                    // Generic field
                    mapForTrack.genericMap[mapKey] = item
                }
            }
        }
    }
    
    func getDuration(mapForTrack: MappedMetadata) -> Double? {
        
        if let item = mapForTrack.map[key_duration], let durationStr = item.stringValue, let durationMsecs = Double(durationStr) {
            return durationMsecs / 1000
        }
        
        return nil
    }
    
    func getTitle(mapForTrack: MappedMetadata) -> String? {
        
        for key in [commonKey_title, key_title] {
            
            if let titleItem = mapForTrack.map[key] {
                return titleItem.stringValue
            }
        }
        
        return nil
    }
    
    func getArtist(mapForTrack: MappedMetadata) -> String? {
        
        for key in [commonKey_artist, key_artist] {
            
            if let artistItem = mapForTrack.map[key] {
                return artistItem.stringValue
            }
        }
        
        return nil
    }
    
    func getAlbum(mapForTrack: MappedMetadata) -> String? {
        
        for key in [commonKey_album, key_album] {
            
            if let albumItem = mapForTrack.map[key] {
                return albumItem.stringValue
            }
        }
        
        return nil
    }
    
    func getGenre(mapForTrack: MappedMetadata) -> String? {
        
        for key in [commonKey_genre, key_genre] {
            
            if let genreItem = mapForTrack.map[key] {
                
                if let str = genreItem.stringValue {
                    
                    return parseGenreNumericString(str)
                    
                } else if let data = genreItem.dataValue {
                    
                    // Parse as hex string
                    let code = Int(data.hexEncodedString(), radix: 16)!
                    return ID3Parser.genreForCode(code)
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
                return ID3Parser.genreForCode(genreCode) ?? string
            }
        }
        
        return string
    }
    
    func getDiscNumber(mapForTrack: MappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let item = mapForTrack.map[key_discNumber] {
            return parseDiscOrTrackNumber(item)
        }
        
        return nil
    }
    
    func getTrackNumber(mapForTrack: MappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let item = mapForTrack.map[key_trackNumber] {
            return parseDiscOrTrackNumber(item)
        }
        
        return nil
    }
    
    private func parseDiscOrTrackNumber(_ item: AVMetadataItem) -> (number: Int?, total: Int?)? {
        
        if let number = item.numberValue {
            return (number.intValue, nil)
        }
        
        if let stringValue = item.stringValue {
            
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
    
    func getArt(mapForTrack: MappedMetadata) -> NSImage? {
        
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
    
    func getLyrics(mapForTrack: MappedMetadata) -> String? {
        
        for key in [key_lyrics, key_syncLyrics] {
            
            if let lyricsItem = mapForTrack.map[key] {
                return lyricsItem.stringValue
            }
        }
        
        return nil
    }
    
    func getGenericMetadata(mapForTrack: MappedMetadata) -> [String: MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        for item in mapForTrack.genericMap.values.filter({item -> Bool in item.keySpace == .id3}) {
            
            if let key = item.keyAsString, let value = item.valueAsString {
                metadata[key] = MetadataEntry(.id3, key, value)
            }
        }
        
        return metadata
    }
}
