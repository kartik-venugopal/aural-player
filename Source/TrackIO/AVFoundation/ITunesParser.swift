import Cocoa
import AVFoundation

/*
    Specification for the iTunes metadata format.
 */
class ITunesParser: AVFMetadataParser {
    
    let keySpace: AVMetadataKeySpace = .iTunes
        
    private let essentialFieldKeys: Set<String> = [ITunesSpec.key_title, ITunesSpec.key_artist, ITunesSpec.key_originalArtist, ITunesSpec.key_originalArtist2, ITunesSpec.key_performer, ITunesSpec.key_album, ITunesSpec.key_originalAlbum, ITunesSpec.key_genre, ITunesSpec.key_predefGenre, ITunesSpec.key_genreID, ITunesSpec.key_discNumber, ITunesSpec.key_discNumber2, ITunesSpec.key_trackNumber]
        
    private let keys_artist: [String] = [ITunesSpec.key_artist, ITunesSpec.key_originalArtist, ITunesSpec.key_originalArtist2, ITunesSpec.key_albumArtist, ITunesSpec.key_performer]
    private let keys_album: [String] = [ITunesSpec.key_album, ITunesSpec.key_originalAlbum]
    private let keys_genre: [String] = [ITunesSpec.key_genre, ITunesSpec.key_predefGenre]
    
    private let keys_discNum: [String] = [ITunesSpec.key_discNumber, ITunesSpec.key_discNumber2]
    
    private let keys_year: [String] = [ITunesSpec.key_releaseDate, ITunesSpec.key_releaseYear]
    
    // BUG TODO: Find out why ITunesNormalization tag is not being ignored in MP3 files
    private let ignoredKeys: Set<String> = [ITunesSpec.key_normalization, ITunesSpec.key_soundCheck]
    
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
    func getDuration(_ meta: AVFMappedMetadata) -> Double? {
        
        if let item = meta.iTunes[ITunesSpec.key_duration], let durationStr = item.stringValue {
            return ParserUtils.parseDuration(durationStr)
        }
        
        return nil
    }
    
    func getTitle(_ meta: AVFMappedMetadata) -> String? {
        meta.iTunes[ITunesSpec.key_title]?.stringValue
    }
    
    func getArtist(_ meta: AVFMappedMetadata) -> String? {
        (keys_artist.firstNonNilMappedValue {meta.iTunes[$0]})?.stringValue
    }
    
    func getAlbum(_ meta: AVFMappedMetadata) -> String? {
        (keys_album.firstNonNilMappedValue {meta.iTunes[$0]})?.stringValue
    }
    
    func getGenre(_ meta: AVFMappedMetadata) -> String? {
        
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
    
    func getTrackNumber(_ meta: AVFMappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let item = meta.iTunes[ITunesSpec.key_trackNumber] {
            return ParserUtils.parseDiscOrTrackNumber(item)
        }
        
        return nil
    }
    
    func getDiscNumber(_ meta: AVFMappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let item = keys_discNum.firstNonNilMappedValue({meta.iTunes[$0]}) {
            return ParserUtils.parseDiscOrTrackNumber(item)
        }
        
        return nil
    }
    
    func getArt(_ meta: AVFMappedMetadata) -> CoverArt? {
        
        if let imgData = meta.iTunes[ITunesSpec.key_art]?.dataValue, let image = NSImage(data: imgData) {
            
            let metadata = ParserUtils.getImageMetadata(imgData as NSData)
            return CoverArt(image, metadata)
        }
        
        return nil
    }
    
    func getLyrics(_ meta: AVFMappedMetadata) -> String? {
        
        if let lyricsItem = meta.iTunes[ITunesSpec.key_lyrics] {
            return lyricsItem.stringValue
        }
        
        return nil
    }
    
    func getYear(_ meta: AVFMappedMetadata) -> Int? {
        
        if let item = keys_year.firstNonNilMappedValue({meta.iTunes[$0]}) {
            return ParserUtils.parseYear(item)
        }
        
        return nil
    }
    
    func getBPM(_ meta: AVFMappedMetadata) -> Int? {
        
        if let item = meta.iTunes[ITunesSpec.key_bpm] {
            return ParserUtils.parseBPM(item)
        }
        
        return nil
    }

    func getChapterTitle(_ items: [AVMetadataItem]) -> String? {
        return items.first(where: {$0.keySpace == .iTunes && $0.keyAsString == ITunesSpec.key_title})?.stringValue
    }
    
    func getGenericMetadata(_ meta: AVFMappedMetadata) -> [String: MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        for item in meta.iTunes.values {
            
            guard let key = item.keyAsString, !essentialFieldKeys.contains(key) else {continue}
            
            var value: String = ""
            
            if key == ITunesSpec.key_language, let langName = LanguageMap.forCode(value.trim()) {
                
                value = langName
                
            } else if key == ITunesSpec.key_compilation || key == ITunesSpec.key_isPodcast, let numVal = item.numberValue {
                
                // Number to boolean
                value = numVal == 0 ? "No" : "Yes"
                
            } else if ITunesSpec.keys_mediaType.contains(key) {
                
                if let mediaTypeCode = item.numberValue?.intValue, let mediaType = ITunesSpec.mediaTypes[mediaTypeCode] {
                    value = mediaType
                } else {
                    continue
                }
                
            } else if key == ITunesSpec.key_contentRating {
                
                if let ratingCode = item.numberValue?.intValue, let rating = ITunesSpec.contentRating[ratingCode] {
                    value = rating
                } else {
                    continue
                }
                
            } else if key == ITunesSpec.key_bpm {
                
                value = item.valueAsNumericalString
                
            } else {
                
                if let strValue = item.valueAsString {
                    value = strValue
                } else {
                    continue
                }
            }
            
            let rKey = ITunesSpec.readableKey(StringUtils.cleanUpString(key))
            
            if !ignoredKeys.contains(rKey.lowercased()) {
                metadata[key] = MetadataEntry(.iTunes, rKey, StringUtils.cleanUpString(value))
            }
        }
        
        return metadata
    }
}
