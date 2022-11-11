//
//  CommonFFMpegMetadataParser.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
 
 album        -- name of the set this work belongs to
 album_artist -- main creator of the set/album, if different from artist.
                 e.g. "Various Artists" for compilation albums.
 artist       -- main creator of the work
 comment      -- any additional description of the file.
 composer     -- who composed the work, if different from artist.
 copyright    -- name of copyright holder.
 creation_time-- date when the file was created, preferably in ISO 8601.
 date         -- date when the work was created, preferably in ISO 8601.
 disc         -- number of a subset, e.g. disc in a multi-disc collection.
 encoder      -- name/settings of the software/hardware that produced the file.
 encoded_by   -- person/group who created the file.
 filename     -- original name of the file.
 genre        -- <self-evident>.
 language     -- main language in which the work is performed, preferably
                 in ISO 639-2 format. Multiple languages can be specified by
                 separating them with commas.
 performer    -- artist who performed the work, if different from artist.
                 E.g for "Also sprach Zarathustra", artist would be "Richard
                 Strauss" and performer "London Philharmonic Orchestra".
 publisher    -- name of the label/publisher.
 service_name     -- name of the service in broadcasting (channel name).
 service_provider -- name of the service provider in broadcasting.
 title        -- name of the work.
 track        -- number of this work in the set, can be in form current/total.
 variant_bitrate -- the total bitrate of the bitrate variant that the current stream is part of
 
 */

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

///
/// Parses "common" metadata recognized by **FFmpeg** from non-native tracks.
///
class CommonFFmpegMetadataParser: FFmpegMetadataParser {
    
    private let essentialKeys: Set<String> = [key_title, key_artist, key_albumArtist, key_album, key_performer, key_genre, key_disc, key_track]
    
    private let auxiliaryKeys: [String: String] = [
        
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
    
    func mapMetadata(_ metadataMap: FFmpegMappedMetadata) {
        
        let metadata = metadataMap.commonMetadata
        
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
        !metadataMap.commonMetadata.essentialFields.isEmpty
    }
    
    func hasAuxiliaryMetadataForTrack(_ metadataMap: FFmpegMappedMetadata) -> Bool {
        !metadataMap.commonMetadata.auxiliaryFields.isEmpty
    }
    
    func getTitle(_ metadataMap: FFmpegMappedMetadata) -> String? {
        metadataMap.commonMetadata.essentialFields[key_title]
    }
    
    func getArtist(_ metadataMap: FFmpegMappedMetadata) -> String? {
        
        metadataMap.commonMetadata.essentialFields[key_artist] ??
            metadataMap.commonMetadata.essentialFields[key_albumArtist] ??
            metadataMap.commonMetadata.essentialFields[key_performer]
    }
    
    func getAlbum(_ metadataMap: FFmpegMappedMetadata) -> String? {
        metadataMap.commonMetadata.essentialFields[key_album]
    }
    
    func getGenre(_ metadataMap: FFmpegMappedMetadata) -> String? {
        metadataMap.commonMetadata.essentialFields[key_genre]
    }
    
    func getLyrics(_ metadataMap: FFmpegMappedMetadata) -> String? {
        metadataMap.commonMetadata.auxiliaryFields[key_lyrics]
    }
    
    func getDiscNumber(_ metadataMap: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let discNumStr = metadataMap.commonMetadata.essentialFields[key_disc] {
            return ParserUtils.parseDiscOrTrackNumberString(discNumStr)
        }
        
        return nil
    }
    
    func getTrackNumber(_ metadataMap: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {
        
        if let trackNumStr = metadataMap.commonMetadata.essentialFields[key_track] {
            return ParserUtils.parseDiscOrTrackNumberString(trackNumStr)
        }
        
        return nil
    }
    
    func getYear(_ metadataMap: FFmpegMappedMetadata) -> Int? {
        
        if let yearString = metadataMap.commonMetadata.auxiliaryFields[key_date] {
            return ParserUtils.parseYear(yearString)
        }
        
        return nil
    }
    
    func getAuxiliaryMetadata(_ metadataMap: FFmpegMappedMetadata) -> [String : MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        for (key, var value) in metadataMap.commonMetadata.auxiliaryFields {
            
            if key == key_language, let langName = LanguageMap.forCode(value.trim()) {
                value = langName
            }
            
            value = value.withEncodingAndNullsRemoved()
            
            metadata[key] = MetadataEntry(format: .common, key: readableKey(key), value: value)
        }
        
        return metadata
    }
    
    func readableKey(_ key: String) -> String {
        return auxiliaryKeys[key] ?? key.capitalizingFirstLetter()
    }
}
