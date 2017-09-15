import Cocoa
import AVFoundation

class MetadataReader {
    
    static func loadDisplayMetadata(_ track: Track) {
        
        var title: String?
        var artist: String?
        var art: NSImage?
        
        if (track.avAsset == nil) {
            track.avAsset = AVURLAsset(url: track.file, options: nil)
        }
        
        let commonMD = track.avAsset?.commonMetadata
        
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
        
        track.setDisplayMetadata(title, artist, art)
    }
    
    static func loadAllMetadata(_ track: Track) {
        
        if (track.avAsset == nil) {
            track.avAsset = AVURLAsset(url: track.file, options: nil)
        }
        
        let formats = track.avAsset!.availableMetadataFormats
        
        for format in formats {
            
            let metadataType: MetadataType
            
            switch format {
                
            case AVMetadataFormatiTunesMetadata: metadataType = .iTunes
            case AVMetadataFormatID3Metadata: metadataType = .id3
            default: metadataType = .other
                
            }
            
            let items = track.avAsset!.metadata(forFormat: format)
            
            for item in items {
                
                let val = item.stringValue
                
                if let key = item.commonKey {
                    
                    // Ignore the display metadata keys (that have already been loaded)
                    if (key != AVMetadataCommonKeyTitle && key != AVMetadataCommonKeyArtist && key != AVMetadataCommonKeyArtwork) {
                        
                        if (!Utils.isStringEmpty(val)) {
                            let entry = MetadataEntry(.common, key, val!)
                            track.metadata[key] = entry
                        }
                    }
                    
                } else {
                    
                    if let key = item.key as? String {
                        
                        if (!Utils.isStringEmpty(val)) {
                            let entry = MetadataEntry(metadataType, key, val!)
                            track.metadata[key] = entry
                        }
                    }
                }
            }
        }
    }
    
    // (Lazily) load extended metadata (e.g. album), for a search, when it is requested by the UI
    static func loadSearchMetadata(_ track: Track) {
        
        // Check if metadata has already been loaded
        if (track.metadata[AVMetadataCommonKeyAlbumName] != nil) {
            return
        }
        
        let sourceAsset = track.avAsset!
        
        // Retrieve extended metadata (ID3)
        let metadataList = sourceAsset.commonMetadata
        
        for item in metadataList {
            
            if item.commonKey == nil || item.value == nil {
                continue
            }
            
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
    
    static func formattedKey(_ entry: MetadataEntry) -> String {
        
        switch entry.type {
            
        case .common:   return Utils.splitCamelCaseWord(entry.key, true)
            
        case .id3:  return ID3Spec.readableKey(entry.key) ?? entry.key
            
        case .iTunes: return ITunesSpec.readableKey(entry.key) ?? entry.key
            
        case .other: return entry.key
            
        }
    }
}

enum MetadataType {
    
    case common
    case iTunes
    case id3
    case other
}
