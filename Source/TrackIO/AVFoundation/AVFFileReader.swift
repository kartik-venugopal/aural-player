//
//  AVFFileReader.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa
import AVFoundation

///
/// Handles loading of track metadata from natively supported tracks, using AVFoundation.
///
class AVFFileReader: FileReaderProtocol {
    
    let commonParser: CommonAVFMetadataParser = CommonAVFMetadataParser()
    let id3Parser: ID3AVFParser = ID3AVFParser()
    let iTunesParser: ITunesParser = ITunesParser()

    let allParsers: [AVFMetadataParser]
    let parsersMap: [AVMetadataKeySpace: AVFMetadataParser]
    
    init() {
        
        // Audio Toolbox is only available starting with macOS 10.13.
        if #available(OSX 10.13, *) {
            
            parsersMap = [.common: commonParser, .id3: id3Parser, .iTunes: iTunesParser, .audioFile: AudioToolboxParser()]
            
        } else {
            parsersMap = [.common: commonParser, .id3: id3Parser, .iTunes: iTunesParser]
        }
        
        allParsers = [id3Parser, iTunesParser, commonParser]
    }
    
    private func cleanUpString(_ string: String?) -> String? {
        
        if let theTrimmedString = string?.trim() {
            return theTrimmedString.isEmpty ? nil : theTrimmedString
        }
        
        return nil
    }
    
    func getPlaylistMetadata(for file: URL) throws -> PlaylistMetadata {
        
        // Construct a metadata map for this file.
        let metadataMap = AVFMappedMetadata(file: file)
        return try doGetPlaylistMetadata(for: file, fromMap: metadataMap)
    }
    
    private func doGetPlaylistMetadata(for file: URL, fromMap metadataMap: AVFMappedMetadata) throws -> PlaylistMetadata {
        
        // Make sure the file has at least one audio track.
        guard metadataMap.hasAudioTracks else {throw NoAudioTracksError(file)}
        
        // Make sure track is not DRM protected.
        guard !metadataMap.avAsset.hasProtectedContent else {throw DRMProtectionError(file)}
        
        // Make sure track is playable.
        // TODO: What does isPlayable actually mean ?
//        guard metadataMap.audioTrack.isPlayable else {throw TrackNotPlayableError(file)}
        
        var metadata = PlaylistMetadata()
        
        // Obtain the parsers relevant to this track, based on the metadata present.
        let parsers = metadataMap.keySpaces.compactMap {parsersMap[$0]}

        // Load the essential metadata fields from the parsers
        
        metadata.title = cleanUpString(parsers.firstNonNilMappedValue {$0.getTitle(metadataMap)})
        metadata.artist = cleanUpString(parsers.firstNonNilMappedValue {$0.getArtist(metadataMap)})
        metadata.album = cleanUpString(parsers.firstNonNilMappedValue {$0.getAlbum(metadataMap)})
        metadata.genre = cleanUpString(parsers.firstNonNilMappedValue {$0.getGenre(metadataMap)})
        
        let trackNum: (number: Int?, total: Int?)? = parsers.firstNonNilMappedValue {$0.getTrackNumber(metadataMap)}
        metadata.trackNumber = trackNum?.number
        metadata.totalTracks = trackNum?.total
        
        let discNum: (number: Int?, total: Int?)? = parsers.firstNonNilMappedValue {$0.getDiscNumber(metadataMap)}
        metadata.discNumber = discNum?.number
        metadata.totalDiscs = discNum?.total
        
        metadata.duration = metadataMap.avAsset.duration.seconds
        metadata.durationIsAccurate = false
        
        metadata.chapters = getChapters(for: file, from: metadataMap.avAsset)
        
        return metadata
    }
    
    func computeAccurateDuration(for file: URL) -> Double? {
        return nil
    }
    
    func getArt(for file: URL) -> CoverArt? {
        
        let metadataMap = AVFMappedMetadata(file: file)
        let parsers = metadataMap.keySpaces.compactMap {parsersMap[$0]}
        
        return parsers.firstNonNilMappedValue {$0.getArt(metadataMap)}
    }
    
    func getPlaybackMetadata(for file: URL) throws -> PlaybackContextProtocol {
        
        let audioFile: AVAudioFile = try AVAudioFile(forReading: file)
        return AVFPlaybackContext(for: audioFile)
    }
    
    func getAuxiliaryMetadata(for file: URL, loadingAudioInfoFrom playbackContext: PlaybackContextProtocol? = nil) -> AuxiliaryMetadata {
        
        // Construct a metadata map for this file.
        let metadataMap = AVFMappedMetadata(file: file)
        return doGetAuxiliaryMetadata(for: file, fromMap: metadataMap, loadingAudioInfoFrom: playbackContext)
    }
    
    private func doGetAuxiliaryMetadata(for file: URL, fromMap metadataMap: AVFMappedMetadata, loadingAudioInfoFrom playbackContext: PlaybackContextProtocol? = nil) -> AuxiliaryMetadata {
        
        // Obtain the parsers relevant to this track, based on the metadata present.
        let parsers = metadataMap.keySpaces.compactMap {parsersMap[$0]}
        
        var metadata = AuxiliaryMetadata()
        
        metadata.year = parsers.firstNonNilMappedValue {$0.getYear(metadataMap)}
        metadata.lyrics = cleanUpString(parsers.firstNonNilMappedValue {$0.getLyrics(metadataMap)})
        
        var auxiliaryMetadata: [String: MetadataEntry] = [:]
        
        // Obtain auxiliary metadata from each of the parsers, and put it in the
        // auxiliaryMetadata dictionary.
        
        for parser in allParsers {
            parser.getAuxiliaryMetadata(metadataMap).forEach {(k,v) in auxiliaryMetadata[k] = v}
        }
        
        metadata.auxiliaryMetadata = auxiliaryMetadata
        
        // Load audio info for the track.
        
        var audioInfo = AudioInfo()
        
        // If the track has an associated playback context, use it, otherwise
        // construct a new one. Audio info will be extracted from this context.
        
        var optionalPlaybackContext: AVFPlaybackContext? = playbackContext as? AVFPlaybackContext
        
        if optionalPlaybackContext == nil {
            
            do {
                
                let audioFile: AVAudioFile = try AVAudioFile(forReading: file)
                optionalPlaybackContext = AVFPlaybackContext(for: audioFile)
            } catch {}
        }
        
        // Transfer audio info from the playback context, if available
        
        if let thePlaybackContext = optionalPlaybackContext {
            
            let intChannelCount = Int(thePlaybackContext.audioFormat.channelCount)
            audioInfo.numChannels = intChannelCount
            audioInfo.channelLayout = thePlaybackContext.audioFormat.channelLayoutString
            
            audioInfo.sampleRate = Int32(thePlaybackContext.sampleRate)
            audioInfo.frames = thePlaybackContext.frameCount
        }
        
        // Compute the bit rate in kilobits/sec (kbps).
        
        var estBitRate: Float = 0
        
        let audioTrack = metadataMap.audioTrack
            
        audioInfo.format = avfFormatDescriptions[audioTrack.format] ?? formatDescriptions[getFormat(audioTrack)]
        estBitRate = audioTrack.estimatedDataRate
        
        if estBitRate > 0 {
            
            // kbps = bps / 1024
            audioInfo.bitRate = (estBitRate / Float(FileSize.KB)).roundedInt
            
        } else if metadataMap.avAsset.duration.seconds == 0 {

            // Default to 0 if duration is unknown
            audioInfo.bitRate = 0
            
        } else {

            // Bit rate = file size / duration in seconds
            let fileSize = file.size
            audioInfo.bitRate = (Double(fileSize.sizeBytes) * 8 / (Double(metadataMap.avAsset.duration.seconds) * Double(FileSize.KB))).roundedInt
        }
        
        metadata.audioInfo = audioInfo
        
        return metadata
    }
    
    func getAllMetadata(for file: URL) -> FileMetadata {
        
        let metadataMap = AVFMappedMetadata(file: file)
        guard metadataMap.hasAudioTracks else {return FileMetadata()}
        
        var metadata = FileMetadata()
        
        do {
            metadata.playlist = try doGetPlaylistMetadata(for: file, fromMap: metadataMap)
        } catch {
            NSLog("Error retrieving playlist metadata for file: '\(file.path)'. Error: \(error)")
        }
        
        metadata.auxiliary = doGetAuxiliaryMetadata(for: file, fromMap: metadataMap, loadingAudioInfoFrom: nil)
        
        let parsers = metadataMap.keySpaces.compactMap {parsersMap[$0]}
        metadata.coverArt = parsers.firstNonNilMappedValue {$0.getArt(metadataMap)}?.image
        
        return metadata
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
        return assetTrack.format4CharString.trimmingCharacters(in: CharacterSet.init(charactersIn: "."))
    }
    
    // Reads all chapter metadata for a given track
    // NOTE - This code does not account for potential overlaps in chapter times due to bad metadata ... assumes no overlaps
    private func getChapters(for file: URL, from asset: AVURLAsset) -> [Chapter] {

        // On older systems (Sierra/HighSierra), the end times are not properly read by **AVFoundation**
        // So, use start times to compute end times / duration
        let fileExtension = file.lowerCasedExtension
        let useAlternativeComputation = System.osVersion.minorVersion < 14 && !["m4a", "m4b"].contains(fileExtension)

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

                chapters.append(Chapter(title: title, startTime: correctedStart, endTime: correctedEnd, duration: correctedDuration))
            }

            // Sort chapters by start time, in ascending order
            chapters.sort(by: {(c1, c2) -> Bool in c1.startTime < c2.startTime})

            // Correct the (empty) chapter titles if required
            for index in 0..<chapters.count {

                // If no title is available, create a default one using the chapter index
                if chapters[index].title.isEmptyAfterTrimming {
                    chapters[index].title = String(format: "Chapter %d", index + 1)
                }
            }
        }
        
        return chapters
    }
    
    // On older systems (Sierra/HighSierra), the end times are not properly read by **AVFoundation**
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

                chapters.append(Chapter(title: title, startTime: correctedStart, endTime: correctedEnd, duration: correctedDuration))
            }

            // Sort chapters by start time, in ascending order
            chapters.sort(by: {(c1, c2) -> Bool in c1.startTime < c2.startTime})

            // Correct the (empty) chapter titles if required
            for index in 0..<chapters.count {

                // If no title is available, create a default one using the chapter index
                if chapters[index].title.isEmptyAfterTrimming {
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
