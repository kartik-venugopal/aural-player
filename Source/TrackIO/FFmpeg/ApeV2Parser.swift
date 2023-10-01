//
//  ApeV2Parser.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa
import AVFoundation

fileprivate let key_title = "title"

fileprivate let key_artist = "artist"
fileprivate let key_artists = "artists"
fileprivate let key_albumArtist = "albumartist"
fileprivate let key_albumArtist2 = "album_artist"
fileprivate let key_originalArtist = "original artist"
fileprivate let key_performer = "performer"

fileprivate let keys_artist: [String] = [key_artist, key_albumArtist, key_albumArtist2, key_originalArtist, key_artists, key_performer]

fileprivate let key_album = "album"
fileprivate let key_originalAlbum = "original album"

fileprivate let key_genre = "genre"

fileprivate let key_disc = "disc"
fileprivate let key_track = "track"
fileprivate let key_lyrics = "lyrics"

fileprivate let keys_year: [String] = ["year", "originaldate", "originalyear", "original year", "originalreleasedate", "original_year"]

fileprivate let key_bpm: String = "bpm"

///
/// A parser that reads APE v2 metadata from a non-native track, i.e. a track that
/// is read using **FFmpeg**.
///
class ApeV2Parser: FFmpegMetadataParser {

    private let essentialKeys: Set<String> = Set([key_title, key_album, key_originalAlbum, key_genre,
                                                  key_disc, key_track] + keys_artist)

    private let key_language = "language"
    private let key_compilation = "compilation"
    
    func mapMetadata(_ metadataMap: FFmpegMappedMetadata) {
        
        let metadata = metadataMap.apeMetadata
        
        for key in metadataMap.map.keys {
            
            let lcKey = key.lowercased().trim()
            
            if essentialKeys.contains(lcKey) {
                
                metadata.essentialFields[lcKey] = metadataMap.map.removeValue(forKey: key)
                
            } else if auxiliaryKeys[lcKey] != nil {
                
                metadata.auxiliaryFields[lcKey] = metadataMap.map.removeValue(forKey: key)
            }
        }
    }
    
    func hasEssentialMetadataForTrack(_ metadataMap: FFmpegMappedMetadata) -> Bool {
        !metadataMap.apeMetadata.essentialFields.isEmpty
    }
    
    func hasAuxiliaryMetadataForTrack(_ metadataMap: FFmpegMappedMetadata) -> Bool {
        !metadataMap.apeMetadata.auxiliaryFields.isEmpty
    }
    
    func getTitle(_ metadataMap: FFmpegMappedMetadata) -> String? {
        metadataMap.apeMetadata.essentialFields[key_title]
    }
    
    func getArtist(_ metadataMap: FFmpegMappedMetadata) -> String? {
        keys_artist.firstNonNilMappedValue({metadataMap.apeMetadata.essentialFields[$0]})
    }
    
    func getAlbum(_ metadataMap: FFmpegMappedMetadata) -> String? {
        metadataMap.apeMetadata.essentialFields[key_album] ?? metadataMap.apeMetadata.essentialFields[key_originalAlbum]
    }
    
    func getGenre(_ metadataMap: FFmpegMappedMetadata) -> String? {
        metadataMap.apeMetadata.essentialFields[key_genre]
    }
    
    func getDiscNumber(_ metadataMap: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let discNumStr = metadataMap.apeMetadata.essentialFields[key_disc] {
            return ParserUtils.parseDiscOrTrackNumberString(discNumStr)
        }
        
        return nil
    }
    
    func getTrackNumber(_ metadataMap: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let trackNumStr = metadataMap.apeMetadata.essentialFields[key_track] {
            return ParserUtils.parseDiscOrTrackNumberString(trackNumStr)
        }
        
        return nil
    }
    
    func getYear(_ metadataMap: FFmpegMappedMetadata) -> Int? {
        
        if let yearString = keys_year.firstNonNilMappedValue({metadataMap.apeMetadata.auxiliaryFields[$0]}) {
            return ParserUtils.parseYear(yearString)
        }
        
        return nil
    }
    
    func getBPM(_ metadataMap: FFmpegMappedMetadata) -> Int? {
        
        if let bpmString = metadataMap.apeMetadata.auxiliaryFields[key_bpm] {
            return ParserUtils.parseBPM(bpmString)
        }
        
        return nil
    }
    
