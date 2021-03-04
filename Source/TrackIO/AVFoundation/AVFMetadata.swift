import AVFoundation

class AVFMetadata {
    
    let file: URL
    let asset: AVURLAsset
    
    let items: [AVMetadataItem]
    
    var common: [String: AVMetadataItem] = [:]
    var id3: [String: AVMetadataItem] = [:]
    var iTunes: [String: AVMetadataItem] = [:]
    var audioToolbox: [String: AVMetadataItem] = [:]
    
    var keySpaces: [AVMetadataKeySpace] = []
    
    var genericMetadata: OrderedMetadataMap = OrderedMetadataMap()
    
    init(file: URL) {
        
        self.file = file
        self.asset = AVURLAsset(url: file, options: nil)
        self.items = asset.metadata
        
        for item in items {
            
            if let keySpace = item.keySpace, let key = item.keyAsString {
                
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
                        
                    } else if #available(OSX 10.13, *) {
                        
                        if keySpace == .audioFile {
                            audioToolbox[key] = item
                        }
                    }
                }
            }
        }
        
        if !common.isEmpty {
            keySpaces.append(.common)
        }
        
        let fileExt = file.pathExtension.lowercased()
        
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
