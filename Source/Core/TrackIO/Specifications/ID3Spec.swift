//
//  ID3Spec.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

///
/// Specification for the ID3 metadata format. Versions 1.0, 2.2, and 2.4 are supported.
///
/// See http://id3.org/id3v2.3.0 and http://id3.org/id3v2.4.0-frames
///

///
/// ID3 version 1 spec.
///
struct ID3_V1Spec {
    
    static let key_title = "Title"
    
    static let key_artist = "Artist"
    static let key_album = "Album"
    static let key_genre = "Genre"
    
    static let key_year = "Year"
    
    static let key_trackNumber = "Album track"
    
    static let essentialFieldKeys: Set<String> = [key_title, key_artist, key_album, key_genre, key_trackNumber, key_year]
    
    static let auxiliaryFields: [String: String] = ["Comment": "Comment"]
}

///
/// ID3 version 2.2 spec.
///
struct ID3_V22Spec {
    
    static let key_duration: String = "TLE"
    
    static let key_title = "TT2"
    
    static let key_artist = "TP1"
    static let key_originalArtist = "TOA"
    static let key_albumArtist = "TP2"
    
    static let key_album = "TAL"
    static let key_originalAlbum = "TOT"
    static let key_composer = "TCM"
    static let key_conductor = "TP3"
    static let key_lyricist = "TXT"
    static let key_originalLyricist = "TOL"
    
    static let key_genre = "TCO"
    
    static let key_discNumber = "TPA"
    static let key_trackNumber = "TRK"
    
    static let key_year = "TYE"
    static let key_originalReleaseYear = "TOR"
    static let key_date = "TDA"
    
    static let key_bpm = "TBP"
    
    static let key_lyrics = "ULT"
    static let key_syncLyrics = "SLT"
    
    static let key_art: String = "PIC"
    
    static let key_language: String = "TLA"
    static let key_playCounter: String = "CNT"
    static let replaceableKeyFields: Set<String> = ["TXX", "COM", "WXX"]
    static let key_GEO: String = "GEO"
    static let key_compilation: String = "TCP"
    static let key_UFI: String = "UFI"
    static let key_mediaType: String = "TMT"
    
    static let essentialFieldKeys: Set<String> = [key_duration, key_title, key_artist, key_originalArtist, key_albumArtist, key_album, key_originalAlbum, key_genre, key_composer, key_conductor, key_lyricist, key_originalLyricist, key_discNumber, key_trackNumber, key_year, key_originalReleaseYear, key_date, key_bpm, key_art, key_lyrics, key_syncLyrics]
    
    static let auxiliaryFields: [String: String] = {
        
        var map: [String: String] = [:]
        
        /*
         
         TODO: Do we need these ???
         
         'ITU'    iTunesU?    no
         'PCS'    Podcast?    no
         
         */
        
        map["BUF"] = "Recommended Buffer Size"
        map["CRA"] = "Audio Encryption"
        map["COM"] = "Comment"
        map["EQU"] = "Equalization"
        map["ETC"] = "Event Timing Codes"
        map["GEO"] = "General Encapsulated Object"
        map["IPL"] = "Involved People List"
        map["LNK"] = "Linked Information"
        map["MCI"] = "Music CD Identifier"
        map["MLL"] = "MPEG Location Lookup Table"
        map["CNT"] = "Play Counter"
        map["POP"] = "Popularimeter"
        map["RVA"] = "Relative Volume Adjustment"
        map["REV"] = "Reverb"
        map["STC"] = "Synchronized Tempo Codes"
        map["TCP"] = "Part of a Compilation?"
        map["TCR"] = "Copyright"
        map["TDY"] = "Playlist Delay"
        map["TPB"] = "Publisher"
        map["TEN"] = "Encoded By"
        map["TFT"] = "File Type"
        map["TIM"] = "Time"
        map["TT1"] = "Grouping"
        map["TT3"] = "Subtitle"
        map["TKE"] = "Initial Key"
        map["TLA"] = "Language(s)"
        map["TMT"] = "Media Type"
        map["TOF"] = "Original Filename"
        map["TP4"] = "Interpreted, Remixed, Or Otherwise Modified By"
        map["TRD"] = "Recording Dates"
        map["TSI"] = "Size"
        map["TRC"] = "ISRC"
        map["TSS"] = "Encoding Tool"
        
        map["TS2"] = "Album Artist Sort Order"
        map["TSA"] = "Album Sort Order"
        map["TSC"] = "Composer Sort Order"
        map["TSP"] = "Performer Sort Order"
        map["TST"] = "Title Sort Order"
        
        // TODO: Use extra attributes to elaborate on TXXX fields (e.g. ALBUMARTIST)
        map["TXX"] = "User Defined Text Information Frame"
        
        map["UFI"] = "Unique File Identifier"
        map["WCM"] = "Commercial Information"
        map["WCP"] = "Copyright Information"
        map["WAF"] = "Official Audio File Webpage"
        map["WAR"] = "Official Artist Webpage"
        map["WAS"] = "Official Audio Source Webpage"
        map["WPB"] = "Publishers Official Webpage"
        
        // TODO: Use extra attributes to elaborate on TXXX fields (e.g. ALBUMARTIST)
        map["WXX"] = "User Defined URL Link Frame"
        
        // TODO: ???
        map["PCS"] = "Podcast"
        
        return map
    }()
}