    func getLyrics(_ metadataMap: FFmpegMappedMetadata) -> String? {
        metadataMap.apeMetadata.auxiliaryFields[key_lyrics]
    }
    
    private let auxiliaryKeys: [String: String] = {
        
        var map: [String: String] = [:]
        
        map["lyrics"] = "Lyrics"
        
        map["year"] = "Year"
        map["originaldate"] = "Original Date"
        map["originalreleasedate"] = "Original Release Date"
        ["originalyear", "original year", "original_year"].forEach {map[$0] = "Year"}

        map["bpm"] = "BPM"
        
        map["composer"] = "Composer"
        map["conductor"] = "Conductor"
        map["lyricist"] = "Lyricist"
        map["original lyricist"] = "Original Lyricist"
        
        map["subtitle"] = "Subtitle"
        map["debut album"] = "Debut Album"
        
        map["comment"] = "Comment"
        map["copyright"] = "Copyright"
        map["publicationright"] = "Publication Right"
        map["file"] = "File"
        map["ean/upc"] = "EAN/UPC"
        map["isbn"] = "ISBN"
        map["catalog"] = "Catalog"
        map["lc"] = "Label Code"
        
        map["record location"] = "Record Location"
        map["media"] = "Media"
        map["index"] = "Index"
        map["related"] = "Related"
        map["isrc"] = "ISRC"
        map["abstract"] = "Abstract"
        map["language"] = "Language"
        map["bibliography"] = "Bibliography"
        map["introplay"] = "Introplay"
        map["tool name"] = "Tool Name"
        map["tool version"] = "Tool Version"
        
        map["albumsort"] = "Album Sort Order"
        map["titlesort"] = "Title Sort Order"
        map["work"] = "Work Name"
        map["artistsort"] = "Artist Sort Order"
        
        map["albumartistsort"] = "Album Artist Sort Order"
        
        map["composersort"] = "Composer Sort Order"
        
        map["writer"] = "Writer"
        map["mixartist"] = "Remixer"
        map["arranger"] = "Arranger"
        map["engineer"] = "Engineer"
        map["producer"] = "Producer"
        map["publisher"] = "Publisher"
        map["djmixer"] = "DJ Mixer"
        map["mixer"] = "Mixer"
        map["label"] = "Label"
        map["movementname"] = "Movement Name"
        map["movement"] = "Movement"
        map["movementtotal"] = "Movement Count"
        map["showmovement"] = "Show Movement"
        map["grouping"] = "Grouping"
        map["discsubtitle"] = "Disc Subtitle"
        map["compilation"] = "Part of a Compilation?"
        map["mood"] = "Mood"
        map["catalognumber"] = "Catalog Number"
        map["releasecountry"] = "Release Country"
        map["record date"] = "Record Date"
        map["script"] = "Script"
        map["license"] = "License"
        map["encodedby"] = "Encoded By"
        map["encodersettings"] = "Encoder Settings"
        map["barcode"] = "Barcode"
        map["asin"] = "ASIN"
        map["weblink"] = "Official Artist Website"
        
        return map
    }()
    
    private func readableKey(_ key: String) -> String {
        
        let lcKey = key.lowercased()
        let trimmedKey = lcKey.trim()
        
        if let rKey = auxiliaryKeys[trimmedKey] {
            
            return rKey
            
        } else if let range = lcKey.range(of: trimmedKey) {
            
            return String(key[range.lowerBound..<range.upperBound]).capitalizingFirstLetter()
        }
        
        return key.capitalizingFirstLetter()
    }
    
    private func numericStringToBoolean(_ string: String) -> Bool? {
        
        if let num = Int(string.trim()) {
            return num != 0
        }
        
        return nil
    }
    
    func getAuxiliaryMetadata(_ metadataMap: FFmpegMappedMetadata) -> [String : MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        for (key, var value) in metadataMap.apeMetadata.auxiliaryFields {
            
            // Check special fields
            if key == key_language, let langName = LanguageMap.forCode(value.trim()) {
                value = langName
            } else if key == key_compilation, let bVal = numericStringToBoolean(value) {
                value = bVal ? "Yes" : "No"
            }
            
            value = value.withEncodingAndNullsRemoved()
            
            metadata[key] = MetadataEntry(format: .ape, key: readableKey(key), value: value)
        }
        
        return metadata
    }
}
