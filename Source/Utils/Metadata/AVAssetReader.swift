import Cocoa
import AVFoundation

class AVAssetReader: MetadataReader, MessageSubscriber {
    
    var allParsers: [AVAssetParser]
    var muxer: MuxerProtocol
    
    private var metadataMap: ConcurrentMap<Track, AVAssetMetadata> = ConcurrentMap<Track, AVAssetMetadata>("metadataMap")
    
    init(_ commonAVAssetParser: CommonAVAssetParser, _ id3Parser: ID3Parser, _ iTunesParser: ITunesParser, _ audioToolboxParser: AudioToolboxParser, _ muxer: MuxerProtocol) {
        
        let osVersion = SystemUtils.osVersion
        
        if (osVersion.majorVersion == 10 && osVersion.minorVersion >= 13) || osVersion.majorVersion > 10 {
            self.allParsers = [commonAVAssetParser, id3Parser, iTunesParser, audioToolboxParser]
            
        } else {
            self.allParsers = [commonAVAssetParser, id3Parser, iTunesParser]
        }
        
        self.muxer = muxer
        
        Messenger.subscribeAsync(self, .tracksRemoved, self.tracksRemoved(_:), queue: DispatchQueue.global(qos: .background))
    }
    
    // Helper function that ensures that a track's AVURLAsset has been initialized
    private func ensureTrackAssetLoaded(_ track: Track) {
        
        if (track.audioAsset == nil) {
            
            track.audioAsset = AVURLAsset(url: track.file, options: nil)
            mapMetadata(track)
        }
    }
    
    private func mapMetadata(_ track: Track) {
        
        let mapForTrack = AVAssetMetadata()
        allParsers.forEach({$0.mapTrack(track, mapForTrack)})
        metadataMap[track] = mapForTrack
    }
    
    func getPrimaryMetadata(_ track: Track) -> PrimaryMetadata {
        
        ensureTrackAssetLoaded(track)
        
        let title = nilIfEmpty(getTitle(track))
        let artist = nilIfEmpty(getArtist(track))
        let album = nilIfEmpty(getAlbum(track))
        let genre = nilIfEmpty(getGenre(track))
        
        let duration = getDuration(track)
        
        return PrimaryMetadata(title, artist, album, genre, duration)
    }
    
    private func nilIfEmpty(_ string: String?) -> String? {
        return StringUtils.isStringEmpty(string) ? nil : string
    }
    
    func getDuration(_ track: Track) -> Double {
        
        // Mux raw streams into containers to get accurate duration data (necessary for proper playback)
        if muxer.trackNeedsMuxing(track), let trackDuration = muxer.muxForDuration(track) {
            return trackDuration
        }
        
        var maxDuration: Double = track.audioAsset!.duration.seconds
        
        for parser in allParsers {
            
            if let map = metadataMap[track], let duration = parser.getDuration(map), duration > maxDuration {
                maxDuration = duration
            }
        }
        
        return maxDuration
    }
    
    private func getTitle(_ track: Track) -> String? {
        
        if let map = metadataMap[track] {
        
            for parser in allParsers {
                
                if let title = parser.getTitle(map) {
                    return title
                }
            }
        }
        
        return nil
    }
    
    private func getArtist(_ track: Track) -> String? {
        
        if let map = metadataMap[track] {
            
            for parser in allParsers {
                
                if let artist = parser.getArtist(map) {
                    return artist
                }
            }
        }
        
        return nil
    }
    
    private func getAlbum(_ track: Track) -> String? {
        
        if let map = metadataMap[track] {
            
            for parser in allParsers {
                
                if let album = parser.getAlbum(map) {
                    return album
                }
            }
        }
        
        return nil
    }
    
    private func getGenre(_ track: Track) -> String? {
        
        if let map = metadataMap[track] {
            
            for parser in allParsers {
                
                if let genre = parser.getGenre(map) {
                    return genre
                }
            }
        }
        
        return nil
    }
    
    func getSecondaryMetadata(_ track: Track) -> SecondaryMetadata {
        
        ensureTrackAssetLoaded(track)
        
        let discInfo = getDiscNumber(track)
        let trackInfo = getTrackNumber(track)
        let lyrics = nilIfEmpty(getLyrics(track))
        
        return SecondaryMetadata(discInfo?.number, discInfo?.total, trackInfo?.number, trackInfo?.total, lyrics)
    }
    
