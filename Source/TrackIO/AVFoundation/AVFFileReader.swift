import Cocoa
import AVFoundation

class AVFFileReader: FileReaderProtocol {
    
    let commonParser: CommonAVFMetadataParser = CommonAVFMetadataParser()
    let id3Parser: ID3AVFParser = ID3AVFParser()
    let iTunesParser: ITunesParser = ITunesParser()
    
    let parsersMap: [AVMetadataKeySpace: AVFMetadataParser]
    
    init() {
        
        if #available(OSX 10.13, *) {
            parsersMap = [.common: commonParser, .id3: id3Parser, .iTunes: iTunesParser, .audioFile: AudioToolboxParser()]
        } else {
            parsersMap = [.common: commonParser, .id3: id3Parser, .iTunes: iTunesParser]
        }
    }
    
    // File extension -> Kind of file description string
    private var kindOfFileCache: [String: String] = [:]
    
    private func kindOfFile(path: String, fileExt: String) -> String? {
        
        if let cachedValue = kindOfFileCache[fileExt] {
            return cachedValue
        }
        
        if let mditem = MDItemCreate(nil, path as CFString),
            let mdnames = MDItemCopyAttributeNames(mditem),
            let mdattrs = MDItemCopyAttributes(mditem, mdnames) as? [String: Any],
            let value = mdattrs[kMDItemKind as String] as? String {
            
            kindOfFileCache[fileExt] = value
            return value
        }
        
        return nil
    }
    
    private func cleanUp(_ string: String?) -> String? {
        
        if let theTrimmedString = string?.trim() {
            return theTrimmedString.isEmpty ? nil : theTrimmedString
        }
        
        return nil
    }
    
    func getPrimaryMetadata(for file: URL) throws -> PrimaryMetadata {
        
        let meta = AVFMetadata(file: file)
        
        guard meta.asset.tracks.first(where: {$0.mediaType == .audio}) != nil else {
            throw NoAudioTracksError(file)
        }
        
        var metadata = PrimaryMetadata()
//        metadata.audioFormat = avfFormatDescriptions[audioTrack.format] ?? audioTrack.format4CharString
        
//        let fileExtension = file.pathExtension.lowercased()
        
//        if let kindOfFile = kindOfFile(path: file.path, fileExt: fileExtension) {
//            metadata.fileType = kindOfFile
//        }
        
        let parsers = meta.keySpaces.compactMap {parsersMap[$0]}

        metadata.title = cleanUp(parsers.firstNonNilMappedValue {$0.getTitle(meta)})
        metadata.artist = cleanUp(parsers.firstNonNilMappedValue {$0.getArtist(meta)})
        metadata.albumArtist = cleanUp(parsers.firstNonNilMappedValue {$0.getAlbumArtist(meta)})
        metadata.album = cleanUp(parsers.firstNonNilMappedValue {$0.getAlbum(meta)})
        metadata.genre = cleanUp(parsers.firstNonNilMappedValue {$0.getGenre(meta)})
        
//        metadata.composer = cleanUp(parsers.firstNonNilMappedValue {$0.getComposer(meta)})
//        metadata.conductor = cleanUp(parsers.firstNonNilMappedValue {$0.getConductor(meta)})
//        metadata.performer = cleanUp(parsers.firstNonNilMappedValue{$0.getPerformer(meta)})
//        metadata.lyricist = cleanUp(parsers.firstNonNilMappedValue {$0.getLyricist(meta)})
        
//        metadata.year = parsers.firstNonNilMappedValue {$0.getYear(meta)}
//        metadata.bpm = parsers.firstNonNilMappedValue {$0.getBPM(meta)}
        
        let trackNum: (number: Int?, total: Int?)? = parsers.firstNonNilMappedValue {$0.getTrackNumber(meta)}
        metadata.trackNumber = trackNum?.number
        metadata.totalTracks = trackNum?.total
        
        let discNum: (number: Int?, total: Int?)? = parsers.firstNonNilMappedValue {$0.getDiscNumber(meta)}
        metadata.discNumber = discNum?.number
        metadata.totalDiscs = discNum?.total
        
        metadata.duration = meta.asset.duration.seconds
        metadata.durationIsAccurate = false
        
//        if let art = parsers.firstNonNilMappedValue({$0.getArt(meta)}) {
//            metadata.art = CoverArt(art)
//        }
        
        return metadata
    }
    
    func getSecondaryMetadata(for file: URL) -> SecondaryMetadata {
        
        let metadata = SecondaryMetadata()
        
        return metadata
    }
    
    func getPlaybackMetadata(file: URL) throws -> PlaybackContextProtocol {
        return try AVFPlaybackContext(for: file)
    }
    
    // Reads all chapter metadata for a given track
    // NOTE - This code does not account for potential overlaps in chapter times due to bad metadata ... assumes no overlaps
    static func getChapters(_ track: Track) -> [Chapter] {

        // On older systems (Sierra/HighSierra), the end times are not properly read by AVFoundation
        // So, use start times to compute end times / duration
//        let fileExtension = track.file.pathExtension.lowercased()
//        let useAlternativeComputation = SystemUtils.osVersion.minorVersion < 14 && !["m4a", "m4b"].contains(fileExtension)
//
//        if useAlternativeComputation {
//            return getChapters_olderSystems(track)
//        }
        
        var chapters: [Chapter] = []
        
//        if let asset = track.avfTrackInfo, let langCode = asset.availableChapterLocales.first?.languageCode {
//
//            let chapterMetadataGroups = asset.chapterMetadataGroups(bestMatchingPreferredLanguages: [langCode])
//
//            // Each group represents one chapter
//            for group in chapterMetadataGroups {
//
//                let title: String = getChapterTitle(group.items) ?? ""
//
//                let timeRange = group.timeRange
//                let start = timeRange.start.seconds
//                let end = timeRange.end.seconds
//                let duration = timeRange.duration.seconds
//
//                // Validate the time fields for NaN and negative values
//                let correctedStart = (start.isNaN || start < 0) ? 0 : start
//                let correctedEnd = (end.isNaN || end < 0) ? 0 : end
//                let correctedDuration = (duration.isNaN || duration < 0) ? nil : duration
//
//                chapters.append(Chapter(title, correctedStart, correctedEnd, correctedDuration))
//            }
//
//            // Sort chapters by start time, in ascending order
//            chapters.sort(by: {(c1, c2) -> Bool in c1.startTime < c2.startTime})
//
//            // Correct the (empty) chapter titles if required
//            for index in 0..<chapters.count {
//
//                // If no title is available, create a default one using the chapter index
//                if chapters[index].title.trim().isEmpty {
//                    chapters[index].title = String(format: "Chapter %d", index + 1)
//                }
//            }
//        }
        
        return chapters
    }
    
    // On older systems (Sierra/HighSierra), the end times are not properly read by AVFoundation
    // So, use start times to compute end times / duration
    static func getChapters_olderSystems(_ track: Track) -> [Chapter] {
        
        // TODO: BUG - This code assumes chapters are sorted by startTime.
        // First sort by startTime, then use start times to compute end times / durations.
        
        var chapters: [Chapter] = []
        
//        if let asset = track.avfTrackInfo, let langCode = asset.availableChapterLocales.first?.languageCode {
//
//            let chapterMetadataGroups = asset.chapterMetadataGroups(bestMatchingPreferredLanguages: [langCode])
//
//            // Collect title and start time from each group
//            var titlesAndStartTimes: [(title: String, startTime: Double)] =
//                chapterMetadataGroups.map {(getChapterTitle($0.items) ?? "", $0.timeRange.start.seconds)}
//
//            if titlesAndStartTimes.isEmpty {return chapters}
//
//            // Start times must be in ascending order
//            titlesAndStartTimes.sort(by: {$0.startTime < $1.startTime})
//
//            for index in 0..<titlesAndStartTimes.count {
//
//                let title = titlesAndStartTimes[index].title
//                let start = titlesAndStartTimes[index].startTime
//
//                // Use start times to compute end times and durations
//
//                let end = index == titlesAndStartTimes.count - 1 ? track.duration : titlesAndStartTimes[index + 1].startTime
//                let duration = end - start
//
//                // Validate the time fields for NaN and negative values
//                let correctedStart = (start.isNaN || start < 0) ? 0 : start
//                let correctedEnd = (end.isNaN || end < 0) ? 0 : end
//                let correctedDuration = (duration.isNaN || duration < 0) ? nil : duration
//
//                chapters.append(Chapter(title, correctedStart, correctedEnd, correctedDuration))
//            }
//
//            // Sort chapters by start time, in ascending order
//            chapters.sort(by: {(c1, c2) -> Bool in c1.startTime < c2.startTime})
//
//            // Correct the (empty) chapter titles if required
//            for index in 0..<chapters.count {
//
//                // If no title is available, create a default one using the chapter index
//                if chapters[index].title.trim().isEmpty {
//                    chapters[index].title = String(format: "Chapter %d", index + 1)
//                }
//            }
//        }
        
        return chapters
    }
    
    // Delegates to all parsers to try and find title metadata among the given items
    private static func getChapterTitle(_ items: [AVMetadataItem]) -> String? {

//        for parser in allParsers {
//            
//            if let title = parser.getChapterTitle(items) {
//                // Found
//                return title
//            }
//        }
        
        // Not found
        return nil
    }
}
