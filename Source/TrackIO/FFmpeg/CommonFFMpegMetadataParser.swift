import Cocoa

fileprivate let key_title = "title"

fileprivate let key_artist = "artist"
fileprivate let key_albumArtist = "album_artist"
fileprivate let key_performer = "performer"

fileprivate let key_album = "album"
fileprivate let key_genre = "genre"

fileprivate let key_disc = "disc"
fileprivate let key_track = "track"

fileprivate let key_lyrics = "lyrics"

fileprivate let key_comment = "comment"
fileprivate let key_composer = "composer"
fileprivate let key_publisher = "publisher"
fileprivate let key_copyright = "copyright"

fileprivate let key_encodedBy = "encoded_by"
fileprivate let key_encoder = "encoder"
fileprivate let key_language = "language"
fileprivate let key_date = "date"

class CommonFFmpegMetadataParser: FFmpegMetadataParser {
    
    private let essentialKeys: Set<String> = [key_title, key_artist, key_albumArtist, key_album, key_performer, key_genre, key_disc, key_track]
    
    private let genericKeys: [String: String] = [
        
        key_composer: "Composer",
        key_publisher: "Publisher",
        key_copyright: "Copyright",
        key_encodedBy: "Encoded By",
        key_encoder: "Encoder",
        key_language: "Language",
        key_comment: "Comment",
        key_date: "Date",
        key_lyrics: "Lyrics"
    ]
    
    func mapTrack(_ meta: FFmpegMappedMetadata) {
        
        let metadata = meta.commonMetadata
        
        for key in meta.map.keys {
            
            let lcKey = key.lowercased().trim()
            
            if essentialKeys.contains(lcKey) {
                
                metadata.essentialFields[lcKey] = meta.map.removeValue(forKey: key)
                
            } else if genericKeys[lcKey] != nil {
                
                metadata.genericFields[lcKey] = meta.map.removeValue(forKey: key)
            }
        }
    }
    
    func hasEssentialMetadataForTrack(_ meta: FFmpegMappedMetadata) -> Bool {
        !meta.commonMetadata.essentialFields.isEmpty
    }
    
    func hasGenericMetadataForTrack(_ meta: FFmpegMappedMetadata) -> Bool {
        !meta.commonMetadata.genericFields.isEmpty
    }
    
    func getTitle(_ meta: FFmpegMappedMetadata) -> String? {
        meta.commonMetadata.essentialFields[key_title]
    }
    
    func getArtist(_ meta: FFmpegMappedMetadata) -> String? {
        
        meta.commonMetadata.essentialFields[key_artist] ??
            meta.commonMetadata.essentialFields[key_albumArtist] ??
            meta.commonMetadata.essentialFields[key_performer]
    }
    
    func getAlbum(_ meta: FFmpegMappedMetadata) -> String? {
        meta.commonMetadata.essentialFields[key_album]
    }
    
    func getGenre(_ meta: FFmpegMappedMetadata) -> String? {
        meta.commonMetadata.essentialFields[key_genre]
    }
    
    func getLyrics(_ meta: FFmpegMappedMetadata) -> String? {
        meta.commonMetadata.genericFields[key_lyrics]
    }
    
    func getDiscNumber(_ meta: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let discNumStr = meta.commonMetadata.essentialFields[key_disc] {
            return ParserUtils.parseDiscOrTrackNumberString(discNumStr)
        }
        
        return nil
    }
    
    func getTrackNumber(_ meta: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let trackNumStr = meta.commonMetadata.essentialFields[key_track] {
            return ParserUtils.parseDiscOrTrackNumberString(trackNumStr)
        }
        
        return nil
    }
    
    func getYear(_ meta: FFmpegMappedMetadata) -> Int? {
        
        if let yearString = meta.commonMetadata.genericFields[key_date] {
            return ParserUtils.parseYear(yearString)
        }
        
        return nil
    }
    
    func getGenericMetadata(_ meta: FFmpegMappedMetadata) -> [String : MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        for (key, var value) in meta.commonMetadata.genericFields {
            
            if key == key_language, let langName = LanguageMap.forCode(value.trim()) {
                value = langName
            }
            
            value = StringUtils.cleanUpString(value)
            
            metadata[key] = MetadataEntry(.common, readableKey(key), value)
        }
        
        return metadata
    }
    
    func readableKey(_ key: String) -> String {
        return genericKeys[key] ?? key.capitalizingFirstLetter()
    }
}