///
/// ID3 version 2.4 spec.
///
struct ID3_V24Spec {
    
    // TLEN
    static let key_duration: String = AVMetadataKey.id3MetadataKeyLength.rawValue
    
    // TIT2
    static let key_title = AVMetadataKey.id3MetadataKeyTitleDescription.rawValue
    
    // TPE1
    static let key_artist = AVMetadataKey.id3MetadataKeyLeadPerformer.rawValue
    
    // TPE2
    static let key_albumArtist = AVMetadataKey.id3MetadataKeyBand.rawValue
    
    // TOPE
    static let key_originalArtist = AVMetadataKey.id3MetadataKeyOriginalArtist.rawValue
    
    // TCOM
    static let key_composer = AVMetadataKey.id3MetadataKeyComposer.rawValue
    
    // TPE3
    static let key_conductor = AVMetadataKey.id3MetadataKeyConductor.rawValue
    
    // TEXT
    static let key_lyricist = AVMetadataKey.id3MetadataKeyLyricist.rawValue
    
    // TOLY
    static let key_originalLyricist = AVMetadataKey.id3MetadataKeyOriginalLyricist.rawValue
    
    // TALB
    static let key_album = AVMetadataKey.id3MetadataKeyAlbumTitle.rawValue
    
    // TOAL
    static let key_originalAlbum = AVMetadataKey.id3MetadataKeyOriginalAlbumTitle.rawValue
    
    // TCON
    static let key_genre = AVMetadataKey.id3MetadataKeyContentType.rawValue
    
    // TPOS
    static let key_discNumber = AVMetadataKey.id3MetadataKeyPartOfASet.rawValue
    
    // TRCK
    static let key_trackNumber = AVMetadataKey.id3MetadataKeyTrackNumber.rawValue
    
    // TYER
    static let key_year = AVMetadataKey.id3MetadataKeyYear.rawValue
    
    // TBPM
    static let key_bpm = AVMetadataKey.id3MetadataKeyBeatsPerMinute.rawValue
    
    // TORY
    static let key_originalReleaseYear = AVMetadataKey.id3MetadataKeyOriginalReleaseYear.rawValue
    
    // TDAT
    static let key_date = AVMetadataKey.id3MetadataKeyDate.rawValue
    
    // USLT
    static let key_lyrics = AVMetadataKey.id3MetadataKeyUnsynchronizedLyric.rawValue
    
    // SYLT
    static let key_syncLyrics = AVMetadataKey.id3MetadataKeySynchronizedLyric.rawValue
    
    static let key_art: String = AVMetadataKey.id3MetadataKeyAttachedPicture.rawValue
    
    static let key_GEOB: String = AVMetadataKey.id3MetadataKeyGeneralEncapsulatedObject.rawValue
    static let key_playCounter: String = AVMetadataKey.id3MetadataKeyPlayCounter.rawValue
    
