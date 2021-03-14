import AVFoundation

public class RecordingParams {
    
    let format: RecordingFormat
    let quality: RecordingQuality
    
    init(_ format: RecordingFormat, _ quality: RecordingQuality) {
        self.format = format
        self.quality = quality
    }
    
    var settings: [String: Any] {
        
        var settings = [String: Any]()
        
        settings[AVFormatIDKey] = format.formatId
        settings[AVEncoderAudioQualityKey] = quality.avAudioQuality
        
        // 44 KHz stereo
        settings[AVSampleRateKey] = 44100
        settings[AVNumberOfChannelsKey] = 2
        
        return settings
    }
}
