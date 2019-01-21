import Cocoa
import AVFoundation

fileprivate let keySpace: String = AVMetadataKeySpace.common.rawValue

fileprivate let key_title = String(format: "%@/%@", keySpace, AVMetadataKey.commonKeyTitle.rawValue)
fileprivate let key_artist = String(format: "%@/%@", keySpace, AVMetadataKey.commonKeyArtist.rawValue)
fileprivate let key_album = String(format: "%@/%@", keySpace, AVMetadataKey.commonKeyAlbumName.rawValue)
fileprivate let key_genre = String(format: "%@/%@", keySpace, AVMetadataKey.commonKeyType.rawValue)
fileprivate let key_art: String = String(format: "%@/%@", keySpace, AVMetadataKey.commonKeyArtwork.rawValue)
fileprivate let id_art: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.commonKeyArtwork.rawValue, keySpace: AVMetadataKeySpace.common)!

fileprivate let key_language: String = AVMetadataKey.commonKeyLanguage.rawValue

fileprivate let essentialFieldKeys: Set<String> = [key_title, key_artist, key_album, key_genre, key_art]

class CommonAVAssetParser: AVAssetParser {
    
    func mapTrack(_ track: Track, _ mapForTrack: AVAssetMetadata) {
        
        let asset = track.audioAsset!
        
        for item in asset.metadata {
            
            if item.keySpace == .common, let key = item.commonKeyAsString {
                
                let mapKey = String(format: "%@/%@", keySpace, key)
                
                if essentialFieldKeys.contains(mapKey) {
                    mapForTrack.map[mapKey] = item
                } else {
                    // Generic field
                    mapForTrack.genericItems.append(item)
                }
            }
        }
        
        // Chapters
        
        if let langCode = asset.availableChapterLocales.first?.languageCode {
            
            for grp in asset.chapterMetadataGroups(bestMatchingPreferredLanguages: [langCode]) {
                
                let chapter = ChapterMetadata()
                chapter.timedGroup = grp
                
                for item in grp.items {
                    
                    if item.keySpace == .common, let key = item.commonKeyAsString {
                        
                        let mapKey = String(format: "%@/%@", keySpace, key)
                        chapter.map[mapKey] = item
                    }
                }
                
                mapForTrack.chapters.append(chapter)
            }
        }
    }
    
    func getDuration(_ mapForTrack: AVAssetMetadata) -> Double? {
        return nil
    }
    
    func getChapters(_ mapForTrack: AVAssetMetadata) -> [Chapter]? {
        
        if mapForTrack.chapters.isEmpty {
           return nil
        }
        
        var chapters: [Chapter] = []
        
        for chp in mapForTrack.chapters {

            if let grp = chp.timedGroup {

                let start = grp.timeRange.start.seconds
                let end = grp.timeRange.end.seconds
                
                // TODO: Validate start and end times ?

                var title: String? = nil
                var artist: String? = nil
                var album: String? = nil
                
                var art: CoverArt? = nil

                if let titleItem = AVMetadataItem.metadataItems(from: grp.items, withKey: AVMetadataKey.commonKeyTitle.rawValue, keySpace: AVMetadataKeySpace.common).first {

                    title = titleItem.stringValue
                }
                
                if let artistItem = AVMetadataItem.metadataItems(from: grp.items, withKey: AVMetadataKey.commonKeyArtist.rawValue, keySpace: AVMetadataKeySpace.common).first {
                    
                    artist = artistItem.stringValue
                }
                
                if let albumItem = AVMetadataItem.metadataItems(from: grp.items, withKey: AVMetadataKey.commonKeyAlbumName.rawValue, keySpace: AVMetadataKeySpace.common).first {
                    
                    album = albumItem.stringValue
                }

                if let artItem = AVMetadataItem.metadataItems(from: grp.items, withKey: AVMetadataKey.commonKeyArtwork.rawValue, keySpace: AVMetadataKeySpace.common).first, let imgData = artItem.dataValue, let image = NSImage(data: imgData) {

                    art = CoverArt(image, ParserUtils.getImageMetadata(imgData as NSData))
                }

                let chapter = Chapter(start, end)
                
                chapter.title = title ?? String(format: "Chapter %d", chapters.count + 1)
                chapter.artist = artist
                chapter.album = album
                chapter.art = art

                chapters.append(chapter)
            }
            
            // TODO: Sort by start time ???
        }
        
        return chapters.isEmpty ? nil : chapters
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
    
    func getArt(_ mapForTrack: AVAssetMetadata) -> CoverArt? {
        
        if let item = mapForTrack.map[key_art], let imgData = item.dataValue, let image = NSImage(data: imgData) {
            
            let metadata = ParserUtils.getImageMetadata(imgData as NSData)
            return CoverArt(image, metadata)
        }
        
        return nil
    }
    
    func getArt(_ asset: AVURLAsset) -> CoverArt? {
        
        if let item = AVMetadataItem.metadataItems(from: asset.commonMetadata, filteredByIdentifier: id_art).first, let imgData = item.dataValue, let image = NSImage(data: imgData) {
            
            let metadata = ParserUtils.getImageMetadata(imgData as NSData)
            return CoverArt(image, metadata)
        }
        
        return nil
    }
    
    func getLyrics(_ mapForTrack: AVAssetMetadata) -> String? {
        return nil
    }
    
    func getGenericMetadata(_ mapForTrack: AVAssetMetadata) -> [String: MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]

        for item in mapForTrack.genericItems.filter({item -> Bool in item.keySpace == .common}) {
            
            if let key = item.commonKeyAsString, var value = item.valueAsString {
                
                if key == key_language, let langName = LanguageMap.forCode(value.trim()) {
                    value = langName
                }
                
                metadata[key] = MetadataEntry(.common, StringUtils.splitCamelCaseWord(key, true), value)
            }
        }
        
        return metadata
    }
}
