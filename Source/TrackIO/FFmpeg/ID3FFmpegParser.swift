//
//  ID3FFmpegParser.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Parses metadata in the ID3 format / key space from non-native tracks (read by **FFmpeg**).
///
class ID3FFmpegParser: FFmpegMetadataParser {
    
    private let keys_duration: [String] = [ID3_V24Spec.key_duration, ID3_V22Spec.key_duration].map {$0.lowercased()}
    
    private let keys_title: [String] = [ID3_V24Spec.key_title, ID3_V22Spec.key_title, ID3_V1Spec.key_title].map {$0.lowercased()}
    
    private let keys_artist: [String] = [ID3_V24Spec.key_artist, ID3_V22Spec.key_artist, ID3_V1Spec.key_artist, ID3_V24Spec.key_originalArtist, ID3_V22Spec.key_originalArtist, ID3_V24Spec.key_albumArtist, ID3_V22Spec.key_albumArtist].map {$0.lowercased()}
    
    private let keys_album: [String] = [ID3_V24Spec.key_album, ID3_V22Spec.key_album, ID3_V1Spec.key_album, ID3_V24Spec.key_originalAlbum, ID3_V22Spec.key_originalAlbum].map {$0.lowercased()}
    
    private let keys_genre: [String] = [ID3_V24Spec.key_genre, ID3_V22Spec.key_genre, ID3_V1Spec.key_genre].map {$0.lowercased()}
    
    private let keys_discNumber: [String] = [ID3_V24Spec.key_discNumber, ID3_V22Spec.key_discNumber].map {$0.lowercased()}
    private let keys_trackNumber: [String] = [ID3_V24Spec.key_trackNumber, ID3_V22Spec.key_trackNumber, ID3_V1Spec.key_trackNumber].map {$0.lowercased()}
    
    private let keys_year: [String] = [ID3_V24Spec.key_year, ID3_V22Spec.key_year, ID3_V24Spec.key_originalReleaseYear, ID3_V22Spec.key_originalReleaseYear, ID3_V24Spec.key_date, ID3_V22Spec.key_date].map {$0.lowercased()}
    
    private let keys_bpm: [String] = [ID3_V24Spec.key_bpm, ID3_V22Spec.key_bpm].map {$0.lowercased()}
    
    private let keys_lyrics: [String] = [ID3_V24Spec.key_lyrics, ID3_V22Spec.key_lyrics, ID3_V24Spec.key_syncLyrics, ID3_V22Spec.key_syncLyrics].map {$0.lowercased()}
    
    private let keys_language: [String] = [ID3_V24Spec.key_language, ID3_V22Spec.key_language]
    private let keys_compilation: [String] = [ID3_V24Spec.key_compilation, ID3_V22Spec.key_compilation]
    private let keys_mediaType: [String] = [ID3_V24Spec.key_mediaType, ID3_V22Spec.key_mediaType]
    
    private let essentialFieldKeys: Set<String> = {
        
        Set<String>().union(ID3_V1Spec.essentialFieldKeys.map {$0.lowercased()}).union(ID3_V22Spec.essentialFieldKeys.map {$0.lowercased()}).union(ID3_V24Spec.essentialFieldKeys.map {$0.lowercased()})
    }()
    
    private let ignoredKeys: Set<String> = Set([ID3_V24Spec.key_private, ID3_V24Spec.key_tableOfContents, ID3_V24Spec.key_chapter, ID3_V24Spec.key_lyrics, ID3_V22Spec.key_lyrics, ID3_V24Spec.key_syncLyrics, ID3_V22Spec.key_syncLyrics].map {$0.lowercased()})
    
    private let auxiliaryFields: [String: String] = {
        
        var map: [String: String] = [:]
        
        ID3_V1Spec.auxiliaryFields.forEach {(k,v) in map[k.lowercased()] = v}
        ID3_V22Spec.auxiliaryFields.forEach {(k,v) in map[k.lowercased()] = v}
        ID3_V24Spec.auxiliaryFields.forEach {(k,v) in map[k.lowercased()] = v}
        
        return map
    }()
    
