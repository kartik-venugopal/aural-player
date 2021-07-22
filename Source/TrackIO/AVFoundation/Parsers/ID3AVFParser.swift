//
//  ID3AVFParser.swift
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
/// Parses metadata in the ID3 format / key space from natively supported tracks (supported by **AVFoundation**).
///
class ID3AVFParser: AVFMetadataParser {
    
    let keySpace: AVMetadataKeySpace = .id3
    
    private let keys_duration: [String] = [ID3_V24Spec.key_duration, ID3_V22Spec.key_duration]
    
    private let keys_title: [String] = [ID3_V24Spec.key_title, ID3_V22Spec.key_title, ID3_V1Spec.key_title]
    
    private let keys_artist: [String] = [ID3_V24Spec.key_artist, ID3_V22Spec.key_artist, ID3_V1Spec.key_artist, ID3_V24Spec.key_originalArtist, ID3_V22Spec.key_originalArtist, ID3_V24Spec.key_albumArtist, ID3_V22Spec.key_albumArtist]
    private let keys_album: [String] = [ID3_V24Spec.key_album, ID3_V22Spec.key_album, ID3_V1Spec.key_album, ID3_V24Spec.key_originalAlbum, ID3_V22Spec.key_originalAlbum]
    private let keys_genre: [String] = [ID3_V24Spec.key_genre, ID3_V22Spec.key_genre, ID3_V1Spec.key_genre]
    
    private let keys_discNumber: [String] = [ID3_V24Spec.key_discNumber, ID3_V22Spec.key_discNumber]
    private let keys_trackNumber: [String] = [ID3_V24Spec.key_trackNumber, ID3_V22Spec.key_trackNumber, ID3_V1Spec.key_trackNumber]
    
    private let keys_year: [String] = [ID3_V24Spec.key_year, ID3_V22Spec.key_year, ID3_V24Spec.key_originalReleaseYear, ID3_V22Spec.key_originalReleaseYear, ID3_V24Spec.key_date, ID3_V22Spec.key_date]
    
    private let keys_bpm: [String] = [ID3_V24Spec.key_bpm, ID3_V22Spec.key_bpm]
    
    private let keys_lyrics: [String] = [ID3_V24Spec.key_lyrics, ID3_V22Spec.key_lyrics, ID3_V24Spec.key_syncLyrics, ID3_V22Spec.key_syncLyrics]
    private let keys_art: [String] = [ID3_V24Spec.key_art, ID3_V22Spec.key_art]
    
    private let keys_GEOB: [String] = [ID3_V24Spec.key_GEOB, ID3_V22Spec.key_GEO]
    private let keys_language: [String] = [ID3_V24Spec.key_language, ID3_V22Spec.key_language]
    private let keys_playCounter: [String] = [ID3_V24Spec.key_playCounter, ID3_V22Spec.key_playCounter]
    private let keys_compilation: [String] = [ID3_V24Spec.key_compilation, ID3_V22Spec.key_compilation]
    private let keys_mediaType: [String] = [ID3_V24Spec.key_mediaType, ID3_V22Spec.key_mediaType]
    
    private let essentialFieldKeys: Set<String> = {
        
        var keys: Set<String> = Set<String>()
        keys = keys.union(ID3_V1Spec.essentialFieldKeys)
        keys = keys.union(ID3_V22Spec.essentialFieldKeys)
        keys = keys.union(ID3_V24Spec.essentialFieldKeys)
        
        return keys
    }()
    
    private let ignoredKeys: Set<String> = [ID3_V24Spec.key_private, ID3_V24Spec.key_tableOfContents, ID3_V24Spec.key_chapter, ID3_V24Spec.key_lyrics, ID3_V22Spec.key_lyrics, ID3_V24Spec.key_syncLyrics, ID3_V22Spec.key_syncLyrics]
    
    private let auxiliaryFields: [String: String] = {
        
        var map: [String: String] = [:]
        ID3_V22Spec.auxiliaryFields.forEach {(k,v) in map[k] = v}
        ID3_V24Spec.auxiliaryFields.forEach {(k,v) in map[k] = v}
        
        return map
    }()
    
    private let replaceableKeyFields: Set<String> = {
        
        var keys: Set<String> = Set<String>()
        keys = keys.union(ID3_V22Spec.replaceableKeyFields)
        keys = keys.union(ID3_V24Spec.replaceableKeyFields)
        
        return keys
    }()
    
    private let infoKeys_TXXX: [String: String] = ["albumartist": "Album Artist", "compatible_brands": "Compatible Brands", "gn_extdata": "Gracenote Data"]
    
    private func readableKey(_ key: String) -> String {
        return auxiliaryFields[key] ?? key.capitalizingFirstLetter()
    }
    
    func getDuration(_ metadataMap: AVFMappedMetadata) -> Double? {
        
        if let item = keys_duration.firstNonNilMappedValue({metadataMap.id3[$0]}),
            let durationStr = item.stringValue {
            
            return ParserUtils.parseDuration(durationStr)
        }
        
        return nil
    }
    
    func getTitle(_ metadataMap: AVFMappedMetadata) -> String? {
        (keys_title.firstNonNilMappedValue {metadataMap.id3[$0]})?.stringValue
    }
    
    func getArtist(_ metadataMap: AVFMappedMetadata) -> String? {
        (keys_artist.firstNonNilMappedValue {metadataMap.id3[$0]})?.stringValue
    }
    
