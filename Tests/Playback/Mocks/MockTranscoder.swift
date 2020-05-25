import Foundation

class MockTranscoder: TranscoderProtocol {
    
    func transcodeImmediately(_ track: Track) {
    }
    
    func transcodeInBackground(_ track: Track) {
    }
    
    func cancel(_ track: Track) {
    }
    
    var currentDiskSpaceUsage: UInt64 {return 0}
    
    func trackNeedsTranscoding(_ track: Track) -> Bool {
        return !track.playbackNativelySupported
    }
    
    func checkDiskSpaceUsage() {}
    
    func setMaxBackgroundTasks(_ numTasks: Int) {}
}
