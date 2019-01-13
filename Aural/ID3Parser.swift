import Cocoa
import AVFoundation

class ID3Parser: AVAssetParser {
    
    private let keys_duration: [String] = [ID3_V22Spec.key_duration, ID3_V24Spec.key_duration]
    
    private let keys_title: [String] = [ID3_V1Spec.key_title, ID3_V22Spec.key_title, ID3_V24Spec.key_title]
    private let keys_artist: [String] = [ID3_V1Spec.key_artist, ID3_V22Spec.key_artist, ID3_V24Spec.key_artist]
    private let keys_album: [String] = [ID3_V1Spec.key_album, ID3_V22Spec.key_album, ID3_V24Spec.key_album]
    private let keys_genre: [String] = [ID3_V1Spec.key_genre, ID3_V22Spec.key_genre, ID3_V24Spec.key_genre]
    
    private let keys_discNumber: [String] = [ID3_V22Spec.key_discNumber, ID3_V24Spec.key_discNumber]
    private let keys_trackNumber: [String] = [ID3_V1Spec.key_trackNumber, ID3_V22Spec.key_trackNumber, ID3_V24Spec.key_trackNumber]
    
    private let keys_lyrics: [String] = [ID3_V22Spec.key_lyrics, ID3_V22Spec.key_syncLyrics, ID3_V24Spec.key_lyrics, ID3_V24Spec.key_syncLyrics]
    private let keys_art: [String] = [ID3_V22Spec.key_art, ID3_V24Spec.key_art]
    
    private let keys_GEOB: [String] = [ID3_V22Spec.key_GEO, ID3_V24Spec.key_GEOB]
    private let keys_language: [String] = [ID3_V22Spec.key_language, ID3_V24Spec.key_language]
    private let keys_playCounter: [String] = [ID3_V22Spec.key_playCounter, ID3_V24Spec.key_playCounter]
    private let keys_compilation: [String] = [ID3_V22Spec.key_compilation, ID3_V24Spec.key_compilation]
    private let keys_mediaType: [String] = [ID3_V22Spec.key_mediaType, ID3_V24Spec.key_mediaType]
    
    private let essentialFieldKeys: Set<String> = {
        
        var keys: Set<String> = Set<String>()
        keys = keys.union(ID3_V1Spec.essentialFieldKeys)
        keys = keys.union(ID3_V22Spec.essentialFieldKeys)
        keys = keys.union(ID3_V24Spec.essentialFieldKeys)
        
        return keys
    }()
    
    private let ignoredKeys: Set<String> = [ID3_V24Spec.key_private]
    
    private let genericFields: [String: String] = {
        
        var map: [String: String] = [:]
        ID3_V22Spec.genericFields.forEach({(k,v) in map[k] = v})
        ID3_V24Spec.genericFields.forEach({(k,v) in map[k] = v})
        
        return map
    }()
    
    private let id_art: AVMetadataIdentifier = AVMetadataItem.identifier(forKey: AVMetadataKey.id3MetadataKeyAttachedPicture.rawValue, keySpace: AVMetadataKeySpace.id3)!
    
    private let replaceableKeyFields: Set<String> = {
        
        var keys: Set<String> = Set<String>()
        keys = keys.union(ID3_V22Spec.replaceableKeyFields)
        keys = keys.union(ID3_V24Spec.replaceableKeyFields)
        
        return keys
    }()
    
    private let infoKeys_TXXX: [String: String] = ["albumartist": "Album Artist", "compatible_brands": "Compatible Brands", "gn_extdata": "Gracenote Data"]
    
    private func readableKey(_ key: String) -> String {
        return genericFields[key] ?? key.capitalizingFirstLetter()
    }
    
    func mapTrack(_ track: Track, _ mapForTrack: AVAssetMetadata) {
        
        for item in track.audioAsset!.metadata {
            
            if item.keySpace == .id3, let key = item.keyAsString {
                
                if ignoredKeys.contains(key) {
                    continue
                }
                
                let mapKey = String(format: "%@/%@", AVMetadataKeySpace.id3.rawValue, key)
                
                if essentialFieldKeys.contains(mapKey) {
                    mapForTrack.map[mapKey] = item
                } else {
                    // Generic field
                    mapForTrack.genericItems.append(item)
                }
            }
        }
    }
    
    func getDuration(_ mapForTrack: AVAssetMetadata) -> Double? {
        
        for key in keys_duration {
            
            if let item = mapForTrack.map[key], let durationStr = item.stringValue, let durationMsecs = Double(durationStr) {
                return durationMsecs / 1000
            }
        }
        
        return nil
    }
    
    func getTitle(_ mapForTrack: AVAssetMetadata) -> String? {
        
        for key in keys_title {

            if let titleItem = mapForTrack.map[key] {
                return titleItem.stringValue
            }
        }
        
        return nil
    }
    
    func getArtist(_ mapForTrack: AVAssetMetadata) -> String? {
        
        for key in keys_artist {

            if let artistItem = mapForTrack.map[key] {
                return artistItem.stringValue
            }
        }
        
        return nil
    }
    
    func getAlbum(_ mapForTrack: AVAssetMetadata) -> String? {
        
        for key in keys_album {

            if let albumItem = mapForTrack.map[key] {
                return albumItem.stringValue
            }
        }
        
        return nil
    }
    
