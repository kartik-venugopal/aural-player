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
        if (tlenItems.count > 0) {
            
            let tlenItem = tlenItems[0]
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
        
        var title: String?
        var artist: String?
        var art: NSImage?
        
        if (track.audioAsset == nil) {
            track.audioAsset = AVURLAsset(url: track.file, options: nil)
        }
        
        let commonMD = track.audioAsset?.commonMetadata
        
        for item in commonMD! {
            
            if (item.commonKey == AVMetadataCommonKeyTitle) {
                
                if (!StringUtils.isStringEmpty(item.stringValue)) {
                    title = item.stringValue!
                }
                
            } else if (item.commonKey == AVMetadataCommonKeyArtist) {
                
                if (!StringUtils.isStringEmpty(item.stringValue)) {
                    artist = item.stringValue!
                }
                
            } else if (item.commonKey == AVMetadataCommonKeyArtwork) {
                
                art = NSImage(data: item.value as! Data)
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
    
    // Load only the metadata required for a search (e.g. album), for a track
    static func loadSearchMetadata(_ track: Track) {
        
        // Check if metadata has already been loaded
        if (track.metadata[AVMetadataCommonKeyAlbumName] != nil) {
            return
        }
        
        if (track.audioAsset == nil) {
            track.audioAsset = AVURLAsset(url: track.file, options: nil)
        }
        
        // Album
        if let album = loadMetadataForCommonKey(track, AVMetadataCommonKeyAlbumName) {
            
            if (!StringUtils.isStringEmpty(album)) {
//                print("Album:", album, "for track:", track.conciseDisplayName)
                let entry = MetadataEntry(.common, AVMetadataCommonKeyAlbumName, album)
                track.metadata[AVMetadataCommonKeyAlbumName] = entry
            }
        }
    }
    
    static func loadGroupingMetadata(_ track: Track) {
        
        // TODO: Optimize
        loadAllMetadata(track)
        
        /*
         var artist: String?
         var album: String?
         var genre: String?
         var diskNumber: Int?
         var trackNumber: Int?
         */
        
        let artist = track.displayInfo.artist
        let album = track.metadata[AVMetadataCommonKeyAlbumName]?.value
        let genre = track.metadata[AVMetadataCommonKeyType]?.value
        let diskNumber = track.metadata[AVMetadataID3MetadataKeyPartOfASet]?.value ?? track.metadata[AVMetadataiTunesMetadataKeyDiscNumber]?.value
        let trackNumber = track.metadata[AVMetadataID3MetadataKeyTrackNumber]?.value ?? track.metadata[AVMetadataiTunesMetadataKeyTrackNumber]?.value
        
//        print("\nGroupingInfo for track:", track.conciseDisplayName)
        
        track.groupingInfo.artist = artist
        track.groupingInfo.album = album
        track.groupingInfo.genre = genre
        
//        if (artist != nil) {
//            print("\tArtist:", artist!)
//        }
//        
//        if (album != nil) {
//            print("\tAlbum:", album!)
//        }
//        
//        if (genre != nil) {
//            print("\tGenre:", genre!)
//        }
        
        // TODO: Clean up
        if let _disk = diskNumber {
            
            let disk = _disk.replacingOccurrences(of: " ", with: "")
            let numStr = disk.components(separatedBy: "/")[0]
            let num = Int(numStr)
            track.groupingInfo.diskNumber = num
//            print("\tDiskNum:", num!)
        }
        
        if let _trackNum = trackNumber {
            
            let trackNum = _trackNum.replacingOccurrences(of: " ", with: "")
            let tns = trackNum.components(separatedBy: "/")[0]
            let num = Int(tns)
            track.groupingInfo.trackNumber = num
//            print("\tTrackNum:", num!)
        }
        
//        track.groupingInfo.diskNumber = diskNumber ? Int(diskN)
//        track.groupingInfo.trackNumber = trackNumber
    }
    
    private static func loadMetadataForCommonKey(_ track: Track, _ key: String) -> String? {
        
        let id = AVMetadataItem.identifier(forKey: key, keySpace: AVMetadataKeySpaceCommon)!
        let items = AVMetadataItem.metadataItems(from: track.audioAsset!.commonMetadata, filteredByIdentifier: id)
        
        // TODO: Make this a one-liner
        if (items.count > 0) {
            
            let item = items[0]
            return item.stringValue
        }
        
        return nil
    }
    
    private static func loadMetadataForKey(_ track: Track, _ key: String, _ keySpace: String) -> String? {
        
        let id = AVMetadataItem.identifier(forKey: key, keySpace: keySpace)!
        
        let items = AVMetadataItem.metadataItems(from: track.audioAsset!.metadata, filteredByIdentifier: id)
        
        // TODO: Make this a one-liner
        if (items.count > 0) {
            
            let item = items[0]
            return item.stringValue
        }
        
        return nil
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
