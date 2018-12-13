import AVFoundation

/*
    Utility functions related to audio.
 */
class AudioUtils {
    
    private static let flacSupported: Bool = {
        
        let systemVersion = ProcessInfo.processInfo.operatingSystemVersion
        return (systemVersion.majorVersion == 10 && systemVersion.minorVersion >= 13) || systemVersion.majorVersion > 10
    }()
    
    // Validates a track to determine if it is playable. If the track is not playable, returns an error object describing the problem.
    static func validateTrack(_ track: Track) -> InvalidTrackError? {
        
        // TODO: What if file has protected content
        // Check sourceAsset.hasProtectedContent()
        // Test against a protected iTunes file
        
        let fileExtension = track.file.pathExtension.lowercased()
        
        if !track.nativelySupported || fileExtension == "flac" {
            
            if track.libAVInfo == nil {
                track.libAVInfo = LibAVWrapper.getMetadata(track.file)
            }
            
            if !track.libAVInfo!.hasValidAudioTrack {
                return TrackNotPlayableError(track)
            }
            
            return nil
            
        } else {
            
            if (track.audioAsset == nil) {
                track.audioAsset = AVURLAsset(url: track.file, options: nil)
            }
            
            let assetTracks = track.audioAsset?.tracks(withMediaType: AVMediaType.audio)
            
            // Check if the asset has any audio tracks
            if (assetTracks?.count == 0) {
                return NoAudioTracksError(track)
            }
            
            // Find out if track is playable
            // TODO: What does isPlayable actually mean ?
            if let assetTrack = assetTracks?.first {
                
                if !assetTrack.isPlayable {
                    return TrackNotPlayableError(track)
                }
                
                // Determine the format to find out if it is supported
                let format = getFormat(assetTrack)
                if !AppConstants.SupportedTypes.audioFormats.contains(format) {
                    return UnsupportedFormatError(track, format)
                }
            }
            
            return nil
            
        }
    }
    
    // Loads info necessary for playback of the given track. Returns whether or not the info was successfully loaded.
    static func loadPlaybackInfo(_ track: Track) -> Bool {
        
        // TODO: Check if need to transcode
        
        var trackFile = track.file
        
        if !track.nativelySupported {
            
            if let transFile = LibAVWrapper.transcode(track.file) {
                trackFile = transFile
            } else {
                // Transcoding failed. TODO: Show error
                return false
            }
        }
        
        if let audioFile = AudioIO.createAudioFileForReading(trackFile) {
        
            let playbackInfo = PlaybackInfo()
            
            playbackInfo.audioFile = audioFile
            playbackInfo.sampleRate = audioFile.processingFormat.sampleRate
            
            if (!track.hasDuration()) {
                let duration = track.audioAsset!.duration.seconds
                track.setDuration(duration)
                
                // TODO: Emit track updated event, so that duration is updated in UI
            }
            
            playbackInfo.frames = Int64(playbackInfo.sampleRate! * track.duration)
            playbackInfo.numChannels = Int(playbackInfo.audioFile!.fileFormat.channelCount)
            
            track.playbackInfo = playbackInfo
            
            return true
        }
        
        return false
    }
    
    // Loads detailed audio-specific info for the given track
    static func loadAudioInfo(_ track: Track) {
        
        let audioInfo = AudioInfo()
        
        // TODO: Check if natively supported
        let fileExtension = track.file.pathExtension.lowercased()
        
        if !track.nativelySupported || fileExtension == "flac" {

            audioInfo.format = track.libAVInfo!.audioFormat
            
        } else {
            
            let assetTracks = track.audioAsset!.tracks(withMediaType: AVMediaType.audio)
            audioInfo.format = getFormat(assetTracks.first!)
        }
        
        let fileSize = FileSystemUtils.sizeOfFile(path: track.file.path)
        audioInfo.bitRate = normalizeBitRate(Double(fileSize.sizeBytes) * 8 / (Double(track.duration) * Double(Size.KB)))
        
        track.audioInfo = audioInfo
    }
    
    // Normalizes a bit rate by rounding it to the nearest multiple of 32. For ex, a bit rate of 251.5 kbps is rounded to 256 kbps.
    private static func normalizeBitRate(_ rate: Double) -> Int {
        return Int(round(rate/32)) * 32
    }
    
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
    
    static func isAudioFileNativelySupported(_ file: URL) -> Bool {
        
        let fileExtension = file.pathExtension.lowercased()
        
        if AppConstants.SupportedTypes.nativeAudioExtensions.contains(fileExtension) {
            return true
        }
        
        // FLAC is available on 10.13 and higher
        if fileExtension == "flac" {return flacSupported}
        
        return false
    }
}