    private func getDiscNumber(_ track: Track) -> (number: Int?, total: Int?)? {
        
        if let map = metadataMap[track] {
            
            for parser in allParsers {
                
                if let discNum = parser.getDiscNumber(map) {
                    return discNum
                }
            }
        }
        
        return nil
    }
    
    private func getTrackNumber(_ track: Track) -> (number: Int?, total: Int?)? {
        
        if let map = metadataMap[track] {
            
            for parser in allParsers {
                
                if let trackNum = parser.getTrackNumber(map) {
                    return trackNum
                }
            }
        }
        
        return nil
    }
    
    private func getLyrics(_ track: Track) -> String? {
        
        if let lyrics = track.audioAsset?.lyrics {
            return lyrics
        }
        
        if let map = metadataMap[track] {
            
            for parser in allParsers {
                
                if let lyrics = parser.getLyrics(map) {
                    return lyrics
                }
            }
        }
        
        return nil
    }
    
    // TODO: Revisit this func and the use cases needing it
    func getDurationForFile(_ file: URL) -> Double {
        return AVURLAsset(url: file, options: nil).duration.seconds
    }
    
    func getAllMetadata(_ track: Track) -> [String: MetadataEntry] {
        
        ensureTrackAssetLoaded(track)
        
        var metadata: [String: MetadataEntry] = [:]
        
        if let map = metadataMap[track] {
            
            for parser in allParsers {
                
                let parserMetadata = parser.getGenericMetadata(map)
                parserMetadata.forEach({(k,v) in metadata[k] = v})
            }
        }
        
        return metadata
    }
    
    func getArt(_ track: Track) -> CoverArt? {
        
        ensureTrackAssetLoaded(track)
        
        if let map = metadataMap[track] {
            
            for parser in allParsers {
                
                if let art = parser.getArt(map) {
                    return art
                }
            }
        }
        
        return nil
    }
    
    func getArt(_ file: URL) -> CoverArt? {
        return getArt(AVURLAsset(url: file, options: nil))
    }
    
    // Retrieves artwork for a given track, if available
    private func getArt(_ asset: AVURLAsset) -> CoverArt? {
        
        for parser in allParsers {
            
            if let art = parser.getArt(asset) {
                return art
            }
        }
        
        return nil
    }
    
    // Reads all chapter metadata for a given track
    // NOTE - This code does not account for potential overlaps in chapter times due to bad metadata ... assumes no overlaps
    func getChapters(_ track: Track) -> [Chapter] {
        
        // On older systems (Sierra/HighSierra), the end times are not properly read by AVFoundation
        // So, use start times to compute end times / duration
        let fileExtension = track.file.pathExtension.lowercased()
        let useAlternativeComputation = SystemUtils.osVersion.minorVersion < 14 && !["m4a", "m4b"].contains(fileExtension)
        
        if useAlternativeComputation {
            return getChapters_olderSystems(track)
        }
        
        var chapters: [Chapter] = []
        
        if let asset = track.audioAsset, let langCode = asset.availableChapterLocales.first?.languageCode {
            
            let chapterMetadataGroups = asset.chapterMetadataGroups(bestMatchingPreferredLanguages: [langCode])
        
            // Each group represents one chapter
            for group in chapterMetadataGroups {
                
                let title: String = getChapterTitle(group.items) ?? ""

                let timeRange = group.timeRange
                let start = timeRange.start.seconds
                let end = timeRange.end.seconds
                let duration = timeRange.duration.seconds
                
                // Validate the time fields for NaN and negative values
                let correctedStart = (start.isNaN || start < 0) ? 0 : start
                let correctedEnd = (end.isNaN || end < 0) ? 0 : end
                let correctedDuration = (duration.isNaN || duration < 0) ? nil : duration
                
                chapters.append(Chapter(title, correctedStart, correctedEnd, correctedDuration))
            }
            
            // Sort chapters by start time, in ascending order
            chapters.sort(by: {(c1, c2) -> Bool in c1.startTime < c2.startTime})
            
            // Correct the (empty) chapter titles if required
            for index in 0..<chapters.count {
                
                // If no title is available, create a default one using the chapter index
                if chapters[index].title.trim().isEmpty {
                    chapters[index].title = String(format: "Chapter %d", index + 1)
                }
            }
        }
        
        return chapters
    }
    
