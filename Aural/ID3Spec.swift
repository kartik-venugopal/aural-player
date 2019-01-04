import Foundation
import AVFoundation

/*  
    Specification for the ID3 metadata format. Versions 2.3 and 2.4 are supported.
 
    See http://id3.org/id3v2.3.0 and http://id3.org/id3v2.4.0-frames
 */
class ID3Spec: MetadataSpec {
    
    // Mappings of format-specific keys to readable keys
    private static var map: [String: String] = initMap()
    private static var mapByID: [String: String] = initMapByID()
    
    static func readableKey(_ key: String) -> String? {
        return map[key]
    }
    
    static func readableKeyByID(_ id: String) -> String? {
        return mapByID[id]
    }
    
    static func initMapByID() -> [String: String] {
        
        var map: [String: String] = [String: String]()
        
        map[AVMetadataIdentifier.id3MetadataAlbumSortOrder.rawValue] = "Album Sort Order"
        
        map[AVMetadataIdentifier.id3MetadataAlbumTitle.rawValue] = "Album"
        
        map[AVMetadataIdentifier.id3MetadataAttachedPicture.rawValue] = "Attached Picture"
        
        map[AVMetadataIdentifier.id3MetadataAudioEncryption.rawValue] = "Audio Encryption"
        
        map[AVMetadataIdentifier.id3MetadataAudioSeekPointIndex.rawValue] = "Audio Seek Point Index"
        
        map[AVMetadataIdentifier.id3MetadataBand.rawValue] = "Band"
        
        map[AVMetadataIdentifier.id3MetadataBeatsPerMinute.rawValue] = "Beats Per Minute"
        
        map[AVMetadataIdentifier.id3MetadataComments.rawValue] = "Comments"
        
        map[AVMetadataIdentifier.id3MetadataCommercial.rawValue] = "Commercial"
        
        map[AVMetadataIdentifier.id3MetadataCommercialInformation.rawValue] = "Commercial Information"
        
        map[AVMetadataIdentifier.id3MetadataComposer.rawValue] = "Composer"
        
        map[AVMetadataIdentifier.id3MetadataConductor.rawValue] = "Conductor"
        
        map[AVMetadataIdentifier.id3MetadataContentGroupDescription.rawValue] = "Content Group Description"
        
        map[AVMetadataIdentifier.id3MetadataContentType.rawValue] = "Genre"
        
        map[AVMetadataIdentifier.id3MetadataCopyright.rawValue] = "Copyright"
        
        map[AVMetadataIdentifier.id3MetadataCopyrightInformation.rawValue] = "Copyright Information"
        
        map[AVMetadataIdentifier.id3MetadataDate.rawValue] = "Date"
        
        map[AVMetadataIdentifier.id3MetadataEncodedBy.rawValue] = "Encoded By"
        
        map[AVMetadataIdentifier.id3MetadataEncodedWith.rawValue] = "Encoded With"
        
        map[AVMetadataIdentifier.id3MetadataEncodingTime.rawValue] = "Encoding Time"
        
        map[AVMetadataIdentifier.id3MetadataEncryption.rawValue] = "Encryption"
        
        map[AVMetadataIdentifier.id3MetadataEqualization.rawValue] = "Equalization"
        
        map[AVMetadataIdentifier.id3MetadataEqualization2.rawValue] = "Equalization"
        
        map[AVMetadataIdentifier.id3MetadataEventTimingCodes.rawValue] = "Event Timing Codes"
        
        map[AVMetadataIdentifier.id3MetadataFileOwner.rawValue] = "File Owner"
        
        map[AVMetadataIdentifier.id3MetadataFileType.rawValue] = "File Type"
        
        map[AVMetadataIdentifier.id3MetadataGeneralEncapsulatedObject.rawValue] = "General Encapsulated Object"
        
        map[AVMetadataIdentifier.id3MetadataGroupIdentifier.rawValue] = "Group Identifier"
        
        map[AVMetadataIdentifier.id3MetadataInitialKey.rawValue] = "Initial Key"
        
        map[AVMetadataIdentifier.id3MetadataInternationalStandardRecordingCode.rawValue] = "International Standard Recording Code"
        
        map[AVMetadataIdentifier.id3MetadataInternetRadioStationName.rawValue] = "Internet Radio Station Name"
        
        map[AVMetadataIdentifier.id3MetadataInternetRadioStationOwner.rawValue] = "Internet Radio Station Owner"
        
        map[AVMetadataIdentifier.id3MetadataInvolvedPeopleList_v23.rawValue] = "Involved People List"
        
        map[AVMetadataIdentifier.id3MetadataInvolvedPeopleList_v24.rawValue] = "Involved People List"
        
        map[AVMetadataIdentifier.id3MetadataLanguage.rawValue] = "Language"
        
        map[AVMetadataIdentifier.id3MetadataLeadPerformer.rawValue] = "Lead Performer"
        
        map[AVMetadataIdentifier.id3MetadataLength.rawValue] = "Length"
        
        map[AVMetadataIdentifier.id3MetadataLink.rawValue] = "Link"
        
        map[AVMetadataIdentifier.id3MetadataLyricist.rawValue] = "Lyricist"
        
        map[AVMetadataIdentifier.id3MetadataMPEGLocationLookupTable.rawValue] = "MPEG Location Lookup Table"
        
        map[AVMetadataIdentifier.id3MetadataMediaType.rawValue] = "Media Type"
        
        map[AVMetadataIdentifier.id3MetadataModifiedBy.rawValue] = "Modified By"
        
        map[AVMetadataIdentifier.id3MetadataMood.rawValue] = "Mood"
        
        map[AVMetadataIdentifier.id3MetadataMusicCDIdentifier.rawValue] = "Music CD Identifier"
        
        map[AVMetadataIdentifier.id3MetadataMusicianCreditsList.rawValue] = "Musician Credits List"
        
        map[AVMetadataIdentifier.id3MetadataOfficialArtistWebpage.rawValue] = "Official Artist Webpage"
        
        map[AVMetadataIdentifier.id3MetadataOfficialAudioFileWebpage.rawValue] = "Official Audio File Webpage"
        
        map[AVMetadataIdentifier.id3MetadataOfficialAudioSourceWebpage.rawValue] = "Official Audio Source Webpage"
        
        map[AVMetadataIdentifier.id3MetadataOfficialInternetRadioStationHomepage.rawValue] = "Official Internet Radio Station Homepage"
        
        map[AVMetadataIdentifier.id3MetadataOfficialPublisherWebpage.rawValue] = "Official Publisher Webpage"
        
        map[AVMetadataIdentifier.id3MetadataOriginalAlbumTitle.rawValue] = "Album"
        
        map[AVMetadataIdentifier.id3MetadataOriginalArtist.rawValue] = "Artist"
        
        map[AVMetadataIdentifier.id3MetadataOriginalFilename.rawValue] = "Original Filename"
        
        map[AVMetadataIdentifier.id3MetadataOriginalLyricist.rawValue] = "Original Lyricist"
        
        map[AVMetadataIdentifier.id3MetadataOriginalReleaseTime.rawValue] = "Original Release Time"
        
        map[AVMetadataIdentifier.id3MetadataOriginalReleaseYear.rawValue] = "Original Release Year"
        
        map[AVMetadataIdentifier.id3MetadataOwnership.rawValue] = "Ownership"
        
        map[AVMetadataIdentifier.id3MetadataPartOfASet.rawValue] = "Disc#"
        
        map[AVMetadataIdentifier.id3MetadataPayment.rawValue] = "Payment"
        
        map[AVMetadataIdentifier.id3MetadataPerformerSortOrder.rawValue] = "Performer Sort Order"
        
        map[AVMetadataIdentifier.id3MetadataPlayCounter.rawValue] = "Play Counter"
        
        map[AVMetadataIdentifier.id3MetadataPlaylistDelay.rawValue] = "Playlist Delay"
        
        map[AVMetadataIdentifier.id3MetadataPopularimeter.rawValue] = "Popularimeter"
        
        map[AVMetadataIdentifier.id3MetadataPositionSynchronization.rawValue] = "Position Synchronization"
        
        map[AVMetadataIdentifier.id3MetadataPrivate.rawValue] = "Private"
        
        map[AVMetadataIdentifier.id3MetadataProducedNotice.rawValue] = "Produced Notice"
        
        map[AVMetadataIdentifier.id3MetadataPublisher.rawValue] = "Publisher"
        
        map[AVMetadataIdentifier.id3MetadataRecommendedBufferSize.rawValue] = "Recommended Buffer Size"
        
        map[AVMetadataIdentifier.id3MetadataRecordingDates.rawValue] = "Recording Dates"
        
        map[AVMetadataIdentifier.id3MetadataRecordingTime.rawValue] = "Recording Time"
        
        map[AVMetadataIdentifier.id3MetadataRelativeVolumeAdjustment.rawValue] = "Relative Volume Adjustment"
        
        map[AVMetadataIdentifier.id3MetadataRelativeVolumeAdjustment2.rawValue] = "Relative Volume Adjustment"
        
        map[AVMetadataIdentifier.id3MetadataReleaseTime.rawValue] = "Release Time"
        
        map[AVMetadataIdentifier.id3MetadataReverb.rawValue] = "Reverb"
        
        map[AVMetadataIdentifier.id3MetadataSeek.rawValue] = "Seek"
        
        map[AVMetadataIdentifier.id3MetadataSetSubtitle.rawValue] = "Set Subtitle"
        
        map[AVMetadataIdentifier.id3MetadataSignature.rawValue] = "Signature"
        
        map[AVMetadataIdentifier.id3MetadataSize.rawValue] = "Size"
        
        map[AVMetadataIdentifier.id3MetadataSubTitle.rawValue] = "Sub Title"
        
        map[AVMetadataIdentifier.id3MetadataSynchronizedLyric.rawValue] = "Synchronized Lyric"
        
        map[AVMetadataIdentifier.id3MetadataSynchronizedTempoCodes.rawValue] = "Synchronized Tempo Codes"
        
        map[AVMetadataIdentifier.id3MetadataTaggingTime.rawValue] = "Tagging Time"
        
        map[AVMetadataIdentifier.id3MetadataTermsOfUse.rawValue] = "Terms Of Use"
        
        map[AVMetadataIdentifier.id3MetadataTime.rawValue] = "Time"
        
        map[AVMetadataIdentifier.id3MetadataTitleDescription.rawValue] = "Title"
        
        map[AVMetadataIdentifier.id3MetadataTitleSortOrder.rawValue] = "Title Sort Order"
        
        map[AVMetadataIdentifier.id3MetadataTrackNumber.rawValue] = "Track#"
        
        map[AVMetadataIdentifier.id3MetadataUniqueFileIdentifier.rawValue] = "Unique File Identifier"
        
        map[AVMetadataIdentifier.id3MetadataUnsynchronizedLyric.rawValue] = "Lyrics"
        
        map[AVMetadataIdentifier.id3MetadataUserText.rawValue] = "User Text"
        
        map[AVMetadataIdentifier.id3MetadataUserURL.rawValue] = "User URL"
        
        map[AVMetadataIdentifier.id3MetadataYear.rawValue] = "Year"
        
        return map
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
        map[AVMetadataKey.id3MetadataKeyPrivate.rawValue] = "Private Frame"
        
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
}
