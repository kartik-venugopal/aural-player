import Foundation

class MockTrack: Track {
    
    override func validateAudio() -> InvalidTrackError? {
        return nil
    }
    
    override func prepareForPlayback() {
        
        if !playbackNativelySupported {
            
            // Transcode the track and let the transcoder prepare the track for playback
            lazyLoadingInfo.needsTranscoding = true
            
        } else {
            
            playbackInfo = PlaybackInfo()
            playbackInfo?.audioFile = MockAVAudioFile()
            playbackInfo?.frames = 44100 * 300
            playbackInfo?.numChannels = 2
            playbackInfo?.sampleRate = 44100
            
            lazyLoadingInfo.preparedForPlayback = true
        }
    }
    
    override func prepareWithAudioFile(_ file: URL) {
        
        playbackInfo = PlaybackInfo()
        playbackInfo?.audioFile = MockAVAudioFile()
        playbackInfo?.frames = 44100 * 300
        playbackInfo?.numChannels = 2
        playbackInfo?.sampleRate = 44100
        
        lazyLoadingInfo.preparedForPlayback = true
    }
}
