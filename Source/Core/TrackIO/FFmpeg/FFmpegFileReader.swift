//
//  FFmpegFileReader.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Handles loading of track metadata from non-native tracks, using **FFmpeg*.
///
class FFmpegFileReader: FileReaderProtocol {
    
    // Parsers that recognize different metadata formats.
    
    let commonFFmpegParser = CommonFFmpegMetadataParser()
    let id3Parser = ID3FFmpegParser()
    let wmParser = WMParser()
    let vorbisParser = VorbisCommentParser()
    let apeParser = ApeV2Parser()
    let defaultParser = DefaultFFmpegMetadataParser()

    private let allParsers: [FFmpegMetadataParser]
    private let wmFileParsers: [FFmpegMetadataParser]
    private let vorbisFileParsers: [FFmpegMetadataParser]
    private let apeFileParsers: [FFmpegMetadataParser]
    
    ///
    /// A mapping of file extension to an ordered collection of metadata parsers that will examine tracks of that file type for metadata.
    /// The order of parsers in the collection will determine the order in which metadata will be examined and parsed.
    ///
    private var parsersByExt: [String: [FFmpegMetadataParser]] = [:]
    
    init() {
        
        // In each of these arrays, parsers are stored in descending order, by relevance for the track's
        // file type. For example, for a Vorbis file, the Vorbis parser appears before other parsers. So the Vorbis
        // parser will examine the Vorbis file's metadata before other parsers do. This is for the sake of efficiency.
        // The common ffmpeg parser will always appear first because it is relevant to all file types.
        
        allParsers = [commonFFmpegParser, id3Parser, vorbisParser, apeParser, wmParser, defaultParser]
        wmFileParsers = [commonFFmpegParser, wmParser, id3Parser, vorbisParser, apeParser, defaultParser]
        vorbisFileParsers = [commonFFmpegParser, vorbisParser, apeParser, id3Parser, wmParser, defaultParser]
        apeFileParsers = [commonFFmpegParser, apeParser, vorbisParser, id3Parser, wmParser, defaultParser]
        
        parsersByExt =
        [
            "wma": wmFileParsers,
            "flac": vorbisFileParsers,
            "dsf": vorbisFileParsers,
            "dsd": vorbisFileParsers,
            "dff": vorbisFileParsers,
            "ogg": vorbisFileParsers,
            "oga": vorbisFileParsers,
            "opus": vorbisFileParsers,
            "ape": apeFileParsers,
            "mpc": apeFileParsers
        ]
    }
    
    private func cleanUp(_ string: String?) -> String? {
        
        if let theTrimmedString = string?.trim() {
            return theTrimmedString.isEmpty ? nil : theTrimmedString
        }
        
        return nil
    }
    
    func getPrimaryMetadata(for file: URL) throws -> PrimaryMetadata {
        
        // Construct an ffmpeg file context for this track.
        // This will be the source of all track metadata.
        let fctx = try FFmpegFileContext(for: file)
        
        // The file must have an audio stream, otherwise it's invalid.
        guard let stream = fctx.bestAudioStream else {throw NoAudioTracksError(file)}
        let codec = try FFmpegAudioCodec(fromParameters: stream.avStream.codecpar)
        
        // Construct a metadata map for this track, using the file context.
        let metadataMap = FFmpegMappedMetadata(for: fctx)
        
        // Determine which parsers (and in what order) will examine the track's metadata.
        let allParsers = parsersByExt[metadataMap.fileType] ?? self.allParsers
        allParsers.forEach {$0.mapMetadata(metadataMap)}
        let relevantParsers = allParsers.filter {$0.hasEssentialMetadataForTrack(metadataMap)}
        
        return try doGetPrimaryMetadata(for: file, fromCtx: fctx, stream: stream, codec: codec, andMap: metadataMap, usingParsers: relevantParsers)
    }
    
