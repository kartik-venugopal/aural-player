import AVFoundation

class MockAVAudioFile: AVAudioFile {
    
    var _processingFormat: AVAudioFormat
    
    override var processingFormat: AVAudioFormat {
        return _processingFormat
    }
    
    override convenience init() {
        self.init(AVAudioFormat(standardFormatWithSampleRate: 44100, channels: 2)!)
    }
    
    init(_ processingFormat: AVAudioFormat) {
        self._processingFormat = processingFormat
        super.init()
    }
}
