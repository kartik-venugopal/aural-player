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
        map[AVMetadataiTunesMetadataKeyAlbum] = "Album"
        
        // @ART
        map[AVMetadataiTunesMetadataKeyArtist] = "Artist"
        
        // @cmt
        map[AVMetadataiTunesMetadataKeyUserComment] = "User Comment"
        
        // covr
        map[AVMetadataiTunesMetadataKeyCoverArt] = "Cover Art"
        
        // cprt
        map[AVMetadataiTunesMetadataKeyCopyright] = "Copyright"
        
        // @day
        map[AVMetadataiTunesMetadataKeyReleaseDate] = "Release Date"
        
        // @enc
        map[AVMetadataiTunesMetadataKeyEncodedBy] = "Encoded By"
        
        // gnre
        map[AVMetadataiTunesMetadataKeyPredefinedGenre] = "Predefined Genre"
        
        // @gen
        map[AVMetadataiTunesMetadataKeyUserGenre] = "User Genre"
        
        // @nam
        map[AVMetadataiTunesMetadataKeySongName] = "Song Name"
        
        // @st3
        map[AVMetadataiTunesMetadataKeyTrackSubTitle] = "Track Sub Title"
        
        // @too
        map[AVMetadataiTunesMetadataKeyEncodingTool] = "Encoding Tool"
        
        // @wrt
        map[AVMetadataiTunesMetadataKeyComposer] = "Composer"
        
        // aART
        map[AVMetadataiTunesMetadataKeyAlbumArtist] = "Album Artist"
        
        // akID
        map[AVMetadataiTunesMetadataKeyAccountKind] = "Account Kind"
        
        // apID
        map[AVMetadataiTunesMetadataKeyAppleID] = "Apple ID"
        
        // atID
        map[AVMetadataiTunesMetadataKeyArtistID] = "Artist ID"
        
        // cnID
        map[AVMetadataiTunesMetadataKeySongID] = "Song ID"
        
        // cpil
        map[AVMetadataiTunesMetadataKeyDiscCompilation] = "Disc Compilation"
        
        // disk
        map[AVMetadataiTunesMetadataKeyDiscNumber] = "Disc Number"
        
        // geID
        map[AVMetadataiTunesMetadataKeyGenreID] = "Genre ID"
        
        // grup
        map[AVMetadataiTunesMetadataKeyGrouping] = "Grouping"
        
        // plID
        map[AVMetadataiTunesMetadataKeyPlaylistID] = "Playlist ID"
        
        // rtng
        map[AVMetadataiTunesMetadataKeyContentRating] = "Content Rating"
        
        // tmpo
        map[AVMetadataiTunesMetadataKeyBeatsPerMin] = "Beats Per Min"
        
        // trkn
        map[AVMetadataiTunesMetadataKeyTrackNumber] = "Track Number"
        
        // @ard
        map[AVMetadataiTunesMetadataKeyArtDirector] = "Art Director"
        
        // @arg
        map[AVMetadataiTunesMetadataKeyArranger] = "Arranger"
        
        // @aut
        map[AVMetadataiTunesMetadataKeyAuthor] = "Author"
        
        // @lyr
        map[AVMetadataiTunesMetadataKeyLyrics] = "Lyrics"
        
        // @cak
        map[AVMetadataiTunesMetadataKeyAcknowledgement] = "Acknowledgement"
        
        // @con
        map[AVMetadataiTunesMetadataKeyConductor] = "Conductor"
        
        // @des
        map[AVMetadataiTunesMetadataKeyDescription] = "Description"
        
        // @dir
        map[AVMetadataiTunesMetadataKeyDirector] = "Director"
        
        // @equ
        map[AVMetadataiTunesMetadataKeyEQ] = "EQ"
        
        // @lnt
        map[AVMetadataiTunesMetadataKeyLinerNotes] = "Liner Notes"
        
        // @mak
        map[AVMetadataiTunesMetadataKeyRecordCompany] = "Record Company"
        
        // @ope
        map[AVMetadataiTunesMetadataKeyOriginalArtist] = "Original Artist"
        
        // @phg
        map[AVMetadataiTunesMetadataKeyPhonogramRights] = "Phonogram Rights"
        
        // @prd
        map[AVMetadataiTunesMetadataKeyProducer] = "Producer"
        
        // @prf
        map[AVMetadataiTunesMetadataKeyPerformer] = "Performer"
        
        // @pub
        map[AVMetadataiTunesMetadataKeyPublisher] = "Publisher"
        
        // @sne
        map[AVMetadataiTunesMetadataKeySoundEngineer] = "Sound Engineer"
        
        // @sol
        map[AVMetadataiTunesMetadataKeySoloist] = "Soloist"
        
        // @src
        map[AVMetadataiTunesMetadataKeyCredits] = "Credits"
        
        // @thx
        map[AVMetadataiTunesMetadataKeyThanks] = "Thanks"
        
        // @url
        map[AVMetadataiTunesMetadataKeyOnlineExtras] = "Online Extras"
        
        // @xpd
        map[AVMetadataiTunesMetadataKeyExecProducer] = "Exec Producer"
        
        return map
    }
}
