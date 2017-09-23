import Cocoa
import AVFoundation

/*
    Utility for reading and categorizing track metadata
 */
class MetadataReader {
    
    // Loads the required display metadata (artist/title/art) for a track
    static func loadDisplayMetadata(_ track: Track) {
        
        var title: String?
        var artist: String?
        var art: NSImage?
        
        if (track.audioAsset == nil) {
            track.audioAsset = AVURLAsset(url: track.file, options: nil)
        }
        
        let commonMD = track.audioAsset?.commonMetadata
        
        for item in commonMD! {
            
            if (item.commonKey == AVMetadataCommonKeyTitle) {
                
                if (!Utils.isStringEmpty(item.stringValue)) {
                    title = item.stringValue!
                }
                
            } else if (item.commonKey == AVMetadataCommonKeyArtist) {
                
                if (!Utils.isStringEmpty(item.stringValue)) {
                    artist = item.stringValue!
                }
                
            } else if (item.commonKey == AVMetadataCommonKeyArtwork) {
                
                if let artwork = NSImage(data: item.value as! Data) {
                    art = artwork
                }
            }
        }
        
        track.setDisplayMetadata(artist, title, art)
    }
    
    // Loads all available metadata for a track
    static func loadAllMetadata(_ track: Track) {
        
        if (track.audioAsset == nil) {
            track.audioAsset = AVURLAsset(url: track.file, options: nil)
        }
        
        // Check which metadata formats are available
        let formats = track.audioAsset!.availableMetadataFormats
        
        // Iterate through the formats and collect metadata for each one
        for format in formats {
            
            let metadataType: MetadataType
            
            switch format {
                
            case AVMetadataFormatiTunesMetadata: metadataType = .iTunes
            case AVMetadataFormatID3Metadata: metadataType = .id3
            default: metadataType = .other
                
            }
            
            let items = track.audioAsset!.metadata(forFormat: format)
            
            // Iterate through all metadata for this format
            for item in items {
                
                let stringValue = item.stringValue
                
                if let key = item.commonKey {
                    
                    // Ignore the display metadata keys (that have already been loaded)
                    if (key != AVMetadataCommonKeyTitle && key != AVMetadataCommonKeyArtist && key != AVMetadataCommonKeyArtwork) {
                        
                        if (!Utils.isStringEmpty(stringValue)) {
                            let entry = MetadataEntry(.common, key, stringValue!)
                            track.metadata[key] = entry
                        }
                    }
                    
                } else if let key = item.key as? String {
                    
                    if (!Utils.isStringEmpty(stringValue)) {
                        let entry = MetadataEntry(metadataType, key, stringValue!)
                        track.metadata[key] = entry
                    }
                }
            }
        }
    }
    
    // Load only the metadata required for a search (e.g. album), for a track
    static func loadSearchMetadata(_ track: Track) {
        
        // Check if metadata has already been loaded
        if (track.metadata[AVMetadataCommonKeyAlbumName] != nil) {
            return
        }
        
        if (track.audioAsset == nil) {
            track.audioAsset = AVURLAsset(url: track.file, options: nil)
        }
        
        let sourceAsset = track.audioAsset!
        
        let metadataList = sourceAsset.commonMetadata
        
        for item in metadataList {
            
            if let key = item.commonKey {
                
                if (key == AVMetadataCommonKeyAlbumName) {
                    
                    if (!Utils.isStringEmpty(item.stringValue)) {
                        let entry = MetadataEntry(.common, key, item.stringValue!)
                        track.metadata[key] = entry
                    }
                }
            }
        }
    }
    
    // Computes a user-friendly key, given a format-specific key, if it has a recognized format (ID3/iTunes)
    static func formattedKey(_ entry: MetadataEntry) -> String {
        
        // Use the metadata spec to format the key
        switch entry.type {
        
        // Common space keys (camel cased) need to be split up into separate words
        case .common:   return Utils.splitCamelCaseWord(entry.key, true)
            
        case .id3:  return ID3Spec.readableKey(entry.key) ?? entry.key
            
        case .iTunes: return ITunesSpec.readableKey(entry.key) ?? entry.key
            
        // Unrecognized entry type, return key as is
        case .other: return entry.key
            
        }
    }
}

// Denotes the type (format) of a metadata entry
enum MetadataType {
    
    case common
    case iTunes
    case id3
    case other
}