    static let replaceableKeyFields: Set<String> = [AVMetadataKey.id3MetadataKeyUserText.rawValue, AVMetadataKey.id3MetadataKeyComments.rawValue, AVMetadataKey.id3MetadataKeyUserURL.rawValue]
    
    static let key_language: String = AVMetadataKey.id3MetadataKeyLanguage.rawValue
    static let key_compilation: String = "TCMP"
    
    static let key_UFID: String = "UFID"
    static let key_termsOfUse: String = "USER"
    
    static let key_private: String = AVMetadataKey.id3MetadataKeyPrivate.rawValue
    
    // Chapter fields
    static let key_tableOfContents: String = "CTOC"
    static let key_chapter: String = "CHAP"
    
    static let key_mediaType: String = "TMED"
    
    static let key_userInfoText: String = AVMetadataKey.id3MetadataKeyUserText.rawValue
    
    static let key_replayGain_trackGain: String = "replaygain_track_gain"
    static let key_replayGain_trackPeak: String = "replaygain_track_peak"
    static let key_replayGain_albumGain: String = "replaygain_album_gain"
    static let key_replayGain_albumPeak: String = "replaygain_album_peak"
    
    static let essentialFieldKeys: Set<String> = [key_duration, key_title, key_artist, key_originalArtist, key_albumArtist, key_album, key_originalAlbum, key_genre, key_composer, key_conductor, key_lyricist, key_originalLyricist, key_discNumber, key_trackNumber, key_year, key_originalReleaseYear, key_date, key_bpm, key_art, key_lyrics, key_syncLyrics]
    
    static let replayGainKeys: [String] = [key_userInfoText]
    
