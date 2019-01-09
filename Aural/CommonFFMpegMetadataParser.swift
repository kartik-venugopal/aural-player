import Cocoa

fileprivate let key_title = "title"
fileprivate let key_artist = "artist"
fileprivate let key_album = "album"
fileprivate let key_genre = "genre"

fileprivate let key_disc = "disc"
fileprivate let key_track = "track"

fileprivate let key_lyrics = "lyrics"

fileprivate let key_albumArtist = "album_artist"
fileprivate let key_composer = "composer"
fileprivate let key_performer = "performer"
fileprivate let key_publisher = "publisher"
fileprivate let key_copyright = "copyright"

fileprivate let key_encodedBy = "encoded_by"
fileprivate let key_encoder = "encoder"
fileprivate let key_language = "language"
fileprivate let key_date = "date"

class CommonFFMpegMetadataParser: FFMpegMetadataParser {

    private let essentialKeys: [String: String] = [
        key_title: "Title",
        key_artist: "Artist",
        key_album: "Album",
        key_genre: "Genre",
        key_disc: "Disc#",
        key_track: "Track#",
        key_lyrics: "Lyrics"
    ]
    
    private let genericKeys: [String: String] = [
        key_albumArtist: "Album Artist",
        key_composer: "Composer",
        key_performer: "Performer",
        key_publisher: "Publisher",
        key_copyright: "Copyright",
        key_encodedBy: "Encoded By",
        key_encoder: "Encoder",
        key_language: "Language",
        key_date: "Date"
    ]
    
    func mapTrack(_ mapForTrack: LibAVMetadata) {
        
        var map = mapForTrack.map
        
        let metadata = LibAVParserMetadata()
        mapForTrack.commonMetadata = metadata
        
        for (key, value) in map {
            
            let lcKey = key.lowercased().trim()
            
            if essentialKeys[lcKey] != nil {
                
                metadata.essentialFields[lcKey] = value
                map.removeValue(forKey: key)
                
            } else if genericKeys[lcKey] != nil {
                
                metadata.genericFields[lcKey] = value
                map.removeValue(forKey: key)
            }
        }
    }
    
    func getTitle(_ mapForTrack: LibAVMetadata) -> String? {
        
        if let title = mapForTrack.commonMetadata?.essentialFields[key_title] {
            return title
        }
    
        return nil
    }
    
    func getArtist(_ mapForTrack: LibAVMetadata) -> String? {
        
        if let artist = mapForTrack.commonMetadata?.essentialFields[key_artist] {
            return artist
        }
        
        return nil
    }
    
    func getAlbum(_ mapForTrack: LibAVMetadata) -> String? {
        
        if let album = mapForTrack.commonMetadata?.essentialFields[key_album] {
            return album
        }
        
        return nil
    }
    
    func getGenre(_ mapForTrack: LibAVMetadata) -> String? {
        
        if let genre = mapForTrack.commonMetadata?.essentialFields[key_genre] {
            return genre
        }
        
        return nil
    }
    
    func getLyrics(_ mapForTrack: LibAVMetadata) -> String? {
        
        if let lyrics = mapForTrack.commonMetadata?.essentialFields[key_lyrics] {
            return lyrics
        }
        
        return nil
    }
    
    func getDiscNumber(_ mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)? {
        
        if let discNumStr = mapForTrack.commonMetadata?.essentialFields[key_disc] {
            return parseDiscOrTrackNumber(discNumStr)
        }
        
        return nil
    }
    
    func getTrackNumber(_ mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)? {
        
        if let trackNumStr = mapForTrack.commonMetadata?.essentialFields[key_track] {
            return parseDiscOrTrackNumber(trackNumStr)
        }
        
        return nil
    }
    
    private func parseDiscOrTrackNumber(_ _string: String) -> (number: Int?, total: Int?)? {
        
        // Parse string (e.g. "2 / 13")
        
        let string = _string.trim()
        
        if let num = Int(string) {
            return (num, nil)
        }
        
        let tokens = string.split(separator: "/")
        
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
        
        return nil
    }
    
    func getGenericMetadata(_ mapForTrack: LibAVMetadata) -> [String : MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        if let fields = mapForTrack.commonMetadata?.genericFields {
            
            for (key, value) in fields {
                metadata[key] = MetadataEntry(.common, readableKey(key), value)
            }
        }
        
        return metadata
    }
    
    func readableKey(_ key: String) -> String {
        
        if let rKey = genericKeys[key] {
            return rKey
        }
        
        if let rKey = essentialKeys[key] {
            return rKey
        }
        
        return key.capitalizingFirstLetter()
    }
}
