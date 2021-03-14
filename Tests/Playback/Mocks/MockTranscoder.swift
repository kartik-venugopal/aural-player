import Foundation

class MockTranscoder: TranscoderProtocol {
    
    var transcodeImmediatelyCallCount: Int = 0
    var transcodeImmediately_track: Track?
    
    var transcodeImmediately_readyForPlayback: Bool = false
    var transcodeImmediately_failed: Bool = false
    
    var transcodeCancelCallCount: Int = 0
    var transcodeCancel_track: Track?
    
    func transcodeImmediately(_ track: Track) -> (readyForPlayback: Bool, transcodingFailed: Bool) {
        
        transcodeImmediatelyCallCount.increment()
        transcodeImmediately_track = track
        
        return (transcodeImmediately_readyForPlayback, transcodeImmediately_failed)
    }
    
    func transcodeInBackground(_ track: Track) {
    }
    
    func moveToBackground(_ track: Track) {
    }
    
    func cancelTranscoding(_ track: Track) {
        
        transcodeCancelCallCount.increment()
        transcodeCancel_track = track
    }
    
    var currentDiskSpaceUsage: UInt64 {return 0}
    
    func trackNeedsTranscoding(_ track: Track) -> Bool {
        return !track.playbackNativelySupported
    }
    
    func checkDiskSpaceUsage() {}
    
    func setMaxBackgroundTasks(_ numTasks: Int) {}
}
