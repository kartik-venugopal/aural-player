import Cocoa
import AVFoundation

fileprivate let keySpace: String = AVMetadataKeySpace.common.rawValue

fileprivate let key_title = String(format: "%@/%@", keySpace, AVMetadataKey.commonKeyTitle.rawValue)
fileprivate let key_artist = String(format: "%@/%@", keySpace, AVMetadataKey.commonKeyArtist.rawValue)
fileprivate let key_album = String(format: "%@/%@", keySpace, AVMetadataKey.commonKeyAlbumName.rawValue)
fileprivate let key_genre = String(format: "%@/%@", keySpace, AVMetadataKey.commonKeyType.rawValue)
fileprivate let key_art: String = String(format: "%@/%@", keySpace, AVMetadataKey.commonKeyArtwork.rawValue)
fileprivate let id_art: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.commonKeyArtwork.rawValue, keySpace: AVMetadataKeySpace.common)!

fileprivate let essentialFieldKeys: [String] = [key_title, key_artist, key_album, key_genre, key_art]

class CommonAVAssetParser: AVAssetParser {
    
    func mapTrack(_ track: Track, _ mapForTrack: AVAssetMetadata) {
        
        let items = track.audioAsset!.metadata
        
        for item in items {
            
            if item.keySpace == AVMetadataKeySpace.common, let key = item.commonKeyAsString {
                
                let mapKey = String(format: "%@/%@", keySpace, key)
                
                if essentialFieldKeys.contains(mapKey) {
                    mapForTrack.map[mapKey] = item
                } else {
                    // Generic field
                    mapForTrack.genericMap[mapKey] = item
                }
            }
        }
    }
    
    func getDuration(_ mapForTrack: AVAssetMetadata) -> Double? {
        return nil
    }
    
    func getTitle(_ mapForTrack: AVAssetMetadata) -> String? {
        
        if let titleItem = mapForTrack.map[key_title] {
            return titleItem.stringValue
        }
        
        return nil
    }
    
    func getArtist(_ mapForTrack: AVAssetMetadata) -> String? {
        
        if let artistItem = mapForTrack.map[key_artist] {
            return artistItem.stringValue
        }
        
        return nil
    }
    
    func getAlbum(_ mapForTrack: AVAssetMetadata) -> String? {
        
        if let albumItem = mapForTrack.map[key_album] {
            return albumItem.stringValue
        }
        
        return nil
    }
    
    func getGenre(_ mapForTrack: AVAssetMetadata) -> String? {
        
        if let genreItem = mapForTrack.map[key_genre] {
            return genreItem.stringValue
        }
        
        return nil
    }
    
    func getDiscNumber(_ mapForTrack: AVAssetMetadata) -> (number: Int?, total: Int?)? {
        return nil
    }
    
    func getTrackNumber(_ mapForTrack: AVAssetMetadata) -> (number: Int?, total: Int?)? {
        return nil
    }
    
    func getArt(_ mapForTrack: AVAssetMetadata) -> NSImage? {
        
        if let item = mapForTrack.map[key_art], let imgData = item.dataValue {
            return NSImage(data: imgData)
        }
        
        return nil
    }
    
    func getArt(_ asset: AVURLAsset) -> NSImage? {
        
        if let item = AVMetadataItem.metadataItems(from: asset.commonMetadata, filteredByIdentifier: id_art).first, let imgData = item.dataValue {
            return NSImage(data: imgData)
        }
        
        return nil
    }
    
    func getLyrics(_ mapForTrack: AVAssetMetadata) -> String? {
        return nil
    }
    
    func getGenericMetadata(_ mapForTrack: AVAssetMetadata) -> [String: MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        for item in mapForTrack.genericMap.values.filter({item -> Bool in item.keySpace == .common}) {
            
            if let key = item.keyAsString, let value = item.valueAsString {
                metadata[key] = MetadataEntry(.common, StringUtils.splitCamelCaseWord(key, true), value)
            }
        }
        
        return metadata
    }
    
    static func readableKey(_ key: String) -> String {
        return ""
    }
}
