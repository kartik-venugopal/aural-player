import Cocoa
import AVFoundation

fileprivate let keySpace: String = AVMetadataKeySpace.common.rawValue

fileprivate let key_title = AVMetadataKey.commonKeyTitle.rawValue
fileprivate let key_artist = AVMetadataKey.commonKeyArtist.rawValue
fileprivate let key_album = AVMetadataKey.commonKeyAlbumName.rawValue
fileprivate let key_genre = AVMetadataKey.commonKeyType.rawValue
fileprivate let key_art: String = AVMetadataKey.commonKeyArtwork.rawValue
fileprivate let id_art: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.commonKeyArtwork.rawValue, keySpace: AVMetadataKeySpace.common)!

fileprivate let key_language: String = AVMetadataKey.commonKeyLanguage.rawValue

//fileprivate let essentialFieldKeys: Set<String> = [key_title, key_artist, key_album, key_genre, key_art]

class CommonAVFMetadataParser: AVFMetadataParser {
    
    let keySpace: AVMetadataKeySpace = .common
    
    func getTitle(_ meta: AVFMetadata) -> String? {
        meta.common[key_title]?.stringValue
    }
    
    func getArtist(_ meta: AVFMetadata) -> String? {
        meta.common[key_artist]?.stringValue
    }
    
    func getAlbum(_ meta: AVFMetadata) -> String? {
        meta.common[key_album]?.stringValue
    }
    
    func getGenre(_ meta: AVFMetadata) -> String? {
        meta.common[key_genre]?.stringValue
    }
    
    func getArt(_ meta: AVFMetadata) -> NSImage? {
        
        if let imgData = meta.common[key_art]?.dataValue, let image = NSImage(data: imgData) {
            return image
        }
        
        return nil
    }
        
//    func getChapterTitle(_ items: [AVMetadataItem]) -> String? {
//
//        return items.first(where: {
//
//            $0.keySpace == .common && $0.commonKeyAsString == AVMetadataKey.commonKeyTitle.rawValue
//
//        })?.stringValue
//    }
//
//    func getGenericMetadata(_ meta: AVFMetadata) -> [String: MetadataEntry] {
//
//        var metadata: [String: MetadataEntry] = [:]
//
//        for item in meta.genericItems.filter({item -> Bool in item.keySpace == .common}) {
//
//            if let key = item.commonKeyAsString, var value = item.valueAsString {
//
//                if key == key_language, let langName = LanguageMap.forCode(value.trim()) {
//                    value = langName
//                }
//
//                metadata[key] = MetadataEntry(.common, StringUtils.splitCamelCaseWord(key, true), value)
//            }
//        }
//
//        return metadata
//    }
}
