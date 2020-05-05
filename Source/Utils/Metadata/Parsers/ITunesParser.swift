import Cocoa
import AVFoundation

/*
    Specification for the iTunes metadata format.
 */
class ITunesParser: AVAssetParser {
    
    private let essentialFieldKeys: Set<String> = [ITunesSpec.key_title, ITunesSpec.key_artist, ITunesSpec.key_album, ITunesSpec.key_genre, ITunesSpec.key_predefGenre, ITunesSpec.key_genreID, ITunesSpec.key_discNumber, ITunesSpec.key_discNumber2, ITunesSpec.key_trackNumber, ITunesSpec.key_lyrics, ITunesSpec.key_art]
    
    // BUG TODO: Find out why ITunesNormalization tag is not being ignored in MP3 file
    private let ignoredKeys: Set<String> = [ITunesSpec.key_normalization, ITunesSpec.key_soundCheck]
    
    func mapTrack(_ track: Track, _ mapForTrack: AVAssetMetadata) {
        
        for item in track.audioAsset!.metadata {
            
            if item.keySpace == .iTunes, let key = item.keyAsString {
                
                let mapKey = String(format: "%@/%@", ITunesSpec.keySpace, key)
                
                if essentialFieldKeys.contains(mapKey) {
                    mapForTrack.map[mapKey] = item
                } else {
                    // Generic field
                    mapForTrack.genericItems.append(item)
                }
                
            } else if item.keySpace?.rawValue == ITunesSpec.longForm_keySpaceID, let key = item.keyAsString { // Long form
                
                let mapKey = String(format: "%@/%@", ITunesSpec.keySpace, key)
                
                if essentialFieldKeys.contains(mapKey) {
                    mapForTrack.map[mapKey] = item
                } else {
                    // Generic field
                    mapForTrack.genericItems.append(item)
                }
            }
        }
    }
    
    func getDuration(_ mapForTrack: AVAssetMetadata) -> Double? {
        
        if let item = mapForTrack.map[ITunesSpec.key_duration], let durationStr = item.stringValue, let durationMsecs = Double(durationStr) {
            return durationMsecs / 1000
        }
        
        return nil
    }
    
    func getTitle(_ mapForTrack: AVAssetMetadata) -> String? {
        
        if let titleItem = mapForTrack.map[ITunesSpec.key_title] {
            return titleItem.stringValue
        }
        
        return nil
    }
    
    func getArtist(_ mapForTrack: AVAssetMetadata) -> String? {
        
        if let artistItem = mapForTrack.map[ITunesSpec.key_artist] {
            return artistItem.stringValue
        }
        
        return nil
    }
    
    func getAlbum(_ mapForTrack: AVAssetMetadata) -> String? {
        
            if let albumItem = mapForTrack.map[ITunesSpec.key_album] {
                return albumItem.stringValue
            }
        
        return nil
    }
    
    func getGenre(_ mapForTrack: AVAssetMetadata) -> String? {
        
        for key in [ITunesSpec.key_genre, ITunesSpec.key_predefGenre] {
            
            if let genreItem = mapForTrack.map[key] {
                return ParserUtils.getID3Genre(genreItem, -1)
            }
        }
        
        if let genreItem = mapForTrack.map[ITunesSpec.key_genreID] {
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
            
        } else if let data = genreItem.dataValue {
            
            // Parse as hex string
            if let code = Int(data.hexEncodedString(), radix: 16) {
                return GenreMap.forITunesCode(code)
            }
        }
        
        return nil
    }
    
    private func parseITunesGenreNumericString(_ string: String) -> String {
        
        if let genreCode = ParserUtils.parseNumericString(string) {
            // Look up genreId in ID3 table
            return GenreMap.forITunesCode(genreCode) ?? string
        }
        
        return string
    }
    
    func getDiscNumber(_ mapForTrack: AVAssetMetadata) -> (number: Int?, total: Int?)? {
        
        for key in [ITunesSpec.key_discNumber, ITunesSpec.key_discNumber2] {
            
            if let item = mapForTrack.map[key] {
                return ParserUtils.parseDiscOrTrackNumber(item)
            }
        }
        
        return nil
    }
    
    func getTrackNumber(_ mapForTrack: AVAssetMetadata) -> (number: Int?, total: Int?)? {
        
        if let item = mapForTrack.map[ITunesSpec.key_trackNumber] {
            return ParserUtils.parseDiscOrTrackNumber(item)
        }
        
        return nil
    }
    
    func getArt(_ mapForTrack: AVAssetMetadata) -> CoverArt? {
        
        if let item = mapForTrack.map[ITunesSpec.key_art], let imgData = item.dataValue, let image = NSImage(data: imgData) {
            
            let metadata = ParserUtils.getImageMetadata(imgData as NSData)
            return CoverArt(image, metadata)
        }
        
        return nil
    }
    
    func getArt(_ asset: AVURLAsset) -> CoverArt? {
        
        if let item = AVMetadataItem.metadataItems(from: asset.commonMetadata, filteredByIdentifier: ITunesSpec.id_art).first, let imgData = item.dataValue, let image = NSImage(data: imgData) {
            
            let metadata = ParserUtils.getImageMetadata(imgData as NSData)
            return CoverArt(image, metadata)
        }
        
        return nil
    }
    
    func getLyrics(_ mapForTrack: AVAssetMetadata) -> String? {
        
        if let lyricsItem = mapForTrack.map[ITunesSpec.key_lyrics] {
            return lyricsItem.stringValue
        }
        
        return nil
    }
    
    func getChapterTitle(_ items: [AVMetadataItem]) -> String? {
        return items.first(where: {$0.keySpace == .iTunes && $0.keyAsString == ITunesSpec.rawKey_title})?.stringValue
    }
    
    func getGenericMetadata(_ mapForTrack: AVAssetMetadata) -> [String: MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        for item in mapForTrack.genericItems.filter({item -> Bool in item.keySpace == .iTunes || item.keySpace?.rawValue == ITunesSpec.longForm_keySpaceID}) {
            
            if let key = item.keyAsString {
                
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
        }
        
        return metadata
    }
}