    func getAlbum(_ metadataMap: AVFMappedMetadata) -> String? {
        (keys_album.firstNonNilMappedValue {metadataMap.id3[$0]})?.stringValue
    }
    
    func getGenre(_ metadataMap: AVFMappedMetadata) -> String? {
        
        if let genreItem = keys_genre.firstNonNilMappedValue({metadataMap.id3[$0]}) {
            return ParserUtils.getID3Genre(genreItem)
        }
        
        return nil
    }
    
    func getDiscNumber(_ metadataMap: AVFMappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let item = keys_discNumber.firstNonNilMappedValue({metadataMap.id3[$0]}) {
            return ParserUtils.parseDiscOrTrackNumber(item)
        }
    
        return nil
    }
    
    func getTrackNumber(_ metadataMap: AVFMappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let item = keys_trackNumber.firstNonNilMappedValue({metadataMap.id3[$0]}) {
            return ParserUtils.parseDiscOrTrackNumber(item)
        }
        
        return nil
    }

    func getArt(_ metadataMap: AVFMappedMetadata) -> CoverArt? {
        
        if let item = keys_art.firstNonNilMappedValue({metadataMap.id3[$0]}),
            let imgData = item.dataValue {
            
            return CoverArt(imageData: imgData)
        }
        
        return nil
    }
    
    func getLyrics(_ metadataMap: AVFMappedMetadata) -> String? {
        (keys_lyrics.firstNonNilMappedValue {metadataMap.id3[$0]})?.stringValue
    }
    
    func getYear(_ metadataMap: AVFMappedMetadata) -> Int? {
        
        if let item = keys_year.firstNonNilMappedValue({metadataMap.id3[$0]}) {
            return ParserUtils.parseYear(item)
        }
        
        return nil
    }
    
    func getBPM(_ metadataMap: AVFMappedMetadata) -> Int? {
        
        if let item = keys_bpm.firstNonNilMappedValue({metadataMap.id3[$0]}) {
            return ParserUtils.parseBPM(item)
        }
        
        return nil
    }
    
    func getAuxiliaryMetadata(_ metadataMap: AVFMappedMetadata) -> [String: MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        for item in metadataMap.id3.values {
            
            guard let key = item.keyAsString, let value = item.valueAsString,
                  !essentialFieldKeys.contains(key), !ignoredKeys.contains(key) else {continue}
            
            var entryKey = key
            var entryValue = value
            
            // Special fields
            if replaceableKeyFields.contains(key), let attrs = item.extraAttributes, !attrs.isEmpty {
                
                // TXXX or COMM or WXXX
                if let infoKey = mapReplaceableKeyField(attrs), !String.isEmpty(infoKey) {
                    entryKey = infoKey
                }
                
            } else if keys_GEOB.contains(key), let attrs = item.extraAttributes, !attrs.isEmpty {
                
                // GEOB
                let kv = mapGEOB(attrs)
                if let infoKey = kv.key {
                    entryKey = infoKey
                }
                
                if let objVal = kv.value {
                    entryValue = objVal
                }
                
            } else if keys_playCounter.contains(key) {
                
                // PCNT
                entryValue = item.valueAsNumericalString
                
            } else if keys_language.contains(key), let langName = LanguageMap.forCode(value.trim()) {
                
                // TLAN
                entryValue = langName
                
            } else if keys_compilation.contains(key), let numVal = item.numberValue {
                
                // Number to boolean
                entryValue = numVal == 0 ? "No" : "Yes"
                
            } else if key.equalsOneOf(ID3_V24Spec.key_UFID, ID3_V22Spec.key_UFI), let data = item.dataValue {
                
                if let str = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\0", with: "\n") {
                    entryValue = str
                }
                
            } else if keys_mediaType.contains(key) {
                
                entryValue = ID3MediaTypes.readableString(for: value)
            }
            
            entryKey = entryKey.withEncodingAndNullsRemoved()
            entryValue = entryValue.withEncodingAndNullsRemoved()
            
            metadata[entryKey] = MetadataEntry(format: .id3, key: readableKey(entryKey), value: entryValue)
        }
        
        return metadata
    }
    
    private func mapGEOB(_ attrs: [AVMetadataExtraAttributeKey : Any]) -> (key: String?, value: String?) {
        
        var info: String?
        var value: String = ""
        
        for (k, v) in attrs {
            
            let key = k.rawValue
            let aValue = String(describing: v)
            
            if key == "info" {
                info = aValue
            } else if !String.isEmpty(aValue) {
                value += String(format: "%@ = %@, ", key, aValue)
            }
        }
        
        if value.count > 2 {
            value = value.substring(range: 0..<(value.count - 2))
        }
        
        return (info?.capitalizingFirstLetter(), value.isEmpty ? nil : value)
    }
    
    private func mapReplaceableKeyField(_ attrs: [AVMetadataExtraAttributeKey : Any]) -> String? {
        
        for (k, v) in attrs {
            
            let key = k.rawValue
            let aValue = String(describing: v)
            
            if key == "info" {
                
                if let rKey = infoKeys_TXXX[aValue.lowercased()] {
                    return rKey
                }
                
                return aValue.capitalizingFirstLetter()
            }
        }
        
        return nil
    }
    
    func getChapterTitle(_ items: [AVMetadataItem]) -> String? {
        return items.first(where: {$0.keySpace == .id3 && keys_title.contains($0.keyAsString ?? "")})?.stringValue
    }
}