    static let auxiliaryFields: [String: String] = {
        
        var map: [String: String] = [:]
        
        // USLT
        map[AVMetadataKey.id3MetadataKeyUnsynchronizedLyric.rawValue] = "Lyrics"
        
        // SYLT
        map[AVMetadataKey.id3MetadataKeySynchronizedLyric.rawValue] = "Lyrics"
        
        // AENC
        map[AVMetadataKey.id3MetadataKeyAudioEncryption.rawValue] = "Audio Encryption"
        
        // ASPI
        map[AVMetadataKey.id3MetadataKeyAudioSeekPointIndex.rawValue] = "Audio Seek Point Index"
        
        // COMM
        map[AVMetadataKey.id3MetadataKeyComments.rawValue] = "Comment"
        
        // COMR
        map[AVMetadataKey.id3MetadataKeyCommercial.rawValue] = "Commercial"
        
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
        map[AVMetadataKey.id3MetadataKeyOwnership.rawValue] = "Ownership"
        
        // PCNT
        map[AVMetadataKey.id3MetadataKeyPlayCounter.rawValue] = "Play Counter"
        
        // POPM
        map[AVMetadataKey.id3MetadataKeyPopularimeter.rawValue] = "Popularimeter"
        
        // POSS
        map[AVMetadataKey.id3MetadataKeyPositionSynchronization.rawValue] = "Position Synchronisation"
        
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
        
        // SYTC
        map[AVMetadataKey.id3MetadataKeySynchronizedTempoCodes.rawValue] = "Synchronized Tempo Codes"
        
        // TCOM
        map[AVMetadataKey.id3MetadataKeyComposer.rawValue] = "Composer"
        
        // TPE3
        map[AVMetadataKey.id3MetadataKeyConductor.rawValue] = "Conductor"
        
        // TEXT
        map[AVMetadataKey.id3MetadataKeyLyricist.rawValue] = "Lyricist"
        
        // TOLY
        map[AVMetadataKey.id3MetadataKeyOriginalLyricist.rawValue] = "Original Lyricist"
        
        // TYER
        map[AVMetadataKey.id3MetadataKeyYear.rawValue] = "Year"
        
        // TBPM
        map[AVMetadataKey.id3MetadataKeyBeatsPerMinute.rawValue] = "BPM"
        
        // TORY
        map[AVMetadataKey.id3MetadataKeyOriginalReleaseYear.rawValue] = "Original Release Year"
        
        // TDAT
        map[AVMetadataKey.id3MetadataKeyDate.rawValue] = "Date"
        
        // TCOP
        map[AVMetadataKey.id3MetadataKeyCopyright.rawValue] = "Copyright"
        
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
        
        // TFLT
        map[AVMetadataKey.id3MetadataKeyFileType.rawValue] = "File Type"
        
        // TIME
        map[AVMetadataKey.id3MetadataKeyTime.rawValue] = "Time"
        
        // TIPL
        map[AVMetadataKey.id3MetadataKeyInvolvedPeopleList_v24.rawValue] = "Involved People List"
        
        // TIT1
        map[AVMetadataKey.id3MetadataKeyContentGroupDescription.rawValue] = "Grouping"
        
        // TIT3
        map[AVMetadataKey.id3MetadataKeySubTitle.rawValue] = "Subtitle"
        
        // TKEY
        map[AVMetadataKey.id3MetadataKeyInitialKey.rawValue] = "Initial Key"
        
        // TLAN
        map[AVMetadataKey.id3MetadataKeyLanguage.rawValue] = "Language(s)"
        
        // TMCL
        map[AVMetadataKey.id3MetadataKeyMusicianCreditsList.rawValue] = "Musician Credits List"
        
        // TPUB
        map[AVMetadataKey.id3MetadataKeyPublisher.rawValue] = "Publisher"
        
        // TMED
        map[AVMetadataKey.id3MetadataKeyMediaType.rawValue] = "Media Type"
        
        // TMOO
        map[AVMetadataKey.id3MetadataKeyMood.rawValue] = "Mood"
        
        // TOFN
        map[AVMetadataKey.id3MetadataKeyOriginalFilename.rawValue] = "Original Filename"
        
        // TOWN
        map[AVMetadataKey.id3MetadataKeyFileOwner.rawValue] = "File Owner"
        
        // TPE4
        map[AVMetadataKey.id3MetadataKeyModifiedBy.rawValue] = "Interpreted, Remixed, Or Otherwise Modified By"
        
        // TPRO
        map[AVMetadataKey.id3MetadataKeyProducedNotice.rawValue] = "Produced Notice"
        
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
        map[AVMetadataKey.id3MetadataKeyInternationalStandardRecordingCode.rawValue] = "ISRC"
        
        // TSSE
        map[AVMetadataKey.id3MetadataKeyEncodedWith.rawValue] = "Encoding Tool"
        
        // TSST
        map[AVMetadataKey.id3MetadataKeySetSubtitle.rawValue] = "Set Subtitle"
        
        // TODO: Use extra attributes to elaborate on TXXX fields (e.g. ALBUMARTIST)
        // TXXX
        map[AVMetadataKey.id3MetadataKeyUserText.rawValue] = "User Defined Text Information Frame"
        
        // UFID
        map[AVMetadataKey.id3MetadataKeyUniqueFileIdentifier.rawValue] = "Unique File Identifier"
        
        // USER
        map[AVMetadataKey.id3MetadataKeyTermsOfUse.rawValue] = "Terms Of Use"
        
        // WCOM
        map[AVMetadataKey.id3MetadataKeyCommercialInformation.rawValue] = "Commercial Information"
        
        // WCOP
        map[AVMetadataKey.id3MetadataKeyCopyrightInformation.rawValue] = "Copyright Information"
        
        // WOAF
        map[AVMetadataKey.id3MetadataKeyOfficialAudioFileWebpage.rawValue] = "Official Audio File Webpage"
        
        // WOAR
        map[AVMetadataKey.id3MetadataKeyOfficialArtistWebpage.rawValue] = "Official Artist Website"
        
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
        
        map[key_compilation] = "Part of a Compilation?"
        
        return map
    }()
}

///
/// A mapping of ID3 media types to user-friendly human-readable strings.
///
struct ID3MediaTypes {
    
