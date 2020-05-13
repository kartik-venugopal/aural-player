import AVFoundation

class MockAVAudioFile: AVAudioFile {
    
    var _processingFormat: AVAudioFormat = AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!
    
    override var processingFormat: AVAudioFormat {
        return _processingFormat
    }
    
    init(_ processingFormat: AVAudioFormat) {
        super.init()
        self._processingFormat = processingFormat
    }
}
