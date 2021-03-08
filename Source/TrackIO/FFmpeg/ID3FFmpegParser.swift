import Cocoa

class ID3FFmpegParser: FFmpegMetadataParser {
    
    private let keys_duration: [String] = [ID3_V24Spec.key_duration, ID3_V22Spec.key_duration].map {$0.lowercased()}
    
    private let keys_title: [String] = [ID3_V24Spec.key_title, ID3_V22Spec.key_title, ID3_V1Spec.key_title].map {$0.lowercased()}
    
    private let keys_artist: [String] = [ID3_V24Spec.key_artist, ID3_V22Spec.key_artist, ID3_V1Spec.key_artist, ID3_V24Spec.key_originalArtist, ID3_V22Spec.key_originalArtist, ID3_V24Spec.key_albumArtist, ID3_V22Spec.key_albumArtist].map {$0.lowercased()}
    
    private let keys_album: [String] = [ID3_V24Spec.key_album, ID3_V22Spec.key_album, ID3_V1Spec.key_album, ID3_V24Spec.key_originalAlbum, ID3_V22Spec.key_originalAlbum].map {$0.lowercased()}
    
    private let keys_genre: [String] = [ID3_V24Spec.key_genre, ID3_V22Spec.key_genre, ID3_V1Spec.key_genre].map {$0.lowercased()}
    
    private let keys_discNumber: [String] = [ID3_V24Spec.key_discNumber, ID3_V22Spec.key_discNumber].map {$0.lowercased()}
    private let keys_trackNumber: [String] = [ID3_V24Spec.key_trackNumber, ID3_V22Spec.key_trackNumber, ID3_V1Spec.key_trackNumber].map {$0.lowercased()}
    
    private let keys_year: [String] = [ID3_V24Spec.key_year, ID3_V22Spec.key_year, ID3_V24Spec.key_originalReleaseYear, ID3_V22Spec.key_originalReleaseYear, ID3_V24Spec.key_date, ID3_V22Spec.key_date].map {$0.lowercased()}
    
    private let keys_bpm: [String] = [ID3_V24Spec.key_bpm, ID3_V22Spec.key_bpm].map {$0.lowercased()}
    
    private let keys_lyrics: [String] = [ID3_V24Spec.key_lyrics, ID3_V22Spec.key_lyrics, ID3_V24Spec.key_syncLyrics, ID3_V22Spec.key_syncLyrics].map {$0.lowercased()}
    private let keys_art: [String] = [ID3_V24Spec.key_art, ID3_V22Spec.key_art].map {$0.lowercased()}
    
    private let keys_language: [String] = [ID3_V24Spec.key_language, ID3_V22Spec.key_language]
    private let keys_compilation: [String] = [ID3_V24Spec.key_compilation, ID3_V22Spec.key_compilation]
    private let keys_mediaType: [String] = [ID3_V24Spec.key_mediaType, ID3_V22Spec.key_mediaType]
    
    private let essentialFieldKeys: Set<String> = {
        
        Set<String>().union(ID3_V1Spec.essentialFieldKeys.map {$0.lowercased()}).union(ID3_V22Spec.essentialFieldKeys.map {$0.lowercased()}).union(ID3_V24Spec.essentialFieldKeys.map {$0.lowercased()})
    }()
    
    private let ignoredKeys: Set<String> = Set([ID3_V24Spec.key_private, ID3_V24Spec.key_tableOfContents, ID3_V24Spec.key_chapter, ID3_V24Spec.key_lyrics, ID3_V22Spec.key_lyrics, ID3_V24Spec.key_syncLyrics, ID3_V22Spec.key_syncLyrics].map {$0.lowercased()})
    
    private let genericFields: [String: String] = {
        
        var map: [String: String] = [:]
        
        ID3_V1Spec.genericFields.forEach({(k,v) in map[k.lowercased()] = v})
        ID3_V22Spec.genericFields.forEach({(k,v) in map[k.lowercased()] = v})
        ID3_V24Spec.genericFields.forEach({(k,v) in map[k.lowercased()] = v})
        
        return map
    }()
    