    func getGenre(_ mapForTrack: AVAssetMetadata) -> String? {
        
        for key in keys_genre {

            if let genreItem = mapForTrack.map[key] {
                return ParserUtils.getID3Genre(genreItem)
            }
        }
        
        return nil
    }
    
    func getDiscNumber(_ mapForTrack: AVAssetMetadata) -> (number: Int?, total: Int?)? {
        
        for key in keys_discNumber {
            
            if let item = mapForTrack.map[key] {
                return ParserUtils.parseDiscOrTrackNumber(item)
            }
        }
        
        return nil
    }
    
    func getTrackNumber(_ mapForTrack: AVAssetMetadata) -> (number: Int?, total: Int?)? {
        
        for key in keys_trackNumber {
            
            if let item = mapForTrack.map[key] {
                return ParserUtils.parseDiscOrTrackNumber(item)
            }
        }
        
        return nil
    }
    
    func getArt(_ mapForTrack: AVAssetMetadata) -> NSImage? {
        
        for key in keys_art {
        
            if let item = mapForTrack.map[key], let imgData = item.dataValue {
                return NSImage(data: imgData)
            }
        }
        
        return nil
    }
    
    func getArt(_ asset: AVURLAsset) -> NSImage? {
        
        // V2.3/2.4
        if let item = AVMetadataItem.metadataItems(from: asset.metadata, filteredByIdentifier: ID3_V24Spec.id_art).first, let imgData = item.dataValue {
            return NSImage(data: imgData)
        }
        
        // V2.2
        for item in asset.metadata {
            
            if item.keySpace == .id3 && item.keyAsString == ID3_V22Spec.key_art, let imgData = item.dataValue {
                return NSImage(data: imgData)
            }
        }
        
        return nil
    }
    
    func getLyrics(_ mapForTrack: AVAssetMetadata) -> String? {
        
        for key in keys_lyrics {

            if let lyricsItem = mapForTrack.map[key] {
                return lyricsItem.stringValue
            }
        }
        
        return nil
    }
    
    func getGenericMetadata(_ mapForTrack: AVAssetMetadata) -> [String: MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        for item in mapForTrack.genericItems.filter({item -> Bool in item.keySpace == .id3}) {

            if let key = item.keyAsString, let value = item.valueAsString {

                var entryKey = key
                var entryValue = value

                // Special fields
                if replaceableKeyFields.contains(key), let attrs = item.extraAttributes, !attrs.isEmpty {

                    // TXXX or COMM or WXXX
                    if let infoKey = mapReplaceableKeyField(attrs), !StringUtils.isStringEmpty(infoKey) {
                        entryKey = infoKey
                    }

                } else if keys_GEOB.contains(key), let attrs = item.extraAttributes, !attrs.isEmpty {

                    // GEOB
                    let kv = mapGEOB(attrs)
                    if let infoKey = kv.key {
                        entryKey = infoKey
                    }

                    if let objVal = kv.value {
                        entryValue = objVal
                    }

                } else if keys_playCounter.contains(key) {

                    // PCNT
                    entryValue = item.valueAsNumericalString

                } else if keys_language.contains(key), let langName = LanguageMap.forCode(value.trim()) {

                    // TLAN
                    entryValue = langName
                    
                } else if keys_compilation.contains(key), let numVal = item.numberValue {
                    
                    // Number to boolean
                    entryValue = numVal == 0 ? "No" : "Yes"
                    
                } else if key == ID3_V24Spec.key_UFID || key == ID3_V22Spec.key_UFI, let data = item.dataValue {
                    
                    if let str = String(data: data, encoding: .utf8)?.replacingOccurrences(of: "\0", with: "\n") {
                        entryValue = str
                    }
                    
                } else if keys_mediaType.contains(key) {
                    
                    entryValue = ID3MediaTypes.mediaType(value)
                }

                entryKey = StringUtils.cleanUpString(entryKey)
                entryValue = StringUtils.cleanUpString(entryValue)

                metadata[entryKey] = MetadataEntry(.id3, readableKey(entryKey), entryValue)
            }
        }
        
        return metadata
    }
    
    private func mapGEOB(_ attrs: [AVMetadataExtraAttributeKey : Any]) -> (key: String?, value: String?) {
        
        var info: String?
        var value: String = ""
        
        for (k, v) in attrs {
            
            let key = k.rawValue
            let aValue = String(describing: v)
            
            if key == "info" {
                info = aValue
            } else if !StringUtils.isStringEmpty(aValue) {
                value += String(format: "%@ = %@, ", key, aValue)
            }
        }
        
        if value.count > 2 {
            value = value.substring(range: 0..<(value.count - 2))
        }
        
        return (info?.capitalizingFirstLetter(), value.isEmpty ? nil : value)
    }
    
    private func mapReplaceableKeyField(_ attrs: [AVMetadataExtraAttributeKey : Any]) -> String? {
        
        for (k, v) in attrs {
            
            let key = k.rawValue
            let aValue = String(describing: v)
            
            if key == "info" {
                
                if let rKey = infoKeys_TXXX[aValue.lowercased()] {
                    return rKey
                }
                
                return aValue.capitalizingFirstLetter()
            }
        }
        
        return nil
    }
}