    ///
    /// Return a user-friendly human-readable string for a given media type code string.
    ///
    static func readableString(for codeString: String) -> String {
        
        let tokens = codeString.split(separator: "/")
        
        if let codeToken = tokens.first {
            
            let code = String(codeToken)
            
            if let codeDesc = mediaTypes[code] {
                
                let desc = codeDesc.0
                var subTypes: [String] = []
                var subTypesDesc: String = ""
                
                if tokens.count > 1 {
                    
                    let numSubTypes = tokens.count - 1
                    for index in 1...numSubTypes {
                        
                        let subTypeCode = String(tokens[index])
                        let subTypeDesc: String = codeDesc.1[subTypeCode] ?? subTypeCode
                        subTypes.append(subTypeDesc)
                    }
                    
                    subTypesDesc = String(format: " (%@)", subTypes.joined(separator: ","))
                }
                
                return String(format: "%@%@", desc, subTypesDesc)
            }
        }
        
        return codeString
    }
    
    ///
    /// A mapping of ID3 media type codes to user-friendly human-readable strings.
    ///
    /// Code string -> (Readable media type category, [Mappings for all sub-types in the category])
    /// Each code string is mapped to a corresponding readable media type category string and a collection of mappings for
    /// all media sub-types in that category.
    ///
    private static let mediaTypes: [String: (String, [String: String])] = {
        
        var map: [String: (String, [String: String])] = [:]
        
        map["DIG"] = ("Other digital media", [
            "A": "Analogue transfer from media"
            ])
        
        map["ANA"] = ("Other analogue media", [
            "WAC": "Wax cylinder",
            "8CA": "8-track tape cassette"
            ])
        
        map["CD"] = ("CD", [
            "A": "Analogue transfer from media",
            "DD": "DDD",
            "AD": "ADD",
            "AA": "AAD"
            ])
        
        map["LD"] = ("Laserdisc", [:])
        
        map["TT"] = ("Turntable records", [
            "78": "78.26 rpm",
            "45": "45 rpm",
            "76": "76.59 rpm",
            "71": "71.29 rpm",
            "80": "80 rpm",
            "33": "33.33 rpm"
            ])
        
        map["MD"] = ("MiniDisc", [
            "A": "Analogue transfer from media"
            ])
        
        map["DAT"] = ("DAT", [
            "6": "mode 6, 44.1 kHz16 bits, 'wide track' play",
            "3": "mode 3, 32 kHz12 bits, non-linear, low speed",
            "A": "Analogue transfer from media",
            "5": "mode 5, 44.1 kHz16 bits, linear",
            "2": "mode 2, 32 kHz16 bits, linear",
            "1": "standard, 48 kHz16 bits, linear",
            "4": "mode 4, 32 kHz12 bits, 4 channels"
            ])
        
        map["DCC"] = ("DCC", [
            "A": "Analogue transfer from media"
            ])
        
        map["DVD"] = ("DVD", [
            "A": "Analogue transfer from media"
            ])
        
        map["TV"] = ("Television", [
            "SECAM": "SECAM",
            "PAL": "PAL",
            "NTSC": "NTSC"
            ])
        
        map["VID"] = ("Video", [
            "BETA": "BETAMAX",
            "VHS": "VHS",
            "NTSC": "NTSC",
            "SECAM": "SECAM",
            "SVHS": "S-VHS",
            "PAL": "PAL"
            ])
        
        map["RAD"] = ("Radio", [
            "LW": "LW",
            "FM": "FM",
            "AM": "AM",
            "MW": "MW"
            ])
        
        map["TEL"] = ("Telephone", [
            "I": "ISDN"
            ])
        
        map["MC"] = ("MC (normal cassette)", [
            "I": "Type I cassette (ferricnormal)",
            "II": "Type II cassette (chrome)",
            "9": "9.5 cms",
            "4": "4.75 cms (normal speed for a two sided cassette)",
            "III": "Type III cassette (ferric chrome)",
            "IV": "Type IV cassette (metal)"
            ])
        
        map["REE"] = ("Reel", [
            "IV": "Type IV cassette (metal)",
            "II": "Type II cassette (chrome)",
            "I": "Type I cassette (ferricnormal)",
            "19": "19 cms",
            "9": "9.5 cms",
            "38": "38 cms",
            "76": "76 cms",
            "III": "Type III cassette (ferric chrome)"
            ])
        
        return map
    }()
}