    func mapTrack(_ meta: FFmpegMappedMetadata) {

        let metadata = meta.id3Metadata

        for key in meta.map.keys {

            let lcKey = key.lowercased().trim()

            if !ignoredKeys.contains(lcKey) {

                if essentialFieldKeys.contains(lcKey) {

                    metadata.essentialFields[lcKey] = meta.map.removeValue(forKey: key)

                } else if genericFields[lcKey] != nil {

                    metadata.genericFields[lcKey] = meta.map.removeValue(forKey: key)
                }

            } else {
                meta.map.removeValue(forKey: key)
            }
        }
    }
    
    private func readableKey(_ key: String) -> String {
        return genericFields[key] ?? key.capitalizingFirstLetter()
    }

    func hasEssentialMetadataForTrack(_ meta: FFmpegMappedMetadata) -> Bool {
        !meta.id3Metadata.essentialFields.isEmpty
    }
    
    func hasGenericMetadataForTrack(_ meta: FFmpegMappedMetadata) -> Bool {
        !meta.id3Metadata.genericFields.isEmpty
    }

    func getTitle(_ meta: FFmpegMappedMetadata) -> String? {
        keys_title.firstNonNilMappedValue {meta.id3Metadata.essentialFields[$0]}
    }

    func getArtist(_ meta: FFmpegMappedMetadata) -> String? {
        keys_artist.firstNonNilMappedValue {meta.id3Metadata.essentialFields[$0]}
    }

    func getAlbum(_ meta: FFmpegMappedMetadata) -> String? {
        keys_album.firstNonNilMappedValue {meta.id3Metadata.essentialFields[$0]}
    }

    func getGenre(_ meta: FFmpegMappedMetadata) -> String? {
        keys_genre.firstNonNilMappedValue {meta.id3Metadata.essentialFields[$0]}
    }

    func getDiscNumber(_ meta: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {

        if let discNumStr = keys_discNumber.firstNonNilMappedValue({meta.id3Metadata.essentialFields[$0]}) {
            return ParserUtils.parseDiscOrTrackNumberString(discNumStr)
        }

        return nil
    }

    func getTrackNumber(_ meta: FFmpegMappedMetadata) -> (number: Int?, total: Int?)? {

        if let trackNumStr = keys_trackNumber.firstNonNilMappedValue({meta.id3Metadata.essentialFields[$0]}) {
            return ParserUtils.parseDiscOrTrackNumberString(trackNumStr)
        }

        return nil
    }

    func getLyrics(_ meta: FFmpegMappedMetadata) -> String? {
        keys_lyrics.firstNonNilMappedValue {meta.id3Metadata.genericFields[$0]}
    }

    func getYear(_ meta: FFmpegMappedMetadata) -> Int? {

        if let yearString = keys_year.firstNonNilMappedValue({meta.id3Metadata.genericFields[$0]}) {
            return ParserUtils.parseYear(yearString)
        }

        return nil
    }

    func getBPM(_ meta: FFmpegMappedMetadata) -> Int? {

        if let bpmString = keys_bpm.firstNonNilMappedValue({meta.id3Metadata.genericFields[$0]}) {
            return ParserUtils.parseBPM(bpmString)
        }

        return nil
    }

    func getDuration(_ meta: FFmpegMappedMetadata) -> Double? {

        if let durationStr = keys_duration.firstNonNilMappedValue({meta.id3Metadata.essentialFields[$0]}) {
            return ParserUtils.parseDuration(durationStr)
        }

        return nil
    }
    
    func getGenericMetadata(_ meta: FFmpegMappedMetadata) -> [String : MetadataEntry] {
        
        var metadata: [String: MetadataEntry] = [:]
        
        for (var key, var value) in meta.id3Metadata.genericFields {
            
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
        
        return metadata
    }
}