    func mapMetadata(_ metadataMap: FFmpegMappedMetadata) {

        let metadata = metadataMap.id3Metadata

        for key in metadataMap.map.keys {

            let lcKey = key.lowercased().trim()

            if !ignoredKeys.contains(lcKey) {

                if essentialFieldKeys.contains(lcKey) {

                    metadata.essentialFields[lcKey] = metadataMap.map.removeValue(forKey: key)

                } else if auxiliaryFields[lcKey] != nil {

                    metadata.auxiliaryFields[lcKey] = metadataMap.map.removeValue(forKey: key)
                }

            } else {
                metadataMap.map.removeValue(forKey: key)
            }
        }
    }
    
    private func readableKey(_ key: String) -> String {
        return auxiliaryFields[key] ?? key.capitalizingFirstLetter()
    }

    func hasEssentialMetadataForTrack(_ metadataMap: FFmpegMappedMetadata) -> Bool {
        !metadataMap.id3Metadata.essentialFields.isEmpty
    }
    
    func hasAuxiliaryMetadataForTrack(_ metadataMap: FFmpegMappedMetadata) -> Bool {
        !metadataMap.id3Metadata.auxiliaryFields.isEmpty
    }

    func getTitle(_ metadataMap: FFmpegMappedMetadata) -> String? {
        keys_title.firstNonNilMappedValue {metadataMap.id3Metadata.essentialFields[$0]}
    }

    func getArtist(_ metadataMap: FFmpegMappedMetadata) -> String? {
        keys_artist.firstNonNilMappedValue {metadataMap.id3Metadata.essentialFields[$0]}
    }

    func getAlbum(_ metadataMap: FFmpegMappedMetadata) -> String? {
        keys_album.firstNonNilMappedValue {metadataMap.id3Metadata.essentialFields[$0]}
    }

    func getGenre(_ metadataMap: FFmpegMappedMetadata) -> String? {
        keys_genre.firstNonNilMappedValue {metadataMap.id3Metadata.essentialFields[$0]}
    }

    func getDiscNumber(_ metadataMap: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {

        if let discNumStr = keys_discNumber.firstNonNilMappedValue({metadataMap.id3Metadata.essentialFields[$0]}) {
            return ParserUtils.parseDiscOrTrackNumberString(discNumStr)
        }

        return nil
    }

    func getTrackNumber(_ metadataMap: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {

        if let trackNumStr = keys_trackNumber.firstNonNilMappedValue({metadataMap.id3Metadata.essentialFields[$0]}) {
            return ParserUtils.parseDiscOrTrackNumberString(trackNumStr)
        }

        return nil
    }

    func getLyrics(_ metadataMap: FFmpegMappedMetadata) -> String? {
        keys_lyrics.firstNonNilMappedValue {metadataMap.id3Metadata.auxiliaryFields[$0]}
    }

    func getYear(_ metadataMap: FFmpegMappedMetadata) -> Int? {

        if let yearString = keys_year.firstNonNilMappedValue({metadataMap.id3Metadata.auxiliaryFields[$0]}) {
            return ParserUtils.parseYear(yearString)
        }

        return nil
    }

    func getBPM(_ metadataMap: FFmpegMappedMetadata) -> Int? {

        if let bpmString = keys_bpm.firstNonNilMappedValue({metadataMap.id3Metadata.auxiliaryFields[$0]}) {
            return ParserUtils.parseBPM(bpmString)
        }

        return nil
    }

    func getDuration(_ metadataMap: FFmpegMappedMetadata) -> Double? {

        if let durationStr = keys_duration.firstNonNilMappedValue({metadataMap.id3Metadata.essentialFields[$0]}) {
            return ParserUtils.parseDuration(durationStr)
        }

        return nil
    }
    
    func getAuxiliaryMetadata(_ metadataMap: FFmpegMappedMetadata) -> [String : MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        for (var key, var value) in metadataMap.id3Metadata.auxiliaryFields {
            
            // Special fields
            if keys_language.contains(key), let langName = LanguageMap.forCode(value.trim()) {
                
                // TLAN
                value = langName
                
            } else if keys_compilation.contains(key), let numVal = Int(value) {
                
                // Number to boolean
                value = numVal == 0 ? "No" : "Yes"
                
            } else if keys_mediaType.contains(key) {
                
                value = ID3MediaTypes.readableString(for: value)
            }
            
            key = key.withEncodingAndNullsRemoved()
            value = value.withEncodingAndNullsRemoved()
            
            metadata[key] = MetadataEntry(format: .id3, key: readableKey(key), value: value)
        }
        
        return metadata
    }
}
