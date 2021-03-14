import AVFoundation

///
/// A "metadata map" that organizes a natively supported (by AVFoundation) track's metadata based on
/// metadata format (ID3, iTunes, etc). So, it functions as an efficient data structure
/// for repeated lookups by metadata parsers.
///
class AVFMappedMetadata {
    
    ///
    /// The file whose metadata is held in this object.
    ///
    let file: URL
    
    ///
    /// The AVFoundation asset object from which metadata is obtained.
    ///
    let avAsset: AVURLAsset
    
    ///
    /// Whether or not the represented file contains any audio tracks. Used for track validation.
    ///
    var hasAudioTracks: Bool {avAsset.tracks.first(where: {$0.mediaType == .audio}) != nil}
    
    ///
    /// The AVFoundation audio track object that contains track-level information (such as bit rate).
    ///
    var audioTrack: AVAssetTrack {avAsset.tracks.first(where: {$0.mediaType == .audio})!}
    
    ///
    /// The following dictionaries contain mappings of key -> AVMetadataItem for each of the supported metadata key spaces.
    /// Metadata parsers can use these maps to quickly look up items having specific keys (e.g. "title" or "artist").
    ///
    var common: [String: AVMetadataItem] = [:]
    var id3: [String: AVMetadataItem] = [:]
    var iTunes: [String: AVMetadataItem] = [:]
    var audioToolbox: [String: AVMetadataItem] = [:]
    
    ///
    /// A collection of all the key spaces for which this track contains any metadata.
    /// Used to determine which parsers are needed to load metadata for this particular track.
    ///
    var keySpaces: [AVMetadataKeySpace] = []
    
    init(file: URL) {
        
        self.file = file
        self.avAsset = AVURLAsset(url: file, options: nil)
        
        // Iterate through all metadata items, and group them based on
        // key space.
        
        for item in avAsset.metadata {
            
            // Determine key space for this item
            guard let keySpace = item.keySpace, let key = item.keyAsString else {continue}
            
            // Put the item in its appropriate dictionary.
            
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
        
        // Determine which key spaces we have any metadata for.
        
        if !common.isEmpty {
            keySpaces.append(.common)
        }
        
        let fileExt = file.lowerCasedExtension
        
        switch fileExt {
            
        case "m4a", "m4b", "aac", "alac":
            
            // These files will commonly have iTunes metadata
            
            keySpaces.append(.iTunes)
            
            // ... and ID3 metadata, if present
            if !id3.isEmpty {
                keySpaces.append(.id3)
            }
            
        default:
            
            // Assume ID3 metadata is present (it's a common format)
            keySpaces.append(.id3)
            
            // ... and iTunes metadata, if present
            if !iTunes.isEmpty {
                keySpaces.append(.iTunes)
            }
        }
    }
}
