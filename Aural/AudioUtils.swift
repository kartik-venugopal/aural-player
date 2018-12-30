import AVFoundation

/*
    Utility functions related to audio.
 */
class AudioUtils {
    
    private static let transcoder: TranscoderProtocol = ObjectGraph.transcoder
    
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
                
                audioInfo.format = avInfo.audioFormat
                
                if let bitRate = avInfo.audioStream?.bitRate {
                    audioInfo.bitRate = Int(round(bitRate))
                } else {
                    
                    // TODO: What if this is a Matroska/MP4 container that also contains video ? This will be overestimated
                    
                    let fileSize = FileSystemUtils.sizeOfFile(path: track.file.path)
                    audioInfo.bitRate = Int(round(Double(fileSize.sizeBytes) * 8 / (Double(track.duration) * Double(Size.KB))))
                }
                
                track.audioInfo = audioInfo
            }
            
        } else {
            
            if let asset = track.audioAsset {
                
                let audioInfo = AudioInfo()
                
                let assetTracks = asset.tracks(withMediaType: AVMediaType.audio)
                audioInfo.format = getFormat(assetTracks.first!)
                
                // TODO: What if this is a Matroska/MP4 container that also contains video ? This will be overestimated
                
                let fileSize = FileSystemUtils.sizeOfFile(path: track.file.path)
                audioInfo.bitRate = Int(round(Double(fileSize.sizeBytes) * 8 / (Double(track.duration) * Double(Size.KB))))
                
                track.audioInfo = audioInfo
            }
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