    private func doGetPrimaryMetadata(for file: URL, fromCtx fctx: FFmpegFileContext, stream: FFmpegAudioStream, codec: FFmpegAudioCodec, andMap metadataMap: FFmpegMappedMetadata, usingParsers relevantParsers: [FFmpegMetadataParser]) throws -> PrimaryMetadata {
        
        let metadata = PrimaryMetadata()

        // Read all essential metadata fields.
        
        metadata.title = cleanUp(relevantParsers.firstNonNilMappedValue {$0.getTitle(metadataMap)})
        metadata.artist = cleanUp(relevantParsers.firstNonNilMappedValue {$0.getArtist(metadataMap)})
        metadata.album = cleanUp(relevantParsers.firstNonNilMappedValue {$0.getAlbum(metadataMap)})
        metadata.genre = cleanUp(relevantParsers.firstNonNilMappedValue {$0.getGenre(metadataMap)})

        metadata.isProtected = relevantParsers.firstNonNilMappedValue {$0.isDRMProtected(metadataMap)}
        
        if metadata.isProtected ?? false {throw DRMProtectionError(file)}
        
        var trackNumberAndTotal = relevantParsers.firstNonNilMappedValue {$0.getTrackNumber(metadataMap)}
        if let trackNum = trackNumberAndTotal?.number, trackNumberAndTotal?.total == nil,
            let totalTracks = relevantParsers.firstNonNilMappedValue({$0.getTotalTracks(metadataMap)}) {
            
            trackNumberAndTotal = (trackNum, totalTracks)
        }
        
        metadata.trackNumber = trackNumberAndTotal?.number
        metadata.totalTracks = trackNumberAndTotal?.total
        
        var discNumberAndTotal = relevantParsers.firstNonNilMappedValue {$0.getDiscNumber(metadataMap)}
        if let discNum = discNumberAndTotal?.number, discNumberAndTotal?.total == nil,
            let totalDiscs = relevantParsers.firstNonNilMappedValue({$0.getTotalDiscs(metadataMap)}) {
            
            discNumberAndTotal = (discNum, totalDiscs)
        }
        
        metadata.discNumber = discNumberAndTotal?.number
        metadata.totalDiscs = discNumberAndTotal?.total
        
        metadata.duration = metadataMap.fileCtx.duration
//        print("For file: \(file.path), est. method = \(metadataMap.fileCtx.avContext.duration_estimation_method)")
        metadata.durationIsAccurate = metadata.duration > 0 && metadataMap.fileCtx.estimatedDurationIsAccurate
        
        metadata.chapters = metadataMap.fileCtx.chapters.map {Chapter($0)}
        
        metadata.year = relevantParsers.firstNonNilMappedValue {$0.getYear(metadataMap)}
        metadata.lyrics = relevantParsers.firstNonNilMappedValue {$0.getLyrics(metadataMap)}
        
        metadata.replayGain = codec.replayGain ?? relevantParsers.firstNonNilMappedValue {$0.getReplayGain(from: metadataMap)}
        
        var auxiliaryMetadata: [String: MetadataEntry] = [:]
        
        for parser in relevantParsers {
            parser.getAuxiliaryMetadata(metadataMap).forEach {(k,v) in auxiliaryMetadata[k] = v}
        }
        
        metadata.nonEssentialMetadata = auxiliaryMetadata
        
        if let imageData = metadataMap.fileCtx.bestImageStream?.attachedPic.data {
            metadata.art = CoverArt(source: .file, originalImageData: imageData)
        }
        
        return metadata
    }
    
    func computeAccurateDuration(for file: URL) -> Double? {
        
        do {
            
            // Construct an ffmpeg file context for this track.
            return try FFmpegFileContext(for: file).bruteForceDuration
            
        } catch {
            
            NSLog("Unable to compute accurate duration for track \(file.path). Error: \(error)")
            return nil
        }
    }
    
    func getAudioInfo(for file: URL, loadingAudioInfoFrom playbackContext: PlaybackContextProtocol? = nil) -> AudioInfo {
        
        do {
            
            // Construct an ffmpeg file context for this track.
            // This will be the source of all track metadata.
            let fctx = try FFmpegFileContext(for: file)
            
            // The file must have an audio stream, otherwise it's invalid.
            guard fctx.bestAudioStream != nil else {throw NoAudioTracksError(file)}
            
            return doGetAudioInfo(for: file, fromCtx: fctx, loadingAudioInfoFrom: playbackContext)
            
        } catch {
            return AudioInfo()
        }
    }
    
