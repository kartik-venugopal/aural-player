import Cocoa

///
/// Parses metadata from non-native tracks (read by ffmpeg), that was not recognized by other parsers.
///
class DefaultFFmpegMetadataParser: FFmpegMetadataParser {
    
    private let ignoredKeys: [String] = ["priv.www.amazon.com"]
    
    func mapMetadata(_ metadataMap: FFmpegMappedMetadata) {
        
        let metadata = metadataMap.otherMetadata
        
        for (key, value) in metadataMap.map {
            
            for iKey in ignoredKeys {
                
                if !key.lowercased().contains(iKey) {
                    metadata.genericFields[formatKey(key)] = value
                }
            }
            
            metadataMap.map.removeValue(forKey: key)
        }
    }
    
    func hasEssentialMetadataForTrack(_ metadataMap: FFmpegMappedMetadata) -> Bool {
        !metadataMap.otherMetadata.essentialFields.isEmpty
    }
    
    func hasGenericMetadataForTrack(_ metadataMap: FFmpegMappedMetadata) -> Bool {
        !metadataMap.otherMetadata.genericFields.isEmpty
    }

    private func formatKey(_ key: String) -> String {
        
        let tokens = key.split(separator: "_")
        var fTokens = [String]()
        
        tokens.forEach({fTokens.append(String($0).capitalizingFirstLetter())})
        
        return fTokens.joined(separator: " ")
    }
    
    func getAuxiliaryMetadata(_ metadataMap: FFmpegMappedMetadata) -> [String : MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        for (key, value) in metadataMap.otherMetadata.genericFields {
            metadata[key] = MetadataEntry(.other, key, StringUtils.cleanUpString(value.trim()))
        }
        
        return metadata
    }
}
