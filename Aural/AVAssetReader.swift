import Cocoa
import AVFoundation

class AVAssetReader: MetadataReader {
    
    private let commonId_title: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.commonKeyTitle.rawValue, keySpace: AVMetadataKeySpace.common)!
    private let commonId_artist: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.commonKeyArtist.rawValue, keySpace: AVMetadataKeySpace.common)!
    private let commonId_album: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.commonKeyAlbumName.rawValue, keySpace: AVMetadataKeySpace.common)!
    private let commonId_genre: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.commonKeyType.rawValue, keySpace: AVMetadataKeySpace.common)!
    private let commonId_art: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.commonKeyArtwork.rawValue, keySpace: AVMetadataKeySpace.common)!
    
    // Identifier for ID3 TLEN metadata item
    private let id3Id_TLEN: AVMetadataIdentifier = AVMetadataIdentifier(rawValue: AVMetadataKey.id3MetadataKeyLength.rawValue)
    
    private let id3Id_discNum: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.id3MetadataKeyPartOfASet.rawValue, keySpace: AVMetadataKeySpace.id3)!

    private let id3Id_trackNum: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.id3MetadataKeyTrackNumber.rawValue, keySpace: AVMetadataKeySpace.id3)!
    
    private let iTunesId_discNum: AVMetadataIdentifier = AVMetadataIdentifier(rawValue: AVMetadataKey.iTunesMetadataKeyDiscNumber.rawValue)
    private let iTunesId_trackNum: AVMetadataIdentifier = AVMetadataIdentifier(rawValue: AVMetadataKey.iTunesMetadataKeyTrackNumber.rawValue)
    
    private let genericMetadata_ignoreKeys: [String] = [AVMetadataKey.commonKeyTitle.rawValue, AVMetadataKey.commonKeyArtist.rawValue, AVMetadataKey.commonKeyArtwork.rawValue, AVMetadataKey.commonKeyAlbumName.rawValue, AVMetadataKey.commonKeyType.rawValue, AVMetadataKey.iTunesMetadataKeyDiscNumber.rawValue, AVMetadataKey.iTunesMetadataKeyTrackNumber.rawValue, AVMetadataKey.id3MetadataKeyPartOfASet.rawValue, AVMetadataKey.id3MetadataKeyTrackNumber.rawValue]
    
    // Helper function that ensures that a track's AVURLAsset has been initialized
    private func ensureTrackAssetLoaded(_ track: Track) {
        
        if (track.audioAsset == nil) {
            track.audioAsset = AVURLAsset(url: track.file, options: nil)
        }
    }
    
    // Retrieves the common metadata entry for the given track, with the given metadata key, if there is one
    private func getMetadataForId(_ asset: AVURLAsset, _ id: AVMetadataIdentifier) -> String? {
        
        let items = AVMetadataItem.metadataItems(from: asset.metadata, filteredByIdentifier: id)
        
        if let first = items.first, !StringUtils.isStringEmpty(first.stringValue) {
            return first.stringValue
        }
        
        return nil
    }
    
    // Retrieves artwork for a given track, if available
    private func getArtwork(_ asset: AVURLAsset) -> NSImage? {
        
        let items = AVMetadataItem.metadataItems(from: asset.commonMetadata, filteredByIdentifier: commonId_art)
        
        if let first = items.first, let imgData = first.dataValue {
            return NSImage(data: imgData)
        }
        
        return nil
    }
    
    // Computes a user-friendly key, given a format-specific key, if it has a recognized format (ID3/iTunes)
    private func formattedKey(_ entry: MetadataEntry) -> String {
        
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
    
    func getPrimaryMetadata(_ track: Track) -> PrimaryMetadata {
        
        ensureTrackAssetLoaded(track)
        
        let title = getMetadataForId(track.audioAsset!, commonId_title)
        let artist = getMetadataForId(track.audioAsset!, commonId_artist)
        let album = getMetadataForId(track.audioAsset!, commonId_album)
        let genre = getMetadataForId(track.audioAsset!, commonId_genre)
        
        let duration = getDuration(track)
        
        return PrimaryMetadata(title, artist, album, genre, duration)
    }
    
    func getSecondaryMetadata(_ track: Track) -> SecondaryMetadata {
        
        ensureTrackAssetLoaded(track)
        
        let art = getArtwork(track.audioAsset!)
        let discNum = getDiscNumber(track)
        let trackNum = getTrackNumber(track)
        
        return SecondaryMetadata(art, discNum, trackNum)
    }
    
    // Loads duration metadata for a track, if available
    func getDuration(_ track: Track) -> Double {
        
        var tlenDuration: Double = 0
        
        if let tlenValue = getMetadataForId(track.audioAsset!, id3Id_TLEN) {
            
            if let durationMsecs = Double(tlenValue) {
                tlenDuration = durationMsecs / 1000
            }
        }
        
        let assetDuration = track.audioAsset!.duration.seconds
        
        return max(tlenDuration, assetDuration)
    }
    
    func getArt(_ track: Track) -> NSImage? {
        
        ensureTrackAssetLoaded(track)
        return getArtwork(track.audioAsset!)
    }
    
    func getArt(_ file: URL) -> NSImage? {
        return getArtwork(AVURLAsset(url: file, options: nil))
    }
    
    func getAllMetadata(_ track: Track) -> [String: MetadataEntry] {
        
        ensureTrackAssetLoaded(track)
        
        var metadata: [String: MetadataEntry] = [:]
        
        // Check which metadata formats are available
        let formats = track.audioAsset!.availableMetadataFormats
        
        // Iterate through the formats and collect metadata for each one
        for format in formats {
            
            let metadataType: MetadataType
            
            switch format {
                
            case AVMetadataFormat.iTunesMetadata: metadataType = .iTunes
                
            case AVMetadataFormat.id3Metadata: metadataType = .id3
                
            default: metadataType = .other
                
            }
            
            let items = track.audioAsset!.metadata(forFormat: format)
            
            
            // Iterate through all metadata for this format
            for item in items {
                
                let stringValue = item.stringValue
                
                if let key = item.commonKey?.rawValue {
                    
                    // Ignore the display metadata keys (that have already been loaded)
                    if !genericMetadata_ignoreKeys.contains(key) && !StringUtils.isStringEmpty(stringValue) {
                        metadata[key] = MetadataEntry(.common, key, stringValue!)
                    }
                    
                } else if let key = item.key as? String, !StringUtils.isStringEmpty(stringValue) {
                    metadata[key] = MetadataEntry(metadataType, key, stringValue!)
                }
            }
        }
        
        return metadata
    }
    
    private func getDiscNumber(_ track: Track) -> Int? {

        // ID3

        if let discNumStr = getMetadataForId(track.audioAsset!, id3Id_discNum) {
            return StringUtils.parseFirstNumber(discNumStr)
        }

        // iTunes

        if let discNumStr = getMetadataForId(track.audioAsset!, iTunesId_discNum) {
            return StringUtils.parseFirstNumber(discNumStr)
        }

        return nil
    }
    
    private func getTrackNumber(_ track: Track) -> Int? {
        
        // ID3
        
        if let trackNumStr = getMetadataForId(track.audioAsset!, id3Id_trackNum) {
            return StringUtils.parseFirstNumber(trackNumStr)
        }
        
        // iTunes
        
        if let trackNumStr = getMetadataForId(track.audioAsset!, iTunesId_trackNum) {
            return StringUtils.parseFirstNumber(trackNumStr)
        }
        
        return nil
    }
    
    func getDurationForFile(_ file: URL) -> Double {
        
        let asset = AVURLAsset(url: file, options: nil)
        return asset.duration.seconds
    }
}
