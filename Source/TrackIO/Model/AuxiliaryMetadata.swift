import Foundation

struct AuxiliaryMetadata {
    
    var composer: String?
    var conductor: String?
    var lyricist: String?
    
    var year: Int?
    
    var bpm: Int?
    
    var lyrics: String?
    
    var auxiliaryMetadata: [String: MetadataEntry] = [:]
    
    var fileSystemInfo: FileSystemInfo?
    var audioInfo: AudioInfo?
}
