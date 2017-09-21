import Foundation
import AVFoundation

// TODO: Add 2.4.0 spec and older 2.00 spec
// http://id3.org/id3v2.4.0-frames
class ID3Spec: MetadataSpec {
    
    private static var map: [String: String] = initMap()
    
    static func readableKey(_ key: String) -> String? {
        return map[key]
    }
    
    private static func initMap() -> [String: String] {
        
        var map: [String: String] = [String: String]()
        
        // AENC
        map[AVMetadataID3MetadataKeyAudioEncryption] = "Audio Encryption"
        
        // APIC
        map[AVMetadataID3MetadataKeyAttachedPicture] = "Attached Picture"
        
        // ASPI
        map[AVMetadataID3MetadataKeyAudioSeekPointIndex] = "Audio Seek Point Index"
        
        // COMM
        map[AVMetadataID3MetadataKeyComments] = "Comments"
        
        // COMR
        map[AVMetadataID3MetadataKeyCommerical] = "Commercial Frame"
        
        // ENCR
        map[AVMetadataID3MetadataKeyEncryption] = "Encryption Method Registration"
        
        // EQU2
        map[AVMetadataID3MetadataKeyEqualization2] = "Equalization"
        
        // EQUA
        map[AVMetadataID3MetadataKeyEqualization] = "Equalization"
        
        // ETCO
        map[AVMetadataID3MetadataKeyEventTimingCodes] = "Event Timing Codes"
        
        // GEOB
        map[AVMetadataID3MetadataKeyGeneralEncapsulatedObject] = "General Encapsulated Object"
        
        // GRID
        map[AVMetadataID3MetadataKeyGroupIdentifier] = "Group Identification Registration"
        
        // IPLS
        map[AVMetadataID3MetadataKeyInvolvedPeopleList_v23] = "Involved People List"
        
        // LINK
        map[AVMetadataID3MetadataKeyLink] = "Linked Information"
        
        // MCDI
        map[AVMetadataID3MetadataKeyMusicCDIdentifier] = "Music CD Identifier"
        
        // MLLT
        map[AVMetadataID3MetadataKeyMPEGLocationLookupTable] = "MPEG Location Lookup Table"
        
        // OWNE
        map[AVMetadataID3MetadataKeyOwnership] = "Ownership Frame"
        
        // PCNT
        map[AVMetadataID3MetadataKeyPlayCounter] = "Play Counter"
        
        // POPM
        map[AVMetadataID3MetadataKeyPopularimeter] = "Popularimeter"
        
        // POSS
        map[AVMetadataID3MetadataKeyPositionSynchronization] = "Position Synchronisation Frame"
        
        // PRIV
        map[AVMetadataID3MetadataKeyPrivate] = "Private Frame"
        
        // RBUF
        map[AVMetadataID3MetadataKeyRecommendedBufferSize] = "Recommended Buffer Size"
        
        // RVA2
        map[AVMetadataID3MetadataKeyRelativeVolumeAdjustment2] = "Relative Volume Adjustment"
        
        // RVAD
        map[AVMetadataID3MetadataKeyRelativeVolumeAdjustment] = "Relative Volume Adjustment"
        
        // RVRB
        map[AVMetadataID3MetadataKeyReverb] = "Reverb"
        
        // SEEK
        map[AVMetadataID3MetadataKeySeek] = "Seek"
        
        // SIGN
        map[AVMetadataID3MetadataKeySignature] = "Signature"
        
        // SYLT
        map[AVMetadataID3MetadataKeySynchronizedLyric] = "Synchronized Lyric"
        
        // SYTC
        map[AVMetadataID3MetadataKeySynchronizedTempoCodes] = "Synchronized Tempo Codes"
        
        // TALB
        map[AVMetadataID3MetadataKeyAlbumTitle] = "Album Name"
        
        // TBPM
        map[AVMetadataID3MetadataKeyBeatsPerMinute] = "BPM (Beats Per Minute)"
        
        // TCOM
        map[AVMetadataID3MetadataKeyComposer] = "Composer"
        
        // TCON
        map[AVMetadataID3MetadataKeyContentType] = "Content Type"
        
        // TCOP
        map[AVMetadataID3MetadataKeyCopyright] = "Copyright Message"
        
        // TDAT
        map[AVMetadataID3MetadataKeyDate] = "Date"
        
        // TDEN
        map[AVMetadataID3MetadataKeyEncodingTime] = "Encoding Time"
        
        // TDLY
        map[AVMetadataID3MetadataKeyPlaylistDelay] = "Playlist Delay"
        
        // TDOR
        map[AVMetadataID3MetadataKeyOriginalReleaseTime] = "Original Release Time"
        
        // TDRC
        map[AVMetadataID3MetadataKeyRecordingTime] = "Recording Time"
        
        // TDRL
        map[AVMetadataID3MetadataKeyReleaseTime] = "Release Time"
        
        // TDTG
        map[AVMetadataID3MetadataKeyTaggingTime] = "Tagging Time"
        
        // TENC
        map[AVMetadataID3MetadataKeyEncodedBy] = "Encoded By"
        
        // TEXT
        map[AVMetadataID3MetadataKeyLyricist] = "Lyricist"
        
        // TFLT
        map[AVMetadataID3MetadataKeyFileType] = "File Type"
        
        // TIME
        map[AVMetadataID3MetadataKeyTime] = "Time"
        
        // TIPL
        map[AVMetadataID3MetadataKeyInvolvedPeopleList_v24] = "Involved People List"
        
        // TIT1
        map[AVMetadataID3MetadataKeyContentGroupDescription] = "Content Group Description"
        
        // TIT2
        map[AVMetadataID3MetadataKeyTitleDescription] = "Title"
        
        // TIT3
        map[AVMetadataID3MetadataKeySubTitle] = "Subtitle"
        
        // TKEY
        map[AVMetadataID3MetadataKeyInitialKey] = "Initial Key"
        
        // TLAN
        map[AVMetadataID3MetadataKeyLanguage] = "Language(s)"
        
        // TLEN
        map[AVMetadataID3MetadataKeyLength] = "Length"
        
        // TMCL
        map[AVMetadataID3MetadataKeyMusicianCreditsList] = "Musician Credits List"
        
        // TMED
        map[AVMetadataID3MetadataKeyMediaType] = "Media Type"
        
        // TMOO
        map[AVMetadataID3MetadataKeyMood] = "Mood"
        
        // TOAL
        map[AVMetadataID3MetadataKeyOriginalAlbumTitle] = "Original Album Title"
        
        // TOFN
        map[AVMetadataID3MetadataKeyOriginalFilename] = "Original Filename"
        
        // TOLY
        map[AVMetadataID3MetadataKeyOriginalLyricist] = "Original Lyricist(s)"
        
        // TOPE
        map[AVMetadataID3MetadataKeyOriginalArtist] = "Original Artist(s)"
        
        // TORY
        map[AVMetadataID3MetadataKeyOriginalReleaseYear] = "Original Release Year"
        
        // TOWN
        map[AVMetadataID3MetadataKeyFileOwner] = "File Owner"
        
        // TPE1
        map[AVMetadataID3MetadataKeyLeadPerformer] = "Lead Performer(s)"
        
        // TPE2
        map[AVMetadataID3MetadataKeyBand] = "Band"
        
        // TPE3
        map[AVMetadataID3MetadataKeyConductor] = "Conductor"
        
        // TPE4
        map[AVMetadataID3MetadataKeyModifiedBy] = "Interpreted, Remixed, Or Otherwise Modified By"
        
        // TPOS
        map[AVMetadataID3MetadataKeyPartOfASet] = "Part Of A Set"
        
        // TPRO
        map[AVMetadataID3MetadataKeyProducedNotice] = "Produced Notice"
        
        // TPUB
        map[AVMetadataID3MetadataKeyPublisher] = "Publisher"
        
        // TRCK
        map[AVMetadataID3MetadataKeyTrackNumber] = "Track Number"
        
        // TRDA
        map[AVMetadataID3MetadataKeyRecordingDates] = "Recording Dates"
        
        // TRSN
        map[AVMetadataID3MetadataKeyInternetRadioStationName] = "Internet Radio Station Name"
        
        // TRSO
        map[AVMetadataID3MetadataKeyInternetRadioStationOwner] = "Internet Radio Station Owner"
        
        // TSIZ
        map[AVMetadataID3MetadataKeySize] = "Size"
        
        // TSOA
        map[AVMetadataID3MetadataKeyAlbumSortOrder] = "Album Sort Order"
        
        // TSOP
        map[AVMetadataID3MetadataKeyPerformerSortOrder] = "Performer Sort Order"
        
        // TSOT
        map[AVMetadataID3MetadataKeyTitleSortOrder] = "Title Sort Order"
        
        // TSRC
        map[AVMetadataID3MetadataKeyInternationalStandardRecordingCode] = "ISRC (International Standard Recording Code)"
        
        // TSSE
        map[AVMetadataID3MetadataKeyEncodedWith] = "Encoding Software / Hardware"
        
        // TSST
        map[AVMetadataID3MetadataKeySetSubtitle] = "Set Subtitle"
        
        // TXXX
        map[AVMetadataID3MetadataKeyUserText] = "User Defined Text Information Frame"
        
        // TYER
        map[AVMetadataID3MetadataKeyYear] = "Year"
        
        // UFID
        map[AVMetadataID3MetadataKeyUniqueFileIdentifier] = "Unique File Identifier"
        
        // USER
        map[AVMetadataID3MetadataKeyTermsOfUse] = "Terms Of Use"
        
        // USLT
        map[AVMetadataID3MetadataKeyUnsynchronizedLyric] = "Unsychronized Lyric"
        
        // WCOM
        map[AVMetadataID3MetadataKeyCommercialInformation] = "Commercial Information"
        
        // WCOP
        map[AVMetadataID3MetadataKeyCopyrightInformation] = "Copyright Information"
        
        // WOAF
        map[AVMetadataID3MetadataKeyOfficialAudioFileWebpage] = "Official Audio File Webpage"
        
        // WOAR
        map[AVMetadataID3MetadataKeyOfficialArtistWebpage] = "Official Artist Webpage"
        
        // WOAS
        map[AVMetadataID3MetadataKeyOfficialAudioSourceWebpage] = "Official Audio Source Webpage"
        
        // WORS
        map[AVMetadataID3MetadataKeyOfficialInternetRadioStationHomepage] = "Official Internet Radio Station Homepage"
        
        // WPAY
        map[AVMetadataID3MetadataKeyPayment] = "Payment"
        
        // WPUB
        map[AVMetadataID3MetadataKeyOfficialPublisherWebpage] = "Publishers Official Webpage"
        
        // WXXX
        map[AVMetadataID3MetadataKeyUserURL] = "User Defined URL Link Frame"
        
        return map
    }
}
