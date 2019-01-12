import AVFoundation

/*
 Specification for the ID3 metadata format. Versions 2.0 2.3 and 2.4 are supported.
 
 TODO: V2: http://id3.org/id3v2-00
 
 TODO: Table of contents and Chapter support (CTOC and CHAP)
 
 See http://id3.org/id3v2.3.0 and http://id3.org/id3v2.4.0-frames
 */

fileprivate let id3KeySpace: String = AVMetadataKeySpace.id3.rawValue

struct ID3_V1Spec {
    
    static let key_title = String(format: "%@/%@", id3KeySpace, "Title")
    static let key_artist = String(format: "%@/%@", id3KeySpace, "Artist")
    static let key_album = String(format: "%@/%@", id3KeySpace, "Album")
    static let key_genre = String(format: "%@/%@", id3KeySpace, "Genre")
    
    static let key_trackNumber = String(format: "%@/%@", id3KeySpace, "Album track")
    
    static let essentialFieldKeys: [String] = [key_title, key_artist, key_album, key_genre, key_trackNumber]
    
    static let genericFields: [String: String] = ["Year": "Year", "Comment": "Comment"]
}

struct ID3_V22Spec {
    
    static let key_duration: String = String(format: "%@/%@", id3KeySpace, "TLE")
    
    static let key_title = String(format: "%@/%@", id3KeySpace, "TT2")
    static let key_artist = String(format: "%@/%@", id3KeySpace, "TP1")
    static let key_band = String(format: "%@/%@", id3KeySpace, "TP2")
    static let key_album = String(format: "%@/%@", id3KeySpace, "TAL")
    static let key_genre = String(format: "%@/%@", id3KeySpace, "TCO")
    
    static let key_discNumber = String(format: "%@/%@", id3KeySpace, "TPA")
    static let key_trackNumber = String(format: "%@/%@", id3KeySpace, "TRK")
    
    static let key_lyrics = String(format: "%@/%@", id3KeySpace, "ULT")
    static let key_syncLyrics = String(format: "%@/%@", id3KeySpace, "SLT")
    
    static let key_art: String = String(format: "%@/%@", id3KeySpace, "PIC")
    
    static let key_language: String = "TLA"
    static let key_playCounter: String = "CNT"
    static let replaceableKeyFields: [String] = ["TXX", "COM", "WXX"]
    static let key_GEO: String = "GEO"
    static let key_compilation: String = "TCP"
    static let key_UFI: String = "UFI"
    
    static let essentialFieldKeys: [String] = [key_duration, key_title, key_artist, key_album, key_genre, key_discNumber, key_trackNumber, key_lyrics, key_syncLyrics, key_art]
    
