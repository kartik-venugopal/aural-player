//
//  ITunesParser.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa
import AVFoundation

///
/// Parses metadata in the iTunes format / key space from natively supported tracks (supported by AVFoundation).
///
class ITunesParser: AVFMetadataParser {
    
    let keySpace: AVMetadataKeySpace = .iTunes
        
    private let essentialFieldKeys: Set<String> = [ITunesSpec.key_title, ITunesSpec.key_artist, ITunesSpec.key_originalArtist, ITunesSpec.key_originalArtist2, ITunesSpec.key_performer, ITunesSpec.key_album, ITunesSpec.key_originalAlbum, ITunesSpec.key_genre, ITunesSpec.key_predefGenre, ITunesSpec.key_genreID, ITunesSpec.key_discNumber, ITunesSpec.key_discNumber2, ITunesSpec.key_trackNumber]
        
    private let keys_artist: [String] = [ITunesSpec.key_artist, ITunesSpec.key_originalArtist, ITunesSpec.key_originalArtist2, ITunesSpec.key_albumArtist, ITunesSpec.key_performer]
    private let keys_album: [String] = [ITunesSpec.key_album, ITunesSpec.key_originalAlbum]
    private let keys_genre: [String] = [ITunesSpec.key_genre, ITunesSpec.key_predefGenre]
    
    private let keys_discNum: [String] = [ITunesSpec.key_discNumber, ITunesSpec.key_discNumber2]
    
    private let keys_year: [String] = [ITunesSpec.key_releaseDate, ITunesSpec.key_releaseYear]
    
    // BUG TODO: Find out why ITunesNormalization tag is not being ignored in MP3 files
    // Is some other parser including it ??? ID3Parser ???
    private let ignoredKeys: Set<String> = [ITunesSpec.key_normalization, ITunesSpec.key_soundCheck]
    
    func getDuration(_ metadataMap: AVFMappedMetadata) -> Double? {
        
        if let item = metadataMap.iTunes[ITunesSpec.key_duration], let durationStr = item.stringValue {
            return ParserUtils.parseDuration(durationStr)
        }
        
        return nil
    }
    
    func getTitle(_ metadataMap: AVFMappedMetadata) -> String? {
        metadataMap.iTunes[ITunesSpec.key_title]?.stringValue
    }
    
    func getArtist(_ metadataMap: AVFMappedMetadata) -> String? {
        (keys_artist.firstNonNilMappedValue {metadataMap.iTunes[$0]})?.stringValue
    }
    
    func getAlbum(_ metadataMap: AVFMappedMetadata) -> String? {
        (keys_album.firstNonNilMappedValue {metadataMap.iTunes[$0]})?.stringValue
    }
    
    func getGenre(_ metadataMap: AVFMappedMetadata) -> String? {
        
        if let genreItem = keys_genre.firstNonNilMappedValue({metadataMap.iTunes[$0]}) {
            return ParserUtils.getID3Genre(genreItem, -1)
        }
        
        if let genreItem = metadataMap.iTunes[ITunesSpec.key_genreID] {
            return getITunesGenre(genreItem)
        }
        
        return nil
    }
    
    private func getITunesGenre(_ genreItem: AVMetadataItem) -> String? {
        
        if let num = genreItem.numberValue {
            return GenreMap.forITunesCode(num.intValue)
        }
        
        if let str = genreItem.stringValue {
            return parseITunesGenreString(str)
            
        } else if let data = genreItem.dataValue, let code = Int(data.hexEncodedString(), radix: 16) { // Parse as hex string
            return GenreMap.forITunesCode(code)
        }
        
        return nil
    }
    
    // A genre string consisting of a number (ITunes genre code) in parenthesis,
    // followed by the genre name. eg. "(9)Opera"
    private let hybridGenreStringRegex = "\\([0-9]+\\)(.+)"
    
    private func parseITunesGenreString(_ string: String) -> String {

        // Look up genreId in ID3 table
        if let genreCode = ParserUtils.parseNumericString(string) {
            return GenreMap.forITunesCode(genreCode) ?? string
        }
        
        // Sometimes, genre strings look like "(9)Metal".
        if let firstMatch = string.match(regex: hybridGenreStringRegex).first,
           firstMatch.count >= 2 {
            
            // The second capture group within the first match is our genre string.
            return firstMatch[1].trim()
        }
        
        return string
    }
    
    func getTrackNumber(_ metadataMap: AVFMappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let item = metadataMap.iTunes[ITunesSpec.key_trackNumber] {
            return ParserUtils.parseDiscOrTrackNumber(item)
        }
        
        return nil
    }
    
    func getDiscNumber(_ metadataMap: AVFMappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let item = keys_discNum.firstNonNilMappedValue({metadataMap.iTunes[$0]}) {
            return ParserUtils.parseDiscOrTrackNumber(item)
        }
        
        return nil
    }
    
    func getArt(_ metadataMap: AVFMappedMetadata) -> CoverArt? {
        
        if let imgData = metadataMap.iTunes[ITunesSpec.key_art]?.dataValue {
            return CoverArt(imageData: imgData)
        }
        
        return nil
    }
    
    func getLyrics(_ metadataMap: AVFMappedMetadata) -> String? {
        
        if let lyricsItem = metadataMap.iTunes[ITunesSpec.key_lyrics] {
            return lyricsItem.stringValue
        }
        
        return nil
    }
    
    func getYear(_ metadataMap: AVFMappedMetadata) -> Int? {
        
        if let item = keys_year.firstNonNilMappedValue({metadataMap.iTunes[$0]}) {
            return ParserUtils.parseYear(item)
        }
        
        return nil
    }
    
    func getBPM(_ metadataMap: AVFMappedMetadata) -> Int? {
        
        if let item = metadataMap.iTunes[ITunesSpec.key_bpm] {
            return ParserUtils.parseBPM(item)
        }
        
        return nil
    }

    func getChapterTitle(_ items: [AVMetadataItem]) -> String? {
        return items.first(where: {$0.keySpace == .iTunes && $0.keyAsString == ITunesSpec.key_title})?.stringValue
    }
    
    func getAuxiliaryMetadata(_ metadataMap: AVFMappedMetadata) -> [String: MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        for item in metadataMap.iTunes.values {
            
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
            
            let rKey = ITunesSpec.readableKey(key.withEncodingAndNullsRemoved())
            
            if !ignoredKeys.contains(rKey.lowercased()) {
                metadata[key] = MetadataEntry(.iTunes, rKey, value.withEncodingAndNullsRemoved())
            }
        }
        
        return metadata
    }
}
