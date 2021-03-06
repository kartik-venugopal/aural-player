import Cocoa
import AVFoundation

class AVFFileReader: FileReaderProtocol {
    
    let commonParser: CommonAVFMetadataParser = CommonAVFMetadataParser()
    let id3Parser: ID3AVFParser = ID3AVFParser()
    let iTunesParser: ITunesParser = ITunesParser()

    let allParsers: [AVFMetadataParser]
    let parsersMap: [AVMetadataKeySpace: AVFMetadataParser]
    
    init() {
        
        if #available(OSX 10.13, *) {
            parsersMap = [.common: commonParser, .id3: id3Parser, .iTunes: iTunesParser, .audioFile: AudioToolboxParser()]
        } else {
            parsersMap = [.common: commonParser, .id3: id3Parser, .iTunes: iTunesParser]
        }
        
        allParsers = [id3Parser, iTunesParser, commonParser]
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
    
    func getPlaylistMetadata(for file: URL) throws -> PlaylistMetadata {
        
        let meta = AVFMetadata(file: file)
        
        guard meta.asset.tracks.first(where: {$0.mediaType == .audio}) != nil else {
            throw NoAudioTracksError(file)
        }
        
        var metadata = PlaylistMetadata()
        
        let parsers = meta.keySpaces.compactMap {parsersMap[$0]}

        metadata.title = cleanUp(parsers.firstNonNilMappedValue {$0.getTitle(meta)})
        
        metadata.artist = cleanUp(parsers.firstNonNilMappedValue {$0.getArtist(meta)})
        metadata.albumArtist = cleanUp(parsers.firstNonNilMappedValue {$0.getAlbumArtist(meta)})
        metadata.performer = cleanUp(parsers.firstNonNilMappedValue{$0.getPerformer(meta)})
        
        metadata.album = cleanUp(parsers.firstNonNilMappedValue {$0.getAlbum(meta)})
        metadata.genre = cleanUp(parsers.firstNonNilMappedValue {$0.getGenre(meta)})
        
        let trackNum: (number: Int?, total: Int?)? = parsers.firstNonNilMappedValue {$0.getTrackNumber(meta)}
        metadata.trackNumber = trackNum?.number
        metadata.totalTracks = trackNum?.total
        
        let discNum: (number: Int?, total: Int?)? = parsers.firstNonNilMappedValue {$0.getDiscNumber(meta)}
        metadata.discNumber = discNum?.number
        metadata.totalDiscs = discNum?.total
        
        metadata.duration = meta.asset.duration.seconds
        metadata.durationIsAccurate = false
        
        metadata.chapters = getChapters(for: file, from: meta.asset)
        
        return metadata
    }
    
    func getArt(for file: URL) -> CoverArt? {
        
        let meta = AVFMetadata(file: file)
        let parsers = meta.keySpaces.compactMap {parsersMap[$0]}
        
        return parsers.firstNonNilMappedValue {$0.getArt(meta)}
    }
    
    func getPlaybackMetadata(for file: URL) throws -> PlaybackContextProtocol {
        return try AVFPlaybackContext(for: file)
    }
    
    func getAuxiliaryMetadata(for file: URL, loadingAudioInfoFrom playbackContext: PlaybackContextProtocol? = nil, loadArt: Bool) -> AuxiliaryMetadata {
        
        var metadata = AuxiliaryMetadata()
        let meta = AVFMetadata(file: file)
        let parsers = meta.keySpaces.compactMap {parsersMap[$0]}
        
        metadata.composer = cleanUp(parsers.firstNonNilMappedValue {$0.getComposer(meta)})
        metadata.conductor = cleanUp(parsers.firstNonNilMappedValue {$0.getConductor(meta)})
        metadata.lyricist = cleanUp(parsers.firstNonNilMappedValue {$0.getLyricist(meta)})
        
        metadata.year = parsers.firstNonNilMappedValue {$0.getYear(meta)}
        metadata.bpm = parsers.firstNonNilMappedValue {$0.getBPM(meta)}
        
        metadata.lyrics = cleanUp(parsers.firstNonNilMappedValue {$0.getLyrics(meta)})
        
        var genericMetadata: [String: MetadataEntry] = [:]
        
        for parser in allParsers {
            
            let parserMetadata = parser.getGenericMetadata(meta)
            parserMetadata.forEach {(k,v) in genericMetadata[k] = v}
        }
        
        metadata.genericMetadata = genericMetadata
        
        let audioInfo = AudioInfo()
        
        var optionalPlaybackContext: PlaybackContextProtocol? = playbackContext
        
        if optionalPlaybackContext == nil {
            
            do {
                optionalPlaybackContext = try AVFPlaybackContext(for: file)
            } catch {}
        }
        
        // Transfer audio info from playback info, if available
        if let thePlaybackContext = optionalPlaybackContext {
            
            let intChannelCount = Int(thePlaybackContext.audioFormat.channelCount)
            audioInfo.numChannels = intChannelCount
            audioInfo.channelLayout = channelLayout(intChannelCount)
            
            audioInfo.sampleRate = Int32(thePlaybackContext.sampleRate)
            audioInfo.frames = thePlaybackContext.frameCount
        }
        
        let fileExtension = file.lowerCasedExtension
        audioInfo.format = formatDescriptions[fileExtension]
        
        var estBitRate: Float = 0
        
        if let audioTrack = meta.asset.tracks.first {
            
            if let codec = formatDescriptions[getFormat(audioTrack)], codec != audioInfo.format {
                audioInfo.codec = codec
            } else {
                audioInfo.codec = fileExtension.uppercased()
            }
            
            estBitRate = audioTrack.estimatedDataRate
        }
        
        if estBitRate > 0 {
            
            audioInfo.bitRate = Int(round(estBitRate)) / Int(Size.KB)
            
        } else if meta.asset.duration.seconds == 0 {
            
            audioInfo.bitRate = 0
            
        } else {
                
            let fileSize = FileSystemUtils.sizeOfFile(path: file.path)
            audioInfo.bitRate = roundedInt(Double(fileSize.sizeBytes) * 8 / (Double(meta.asset.duration.seconds) * Double(Size.KB)))
        }
        
        metadata.audioInfo = audioInfo
        
        if loadArt {
            metadata.art = parsers.firstNonNilMappedValue {$0.getArt(meta)}
        }
        
        return metadata
    }
    
