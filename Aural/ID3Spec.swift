import Foundation
import AVFoundation

/*  
    Specification for the ID3 metadata format. Versions 2.3 and 2.4 are supported.
 
    See http://id3.org/id3v2.3.0 and http://id3.org/id3v2.4.0-frames
 */
class ID3Spec: MetadataSpec {
    
    // Mappings of format-specific keys to readable keys
    private static var map: [String: String] = initMap()
    
    static func readableKey(_ key: String) -> String? {
        return map[key]
    }
    
    private static func initMap() -> [String: String] {
        
        var map: [String: String] = [String: String]()
        
        // AENC
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyAudioEncryption)] = "Audio Encryption"
        
        // APIC
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyAttachedPicture)] = "Attached Picture"
        
        // ASPI
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyAudioSeekPointIndex)] = "Audio Seek Point Index"
        
        // COMM
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyComments)] = "Comments"
        
        // COMR
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyCommerical)] = "Commercial Frame"
        
        // ENCR
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyEncryption)] = "Encryption Method Registration"
        
        // EQU2
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyEqualization2)] = "Equalization"
        
        // EQUA
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyEqualization)] = "Equalization"
        
        // ETCO
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyEventTimingCodes)] = "Event Timing Codes"
        
        // GEOB
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyGeneralEncapsulatedObject)] = "General Encapsulated Object"
        
        // GRID
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyGroupIdentifier)] = "Group Identification Registration"
        
        // IPLS
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyInvolvedPeopleList_v23)] = "Involved People List"
        
        // LINK
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyLink)] = "Linked Information"
        
        // MCDI
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyMusicCDIdentifier)] = "Music CD Identifier"
        
        // MLLT
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyMPEGLocationLookupTable)] = "MPEG Location Lookup Table"
        
        // OWNE
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyOwnership)] = "Ownership Frame"
        
        // PCNT
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyPlayCounter)] = "Play Counter"
        
        // POPM
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyPopularimeter)] = "Popularimeter"
        
        // POSS
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyPositionSynchronization)] = "Position Synchronisation Frame"
        
        // PRIV
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyPrivate)] = "Private Frame"
        
        // RBUF
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyRecommendedBufferSize)] = "Recommended Buffer Size"
        
        // RVA2
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyRelativeVolumeAdjustment2)] = "Relative Volume Adjustment"
        
        // RVAD
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyRelativeVolumeAdjustment)] = "Relative Volume Adjustment"
        
        // RVRB
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyReverb)] = "Reverb"
        
        // SEEK
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeySeek)] = "Seek"
        
        // SIGN
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeySignature)] = "Signature"
        
        // SYLT
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeySynchronizedLyric)] = "Synchronized Lyric"
        
        // SYTC
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeySynchronizedTempoCodes)] = "Synchronized Tempo Codes"
        
        // TALB
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyAlbumTitle)] = "Album Name"
        
        // TBPM
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyBeatsPerMinute)] = "BPM (Beats Per Minute)"
        
        // TCOM
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyComposer)] = "Composer"
        
        // TCON
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyContentType)] = "Content Type"
        
        // TCOP
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyCopyright)] = "Copyright Message"
        
        // TDAT
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyDate)] = "Date"
        
        // TDEN
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyEncodingTime)] = "Encoding Time"
        
        // TDLY
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyPlaylistDelay)] = "Playlist Delay"
        
        // TDOR
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyOriginalReleaseTime)] = "Original Release Time"
        
        // TDRC
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyRecordingTime)] = "Recording Time"
        
        // TDRL
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyReleaseTime)] = "Release Time"
        
        // TDTG
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyTaggingTime)] = "Tagging Time"
        
        // TENC
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyEncodedBy)] = "Encoded By"
        
        // TEXT
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyLyricist)] = "Lyricist"
        
        // TFLT
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyFileType)] = "File Type"
        
        // TIME
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyTime)] = "Time"
        
        // TIPL
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyInvolvedPeopleList_v24)] = "Involved People List"
        
        // TIT1
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyContentGroupDescription)] = "Content Group Description"
        
        // TIT2
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyTitleDescription)] = "Title"
        
        // TIT3
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeySubTitle)] = "Subtitle"
        
        // TKEY
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyInitialKey)] = "Initial Key"
        
        // TLAN
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyLanguage)] = "Language(s)"
        
        // TLEN
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyLength)] = "Length"
        
        // TMCL
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyMusicianCreditsList)] = "Musician Credits List"
        
        // TMED
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyMediaType)] = "Media Type"
        
        // TMOO
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyMood)] = "Mood"
        
        // TOAL
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyOriginalAlbumTitle)] = "Original Album Title"
        
        // TOFN
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyOriginalFilename)] = "Original Filename"
        
        // TOLY
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyOriginalLyricist)] = "Original Lyricist(s)"
        
        // TOPE
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyOriginalArtist)] = "Original Artist(s)"
        
        // TORY
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyOriginalReleaseYear)] = "Original Release Year"
        
        // TOWN
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyFileOwner)] = "File Owner"
        
        // TPE1
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyLeadPerformer)] = "Lead Performer(s)"
        
        // TPE2
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyBand)] = "Band"
        
        // TPE3
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyConductor)] = "Conductor"
        
        // TPE4
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyModifiedBy)] = "Interpreted, Remixed, Or Otherwise Modified By"
        
        // TPOS
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyPartOfASet)] = "Part Of A Set"
        
        // TPRO
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyProducedNotice)] = "Produced Notice"
        
        // TPUB
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyPublisher)] = "Publisher"
        
        // TRCK
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyTrackNumber)] = "Track Number"
        
        // TRDA
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyRecordingDates)] = "Recording Dates"
        
        // TRSN
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyInternetRadioStationName)] = "Internet Radio Station Name"
        
        // TRSO
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyInternetRadioStationOwner)] = "Internet Radio Station Owner"
        
        // TSIZ
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeySize)] = "Size"
        
        // TSOA
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyAlbumSortOrder)] = "Album Sort Order"
        
        // TSOP
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyPerformerSortOrder)] = "Performer Sort Order"
        
        // TSOT
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyTitleSortOrder)] = "Title Sort Order"
        
        // TSRC
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyInternationalStandardRecordingCode)] = "ISRC (International Standard Recording Code)"
        
        // TSSE
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyEncodedWith)] = "Encoding Software / Hardware"
        
        // TSST
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeySetSubtitle)] = "Set Subtitle"
        
        // TXXX
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyUserText)] = "User Defined Text Information Frame"
        
        // TYER
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyYear)] = "Year"
        
        // UFID
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyUniqueFileIdentifier)] = "Unique File Identifier"
        
        // USER
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyTermsOfUse)] = "Terms Of Use"
        
        // USLT
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyUnsynchronizedLyric)] = "Unsychronized Lyric"
        
        // WCOM
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyCommercialInformation)] = "Commercial Information"
        
        // WCOP
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyCopyrightInformation)] = "Copyright Information"
        
        // WOAF
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyOfficialAudioFileWebpage)] = "Official Audio File Webpage"
        
        // WOAR
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyOfficialArtistWebpage)] = "Official Artist Webpage"
        
        // WOAS
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyOfficialAudioSourceWebpage)] = "Official Audio Source Webpage"
        
        // WORS
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyOfficialInternetRadioStationHomepage)] = "Official Internet Radio Station Homepage"
        
        // WPAY
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyPayment)] = "Payment"
        
        // WPUB
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyOfficialPublisherWebpage)] = "Publishers Official Webpage"
        
        // WXXX
        map[convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyUserURL)] = "User Defined URL Link Frame"
        
        return map
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMetadataKey(_ input: AVMetadataKey) -> String {
	return input.rawValue
}