    // On older systems (Sierra/HighSierra), the end times are not properly read by AVFoundation
    // So, use start times to compute end times / duration
    func getChapters_olderSystems(_ track: Track) -> [Chapter] {
        
        var chapters: [Chapter] = []
        
        if let asset = track.audioAsset, let langCode = asset.availableChapterLocales.first?.languageCode {
            
            let chapterMetadataGroups = asset.chapterMetadataGroups(bestMatchingPreferredLanguages: [langCode])
            
            // Collect title and start time from each group
            let titlesAndStartTimes: [(title: String, startTime: Double)] =
                chapterMetadataGroups.map {(getChapterTitle($0.items) ?? "", $0.timeRange.start.seconds)}
            
            if titlesAndStartTimes.isEmpty {return chapters}
            
            for index in 0..<titlesAndStartTimes.count {
                
                let title = titlesAndStartTimes[index].title
                let start = titlesAndStartTimes[index].startTime

                // Use start times to compute end times and durations
                
                let end = index == titlesAndStartTimes.count - 1 ? track.duration : titlesAndStartTimes[index + 1].startTime
                let duration = end - start
                
                // Validate the time fields for NaN and negative values
                let correctedStart = (start.isNaN || start < 0) ? 0 : start
                let correctedEnd = (end.isNaN || end < 0) ? 0 : end
                let correctedDuration = (duration.isNaN || duration < 0) ? nil : duration
                
                chapters.append(Chapter(title, correctedStart, correctedEnd, correctedDuration))
            }
            
            // Sort chapters by start time, in ascending order
            chapters.sort(by: {(c1, c2) -> Bool in c1.startTime < c2.startTime})

            // Correct the (empty) chapter titles if required
            for index in 0..<chapters.count {

                // If no title is available, create a default one using the chapter index
                if chapters[index].title.trim().isEmpty {
                    chapters[index].title = String(format: "Chapter %d", index + 1)
                }
            }
        }
        
        return chapters
    }
    
    // Delegates to all parsers to try and find title metadata among the given items
    private func getChapterTitle(_ items: [AVMetadataItem]) -> String? {

        for parser in allParsers {
            
            if let title = parser.getChapterTitle(items) {
                // Found
                return title
            }
        }
        
        // Not found
        return nil
    }
    
    func tracksRemoved(_ notification: TracksRemovedNotification) {
        
        for track in notification.results.tracks {
            _ = metadataMap.remove(track)
        }
    }
}

extension Data {
    
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}

class AVAssetMetadata {
    
    var map: [String: AVMetadataItem] = [:]
    var genericItems: [AVMetadataItem] = []
}

extension AVMetadataItem {
    
    var commonKeyAsString: String? {
        return commonKey?.rawValue ?? nil
    }
    
    var keyAsString: String? {
        
        if let key = self.key as? String {
            return StringUtils.cleanUpString(key).trim()
        }
        
        if let id = self.identifier {
            
            let tokens = id.rawValue.split(separator: "/")
            if tokens.count == 2 {
                return StringUtils.cleanUpString(String(tokens[1].trim().replacingOccurrences(of: "%A9", with: "@"))).trim()
            }
        }
        
        return nil
    }
    
    var valueAsString: String? {

        if !StringUtils.isStringEmpty(self.stringValue) {
            return self.stringValue
        }
        
        if let number = self.numberValue {
            return String(describing: number)
        }
        
        if let data = self.dataValue {
            return String(data: data, encoding: .utf8)
        }
        
        if let date = self.dateValue {
            return String(describing: date)
        }
        
        return nil
    }
    
    var valueAsNumericalString: String {
        
        if !StringUtils.isStringEmpty(self.stringValue), let num = Int(self.stringValue!) {
            return String(describing: num)
        }
        
        if let number = self.numberValue {
            return String(describing: number)
        }
        
        if let data = self.dataValue, let num = Int(data.hexEncodedString(), radix: 16) {
            return String(describing: num)
        }
        
        return "0"
    }
}