    private func channelLayout(_ numChannels: Int) -> String {
        
        switch numChannels {
            
        case 1: return "Mono (1 ch)"
            
        case 2: return "Stereo (2 ch)"
            
        case 6: return "5.1 (6 ch)"
            
        case 8: return "7.1 (8 ch)"
            
        case 10: return "9.1 (10 ch)"
            
        default: return String(format: "%d channels", numChannels)
            
        }
    }
    
    private let formatDescriptions: [String: String] = [
    
        "mp3": "MPEG Audio Layer III (mp3)",
        "m4a": "MPEG-4 Audio (m4a)",
        "m4b": "MPEG-4 Audio (m4b)",
        "m4r": "MPEG-4 Audio (m4r)",
        "aac": "Advanced Audio Coding (aac)",
        "alac": "Apple Lossless Audio Codec (alac)",
        "caf": "Apple Core Audio Format (caf)",
        "ac3": "Dolby Digital Audio Coding 3 (ac3)",
        "ac-3": "Dolby Digital Audio Coding 3 (ac3)",
        "wav": "Waveform Audio (wav / wave)",
        "au": "NeXT/Sun Audio (au)",
        "snd": "NeXT/Sun Audio (snd)",
        "sd2": "Sound Designer II (sd2)",
        "aiff": "Audio Interchange File Format (aiff)",
        "aif": "Audio Interchange File Format (aiff)",
        "aifc": "Audio Interchange File Format - Compressed (aiff-c)",
        "adts": "Audio Data Transport Stream (adts)",
        "lpcm": "Linear Pulse-Code Modulation (lpcm)",
        "pcm": "Pulse-Code Modulation (pcm)"
    ]
    
    private func getFormat(_ assetTrack: AVAssetTrack) -> String {

        let description = CMFormatDescriptionGetMediaSubType(assetTrack.formatDescriptions.first as! CMFormatDescription)
        return codeToString(description).trimmingCharacters(in: CharacterSet.init(charactersIn: "."))
    }

    // Converts a four character media type code to a readable string
    private func codeToString(_ code: FourCharCode) -> String {

        let numericCode = Int(code)

        var codeString: String = String (describing: UnicodeScalar((numericCode >> 24) & 255)!)
        codeString.append(String(describing: UnicodeScalar((numericCode >> 16) & 255)!))
        codeString.append(String(describing: UnicodeScalar((numericCode >> 8) & 255)!))
        codeString.append(String(describing: UnicodeScalar(numericCode & 255)!))

        return codeString.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    // Reads all chapter metadata for a given track
    // NOTE - This code does not account for potential overlaps in chapter times due to bad metadata ... assumes no overlaps
    private func getChapters(for file: URL, from asset: AVURLAsset) -> [Chapter] {

        // On older systems (Sierra/HighSierra), the end times are not properly read by AVFoundation
        // So, use start times to compute end times / duration
        let fileExtension = file.lowerCasedExtension
        let useAlternativeComputation = SystemUtils.osVersion.minorVersion < 14 && !["m4a", "m4b"].contains(fileExtension)

        if useAlternativeComputation {
            return getChapters_olderSystems(for: file, from: asset)
        }
        
        var chapters: [Chapter] = []
        
        if let langCode = asset.availableChapterLocales.first?.languageCode {

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
    private func getChapters_olderSystems(for file: URL, from asset: AVURLAsset) -> [Chapter] {
        
        // First sort by startTime, then use start times to compute end times / durations.
        
        var chapters: [Chapter] = []
        
        if let langCode = asset.availableChapterLocales.first?.languageCode {

            let chapterMetadataGroups = asset.chapterMetadataGroups(bestMatchingPreferredLanguages: [langCode])

            // Collect title and start time from each group
            var titlesAndStartTimes: [(title: String, startTime: Double)] =
                chapterMetadataGroups.map {(getChapterTitle($0.items) ?? "", $0.timeRange.start.seconds)}

            if titlesAndStartTimes.isEmpty {return chapters}

            // Start times must be in ascending order
            titlesAndStartTimes.sort(by: {$0.startTime < $1.startTime})

            for index in 0..<titlesAndStartTimes.count {

                let title = titlesAndStartTimes[index].title
                let start = titlesAndStartTimes[index].startTime

                // Use start times to compute end times and durations

                let end = index == titlesAndStartTimes.count - 1 ? asset.duration.seconds : titlesAndStartTimes[index + 1].startTime
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
        return allParsers.firstNonNilMappedValue {$0.getChapterTitle(items)}
    }
}
