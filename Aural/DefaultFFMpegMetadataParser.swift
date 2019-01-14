import Cocoa

class DefaultFFMpegMetadataParser: FFMpegMetadataParser {
    
    private let ignoredKeys: [String] = ["priv.www.amazon.com"]
    
    func mapTrack(_ mapForTrack: LibAVMetadata) {
        
        let metadata = LibAVParserMetadata()
        mapForTrack.otherMetadata = metadata
        
        for (key, value) in mapForTrack.map {
            
            for iKey in ignoredKeys {
                
                if !key.lowercased().contains(iKey) {
                    
                    let fKey = formatKey(key)
                    
                    metadata.genericFields[fKey] = value
                }
            }
            
            mapForTrack.map.removeValue(forKey: key)
        }
    }

    private func formatKey(_ key: String) -> String {
        
        let tokens = key.split(separator: "_")
        var fTokens = [String]()
        
        tokens.forEach({fTokens.append($0.lowercased().capitalizingFirstLetter())})
        
        let joined = fTokens.joined(separator: " ")
        return joined
    }
    
    func getGenericMetadata(_ mapForTrack: LibAVMetadata) -> [String : MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        if let fields = mapForTrack.otherMetadata?.genericFields {
            
            for (key, value) in fields {
                metadata[key] = MetadataEntry(.other, key, StringUtils.cleanUpString(value.trim()))
            }
        }
        
        return metadata
    }
    
    func getTitle(_ mapForTrack: LibAVMetadata) -> String? {
        return nil
    }
    
    func getArtist(_ mapForTrack: LibAVMetadata) -> String? {
        return nil
    }
    
    func getAlbum(_ mapForTrack: LibAVMetadata) -> String? {
        return nil
    }
    
    func getGenre(_ mapForTrack: LibAVMetadata) -> String? {
        return nil
    }
    
    func getLyrics(_ mapForTrack: LibAVMetadata) -> String? {
        return nil
    }
    
    func getDiscNumber(_ mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)? {
        return nil
    }
    
    func getTotalDiscs(_ mapForTrack: LibAVMetadata) -> Int? {
        return nil
    }
    
    func getTrackNumber(_ mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)? {
        return nil
    }
    
    func getTotalTracks(_ mapForTrack: LibAVMetadata) -> Int? {
        return nil
    }
}
