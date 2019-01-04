import Foundation
import AVFoundation

/*
    Specification for the iTunes metadata format.
 */
class ITunesSpec: MetadataSpec {
    
    // Mappings of format-specific keys to readable keys
    private static var mapByKey: [String: String] = initMapByKey()
    private static var mapByID: [String: String] = initMapByID()
    
    static func readableKey(_ key: String) -> String? {
        return mapByKey[key]
    }
    
    static func readableKeyByID(_ id: String) -> String? {
        return mapByID[id]
    }
    
    private static func initMapByID() -> [String: String] {
        
        var map: [String: String] = [:]
        
        map[AVMetadataIdentifier.iTunesMetadataAlbum.rawValue] = "Album"
        
        map[AVMetadataIdentifier.iTunesMetadataArtist.rawValue] = "Artist"
        
        map[AVMetadataIdentifier.iTunesMetadataUserComment.rawValue] = "User Comment"
        
        map[AVMetadataIdentifier.iTunesMetadataCoverArt.rawValue] = "Cover Art"
        
        map[AVMetadataIdentifier.iTunesMetadataCopyright.rawValue] = "Copyright"
        
        map[AVMetadataIdentifier.iTunesMetadataReleaseDate.rawValue] = "Release Date"
        
        map[AVMetadataIdentifier.iTunesMetadataEncodedBy.rawValue] = "Encoded By"
        
        map[AVMetadataIdentifier.iTunesMetadataPredefinedGenre.rawValue] = "Predefined Genre"
        
        map[AVMetadataIdentifier.iTunesMetadataUserGenre.rawValue] = "User Genre"
        
        map[AVMetadataIdentifier.iTunesMetadataSongName.rawValue] = "Song Name"
        
        map[AVMetadataIdentifier.iTunesMetadataTrackSubTitle.rawValue] = "Track Sub Title"
        
        map[AVMetadataIdentifier.iTunesMetadataEncodingTool.rawValue] = "Encoding Tool"
        
        map[AVMetadataIdentifier.iTunesMetadataComposer.rawValue] = "Composer"
        
        map[AVMetadataIdentifier.iTunesMetadataAlbumArtist.rawValue] = "Album Artist"
        
        map[AVMetadataIdentifier.iTunesMetadataAccountKind.rawValue] = "Account Kind"
        
        map[AVMetadataIdentifier.iTunesMetadataAppleID.rawValue] = "Apple ID"
        
        map[AVMetadataIdentifier.iTunesMetadataArtistID.rawValue] = "Artist ID"
        
        map[AVMetadataIdentifier.iTunesMetadataSongID.rawValue] = "Song ID"
        
        map[AVMetadataIdentifier.iTunesMetadataDiscCompilation.rawValue] = "Disc Compilation"
        
        map[AVMetadataIdentifier.iTunesMetadataDiscNumber.rawValue] = "Disc Number"
        
        map[AVMetadataIdentifier.iTunesMetadataGenreID.rawValue] = "Genre ID"
        
        map[AVMetadataIdentifier.iTunesMetadataGrouping.rawValue] = "Grouping"
        
        map[AVMetadataIdentifier.iTunesMetadataPlaylistID.rawValue] = "Playlist ID"
        
        map[AVMetadataIdentifier.iTunesMetadataContentRating.rawValue] = "Content Rating"
        
        map[AVMetadataIdentifier.iTunesMetadataBeatsPerMin.rawValue] = "Beats Per Min"
        
        map[AVMetadataIdentifier.iTunesMetadataTrackNumber.rawValue] = "Track Number"
        
        map[AVMetadataIdentifier.iTunesMetadataArtDirector.rawValue] = "Art Director"
        
        map[AVMetadataIdentifier.iTunesMetadataArranger.rawValue] = "Arranger"
        
        map[AVMetadataIdentifier.iTunesMetadataAuthor.rawValue] = "Author"
        
        map[AVMetadataIdentifier.iTunesMetadataLyrics.rawValue] = "Lyrics"
        
        map[AVMetadataIdentifier.iTunesMetadataAcknowledgement.rawValue] = "Acknowledgement"
        
        map[AVMetadataIdentifier.iTunesMetadataConductor.rawValue] = "Conductor"
        
        map[AVMetadataIdentifier.iTunesMetadataDescription.rawValue] = "Description"
        
        map[AVMetadataIdentifier.iTunesMetadataDirector.rawValue] = "Director"
        
        map[AVMetadataIdentifier.iTunesMetadataEQ.rawValue] = "EQ"
        
        map[AVMetadataIdentifier.iTunesMetadataLinerNotes.rawValue] = "Liner Notes"
        
        map[AVMetadataIdentifier.iTunesMetadataRecordCompany.rawValue] = "Record Company"
        
        map[AVMetadataIdentifier.iTunesMetadataOriginalArtist.rawValue] = "Original Artist"
        
        map[AVMetadataIdentifier.iTunesMetadataPhonogramRights.rawValue] = "Phonogram Rights"
        
        map[AVMetadataIdentifier.iTunesMetadataProducer.rawValue] = "Producer"
        
        map[AVMetadataIdentifier.iTunesMetadataPerformer.rawValue] = "Performer"
        
        map[AVMetadataIdentifier.iTunesMetadataPublisher.rawValue] = "Publisher"
        
        map[AVMetadataIdentifier.iTunesMetadataSoundEngineer.rawValue] = "Sound Engineer"
        
        map[AVMetadataIdentifier.iTunesMetadataSoloist.rawValue] = "Soloist"
        
        map[AVMetadataIdentifier.iTunesMetadataCredits.rawValue] = "Credits"
        
        map[AVMetadataIdentifier.iTunesMetadataThanks.rawValue] = "Thanks"
        
        map[AVMetadataIdentifier.iTunesMetadataOnlineExtras.rawValue] = "Online Extras"
        
        map[AVMetadataIdentifier.iTunesMetadataExecProducer.rawValue] = "Exec Producer"
        
        return map
    }
    
    private static func initMapByKey() -> [String: String] {
        
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
        map[AVMetadataKey.iTunesMetadataKeyDiscCompilation.rawValue] = "Disc Compilation"
        
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
    }
}

class ITunesLongFormSpec: MetadataSpec {
    
    // Mappings of format-specific keys to readable keys
    private static var mapByKey: [String: String] = initMapByKey()
    private static var mapByID: [String: String] = initMapByID()
    
    static func readableKey(_ key: String) -> String? {
        return mapByKey[key]
    }
    
    static func readableKeyByID(_ id: String) -> String? {
        return mapByID[id]
    }
    
    private static func initMapByID() -> [String: String] {
        
        var map: [String: String] = [:]
        
        map["com.apple.iTunes;iTunSMPB"] = "Album"
        
        return map
    }
    
    private static func initMapByKey() -> [String: String] {
        
        return [:]
    }
}
