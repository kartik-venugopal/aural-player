import Cocoa
import AVFoundation

/*
    Utility for reading and categorizing track metadata
 */
class MetadataReader {
    
    // Identifier for ID3 TLEN metadata item
    private static let tlenID: String = AVMetadataItem.identifier(forKey: AVMetadataID3MetadataKeyLength, keySpace: AVMetadataKeySpaceID3)!
    
    // Loads duration metadata for a track, if available
    static func loadDurationMetadata(_ track: Track) {
        
        var tlenDuration: Double = 0
        
        if (track.audioAsset == nil) {
            track.audioAsset = AVURLAsset(url: track.file, options: nil)
        }
        
        let tlenItems = AVMetadataItem.metadataItems(from: track.audioAsset!.metadata, filteredByIdentifier: tlenID)
        if (!tlenItems.isEmpty) {
            
            let tlenItem = tlenItems.first!
            if (!StringUtils.isStringEmpty(tlenItem.stringValue)) {
                
                if let durationMsecs = Double(tlenItem.stringValue!) {
                    tlenDuration = durationMsecs / 1000
                }
            }
        }
        
        let assetDuration = track.audioAsset!.duration.seconds
        
        track.setDuration(max(tlenDuration, assetDuration))
    }
    
    // Loads the required display metadata (artist/title/art) for a track
    static func loadDisplayMetadata(_ track: Track) {
        
        if (track.audioAsset == nil) {
            track.audioAsset = AVURLAsset(url: track.file, options: nil)
        }
        
        let title = getMetadataForCommonKey(track, AVMetadataCommonKeyTitle)
        let artist = getMetadataForCommonKey(track, AVMetadataCommonKeyArtist)
        let art = getArtwork(track)
        
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
                        
                        if (!StringUtils.isStringEmpty(stringValue)) {
                            
                            let entry = MetadataEntry(.common, key, stringValue!)
                            track.metadata[key] = entry
                        }
                    }
                    
                } else if let key = item.key as? String {
                    
                    if (!StringUtils.isStringEmpty(stringValue)) {
                        
                        let entry = MetadataEntry(metadataType, key, stringValue!)
                        track.metadata[key] = entry
                    }
                }
            }
        }
    }
    
    // Loads the required grouping metadata (artist/album/genre) for a track
    static func loadGroupingMetadata(_ track: Track) {
        
        if (track.audioAsset == nil) {
            track.audioAsset = AVURLAsset(url: track.file, options: nil)
        }
        
        track.groupingInfo.artist = track.displayInfo.artist
        track.groupingInfo.album = getMetadataForCommonKey(track, AVMetadataCommonKeyAlbumName)
        track.groupingInfo.genre = getMetadataForCommonKey(track, AVMetadataCommonKeyType)
    }
    
    // Retrieves the common metadata entry for the given track, with the given metadata key, if there is one
    private static func getMetadataForCommonKey(_ track: Track, _ key: String) -> String? {
        
        let id = AVMetadataItem.identifier(forKey: key, keySpace: AVMetadataKeySpaceCommon)!
        let items = AVMetadataItem.metadataItems(from: track.audioAsset!.commonMetadata, filteredByIdentifier: id)
        
        return (items.isEmpty || StringUtils.isStringEmpty(items.first!.stringValue)) ? nil : items.first!.stringValue
    }
    
    // Retrieves the metadata entry for the given track, with the given metadata key and key space, if there is one
    private static func getMetadataForKey(_ track: Track, _ key: String, _ keySpace: String) -> String? {
        
        let id = AVMetadataItem.identifier(forKey: key, keySpace: keySpace)!
        let items = AVMetadataItem.metadataItems(from: track.audioAsset!.metadata, filteredByIdentifier: id)
        
        return (items.isEmpty || StringUtils.isStringEmpty(items.first!.stringValue)) ? nil : items.first!.stringValue
    }
    
    // Retrieves artwork for a given track, if available
    private static func getArtwork(_ track: Track) -> NSImage? {
        
        let id = AVMetadataItem.identifier(forKey: AVMetadataCommonKeyArtwork, keySpace: AVMetadataKeySpaceCommon)!
        let items = AVMetadataItem.metadataItems(from: track.audioAsset!.commonMetadata, filteredByIdentifier: id)
        
        return (items.isEmpty || items.first!.value == nil) ? nil : NSImage(data: items.first!.value as! Data)
    }
    
    // Computes a user-friendly key, given a format-specific key, if it has a recognized format (ID3/iTunes)
    static func formattedKey(_ entry: MetadataEntry) -> String {
        
        // Use the metadata spec to format the key
        switch entry.type {
        
        // Common space keys (camel cased) need to be split up into separate words
        case .common:   return StringUtils.splitCamelCaseWord(entry.key, true)
            
        case .id3:  return ID3Spec.readableKey(entry.key) ?? entry.key
            
        case .iTunes: return ITunesSpec.readableKey(entry.key) ?? entry.key
            
        // Unrecognized entry type, return key as is
        case .other: return entry.key
            
        }
    }
}

// Denotes the type (format) of a metadata entry
enum MetadataType: String {
    
    case common
    case iTunes
    case id3
    case other
}
