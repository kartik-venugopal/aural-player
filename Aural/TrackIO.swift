/*
 Reads track info from the filesystem
 */

import Cocoa
import AVFoundation

class TrackIO {
    
    // Load duration and display metadata (artist/title/art)
    static func loadDisplayInfo(_ track: Track) {
        
        let sourceAsset = AVURLAsset(url: track.file, options: nil)
        track.avAsset = sourceAsset
        track.setDuration(sourceAsset.duration.seconds)
        
        MetadataReader.loadDisplayMetadata(track)
    }
    
    // Load all the information required to play this track
    static func prepareForPlayback(_ track: Track) {
        
        let lazyLoadInfo = track.lazyLoadingInfo
        
        if (lazyLoadInfo.preparedForPlayback || lazyLoadInfo.preparationFailed) {
            return
        }
        
        if (track.avAsset == nil) {
            track.avAsset = AVURLAsset(url: track.file, options: nil)
        }
        
        let assetTracks = track.avAsset?.tracks(withMediaType: AVMediaTypeAudio)
        
        // Check if the asset has any audio tracks
        if (assetTracks?.count == 0) {
            lazyLoadInfo.preparationFailed = true
            lazyLoadInfo.preparationError = NoAudioTracksError(track.file)
            return
        }
        
        // Find out if track is playable
        let assetTrack = assetTracks?[0]
        
        // TODO: What does isPlayable actually mean ?
        if (!(assetTrack?.isPlayable)!) {
            lazyLoadInfo.preparationFailed = true
            lazyLoadInfo.preparationError = TrackNotPlayableError(track.file)
            return
        }
        
        // Determine the format to find out if it is supported
        let format = getFormat(assetTrack!)
        if (!AppConstants.supportedAudioFileFormats.contains(format)) {
            lazyLoadInfo.preparationFailed = true
            lazyLoadInfo.preparationError = UnsupportedFormatError(track.file, format)
            return
        }
        
        // TODO: What if file has protected content
        // Check sourceAsset.hasProtectedContent()
        // Test against a protected iTunes file
        
        var avFile: AVAudioFile? = nil
        do {
            avFile = try AVAudioFile(forReading: track.file)
            
            let playbackInfo = PlaybackInfo()
            
            playbackInfo.avFile = avFile!
            playbackInfo.sampleRate = avFile!.processingFormat.sampleRate
            
            if (!track.hasDuration()) {
                let duration = track.avAsset!.duration.seconds
                track.setDuration(duration)
            }
            
            playbackInfo.frames = Int64(playbackInfo.sampleRate! * track.duration)
            playbackInfo.numChannels = Int(playbackInfo.avFile!.fileFormat.channelCount)
            
            track.playbackInfo = playbackInfo
            lazyLoadInfo.preparedForPlayback = true
            
        } catch let error as NSError {
            
            lazyLoadInfo.preparationFailed = true
            lazyLoadInfo.preparationError = TrackNotPlayableError(track.file)
            
            NSLog("Error reading track '%@': %@", track.file.path, error.description)
        }
    }
    
    // Load detailed track info
    static func loadDetailedTrackInfo(_ track: Track) {
        
        let lazyLoadInfo = track.lazyLoadingInfo
        
        if (lazyLoadInfo.detailedInfoLoaded) {
            return
        }
        
        var fileAttrLoaded: Bool = false
        var extendedMetadataLoaded: Bool = false
        
        let audioAndFileInfo = AudioAndFileInfo()
        
        let assetTracks = track.avAsset!.tracks(withMediaType: AVMediaTypeAudio)
        audioAndFileInfo.format = getFormat(assetTracks[0])
        
        // File size and bit rate
        audioAndFileInfo.size = FileSystemUtils.sizeOfFile(path: track.file.path)
        audioAndFileInfo.bitRate = normalizeBitRate(Double(audioAndFileInfo.size!.sizeBytes) * 8 / (Double(track.duration) * Double(Size.KB)))
        
        track.audioAndFileInfo = audioAndFileInfo
        
        fileAttrLoaded = true
        
        MetadataReader.loadAllMetadata(track)
        extendedMetadataLoaded = true
        
        lazyLoadInfo.detailedInfoLoaded = fileAttrLoaded && extendedMetadataLoaded
    }
    
    // Normalizes a bit rate by rounding it to the nearest multiple of 32. For ex, a bit rate of 251.5 kbps is rounded to 256 kbps.
    private static func normalizeBitRate(_ rate: Double) -> Int {
        return Int(round(rate/32)) * 32
    }
    
    // Computes a readable format string for an audio track
    private static func getFormat(_ assetTrack: AVAssetTrack) -> String {
        
        let desc = CMFormatDescriptionGetMediaSubType(assetTrack.formatDescriptions[0] as! CMFormatDescription)
        var format = codeToString(desc)
        format = format.trimmingCharacters(in: CharacterSet.init(charactersIn: "."))
        return format
    }
    
    // Converts a four character media type code to a readable string
    private static func codeToString(_ code: FourCharCode) -> String {
        let n = Int(code)
        var s: String = String (describing: UnicodeScalar((n >> 24) & 255)!)
        s.append(String(describing: UnicodeScalar((n >> 16) & 255)!))
        s.append(String(describing: UnicodeScalar((n >> 8) & 255)!))
        s.append(String(describing: UnicodeScalar(n & 255)!))
        return s.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}
