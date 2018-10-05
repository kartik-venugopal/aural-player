import Cocoa
import AVFoundation

/*
    Utility for reading and categorizing track metadata
 */
class MetadataReader {
    
    // Identifier for ID3 TLEN metadata item
    private static let tlenID: String = AVMetadataItem.identifier(forKey: convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyLength), keySpace: AVMetadataKeySpace.id3)!.rawValue
    
    // Loads duration metadata for a track, if available
    static func loadDurationMetadata(_ track: Track) {
        
        var tlenDuration: Double = 0
        
        ensureTrackAssetLoaded(track)
        
        let tlenItems = AVMetadataItem.metadataItems(from: track.audioAsset!.metadata, filteredByIdentifier: convertToAVMetadataIdentifier(tlenID))
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
    
    // Helper function that ensures that a track's AVURLAsset has been initialized
    private static func ensureTrackAssetLoaded(_ track: Track) {
        if (track.audioAsset == nil) {
            track.audioAsset = AVURLAsset(url: track.file, options: nil)
        }
    }
    
    // Loads the required display metadata (artist/title/art) for a track
    static func loadDisplayMetadata(_ track: Track) {
        
        ensureTrackAssetLoaded(track)
        
        let title = getMetadataForCommonKey(track.audioAsset!, convertFromAVMetadataKey(AVMetadataKey.commonKeyTitle))
        let artist = getMetadataForCommonKey(track.audioAsset!, convertFromAVMetadataKey(AVMetadataKey.commonKeyArtist))
        let art = getArtwork(track.audioAsset!)
        
        track.setDisplayMetadata(artist, title, art)
    }
    
    // Loads all available metadata for a track
    static func loadAllMetadata(_ track: Track) {
        
        ensureTrackAssetLoaded(track)
        
        // Check which metadata formats are available
        let formats = convertFromAVMetadataFormatArray(track.audioAsset!.availableMetadataFormats)
        
        // Iterate through the formats and collect metadata for each one
        for format in formats {
            
            let metadataType: MetadataType
            
            switch format {
                
            case convertFromAVMetadataFormat(AVMetadataFormat.iTunesMetadata): metadataType = .iTunes
                
            case convertFromAVMetadataFormat(AVMetadataFormat.id3Metadata): metadataType = .id3
                
            default: metadataType = .other
                
            }
            
            let items = track.audioAsset!.metadata(forFormat: convertToAVMetadataFormat(format))
            
            // Iterate through all metadata for this format
            for item in items {
                
                let stringValue = item.stringValue
                
                if let key = convertFromOptionalAVMetadataKey(item.commonKey) {
                    
                    // Ignore the display metadata keys (that have already been loaded)
                    if (key != convertFromAVMetadataKey(AVMetadataKey.commonKeyTitle) && key != convertFromAVMetadataKey(AVMetadataKey.commonKeyArtist) && key != convertFromAVMetadataKey(AVMetadataKey.commonKeyArtwork)) {
                        
                        if (!StringUtils.isStringEmpty(stringValue)) {
                            track.metadata[key] = MetadataEntry(.common, key, stringValue!)
                        }
                    }
                    
                } else if let key = item.key as? String {
                    
                    if (!StringUtils.isStringEmpty(stringValue)) {
                        track.metadata[key] = MetadataEntry(metadataType, key, stringValue!)
                    }
                }
            }
        }
    }
    
    // Loads the required grouping metadata (artist/album/genre) for a track
    static func loadGroupingMetadata(_ track: Track) {
        
        ensureTrackAssetLoaded(track)
        
        track.groupingInfo.artist = track.displayInfo.artist
        track.groupingInfo.album = getMetadataForCommonKey(track.audioAsset!, convertFromAVMetadataKey(AVMetadataKey.commonKeyAlbumName))
        track.groupingInfo.genre = getMetadataForCommonKey(track.audioAsset!, convertFromAVMetadataKey(AVMetadataKey.commonKeyType))
    }
    
    // Retrieves the common metadata entry for the given track, with the given metadata key, if there is one
    private static func getMetadataForCommonKey(_ asset: AVURLAsset, _ key: String) -> String? {
        
        let id = AVMetadataItem.identifier(forKey: key, keySpace: AVMetadataKeySpace.common)!
        let items = AVMetadataItem.metadataItems(from: asset.commonMetadata, filteredByIdentifier: convertToAVMetadataIdentifier(id.rawValue))
        
        return (items.isEmpty || StringUtils.isStringEmpty(items.first!.stringValue)) ? nil : items.first!.stringValue
    }
    
    // Retrieves the metadata entry for the given track, with the given metadata key and key space, if there is one
    private static func getMetadataForKey(_ asset: AVURLAsset, _ key: String, _ keySpace: String) -> String? {
        
        let id = AVMetadataItem.identifier(forKey: key, keySpace: convertToAVMetadataKeySpace(keySpace))!
        let items = AVMetadataItem.metadataItems(from: asset.metadata, filteredByIdentifier: convertToAVMetadataIdentifier(id.rawValue))
        
        return (items.isEmpty || StringUtils.isStringEmpty(items.first!.stringValue)) ? nil : items.first!.stringValue
    }
    
    // Retrieves artwork for a given track, if available
    private static func getArtwork(_ asset: AVURLAsset) -> NSImage? {
        
        let id = AVMetadataItem.identifier(forKey: convertFromAVMetadataKey(AVMetadataKey.commonKeyArtwork), keySpace: AVMetadataKeySpace.common)!
        let items = AVMetadataItem.metadataItems(from: asset.commonMetadata, filteredByIdentifier: convertToAVMetadataIdentifier(id.rawValue))
        
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
    
    // Loads display information (name and artwork, if available) for the track at the given file. If no metadata is available, the display name will be derived from the file name.
    static func loadDisplayInfoForFile(_ file: URL) -> (displayName: String, art: NSImage?) {
        
        let asset = AVURLAsset(url: file, options: nil)
        
        let title = getMetadataForCommonKey(asset, convertFromAVMetadataKey(AVMetadataKey.commonKeyTitle))
        let artist = getMetadataForCommonKey(asset, convertFromAVMetadataKey(AVMetadataKey.commonKeyArtist))
        
        // Display name is a function of artist and title, if available. Defaults to filesystem file name.
        let displayName: String = title != nil ? (artist != nil ? String(format: "%@ - %@", artist!, title!) : title!) : file.deletingPathExtension().lastPathComponent
        
        return (displayName, getArtwork(asset))
    }
    
    // Loads art for a given file (used by bookmarks)
    static func loadArtworkForFile(_ file: URL) -> NSImage? {
        
        return getArtwork(AVURLAsset(url: file, options: nil))
    }
}

// Denotes the type (format) of a metadata entry
enum MetadataType: String {
    
    case common
    case iTunes
    case id3
    case other
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMetadataKey(_ input: AVMetadataKey) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToAVMetadataIdentifier(_ input: String) -> AVMetadataIdentifier {
	return AVMetadataIdentifier(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMetadataFormatArray(_ input: [AVMetadataFormat]) -> [String] {
	return input.map { key in key.rawValue }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromAVMetadataFormat(_ input: AVMetadataFormat) -> String {
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToAVMetadataFormat(_ input: String) -> AVMetadataFormat {
	return AVMetadataFormat(rawValue: input)
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromOptionalAVMetadataKey(_ input: AVMetadataKey?) -> String? {
	guard let input = input else { return nil }
	return input.rawValue
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToAVMetadataKeySpace(_ input: String) -> AVMetadataKeySpace {
	return AVMetadataKeySpace(rawValue: input)
}
