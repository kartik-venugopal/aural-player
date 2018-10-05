import Foundation
import AVFoundation

/*
    Specification for the iTunes metadata format.
 */
class ITunesSpec: MetadataSpec {
    
    // Mappings of format-specific keys to readable keys
    private static var map: [String: String] = initMap()
    
    static func readableKey(_ key: String) -> String? {
        return map[key]
    }
    
    private static func initMap() -> [String: String] {
        
        var map: [String: String] = [String: String]()
        
        // @alb
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyAlbum)] = "Album"
        
        // @ART
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyArtist)] = "Artist"
        
        // @cmt
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyUserComment)] = "User Comment"
        
        // covr
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyCoverArt)] = "Cover Art"
        
        // cprt
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyCopyright)] = "Copyright"
        
        // @day
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyReleaseDate)] = "Release Date"
        
        // @enc
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyEncodedBy)] = "Encoded By"
        
        // gnre
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyPredefinedGenre)] = "Predefined Genre"
        
        // @gen
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyUserGenre)] = "User Genre"
        
        // @nam
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeySongName)] = "Song Name"
        
        // @st3
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyTrackSubTitle)] = "Track Sub Title"
        
        // @too
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyEncodingTool)] = "Encoding Tool"
        
        // @wrt
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyComposer)] = "Composer"
        
        // aART
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyAlbumArtist)] = "Album Artist"
        
        // akID
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyAccountKind)] = "Account Kind"
        
        // apID
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyAppleID)] = "Apple ID"
        
        // atID
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyArtistID)] = "Artist ID"
        
        // cnID
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeySongID)] = "Song ID"
        
        // cpil
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyDiscCompilation)] = "Disc Compilation"
        
        // disk
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyDiscNumber)] = "Disc Number"
        
        // geID
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyGenreID)] = "Genre ID"
        
        // grup
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyGrouping)] = "Grouping"
        
        // plID
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyPlaylistID)] = "Playlist ID"
        
        // rtng
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyContentRating)] = "Content Rating"
        
        // tmpo
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyBeatsPerMin)] = "Beats Per Min"
        
        // trkn
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyTrackNumber)] = "Track Number"
        
        // @ard
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyArtDirector)] = "Art Director"
        
        // @arg
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyArranger)] = "Arranger"
        
        // @aut
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyAuthor)] = "Author"
        
        // @lyr
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyLyrics)] = "Lyrics"
        
        // @cak
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyAcknowledgement)] = "Acknowledgement"
        
        // @con
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyConductor)] = "Conductor"
        
        // @des
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyDescription)] = "Description"
        
        // @dir
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyDirector)] = "Director"
        
        // @equ
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyEQ)] = "EQ"
        
        // @lnt
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyLinerNotes)] = "Liner Notes"
        
        // @mak
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyRecordCompany)] = "Record Company"
        
        // @ope
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyOriginalArtist)] = "Original Artist"
        
        // @phg
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyPhonogramRights)] = "Phonogram Rights"
        
        // @prd
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyProducer)] = "Producer"
        
        // @prf
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyPerformer)] = "Performer"
        
        // @pub
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyPublisher)] = "Publisher"
        
        // @sne
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeySoundEngineer)] = "Sound Engineer"
        
        // @sol
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeySoloist)] = "Soloist"
        
        // @src
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyCredits)] = "Credits"
        
        // @thx
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyThanks)] = "Thanks"
        
        // @url
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyOnlineExtras)] = "Online Extras"
        
        // @xpd
        map[convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyExecProducer)] = "Exec Producer"
        
        return map
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMetadataKey(_ input: AVMetadataKey) -> String {
	return input.rawValue
}
