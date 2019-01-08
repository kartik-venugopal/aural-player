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

class CommonMetadataParser: MetadataParser {
    
    func mapTrack(_ track: Track, _ mapForTrack: MappedMetadata) {
        
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
    
    func getDuration(mapForTrack: MappedMetadata) -> Double? {
        return nil
    }
    
    func getTitle(mapForTrack: MappedMetadata) -> String? {
        
        if let titleItem = mapForTrack.map[key_title] {
            return titleItem.stringValue
        }
        
        return nil
    }
    
    func getArtist(mapForTrack: MappedMetadata) -> String? {
        
        if let artistItem = mapForTrack.map[key_artist] {
            return artistItem.stringValue
        }
        
        return nil
    }
    
    func getAlbum(mapForTrack: MappedMetadata) -> String? {
        
        if let albumItem = mapForTrack.map[key_album] {
            return albumItem.stringValue
        }
        
        return nil
    }
    
    func getGenre(mapForTrack: MappedMetadata) -> String? {
        
        if let genreItem = mapForTrack.map[key_genre] {
            return genreItem.stringValue
        }
        
        return nil
    }
    
    func getLyrics(mapForTrack: MappedMetadata) -> String? {
        return nil
    }
    
    func getDiscNumber(mapForTrack: MappedMetadata) -> (number: Int?, total: Int?)? {
        return nil
    }
    
    func getTrackNumber(mapForTrack: MappedMetadata) -> (number: Int?, total: Int?)? {
        return nil
    }
    
    func getArt(mapForTrack: MappedMetadata) -> NSImage? {
        
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
    
    static func readableKey(_ key: String) -> String {
        return ""
    }
}
