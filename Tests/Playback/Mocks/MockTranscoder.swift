import Foundation

class MockTranscoder: TranscoderProtocol {
    
    var transcodeImmediatelyCallCount: Int = 0
    var transcodeImmediately_track: Track?
    
    var transcodeCancelCallCount: Int = 0
    var transcodeCancel_track: Track?
    
    func transcodeImmediately(_ track: Track) {
        
        transcodeImmediatelyCallCount.increment()
        transcodeImmediately_track = track
    }
    
    func transcodeInBackground(_ track: Track) {
    }
    
    func cancel(_ track: Track) {
        
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
