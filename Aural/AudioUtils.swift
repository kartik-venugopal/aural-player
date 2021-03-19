import AVFoundation

/*
    Utility functions related to audio.
 */
class AudioUtils {
    
    private static let transcoder: TranscoderProtocol = ObjectGraph.transcoder
    
    private static let formatDescriptions: [String: String] = [
    
        "mp3": "MPEG Audio Layer III (mp3)",
        "m4a": "MPEG-4 Audio (m4a)",
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
    static func validateTrack(_ track: Track) -> InvalidTrackError? {
        
        // TODO: What if file has protected content
        // Check sourceAsset.hasProtectedContent()
        // Test against a protected iTunes file
        
        let fileExtension = track.file.pathExtension.lowercased()
        
        if !track.playbackNativelySupported || fileExtension == "flac" {
            
            if track.libAVInfo == nil {
                track.libAVInfo = FFMpegWrapper.getMetadata(track)
            }
            
            let avInfo = track.libAVInfo!
            
            if !avInfo.hasValidAudioTrack {
                return TrackNotPlayableError(track)
            }
            
            if avInfo.drmProtected {
                return DRMProtectionError(track)
            }
            
            return nil
            
        } else {
            
            if (track.audioAsset == nil) {
                track.audioAsset = AVURLAsset(url: track.file, options: nil)
            }
            
            if track.audioAsset!.hasProtectedContent {
                return DRMProtectionError(track)
            }
            
            let assetTracks = track.audioAsset?.tracks(withMediaType: AVMediaType.audio)
            
            // Check if the asset has any audio tracks
            if (assetTracks?.count == 0) {
                return NoAudioTracksError(track)
            }
            
            // Find out if track is playable
            // TODO: What does isPlayable actually mean ?
            if let assetTrack = assetTracks?.first, !assetTrack.isPlayable {
                return TrackNotPlayableError(track)
            }
            
            return nil
        }
    }
    
    // Loads info necessary for playback of the given track. Returns whether or not the info was successfully loaded.
    static func loadPlaybackInfo(_ track: Track) {
        
        if !track.playbackNativelySupported {
            
            // Transcode the track and let the transcoder prepare the track for playback
            track.lazyLoadingInfo.needsTranscoding = true
            
            // If there is already a transcoded output file for this track, just use it to prepare the track. Otherwise, just return ... the transcoder will produce a file later.
            transcoder.transcodeImmediately(track)
            
        } else {
            prepareTrackWithFile(track, track.file)
        }
    }
    
    static func loadPlaybackInfo_noPlayback(_ track: Track) {
        
        if track.playbackNativelySupported {
            
            if let audioFile = AudioIO.createAudioFileForReading(track.file) {
                
                let playbackInfo = PlaybackInfo()
                
                playbackInfo.audioFile = audioFile
                track.lazyLoadingInfo.preparedForPlayback = true
                
                playbackInfo.sampleRate = audioFile.processingFormat.sampleRate
                playbackInfo.frames = Int64(playbackInfo.sampleRate! * track.duration)
                playbackInfo.numChannels = Int(playbackInfo.audioFile!.fileFormat.channelCount)
                
                track.playbackInfo = playbackInfo
            }
            
        } else {
            
            if let stream = track.libAVInfo?.audioStream {
                
                let playbackInfo = PlaybackInfo()
                
                playbackInfo.sampleRate = stream.sampleRate
                playbackInfo.numChannels = stream.channelCount
                playbackInfo.frames = Int64(playbackInfo.sampleRate! * track.duration)
                
                track.playbackInfo = playbackInfo
            }
        }
    }
    
    static func prepareTrackWithFile(_ track: Track, _ file: URL) {
        
        let playbackInfo = PlaybackInfo()
        
        if let audioFile = AudioIO.createAudioFileForReading(file) {
            
            if track.duration == 0 {
                
                // Load duration from transcoded output file
                track.setDuration(MetadataUtils.durationForFile(file))
                AsyncMessenger.publishMessage(TrackUpdatedAsyncMessage(track))
            }
            
            playbackInfo.audioFile = audioFile
            track.playbackInfo = playbackInfo
            track.lazyLoadingInfo.preparedForPlayback = true
            
            if !track.playbackNativelySupported, let stream = track.libAVInfo?.audioStream {
                
                playbackInfo.sampleRate = stream.sampleRate
                playbackInfo.numChannels = stream.channelCount
                playbackInfo.frames = Int64(playbackInfo.sampleRate! * track.duration)
                
            } else {
                
                playbackInfo.sampleRate = audioFile.processingFormat.sampleRate
                playbackInfo.frames = Int64(playbackInfo.sampleRate! * track.duration)
                playbackInfo.numChannels = Int(playbackInfo.audioFile!.fileFormat.channelCount)
            }
        }
    }
    
    // Loads detailed audio-specific info for the given track
    static func loadAudioInfo(_ track: Track) {
        
        let fileExtension = track.file.pathExtension.lowercased()
        
        if !track.playbackNativelySupported || fileExtension == "flac" {
            
            if let avInfo = track.libAVInfo {
                
                let audioInfo = AudioInfo()
                
                audioInfo.format = avInfo.fileFormatDescription
                
                if let codec = avInfo.audioStream?.formatDescription, codec != audioInfo.format {
                    audioInfo.codec = codec
                }
                
                audioInfo.channelLayout = avInfo.audioStream?.channelLayout
                
                if let bitRate = avInfo.audioStream?.bitRate {
                    audioInfo.bitRate = Int(round(bitRate))
                } else {
                    
                    // TODO: What if this is a Matroska/MP4 container that also contains video ? This will be overestimated
                    
                    if track.duration == 0 {
                        audioInfo.bitRate = 0
                    } else {
                        let fileSize = FileSystemUtils.sizeOfFile(path: track.file.path)
                        audioInfo.bitRate = Int(round(Double(fileSize.sizeBytes) * 8 / (Double(track.duration) * Double(Size.KB))))
                    }
                }
                
                track.audioInfo = audioInfo
            }
            
        } else {
            
            let audioInfo = AudioInfo()
            
            let ext = track.file.pathExtension.lowercased()
            audioInfo.format = formatDescriptions[ext]
            
            if let audioTrack = track.audioAsset?.tracks.first, let codec = formatDescriptions[getFormat(audioTrack)], codec != audioInfo.format {
                audioInfo.codec = codec
            }
            
            // TODO: What if this is a MP4 container that also contains video ? This will be overestimated
            
            if track.duration == 0 {
                audioInfo.bitRate = 0
            } else {
                let fileSize = FileSystemUtils.sizeOfFile(path: track.file.path)
                audioInfo.bitRate = Int(round(Double(fileSize.sizeBytes) * 8 / (Double(track.duration) * Double(Size.KB))))
            }
            
            track.audioInfo = audioInfo
        }
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
    private static func codeToString(_ code: FourCharCode) -> String {

        let numericCode = Int(code)

        var codeString: String = String (describing: UnicodeScalar((numericCode >> 24) & 255)!)
        codeString.append(String(describing: UnicodeScalar((numericCode >> 16) & 255)!))
        codeString.append(String(describing: UnicodeScalar((numericCode >> 8) & 255)!))
        codeString.append(String(describing: UnicodeScalar(numericCode & 255)!))

        return codeString.trimmingCharacters(in: CharacterSet.whitespaces)
    }
    
    static func isAudioFilePlaybackNativelySupported(_ file: URL) -> Bool {
        return AppConstants.SupportedTypes.nativeAudioExtensions.contains(file.pathExtension.lowercased())
    }
}