    private func doGetAudioInfo(for file: URL, fromCtx fctx: FFmpegFileContext, loadingAudioInfoFrom playbackContext: PlaybackContextProtocol? = nil) -> AudioInfo {
        
        var audioInfo = AudioInfo()
        
        audioInfo.format = fctx.formatLongName
        audioInfo.bitRate = (Double(fctx.bitRate) / Double(FileSize.KB)).roundedInt
        
        if let ffmpegPlaybackCtx = playbackContext as? FFmpegPlaybackContext {
            
            audioInfo.codec = ffmpegPlaybackCtx.audioCodec?.longName ?? fctx.bestAudioStream?.codecLongName ?? fctx.formatName
            audioInfo.channelLayout = ffmpegPlaybackCtx.audioFormat.channelLayoutString
            
        } else {
            audioInfo.codec = fctx.bestAudioStream?.codecLongName ?? fctx.formatName
        }
        
        if let audioStream = fctx.bestAudioStream {
            
            audioInfo.sampleRate = audioStream.sampleRate
            
            audioInfo.sampleFormat = FFmpegSampleFormat(encapsulating: AVSampleFormat(rawValue: audioStream.codecParams.format)).description
            
            audioInfo.frames = Int64(Double(audioStream.sampleRate) * fctx.duration)
            
            audioInfo.numChannels = Int(audioStream.channelCount)
            
            if audioInfo.channelLayout == nil {
                audioInfo.channelLayout = FFmpegChannelLayout(encapsulating: audioStream.avChannelLayout).description
            }
        }
        
        return audioInfo
    }
    
//    func getAllMetadata(for file: URL) -> FileMetadata {
//        
//        do {
//            
//            // Construct an ffmpeg file context for this track.
//            // This will be the source of all track metadata.
//            let fctx = try FFmpegFileContext(for: file)
//            
//            // The file must have an audio stream, otherwise it's invalid.
//            guard let stream = fctx.bestAudioStream else {throw NoAudioTracksError(file)}
//            let codec = try FFmpegAudioCodec(fromParameters: stream.avStream.codecpar)
//            
//            // Construct a metadata map for this track, using the file context.
//            let metadataMap = FFmpegMappedMetadata(for: fctx)
//
//            // Determine which parsers (and in what order) will examine the track's metadata.
//            let allParsers = parsersByExt[metadataMap.fileType] ?? self.allParsers
//            allParsers.forEach {$0.mapMetadata(metadataMap)}
//            let relevantParsers = allParsers.filter {$0.hasEssentialMetadataForTrack(metadataMap)}
//            
//            var metadata = FileMetadata(primary: try doGetPrimaryMetadata(for: file, fromCtx: fctx, stream: stream, codec: codec, andMap: metadataMap, usingParsers: relevantParsers))
//            metadata.audioInfo = doGetAudioInfo(for: file, fromCtx: fctx, loadingAudioInfoFrom: nil)
//            
//            if let imageData = fctx.bestImageStream?.attachedPic.data {
//                metadata.primary?.art = CoverArt(imageData: imageData)
//            }
//            
//            return metadata
//            
//        } catch {
//            
//            NSLog("Error retrieving metadata for file: '\(file.path)'. Error: \(error)")
//            return FileMetadata(primary: nil)
//        }
//    }
    
    func getArt(for file: URL) -> CoverArt? {
        
        do {
            
            // Construct an ffmpeg file context for this track.
            // This will be used to read cover art.
            let fctx = try FFmpegFileContext(for: file)
            
            if let imageData = fctx.bestImageStream?.attachedPic.data {
                return CoverArt(source: .file, originalImageData: imageData)
            }
            
        } catch {}
        
        return nil
    }
    
    func getPlaybackMetadata(for file: URL) throws -> PlaybackContextProtocol {
        return try FFmpegPlaybackContext(for: file)
    }
}
