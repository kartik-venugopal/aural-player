import Cocoa
import AVFoundation

fileprivate let keySpace: String = AVMetadataKeySpace.common.rawValue

fileprivate let key_title = AVMetadataKey.commonKeyTitle.rawValue
fileprivate let key_artist = AVMetadataKey.commonKeyArtist.rawValue
fileprivate let key_album = AVMetadataKey.commonKeyAlbumName.rawValue
fileprivate let key_genre = AVMetadataKey.commonKeyType.rawValue
fileprivate let key_art: String = AVMetadataKey.commonKeyArtwork.rawValue

fileprivate let key_language: String = AVMetadataKey.commonKeyLanguage.rawValue

fileprivate let essentialFieldKeys: Set<String> = [key_title, key_artist, key_album, key_genre, key_art]

///
/// Parses metadata in the "common" format / key space from natively supported tracks (supported by AVFoundation).
///
class CommonAVFMetadataParser: AVFMetadataParser {
    
    let keySpace: AVMetadataKeySpace = .common
    
    func getTitle(_ metadataMap: AVFMappedMetadata) -> String? {
        metadataMap.common[key_title]?.stringValue
    }
    
    func getArtist(_ metadataMap: AVFMappedMetadata) -> String? {
        metadataMap.common[key_artist]?.stringValue
    }
    
    func getAlbum(_ metadataMap: AVFMappedMetadata) -> String? {
        metadataMap.common[key_album]?.stringValue
    }
    
    func getGenre(_ metadataMap: AVFMappedMetadata) -> String? {
        metadataMap.common[key_genre]?.stringValue
    }
    
    func getArt(_ metadataMap: AVFMappedMetadata) -> CoverArt? {
        
        if let imgData = metadataMap.common[key_art]?.dataValue {
            return CoverArt(imageData: imgData)
        }
        
        return nil
    }
    
    func getChapterTitle(_ items: [AVMetadataItem]) -> String? {

        return items.first(where: {

            $0.keySpace == .common && $0.commonKeyAsString == key_title

        })?.stringValue
    }

    func getAuxiliaryMetadata(_ metadataMap: AVFMappedMetadata) -> [String: MetadataEntry] {

        var metadata: [String: MetadataEntry] = [:]

        for item in metadataMap.common.values {

            if let key = item.commonKeyAsString, var value = item.valueAsString, !essentialFieldKeys.contains(key) {

                if key == key_language, let langName = LanguageMap.forCode(value.trim()) {
                    value = langName
                }

                metadata[key] = MetadataEntry(.common, key.splitAsCamelCaseWord(capitalizeEachWord: true), value)
            }
        }

        return metadata
    }
}
