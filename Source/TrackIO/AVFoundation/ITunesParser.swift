import Cocoa
import AVFoundation

/*
    Specification for the iTunes metadata format.
 */
class ITunesParser: AVFMetadataParser {
    
    let keySpace: AVMetadataKeySpace = .iTunes
        
    //    private let essentialFieldKeys: Set<String> = [ITunesSpec.key_title, ITunesSpec.key_artist, ITunesSpec.key_originalArtist, ITunesSpec.key_originalArtist2, ITunesSpec.key_album, ITunesSpec.key_originalAlbum, ITunesSpec.key_composer, ITunesSpec.key_conductor, ITunesSpec.key_conductor2, ITunesSpec.key_genre, ITunesSpec.key_predefGenre, ITunesSpec.key_genreID, ITunesSpec.key_discNumber, ITunesSpec.key_discNumber2, ITunesSpec.key_trackNumber, ITunesSpec.key_releaseDate, ITunesSpec.key_releaseYear, ITunesSpec.key_lyrics, ITunesSpec.key_art]
        
        private let keys_artist: [String] = [ITunesSpec.key_artist, ITunesSpec.key_originalArtist, ITunesSpec.key_originalArtist2]
        private let keys_album: [String] = [ITunesSpec.key_album, ITunesSpec.key_originalAlbum]
        private let keys_conductor: [String] = [ITunesSpec.key_conductor, ITunesSpec.key_conductor2]
        private let keys_lyricist: [String] = [ITunesSpec.key_lyricist, ITunesSpec.key_originalLyricist]
        private let keys_genre: [String] = [ITunesSpec.key_genre, ITunesSpec.key_predefGenre]
        
        private let keys_discNum: [String] = [ITunesSpec.key_discNumber, ITunesSpec.key_discNumber2]
        
        private let keys_year: [String] = [ITunesSpec.key_releaseDate, ITunesSpec.key_releaseYear]
        
        // BUG TODO: Find out why ITunesNormalization tag is not being ignored in MP3 file
    //    private let ignoredKeys: Set<String> = [ITunesSpec.key_normalization, ITunesSpec.key_soundCheck]
    
//    func mapTrack(_ meta: AVFMetadata) {
//    
//        for item in meta.asset.metadata {
//            
//            if item.keySpace == .iTunes, let key = item.keyAsString {
//                
//                let mapKey = String(format: "%@/%@", ITunesSpec.keySpace, key)
//                
//                if essentialFieldKeys.contains(mapKey) {
//                    meta.map[mapKey] = item
//                } else {
//                    // Generic field
//                    meta.genericItems.append(item)
//                }
//                
//            } else if item.keySpace?.rawValue == ITunesSpec.longForm_keySpaceID, let key = item.keyAsString { // Long form
//                
//                let mapKey = String(format: "%@/%@", ITunesSpec.keySpace, key)
//                
//                if essentialFieldKeys.contains(mapKey) {
//                    meta.map[mapKey] = item
//                } else {
//                    // Generic field
//                    meta.genericItems.append(item)
//                }
//            }
//        }
//    }
//    
    func getDuration(_ meta: AVFMetadata) -> Double? {
        
        if let item = meta.iTunes[ITunesSpec.key_duration], let durationStr = item.stringValue {
            return ParserUtils.parseDuration(durationStr)
        }
        
        return nil
    }
    
    func getTitle(_ meta: AVFMetadata) -> String? {
        meta.iTunes[ITunesSpec.key_title]?.stringValue
    }
    
    func getArtist(_ meta: AVFMetadata) -> String? {
        (keys_artist.firstNonNilMappedValue {meta.iTunes[$0]})?.stringValue
    }
    
    func getAlbumArtist(_ meta: AVFMetadata) -> String? {
        meta.iTunes[ITunesSpec.key_albumArtist]?.stringValue
    }
    
    func getAlbum(_ meta: AVFMetadata) -> String? {
        (keys_album.firstNonNilMappedValue {meta.iTunes[$0]})?.stringValue
    }
    
    func getComposer(_ meta: AVFMetadata) -> String? {
        meta.iTunes[ITunesSpec.key_composer]?.stringValue
    }
    
    func getConductor(_ meta: AVFMetadata) -> String? {
        (keys_conductor.firstNonNilMappedValue {meta.iTunes[$0]})?.stringValue
    }
    
    func getPerformer(_ meta: AVFMetadata) -> String? {
        meta.iTunes[ITunesSpec.key_performer]?.stringValue
    }
    
    func getLyricist(_ meta: AVFMetadata) -> String? {
        (keys_lyricist.firstNonNilMappedValue {meta.iTunes[$0]})?.stringValue
    }
    
