import Cocoa
import AVFoundation

/*
    Utility for reading and categorizing track metadata
 */
class MetadataReader {
    
    // Identifier for ID3 TLEN metadata item
    private static let tlenID: String = AVMetadataItem.identifier(forKey: convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyLength), keySpace: AVMetadataKeySpace.id3)!.rawValue
    
    private static let playlist: PlaylistDelegateProtocol = ObjectGraph.playlistDelegate
    
    // Loads duration metadata for a track, if available
    static func loadDurationMetadata(_ track: Track) {
        
        ensureTrackAssetLoaded(track)
        
        if !track.nativelySupported || track.file.pathExtension.lowercased() == "flac" {
            
            track.setDuration(track.libAVInfo!.duration)
            
        } else {
            
            var tlenDuration: Double = 0
            
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
    }
    
    // Helper function that ensures that a track's AVURLAsset has been initialized
    private static func ensureTrackAssetLoaded(_ track: Track) {
        
        if !track.nativelySupported || track.file.pathExtension.lowercased() == "flac" {

            if track.libAVInfo == nil {
                track.libAVInfo = FFMpegWrapper.getMetadata(track)
            }

        } else {
        
            if (track.audioAsset == nil) {
                track.audioAsset = AVURLAsset(url: track.file, options: nil)
            }
        }
    }
    
    // Loads the required display metadata (artist/title/art) for a track
    static func loadDisplayMetadata(_ track: Track) {
        
        ensureTrackAssetLoaded(track)
        
        if !track.nativelySupported || track.file.pathExtension.lowercased() == "flac" {

            let metadata = track.libAVInfo!.metadata
            
            track.setDisplayMetadata(metadata["artist"], metadata["title"], nil)
            
            track.groupingInfo.artist = track.displayInfo.artist
            track.groupingInfo.album = metadata["album"]
            track.groupingInfo.genre = metadata["genre"]
            
//            print(track.groupingInfo.artist)
            
//            track.groupingInfo.discNumber = Int(metadata["disc"] ?? "")
//            track.groupingInfo.trackNumber = Int(metadata["track"] ?? "")

            // TODO: Create an op queue for this and limit the op count
//            DispatchQueue.global(qos: .userInteractive).async {
//                track.displayInfo.art = FFMpegWrapper.getArtwork(track)
//            }

        } else {
        
            let title = getMetadataForCommonKey(track.audioAsset!, AVMetadataKey.commonKeyTitle.rawValue)
            let artist = getMetadataForCommonKey(track.audioAsset!, AVMetadataKey.commonKeyArtist.rawValue)
        
            track.groupingInfo.artist = artist
            track.groupingInfo.album = getMetadataForCommonKey(track.audioAsset!, AVMetadataKey.commonKeyAlbumName.rawValue)
            track.groupingInfo.genre = getMetadataForCommonKey(track.audioAsset!, AVMetadataKey.commonKeyType.rawValue)
            
            track.setDisplayMetadata(artist, title, nil)
            
//            let art = getArtwork(track.audioAsset!)
//            track.setDisplayMetadata(artist, title, art)
            
//            track.groupingInfo.discNumber = getDiscNumber(track)
//            track.groupingInfo.trackNumber = getTrackNumber(track)
        }
    }
    
    private static func getDiscNumber(_ track: Track) -> Int? {
        
        let id3DiscNumKey = AVMetadataItem.identifier(forKey: convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyPartOfASet), keySpace: AVMetadataKeySpace.id3)!.rawValue
        
        var discNumItems = AVMetadataItem.metadataItems(from: track.audioAsset!.metadata, filteredByIdentifier: convertToAVMetadataIdentifier(id3DiscNumKey))
        if (!discNumItems.isEmpty) {
            
            let discNumItem = discNumItems.first!
            if (!StringUtils.isStringEmpty(discNumItem.stringValue)) {
                return StringUtils.parseFirstNumber(discNumItem.stringValue!)
            }
        }
        
        // iTunes
        
        let iTunesDiscNumKey = AVMetadataItem.identifier(forKey: convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyDiscNumber), keySpace: AVMetadataKeySpace.iTunes)!.rawValue
        
        discNumItems = AVMetadataItem.metadataItems(from: track.audioAsset!.metadata, filteredByIdentifier: convertToAVMetadataIdentifier(iTunesDiscNumKey))
        if (!discNumItems.isEmpty) {
            
            let discNumItem = discNumItems.first!
            
            if (!StringUtils.isStringEmpty(discNumItem.stringValue)) {
                return StringUtils.parseFirstNumber(discNumItem.stringValue!)
            }
        }
        
        return nil
    }
    
    private static func getTrackNumber(_ track: Track) -> Int? {
        
        let id3TrackNumKey = AVMetadataItem.identifier(forKey: convertFromAVMetadataKey(AVMetadataKey.id3MetadataKeyTrackNumber), keySpace: AVMetadataKeySpace.id3)!.rawValue
        
        var trackNumItems = AVMetadataItem.metadataItems(from: track.audioAsset!.metadata, filteredByIdentifier: convertToAVMetadataIdentifier(id3TrackNumKey))
        if (!trackNumItems.isEmpty) {
            
            let trackNumItem = trackNumItems.first!
            
            if (!StringUtils.isStringEmpty(trackNumItem.stringValue)) {
                return StringUtils.parseFirstNumber(trackNumItem.stringValue!)
            }
        }
        
        // iTunes
        
        let iTunesTrackNumKey = AVMetadataItem.identifier(forKey: convertFromAVMetadataKey(AVMetadataKey.iTunesMetadataKeyTrackNumber), keySpace: AVMetadataKeySpace.iTunes)!.rawValue
        
        trackNumItems = AVMetadataItem.metadataItems(from: track.audioAsset!.metadata, filteredByIdentifier: convertToAVMetadataIdentifier(iTunesTrackNumKey))
        if (!trackNumItems.isEmpty) {
            
            let trackNumItem = trackNumItems.first!
            
            if (!StringUtils.isStringEmpty(trackNumItem.stringValue)) {
                return StringUtils.parseFirstNumber(trackNumItem.stringValue!)
            }
        }
        
        return nil
    }
    
    // Loads all available metadata for a track
    static func loadAllMetadata(_ track: Track) {
        
        ensureTrackAssetLoaded(track)
        
        let fileExtension = track.file.pathExtension.lowercased()
        
        if !track.nativelySupported || fileExtension == "flac" {
            
            let ignoreKeys = ["title", "artist", "duration", "disc", "track", "album", "genre"]
            
            let metadata = track.libAVInfo!.metadata.filter({!ignoreKeys.contains($0.key)})
            
            for (key, value) in metadata {
                let capitalizedKey = key.capitalized
                track.metadata[capitalizedKey] = MetadataEntry(.other, capitalizedKey, value)
            }
            
        } else {
            
            // Display/grouping metadata can be ignored because it is already present
            let ignoreKeys = [AVMetadataKey.commonKeyTitle.rawValue, AVMetadataKey.commonKeyArtist.rawValue, AVMetadataKey.commonKeyArtwork.rawValue, AVMetadataKey.commonKeyAlbumName.rawValue, AVMetadataKey.commonKeyType.rawValue, AVMetadataKey.iTunesMetadataKeyDiscNumber.rawValue, AVMetadataKey.iTunesMetadataKeyTrackNumber.rawValue, AVMetadataKey.id3MetadataKeyPartOfASet.rawValue, AVMetadataKey.id3MetadataKeyTrackNumber.rawValue]
            
            // Check which metadata formats are available
            let formats = convertFromAVMetadataFormatArray(track.audioAsset!.availableMetadataFormats)
            
            // Iterate through the formats and collect metadata for each one
            for format in formats {
                
                let metadataType: MetadataType
                
                switch format {
                    
                case AVMetadataFormat.iTunesMetadata.rawValue: metadataType = .iTunes
                    
                case AVMetadataFormat.id3Metadata.rawValue: metadataType = .id3
                    
                default: metadataType = .other
                    
                }
                
                let items = track.audioAsset!.metadata(forFormat: convertToAVMetadataFormat(format))
                
                // Iterate through all metadata for this format
                for item in items {
                    
                    let stringValue = item.stringValue
                    
                    if let key = convertFromOptionalAVMetadataKey(item.commonKey) {
                        
                        // Ignore the display metadata keys (that have already been loaded)
                        if !ignoreKeys.contains(key) && !StringUtils.isStringEmpty(stringValue) {
                            track.metadata[key] = MetadataEntry(.common, key, stringValue!)
                        }
                        
                    } else if let key = item.key as? String, !StringUtils.isStringEmpty(stringValue) {
                        track.metadata[key] = MetadataEntry(metadataType, key, stringValue!)
                    }
                }
            }
        }
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
    
    // Loads art for a given file (used by bookmarks)
    static func loadArtworkForFile(_ file: URL) -> NSImage? {
        
        if let track = playlist.findFile(file) {
            return track.track.displayInfo.art
        }
        
        if !AudioUtils.isAudioFileNativelySupported(file) || file.pathExtension.lowercased() == "flac" {
            
            // TODO: Need to make this thread-safe and efficient
//            return FFMpegWrapper.getArtwork(file)
            return nil
        } else {
            return getArtwork(AVURLAsset(url: file, options: nil))
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
