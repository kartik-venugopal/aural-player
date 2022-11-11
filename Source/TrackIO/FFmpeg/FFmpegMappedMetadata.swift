//
//  FFmpegMappedMetadata.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A "metadata map" that organizes a non-native (read by **FFmpeg**) track's metadata based on
/// metadata format (ID3, Vorbis Comment, etc). So, it functions as an efficient data structure
/// for repeated lookups by metadata parsers.
///
class FFmpegMappedMetadata {
    
    ///
    /// Utility object that uses ffmpeg to read metadata from this track.
    ///
    let fileCtx: FFmpegFileContext
    
    ///
    /// File extension (used to determine what kinds of metadata this file may contain).
    ///
    let fileType: String
    
    ///
    /// The "best audio stream" (as determined by **FFmpeg**) in this track. Can be nil (in an invalid track).
    /// Used to read audio metadata from the track.
    ///
    let audioStream: FFmpegAudioStream?
    
    ///
    /// An optional image stream (containing cover art).
    ///
    let imageStream: FFmpegImageStream?
    
    ///
    /// A dictionary containing a mapping of key -> value for all metadata entries.
    ///
    var map: [String: String] = [:]
    
    ///
    /// The following maps contain mappings of key -> value for each of the supported metadata formats.
    /// Metadata parsers can use these maps to quickly look up items having specific keys (e.g. "title" or "artist").
    ///
    let commonMetadata: FFmpegParserMetadataMap = FFmpegParserMetadataMap()
    let id3Metadata: FFmpegParserMetadataMap = FFmpegParserMetadataMap()
    let wmMetadata: FFmpegParserMetadataMap = FFmpegParserMetadataMap()
    let vorbisMetadata: FFmpegParserMetadataMap = FFmpegParserMetadataMap()
    let apeMetadata: FFmpegParserMetadataMap = FFmpegParserMetadataMap()
    let otherMetadata: FFmpegParserMetadataMap = FFmpegParserMetadataMap()
    
    init(for fileCtx: FFmpegFileContext) {
        
        self.fileCtx = fileCtx
        self.fileType = fileCtx.file.lowerCasedExtension
        
        self.audioStream = fileCtx.bestAudioStream
        self.imageStream = fileCtx.bestImageStream
        
        // Read all metadata entries from the file's container (ffmpeg "format context").
        for (key, value) in fileCtx.metadata {
            map[key] = value
        }
        
        // Read all metadata entries from the file's best audio stream.
        for (key, value) in audioStream?.metadata ?? [:] {
            map[key] = value
        }
    }
}

///
/// A "metadata map" that contains ffmpeg track metadata for a single metadata format (ID3, Vorbis Comment, etc).
/// So, it functions as an efficient data structure for repeated lookups by metadata parsers.
///
/// NOTE - Instances of this class are used as members by **FFmpeg**MappedMetadata.
///
class FFmpegParserMetadataMap {
    
    ///
    /// All key/value mappings for essential fields (eg. title, artist, etc)
    ///
    var essentialFields: [String: String] = [:]
    
    ///
    /// All key/value mappings for non-essential fields (eg. title, artist, etc)
    ///
    var auxiliaryFields: [String: String] = [:]
}