    func getGenre(_ meta: AVFMetadata) -> String? {
        
        if let genreItem = keys_genre.firstNonNilMappedValue({meta.iTunes[$0]}) {
            return ParserUtils.getID3Genre(genreItem, -1)
        }
        
        if let genreItem = meta.iTunes[ITunesSpec.key_genreID] {
            return getITunesGenre(genreItem)
        }
        
        return nil
    }
    
    private func getITunesGenre(_ genreItem: AVMetadataItem) -> String? {
        
        if let num = genreItem.numberValue {
            return GenreMap.forITunesCode(num.intValue)
        }
        
        if let str = genreItem.stringValue {
            return parseITunesGenreNumericString(str)
            
        } else if let data = genreItem.dataValue, let code = Int(data.hexEncodedString(), radix: 16) { // Parse as hex string
            return GenreMap.forITunesCode(code)
        }
        
        return nil
    }
    
    private func parseITunesGenreNumericString(_ string: String) -> String {

        // Look up genreId in ID3 table
        if let genreCode = ParserUtils.parseNumericString(string) {
            return GenreMap.forITunesCode(genreCode) ?? string
        }
        
        return string
    }
    
    func getTrackNumber(_ meta: AVFMetadata) -> (number: Int?, total: Int?)? {
        
        if let item = meta.iTunes[ITunesSpec.key_trackNumber] {
            return ParserUtils.parseDiscOrTrackNumber(item)
        }
        
        return nil
    }
    
    func getDiscNumber(_ meta: AVFMetadata) -> (number: Int?, total: Int?)? {
        
        if let item = keys_discNum.firstNonNilMappedValue({meta.iTunes[$0]}) {
            return ParserUtils.parseDiscOrTrackNumber(item)
        }
        
        return nil
    }
    
    func getArt(_ meta: AVFMetadata) -> NSImage? {
        
        if let imgData = meta.iTunes[ITunesSpec.key_art]?.dataValue, let image = NSImage(data: imgData) {
            return image
        }
        
        return nil
    }
    
    func getLyrics(_ meta: AVFMetadata) -> String? {
        
        if let lyricsItem = meta.iTunes[ITunesSpec.key_lyrics] {
            return lyricsItem.stringValue
        }
        
        return nil
    }
    
    func getYear(_ meta: AVFMetadata) -> Int? {
        
        if let item = keys_year.firstNonNilMappedValue({meta.iTunes[$0]}) {
            return ParserUtils.parseYear(item)
        }
        
        return nil
    }
    
    func getBPM(_ meta: AVFMetadata) -> Int? {
        
        if let item = meta.iTunes[ITunesSpec.key_bpm] {
            return ParserUtils.parseBPM(item)
        }
        
        return nil
    }
//
//    func getChapterTitle(_ items: [AVMetadataItem]) -> String? {
//        return items.first(where: {$0.keySpace == .iTunes && $0.keyAsString == ITunesSpec.rawKey_title})?.stringValue
//    }
//    
//    func getGenericMetadata(_ meta: AVFMetadata) -> [String: MetadataEntry] {
//        
//        var metadata: [String: MetadataEntry] = [:]
//        
//        for item in meta.genericItems.filter({item -> Bool in item.keySpace == .iTunes || item.keySpace?.rawValue == ITunesSpec.longForm_keySpaceID}) {
//            
//            if let key = item.keyAsString {
//                
//                var value: String = ""
//                
//                if key == ITunesSpec.key_language, let langName = LanguageMap.forCode(value.trim()) {
//                    
//                    value = langName
//                    
//                } else if key == ITunesSpec.key_compilation || key == ITunesSpec.key_isPodcast, let numVal = item.numberValue {
//                    
//                    // Number to boolean
//                    value = numVal == 0 ? "No" : "Yes"
//                    
//                } else if ITunesSpec.keys_mediaType.contains(key) {
//
//                    if let mediaTypeCode = item.numberValue?.intValue, let mediaType = ITunesSpec.mediaTypes[mediaTypeCode] {
//                        value = mediaType
//                    } else {
//                        continue
//                    }
//                    
//                } else if key == ITunesSpec.key_contentRating {
//                    
//                    if let ratingCode = item.numberValue?.intValue, let rating = ITunesSpec.contentRating[ratingCode] {
//                        value = rating
//                    } else {
//                        continue
//                    }
//                    
//                } else if key == ITunesSpec.key_bpm {
//                    
//                    value = item.valueAsNumericalString
//                    
//                } else {
//                    
//                    if let strValue = item.valueAsString {
//                        value = strValue
//                    } else {
//                        continue
//                    }
//                }
//                
//                let rKey = ITunesSpec.readableKey(StringUtils.cleanUpString(key))
//                
//                if !ignoredKeys.contains(rKey.lowercased()) {
//                    metadata[key] = MetadataEntry(.iTunes, rKey, StringUtils.cleanUpString(value))
//                }
//            }
//        }
//        
//        return metadata
//    }
}
