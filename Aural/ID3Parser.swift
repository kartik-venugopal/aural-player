import Cocoa
import AVFoundation

class ID3Parser: AVAssetParser, FFMpegMetadataParser {
    
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
                    
                } else if key == "CHAP" {
                    
                    let chm = ChapterMetadata()
                    chm.item = item
                    mapForTrack.chapters.append(chm)
                    
                } else {
                    // Generic field
                    mapForTrack.genericItems.append(item)
                }
            }
        }
    }
    
    private func readChapter(_ data: Data) -> Chapter {

        var arr: [Int] = []

        for num in data {
            arr.append(Int(num))
        }

        var metadata: [String: String] = [:]

        let firstZeroIndex = arr.firstIndex(of: 0)!
        let startTimeData = Array(arr[(firstZeroIndex + 1)..<(firstZeroIndex + 5)])
        let startTime: Double = Double(compute4ByteNumber(startTimeData)) / 1000.0

        let endTimeData = Array(arr[(firstZeroIndex + 5)..<(firstZeroIndex + 9)])
        let endTime: Double = Double(compute4ByteNumber(endTimeData)) / 1000.0
        
        var cur = firstZeroIndex + 17
        
        while cur < arr.count - 1 {
            
            // Read subframe
            let frameIdData: Data = data.subdata(in: cur..<(cur + 4))
            let frameId = frameIdData.asciiString()
            
            cur += 4
            
            if frameId == "APIC" {
                break
            }
            
            let frameSizeData = Array(arr[cur..<(cur + 4)])
            var frameSize = compute4ByteNumber(frameSizeData)
            
            // Skip size and flags
            cur += 6
            
            let encoding = arr[cur]
            var value: String
            
            switch encoding {
                
            case 0, 3:
                
                // UTF-8 or ISO-8859-1 (LATIN-1)
                
                frameSize -= 1
                cur += 1
                
                var subArray = data.subdata(in: cur..<arr.count)
                let indexOfTerminator = subArray.firstIndex(of: 0)!
                subArray = subArray.subdata(in: 0..<indexOfTerminator)
                
                cur += indexOfTerminator + 1
                value = subArray.utf8String()
                
            case 1:
                
                // UCS-2 encoded Unicode with BOM, in ID3v2.2 and ID3v2.3.
                
                frameSize -= 3
                
                // Little-endian or big-endian ?
                if arr[cur + 1] == 255 && arr[cur + 2] == 254 {
                    
                    // Little-endian
                    cur += 3
                    let valData = data.subdata(in: cur..<(cur + frameSize))
                    value = valData.utf16LEString()
                    
                } else if arr[cur + 1] == 254 && arr[cur + 2] == 255 {
                    
                    // Big-endian
                    cur += 3
                    let valData = data.subdata(in: cur..<(cur + frameSize))
                    value = valData.utf16BEString()
                    
                } else {
                
                    cur += 3
                    value = "<Unknown>"
                }
                
                cur += frameSize
                
            case 2:
                
                // UTF-16BE encoded Unicode without BOM, in ID3v2.4.
                
                frameSize -= 1
                cur += 1
                
                let valData = data.subdata(in: cur..<(cur + frameSize))
                value = valData.utf16BEString()
                
                cur += frameSize
                
            default:
                
                // IMPOSSIBLE
                cur += frameSize
                value = "<Unknown>"
            }
            
            metadata[frameId] = value
        }
        
        var title: String? = nil
        var artist: String? = nil
        var album: String? = nil
        
        for (key, value) in metadata {
            
            if key == AVMetadataKey.id3MetadataKeyTitleDescription.rawValue {
                title = value
            } else if key == AVMetadataKey.id3MetadataKeyLeadPerformer.rawValue {
                artist = value
            } else if key == AVMetadataKey.id3MetadataKeyAlbumTitle.rawValue {
                album = value
            }
        }
        
        let chapter = Chapter(startTime, endTime)
        
        chapter.title = title
        chapter.artist = artist
        chapter.album = album
        
        return chapter
    }
    
    private func compute4ByteNumber(_ arr: [Int]) -> Int {
        
        let d0 = arr[0] * (256 * 256 * 256)
        let d1 = arr[1] * (256 * 256)
        let d2 = arr[2] * 256
        let d3 = arr[3]
        
        return d0 + d1 + d2 + d3
    }
    
    func mapTrack(_ mapForTrack: LibAVMetadata) {
        
        let metadata = LibAVParserMetadata()
        mapForTrack.id3Metadata = metadata
        
        for (key, value) in mapForTrack.map {
            
            let ucKey = key.uppercased()
            
            if !ignoredKeys.contains(ucKey) {
                
                if essentialFieldKeys.contains(ucKey) {
                    
                    metadata.essentialFields[ucKey] = value
                    mapForTrack.map.removeValue(forKey: key)
                    
                } else if genericFields[ucKey] != nil {
                    
                    metadata.genericFields[ucKey] = value
                    mapForTrack.map.removeValue(forKey: key)
                }
                
            } else {
                mapForTrack.map.removeValue(forKey: key)
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
    
    func getChapters(_ mapForTrack: AVAssetMetadata) -> [Chapter]? {
        
        if mapForTrack.chapters.isEmpty {
            return nil
        }
        
        var chapters: [Chapter] = []
        
        for chapterMetadata in mapForTrack.chapters {
            
            if let item = chapterMetadata.item, let data = item.dataValue {
                chapters.append(readChapter(data))
            }
        }
        
        return chapters
    }
    
    func getTitle(_ mapForTrack: AVAssetMetadata) -> String? {
        
        for key in keys_title {

            if let titleItem = mapForTrack.map[key] {
                return titleItem.stringValue
            }
        }
        
        return nil
    }
    
    func getTitle(_ mapForTrack: LibAVMetadata) -> String? {
        
        for key in keys_title {
            
            if let title = mapForTrack.id3Metadata?.essentialFields[key] {
                return title
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
    
    func getArtist(_ mapForTrack: LibAVMetadata) -> String? {
        
        for key in keys_artist {
            
            if let artist = mapForTrack.id3Metadata?.essentialFields[key] {
                return artist
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
    
    func getAlbum(_ mapForTrack: LibAVMetadata) -> String? {
        
        for key in keys_album {
            
            if let album = mapForTrack.id3Metadata?.essentialFields[key] {
                return album
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
    
    func getGenre(_ mapForTrack: LibAVMetadata) -> String? {
        
        for key in keys_genre {
            
            if let genre = mapForTrack.id3Metadata?.essentialFields[key] {
                return genre
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
    
    func getDiscNumber(_ mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)? {
        
        for key in keys_discNumber {
            
            if let discNumStr = mapForTrack.id3Metadata?.essentialFields[key] {
                return ParserUtils.parseDiscOrTrackNumberString(discNumStr)
            }
        }
        
        return nil
    }
    
    func getTotalDiscs(_ mapForTrack: LibAVMetadata) -> Int? {
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
    
    func getTrackNumber(_ mapForTrack: LibAVMetadata) -> (number: Int?, total: Int?)? {
        
        for key in keys_trackNumber {
            
            if let trackNumStr = mapForTrack.id3Metadata?.essentialFields[key] {
                return ParserUtils.parseDiscOrTrackNumberString(trackNumStr)
            }
        }
        
        return nil
    }
    
    func getTotalTracks(_ mapForTrack: LibAVMetadata) -> Int? {
        return nil
    }
    
    func getArt(_ mapForTrack: AVAssetMetadata) -> CoverArt? {
        
        for key in keys_art {
            
            if let item = mapForTrack.map[key], let imgData = item.dataValue, let image = NSImage(data: imgData) {
                
                let metadata = ParserUtils.getImageMetadata(imgData as NSData)
                return CoverArt(image, metadata)
            }
        }
        
        return nil
    }
    
    func getArt(_ asset: AVURLAsset) -> CoverArt? {
        
        // V2.3/2.4
        if let item = AVMetadataItem.metadataItems(from: asset.metadata, filteredByIdentifier: ID3_V24Spec.id_art).first, let imgData = item.dataValue, let image = NSImage(data: imgData) {
            
            let metadata = ParserUtils.getImageMetadata(imgData as NSData)
            return CoverArt(image, metadata)
        }
        
        // V2.2
        for item in asset.metadata {
            
            if item.keySpace == .id3 && item.keyAsString == ID3_V22Spec.key_art, let imgData = item.dataValue, let image = NSImage(data: imgData) {
                
                let metadata = ParserUtils.getImageMetadata(imgData as NSData)
                return CoverArt(image, metadata)
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
    
    func getLyrics(_ mapForTrack: LibAVMetadata) -> String? {
        
        for key in keys_lyrics {
            
            if let lyrics = mapForTrack.id3Metadata?.essentialFields[key] {
                return lyrics
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
    
    func getGenericMetadata(_ mapForTrack: LibAVMetadata) -> [String : MetadataEntry] {

        var metadata: [String: MetadataEntry] = [:]
        
        if let fields = mapForTrack.id3Metadata?.genericFields {
            
            for (var key, var value) in fields {
                
                // Special fields
                if keys_language.contains(key), let langName = LanguageMap.forCode(value.trim()) {
                    
                    // TLAN
                    value = langName
                    
                } else if keys_compilation.contains(key), let numVal = Int(value) {
                    
                    // Number to boolean
                    value = numVal == 0 ? "No" : "Yes"
                    
                } else if keys_mediaType.contains(key) {
                    
                    value = ID3MediaTypes.mediaType(value)
                }
                
                key = StringUtils.cleanUpString(key)
                value = StringUtils.cleanUpString(value)
                
                metadata[key] = MetadataEntry(.id3, readableKey(key), value)
            }
        }
        
        return metadata
    }
}
