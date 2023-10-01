//
//  DefaultFFMpegMetadataParser.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// Parses metadata from non-native tracks (read by **FFmpeg**), that was not recognized by other parsers.
///
class DefaultFFmpegMetadataParser: FFmpegMetadataParser {
    
    private let ignoredKeys: [String] = ["priv.www.amazon.com"]
    
    func mapMetadata(_ metadataMap: FFmpegMappedMetadata) {
        
        let metadata = metadataMap.otherMetadata
        
        for (key, value) in metadataMap.map {
            
            for iKey in ignoredKeys {
                
                if !key.lowercased().contains(iKey) {
                    metadata.auxiliaryFields[formatKey(key)] = value
                }
            }
            
            metadataMap.map.removeValue(forKey: key)
        }
    }
    
    func hasEssentialMetadataForTrack(_ metadataMap: FFmpegMappedMetadata) -> Bool {
        !metadataMap.otherMetadata.essentialFields.isEmpty
    }
    
    func hasAuxiliaryMetadataForTrack(_ metadataMap: FFmpegMappedMetadata) -> Bool {
        !metadataMap.otherMetadata.auxiliaryFields.isEmpty
    }

    private func formatKey(_ key: String) -> String {
        
        let tokens = key.split(separator: "_")
        var fTokens = [String]()
        
        tokens.forEach {fTokens.append(String($0).capitalizingFirstLetter())}
        
        return fTokens.joined(separator: " ")
    }
    
    func getAuxiliaryMetadata(_ metadataMap: FFmpegMappedMetadata) -> [String : MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        for (key, value) in metadataMap.otherMetadata.auxiliaryFields {
            metadata[key] = MetadataEntry(format: .other, key: key, value: value.trim().withEncodingAndNullsRemoved())
        }
        
        return metadata
    }
}
