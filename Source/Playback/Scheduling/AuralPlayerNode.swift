import AVFoundation

typealias SessionCompletionHandler = (PlaybackSession) -> Void

/*
    A custom AVAudioPlayerNode that provides:
 
    1 - Convenient scheduling functions that convert seek times to audio frame positions. Callers can schedule segments
    in terms of seek times and do not need to compute segments in terms of audio frames.
 
    2 - Computation of the current track seek position (by converting playerNode's sampleTime).
 */
class AuralPlayerNode: AVAudioPlayerNode {

    // This property will have no effect on macOS 10.12 or older.
    var completionCallbackType: AVAudioPlayerNodeCompletionCallbackType = .dataPlayedBack
    
    var completionCallbackQueue: DispatchQueue = DispatchQueue.global()
    
    // The start frame for the current playback session (used to calculate seek position). Represents the point in the track at which playback began.
    private var startFrame: AVAudioFramePosition = 0

    // Cached seek position (used when looping, to remember last seek position and avoid displaying 0 when player is temporarily stopped at the end of a loop)
    private var lastSeekPosn: Double = 0
    
    // The absolute minimum frame count when scheduling a segment (to prevent crashes in the playerNode).
    private static let minFrames: AVAudioFrameCount = 2
    
    // Retrieves the current seek position, in seconds
    var seekPosition: Double {
        
        if let nodeTime = lastRenderTime, let playerTime = playerTime(forNodeTime: nodeTime) {
            lastSeekPosn = Double(startFrame + playerTime.sampleTime) / playerTime.sampleRate
        }

        // Default to last remembered position when nodeTime is nil
        return lastSeekPosn
    }
    
    func scheduleSegment(_ session: PlaybackSession, _ completionHandler: @escaping SessionCompletionHandler, _ startTime: Double, _ endTime: Double? = nil, _ startFrame: AVAudioFramePosition? = nil, _ immediatePlayback: Bool = true) -> PlaybackSegment? {

        guard let segment = computeSegment(session, startTime, endTime, startFrame) else {return nil}
        
        scheduleSegment(segment, completionHandler, immediatePlayback)
        return segment
    }

    func scheduleSegment(_ segment: PlaybackSegment, _ completionHandler: @escaping SessionCompletionHandler, _ immediatePlayback: Bool = true) {

        // The start frame and seek position should be reset only if this segment will be played immediately.
        // If it is being scheduled for the future, doing this will cause inaccurate seek position values.
        if immediatePlayback {
            
            // Advance the last seek position to the new position
            startFrame = segment.firstFrame
            lastSeekPosn = segment.startTime
        }
        
        if #available(OSX 10.13, *) {

            scheduleSegment(segment.playingFile, startingFrame: segment.firstFrame, frameCount: segment.frameCount, at: nil, completionCallbackType: completionCallbackType, completionHandler: {(callbackType: AVAudioPlayerNodeCompletionCallbackType) -> Void in
                self.completionCallbackQueue.async {completionHandler(segment.session)}
            })

        } else {
            
            scheduleSegment(segment.playingFile, startingFrame: segment.firstFrame, frameCount: segment.frameCount, at: nil, completionHandler: {() -> Void in
                self.completionCallbackQueue.async {completionHandler(segment.session)}
            })
        }
    }
    
    func computeSegment(_ session: PlaybackSession, _ startTime: Double, _ endTime: Double? = nil, _ startFrame: AVAudioFramePosition? = nil) -> PlaybackSegment? {
        
        guard let playbackInfo = session.track.playbackInfo, let playingFile: AVAudioFile = playbackInfo.audioFile else {
            return nil
        }

        let sampleRate = playbackInfo.sampleRate

        // If an exact start frame is specified, use it.
        // Otherwise, multiply sample rate by the new seek time in seconds to obtain the start frame.
        var firstFrame: AVAudioFramePosition = startFrame ?? AVAudioFramePosition(startTime * sampleRate)
        
        var lastFrame: AVAudioFramePosition
        var segmentEndTime: Double

        // Check if end time is specified.
        if let theEndTime = endTime {

            // Use loop end time to calculate the last frame.
            lastFrame = AVAudioFramePosition(theEndTime * sampleRate)
            segmentEndTime = theEndTime

        } else {

            // No end time, use audio file's total frame count to determine the last frame
            lastFrame = playbackInfo.frames
            segmentEndTime = session.track.duration
        }

        var frameCount: AVAudioFrameCount = AVAudioFrameCount(lastFrame - firstFrame + 1)

        // If the frame count is less than the minimum required to continue playback,
        // schedule the minimum frame count for playback, to avoid crashes in the playerNode.
        if frameCount < AuralPlayerNode.minFrames {
            
            frameCount = AuralPlayerNode.minFrames
            firstFrame = lastFrame - AVAudioFramePosition(frameCount) + 1
        }
        
        return PlaybackSegment(session, playingFile, firstFrame, lastFrame, frameCount, startTime, segmentEndTime)
    }
}