    static let genericFields: [String: String] = {
        
        var map: [String: String] = [:]
        
        /*
         
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
        map["TBP"] = "BPM (Beats Per Minute)"
        map["TCM"] = "Composer"
        map["TCP"] = "Part of a Compilation?"
        map["TCR"] = "Copyright"
        map["TDA"] = "Date"
        map["TDY"] = "Playlist Delay"
        map["TOR"] = "Original Release Time"
        map["TEN"] = "Encoded By"
        map["TXT"] = "Lyricist"
        map["TFT"] = "File Type"
        map["TIM"] = "Time"
        map["TT1"] = "Grouping"
        map["TT3"] = "Subtitle"
        map["TKE"] = "Initial Key"
        map["TLA"] = "Language(s)"
        map["TMT"] = "Media Type"
        map["TOT"] = "Original Album Title"
        map["TOF"] = "Original Filename"
        map["TOL"] = "Original Lyricist(s)"
        map["TOA"] = "Original Artist"
        map["TOR"] = "Original Release Year"
        map["TP2"] = "Band"
        map["TP3"] = "Conductor"
        map["TP4"] = "Interpreted, Remixed, Or Otherwise Modified By"
        map["TPB"] = "Publisher"
        map["TRD"] = "Recording Dates"
        map["TSI"] = "Size"
        map["TRC"] = "ISRC (International Standard Recording Code)"
        map["TSS"] = "Encoding Software / Hardware"
        
        map["TS2"] = "Album Artist Sort Order"
        map["TSA"] = "Album Sort Order"
        map["TSC"] = "Composer Sort Order"
        map["TSP"] = "Performer Sort Order"
        map["TST"] = "Title Sort Order"
        
        // TODO: Use extra attributes to elaborate on TXXX fields (e.g. ALBUMARTIST)
        map["TXX"] = "User Defined Text Information Frame"
        
        map["TYE"] = "Year"
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

struct ID3_V24Spec {
    
    static let key_duration: String = String(format: "%@/%@", id3KeySpace, AVMetadataKey.id3MetadataKeyLength.rawValue)
    
    static let key_title = String(format: "%@/%@", id3KeySpace, AVMetadataKey.id3MetadataKeyTitleDescription.rawValue)
    static let key_artist = String(format: "%@/%@", id3KeySpace, AVMetadataKey.id3MetadataKeyLeadPerformer.rawValue)
    static let key_band = String(format: "%@/%@", id3KeySpace, AVMetadataKey.id3MetadataKeyBand.rawValue)
    static let key_album = String(format: "%@/%@", id3KeySpace, AVMetadataKey.id3MetadataKeyAlbumTitle.rawValue)
    static let key_genre = String(format: "%@/%@", id3KeySpace, AVMetadataKey.id3MetadataKeyContentType.rawValue)
    
    static let key_discNumber = String(format: "%@/%@", id3KeySpace, AVMetadataKey.id3MetadataKeyPartOfASet.rawValue)
    static let key_trackNumber = String(format: "%@/%@", id3KeySpace, AVMetadataKey.id3MetadataKeyTrackNumber.rawValue)
    
    static let key_lyrics = String(format: "%@/%@", id3KeySpace, AVMetadataKey.id3MetadataKeyUnsynchronizedLyric.rawValue)
    static let key_syncLyrics = String(format: "%@/%@", id3KeySpace, AVMetadataKey.id3MetadataKeySynchronizedLyric.rawValue)
    
    static let key_art: String = String(format: "%@/%@", id3KeySpace, AVMetadataKey.id3MetadataKeyAttachedPicture.rawValue)
    static let id_art: AVMetadataIdentifier = AVMetadataIdentifier.commonIdentifierArtwork
    
    static let key_GEOB: String = AVMetadataKey.id3MetadataKeyGeneralEncapsulatedObject.rawValue
    static let key_playCounter: String = AVMetadataKey.id3MetadataKeyPlayCounter.rawValue
    
    static let replaceableKeyFields: [String] = [AVMetadataKey.id3MetadataKeyUserText.rawValue, AVMetadataKey.id3MetadataKeyComments.rawValue, AVMetadataKey.id3MetadataKeyUserURL.rawValue]
    
    static let key_language: String = AVMetadataKey.id3MetadataKeyLanguage.rawValue
    static let key_compilation: String = "TCMP"
    
    static let key_UFID: String = "UFID"
    static let key_termsOfUse: String = "USER"
    
    static let key_private: String = AVMetadataKey.id3MetadataKeyPrivate.rawValue
    
    static let essentialFieldKeys: [String] = [key_duration, key_title, key_artist, key_album, key_genre, key_discNumber, key_trackNumber, key_lyrics, key_syncLyrics, key_art]
    
    static let genericFields: [String: String] = {
        
        var map: [String: String] = [:]
        
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
        map[AVMetadataKey.id3MetadataKeyCopyright.rawValue] = "Copyright"
        
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
        map[AVMetadataKey.id3MetadataKeyContentGroupDescription.rawValue] = "Grouping"
        
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
        map[AVMetadataKey.id3MetadataKeyOriginalArtist.rawValue] = "Original Artist"
        
        // TORY
        map[AVMetadataKey.id3MetadataKeyOriginalReleaseYear.rawValue] = "Original Release Year"
        
        // TOWN
        map[AVMetadataKey.id3MetadataKeyFileOwner.rawValue] = "File Owner"
        
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
        
        map["TCMP"] = "Part of a Compilation?"
        
        return map
    }()
}
