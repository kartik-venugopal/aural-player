import Cocoa
import AVFoundation

fileprivate let key_title = String(format: "%@/%@", AVMetadataKeySpace.common.rawValue, AVMetadataKey.commonKeyTitle.rawValue)
fileprivate let key_artist = String(format: "%@/%@", AVMetadataKeySpace.common.rawValue, AVMetadataKey.commonKeyArtist.rawValue)
fileprivate let key_album = String(format: "%@/%@", AVMetadataKeySpace.common.rawValue, AVMetadataKey.commonKeyAlbumName.rawValue)
fileprivate let key_genre = String(format: "%@/%@", AVMetadataKeySpace.common.rawValue, AVMetadataKey.commonKeyType.rawValue)
fileprivate let key_art: String = String(format: "%@/%@", AVMetadataKeySpace.common.rawValue, AVMetadataKey.commonKeyArtwork.rawValue)
fileprivate let id_art: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.commonKeyArtwork.rawValue, keySpace: AVMetadataKeySpace.common)!

fileprivate let essentialFieldKeys: [String] = [key_title, key_artist, key_album, key_genre, key_art]

class CommonMetadataParser: MetadataParser {
    
    func mapTrack(_ track: Track, _ mapForTrack: MappedMetadata) {
        
        let items = track.audioAsset!.metadata
        
        for item in items {
            
            if let key = item.commonKeyAsString {
                
                if essentialFieldKeys.contains(key) {
                    mapForTrack.map[key] = item
                } else {
                    // Generic field
                    mapForTrack.genericMap[key] = item
                }
            }
        }
    }
    
    func getTitle(mapForTrack: MappedMetadata) -> String? {
        return nil
    }
    
    func getArtist(mapForTrack: MappedMetadata) -> String? {
        return nil
    }
    
    func getAlbum(mapForTrack: MappedMetadata) -> String? {
        return nil
    }
    
    func getGenre(mapForTrack: MappedMetadata) -> String? {
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
        return nil
    }
    
    func getArt(_ asset: AVURLAsset) -> NSImage? {
        return nil
    }
    
    static func readableKey(_ key: String) -> String {
        return ""
    }
}
