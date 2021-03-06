import AVFoundation

/*
    Utility functions related to audio.
 */
class AudioUtils {
    
    private init() {}
    
    private static let formatDescriptions: [String: String] = [
    
        "mp2": "MPEG Audio Layer II (mp2)",
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
    
    static let flacSupported: Bool = {
        
        let osVersion = SystemUtils.osVersion
        return (osVersion.majorVersion == 10 && osVersion.minorVersion >= 13) || osVersion.majorVersion > 10
    }()
    
    // Validates a track to determine if it is playable. If the track is not playable, returns an error object describing the problem.
    static func validateTrack(_ track: Track) throws {
        
        // TODO: What if file has protected content
        // Check sourceAsset.hasProtectedContent()
        // Test against a protected iTunes file
        
//        let fileExtension = track.file.lowerCasedExtension
//
//        if !track.isNativelySupported || fileExtension == "flac" {
//
//            if track.libAVInfo == nil {
//                track.libAVInfo = FFMpegWrapper.getMetadata(track)
//            }
//
//            let avInfo = track.libAVInfo!
//
//            if !avInfo.hasValidAudioTrack {
//                throw TrackNotPlayableError(track)
//            }
//
//            if avInfo.drmProtected {
//                throw DRMProtectionError(track)
//            }
//
//            return
//
//        } else {
//
//            if (track.audioAsset == nil) {
//                track.audioAsset = AVURLAsset(url: track.file, options: nil)
//            }
//
//            if track.audioAsset!.hasProtectedContent {
//                throw DRMProtectionError(track)
//            }
//
//            let assetTracks = track.audioAsset?.tracks(withMediaType: AVMediaType.audio)
//
//            // Check if the asset has any audio tracks
//            if (assetTracks?.count == 0) {
//                throw NoAudioTracksError(track)
//            }
//
//            // Find out if track is playable
//            // TODO: What does isPlayable actually mean ?
//            if let assetTrack = assetTracks?.first, !assetTrack.isPlayable {
//                throw TrackNotPlayableError(track)
//            }
//
//            return
//        }
    }
    
    // Loads info necessary for playback of the given track. Returns whether or not the info was successfully loaded.
    static func loadPlaybackInfo(_ track: Track) {
        
//        if !track.isNativelySupported {
//
            // TODO
//
//        } else {
//            prepareTrackWithFile(track, track.file)
//        }
    }
    
    static func loadPlaybackInfo_noPlayback(_ track: Track) {
        
//        let playbackInfo = PlaybackInfo()
//
//        // TODO: Load audioInfo here, not playbackInfo
//
//        if track.isNativelySupported {
//
//            if let audioFile = AudioIO.createAudioFileForReading(track.file) {
//
//                playbackInfo.audioFile = audioFile
//                track.lazyLoadingInfo.preparedForPlayback = true
//
//                playbackInfo.sampleRate = audioFile.processingFormat.sampleRate
//                playbackInfo.frames = audioFile.length
//                playbackInfo.numChannels = Int(audioFile.fileFormat.channelCount)
//
//                track.playbackInfo = playbackInfo
//            }
//
//        } else if let stream = track.libAVInfo?.audioStream {
//
//            let playbackInfo = PlaybackInfo()
//
//            if let sampleRate = stream.sampleRate {
//                playbackInfo.sampleRate = sampleRate
//            }
//
//            if let channelCount = stream.channelCount {
//                playbackInfo.numChannels = channelCount
//            }
//
//            playbackInfo.frames = Int64(playbackInfo.sampleRate * track.duration)
//        }
//
//        track.playbackInfo = playbackInfo
    }
    
    static func prepareTrackWithFile(_ track: Track, _ file: URL) {
        
//        guard let audioFile = AudioIO.createAudioFileForReading(file) else {return}
//
//        let trackDurationBeforePrep: Double = track.duration
//
//        let playbackInfo = PlaybackInfo()
//
//        if track.duration == 0 {
//
//            // Load duration from metadata
//            track.setDuration(MetadataUtils.durationForFile(file))
//        }
//
//        playbackInfo.audioFile = audioFile
//        track.playbackInfo = playbackInfo
//
//        // TODO: Look in AVAudioFormat (i.e. processingFormat) settings property ... see what's there to be used.
//
//        playbackInfo.sampleRate = audioFile.processingFormat.sampleRate
//        playbackInfo.frames = audioFile.length
//        playbackInfo.numChannels = Int(audioFile.fileFormat.channelCount)
//
//        let computedDuration = Double(playbackInfo.frames) / playbackInfo.sampleRate
//
//        // If this computed duration differs from the previously estimated duration, update the track and send out a notification.
//        if computedDuration != track.duration {
//            track.setDuration(computedDuration)
//        }
//
//        if track.duration != trackDurationBeforePrep {
//            Messenger.publish(TrackInfoUpdatedNotification(updatedTrack: track, updatedFields: .duration))
//        }
//
//        track.lazyLoadingInfo.preparedForPlayback = true
    }
    
    // TODO: Split this into 2 functions (supported types vs non-supported)
    // Loads detailed audio-specific info for the given track
    static func loadAudioInfo(_ track: Track) {
        
//        let fileExtension = track.file.lowerCasedExtension
//        
//        // TODO: Make it like this ... (initialize AudioInfo with playbackInfo)
////        if let playbackInfo = track.playbackInfo {
////            audioInfo = AudioInfo(playbackInfo)
////        }
//        
//        let audioInfo = AudioInfo()
//        
//        if (!track.isNativelySupported || fileExtension == "flac") {
//            
//            if let avInfo = track.libAVInfo, let audioStream = avInfo.audioStream {
//                
//                if let sampleRate = audioStream.sampleRate {
//                    audioInfo.sampleRate = sampleRate
//                    audioInfo.frames = Int64(sampleRate * track.duration)
//                }
//                
//                audioInfo.numChannels = audioStream.channelCount
//                
//                audioInfo.format = avInfo.fileFormatDescription
//                
//                if let codec = audioStream.formatDescription {
//                    audioInfo.codec = codec
//                }
//                
//                audioInfo.channelLayout = audioStream.channelLayout
//                
//                if let bitRate = audioStream.bitRate {
//                    
//                    audioInfo.bitRate = roundedInt(bitRate)
//                    
//                } else if track.duration == 0 {
//                    
//                    audioInfo.bitRate = 0
//                    
//                } else {
//
//                    let fileSize = FileSystemUtils.sizeOfFile(path: track.file.path)
//                    audioInfo.bitRate = roundedInt(Double(fileSize.sizeBytes) * 8 / (Double(track.duration) * Double(Size.KB)))
//                }
//            }
//            
//        } else {
//            
//            // TODO: If playback info is present, copy over the info. Otherwise, estimate frameCount.
//            
//            // Natively supported file type
//            
//            audioInfo.format = formatDescriptions[fileExtension]
//            
//            var estBitRate: Float = 0
//            
//            if let audioTrack = track.audioAsset?.tracks.first {
//                
//                if let codec = formatDescriptions[getFormat(audioTrack)], codec != audioInfo.format {
//                    audioInfo.codec = codec
//                } else {
//                    audioInfo.codec = fileExtension.uppercased()
//                }
//                
//                estBitRate = audioTrack.estimatedDataRate
//            }
//            
//            if estBitRate > 0 {
//                
//                audioInfo.bitRate = Int(round(estBitRate)) / Int(Size.KB)
//                
//            } else if track.duration == 0 {
//                
//                audioInfo.bitRate = 0
//                
//            } else {
//                    
//                let fileSize = FileSystemUtils.sizeOfFile(path: track.file.path)
//                audioInfo.bitRate = Int(round(Double(fileSize.sizeBytes) * 8 / (Double(track.duration) * Double(Size.KB))))
//            }
//        }
//        
//        track.audioInfo = audioInfo
    }
    
    // Normalizes a bit rate by rounding it to the nearest multiple of 32. For ex, a bit rate of 251.5 kbps is rounded to 256 kbps.
//    private static func normalizeBitRate(_ rate: Double) -> Int {
//        return Int(round(rate/32)) * 32
//    }
    
    // Computes a readable format string for an audio track
    private static func getFormat(_ assetTrack: AVAssetTrack) -> String {

        let description = CMFormatDescriptionGetMediaSubType(assetTrack.formatDescriptions.first as! CMFormatDescription)
        return codeToString(description).trimmingCharacters(in: CharacterSet.init(charactersIn: "."))
    }

    // Converts a four character media type code to a readable string
    static func codeToString(_ code: FourCharCode) -> String {

        let numericCode = Int(code)

        var codeString: String = String (describing: UnicodeScalar((numericCode >> 24) & 255)!)
        codeString.append(String(describing: UnicodeScalar((numericCode >> 16) & 255)!))
        codeString.append(String(describing: UnicodeScalar((numericCode >> 8) & 255)!))
        codeString.append(String(describing: UnicodeScalar(numericCode & 255)!))

        return codeString.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}
