import AVFoundation

class AVFMetadata {
    
    let file: URL
    let asset: AVURLAsset
    
    var common: [String: AVMetadataItem] = [:]
    var id3: [String: AVMetadataItem] = [:]
    var iTunes: [String: AVMetadataItem] = [:]
    var audioToolbox: [String: AVMetadataItem] = [:]
    
    var keySpaces: [AVMetadataKeySpace] = []
    
    init(file: URL) {
        
        self.file = file
        self.asset = AVURLAsset(url: file, options: nil)
        
        for item in asset.metadata {
            
            guard let keySpace = item.keySpace, let key = item.keyAsString else {continue}
            
            switch keySpace {
            
            case .id3:
                
                id3[key] = item
                
            case .iTunes:
                
                iTunes[key] = item
                
            case .common:
                
                common[key] = item
                
            default:
                
                // iTunes long format
                
                if keySpace.rawValue.lowercased() == ITunesSpec.longForm_keySpaceID {
                    iTunes[key] = item
                    
                } else if #available(OSX 10.13, *), keySpace == .audioFile {
                    audioToolbox[key] = item
                }
            }
        }
        
        if !common.isEmpty {
            keySpaces.append(.common)
        }
        
        let fileExt = file.lowerCasedExtension
        
        switch fileExt {
            
        case "m4a", "m4b", "aac", "alac":
            
            keySpaces.append(.iTunes)
            
            if !id3.isEmpty {
                keySpaces.append(.id3)
            }
            
        default:
            
            keySpaces.append(.id3)
            
            if !iTunes.isEmpty {
                keySpaces.append(.iTunes)
            }
        }
    }
}
