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
