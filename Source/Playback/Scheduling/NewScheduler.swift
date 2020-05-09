import Cocoa
import AVFoundation

// ***** WARNING - This class is a WORK IN PROGRESS. It is NOT ready for use. ***

/*
 Manages audio scheduling, and playback. Provides two main operations - play() and seekToTime(). Works in conjunction with a playerNode to perform playback.
 
 A "playback session" begins when playback is started, as a result of either play() or seekToTime(). It ends when either playback is completed or a new request is received (and stop() is called).
 */
@available(OSX 10.13, *)
class NewScheduler: PlaybackSchedulerProtocol {
    
    // Interval (defined in seconds) used for scheduling of a minimal playback segment to prevent problems arising from zero/negative frame counts and to ensure
    // that the completion handler is invoked (eg. at the end of a track)
    static let minPlaybackTime: Double = 0.01

    // Player node used for actual playback
    private var playerNode: AVAudioPlayerNode

    // The start frame for the current playback session (used to calculate seek position). Represents the point in the track at which playback began.
    private var startFrame: AVAudioFramePosition = 0

    // Cached seek position (used when looping, to remember last seek position and avoid displaying 0 when player is temporarily stopped at the end of a loop)
    private var lastSeekPosn: Double = 0

    private var loopingSegment: PlaybackSegment?

    init(_ playerNode: AVAudioPlayerNode) {
        self.playerNode = playerNode
    }

    // Start track playback from a given position expressed in seconds
    func playTrack(_ session: PlaybackSession, _ startPosition: Double) {
        seekToTime(session, startPosition, true)
    }

    // Seeks to a certain position (seconds) in the specified track. Returns the calculated start frame.
    func seekToTime(_ session: PlaybackSession, _ startTime: Double, _ beginPlayback: Bool) {

        // Halt current playback
        stop()

        _ = scheduleSegment(session, .dataPlayedBack, {(callbackType: AVAudioPlayerNodeCompletionCallbackType) -> Void in
            
            DispatchQueue.global(qos: .userInteractive).async {
                self.segmentCompleted(session)
            }
            
        }, startTime)

        // Don't start playing if player is paused
        if beginPlayback {
            playerNode.play()
        }
    }

    private func scheduleSegment(_ session: PlaybackSession, _ callbackType: AVAudioPlayerNodeCompletionCallbackType, _ completionHandler: ((AVAudioPlayerNodeCompletionCallbackType) -> Void)?, _ startTime: Double, _ endTime: Double? = nil) -> PlaybackSegment? {

        if let segment = computeSegment(session, startTime, endTime) {

            doScheduleSegment(segment, callbackType, completionHandler)
            return segment
        }

        return nil
    }

    private func doScheduleSegment(_ segment: PlaybackSegment, _ callbackType: AVAudioPlayerNodeCompletionCallbackType, _ completionHandler: ((AVAudioPlayerNodeCompletionCallbackType) -> Void)?) {

        // Advance the last seek position to the new position
        startFrame = segment.firstFrame
        lastSeekPosn = segment.startTime

        // Schedule a segment beginning at the seek time, with the calculated frame count reflecting the remaining audio frames in the file
        playerNode.scheduleSegment(segment.playingFile, startingFrame: segment.firstFrame, frameCount: segment.frameCount, at: nil, completionCallbackType: callbackType, completionHandler: completionHandler)
    }

    private func computeSegment(_ session: PlaybackSession, _ startTime: Double, _ endTime: Double? = nil) -> PlaybackSegment? {

        if let playingFile: AVAudioFile = session.track.playbackInfo?.audioFile,
            let totalFrames: AVAudioFramePosition = session.track.playbackInfo?.frames {

            let sampleRate = playingFile.processingFormat.sampleRate
            let minFrames = Int64(sampleRate * NewScheduler.minPlaybackTime)

            //  Multiply sample rate by the new seek time in seconds. This will produce the exact start frame.
            var firstFrame = Int64(startTime * sampleRate)
            var lastFrame: Int64

            // Check if a complete loop is present.
            if let _endTime = endTime {

                // Use loop end time to calculate the last frame.
                lastFrame = Int64(_endTime * sampleRate)

            } else {

                // No loop, use audio file's total frame count
                lastFrame = totalFrames
            }

            var frameCount: Int64 = lastFrame - firstFrame + 1

            // If the frame count is less than the minimum required to continue playback,
            // schedule the minimum frame count for playback, to avoid scheduling problems
            if frameCount < minFrames {

                frameCount = minFrames
                firstFrame = lastFrame - minFrames + 1
            }

            return PlaybackSegment(session, playingFile, firstFrame, lastFrame, AVAudioFrameCount(frameCount), startTime, endTime)
        }

        // Impossible
        return nil
    }

    private func segmentCompleted(_ session: PlaybackSession) {

        // If the segment-associated session is not the same as the current session
        // (possible if stop() was called, eg. when seeking), don't do anything
        if let curSession = PlaybackSession.currentSession, curSession == session {

            // Prevent lastSeekPosn from overruning the track duration to prevent weird incorrect UI displays of seek time
            lastSeekPosn = session.track.duration
            
            // Signal track playback completion
            AsyncMessenger.publishMessage(PlaybackCompletedAsyncMessage.instance)
        }
    }

    func pause() {

        // Update lastSeekPosn before pausing
        _ = seekPosition
        playerNode.pause()
    }

    func resume() {
        playerNode.play()
    }

    // Clears any previously scheduled segments and stops playback, in response to a request to stop playback, change a track, or when seeking to a new position. Marks the end of a "playback session".
    func stop() {

        // Invalidate the loop segment, if one is defined
        loopingSegment = nil

        // Clear any previous buffers and stop playback
        playerNode.stop()
    }

    // Retrieves the current seek position, in seconds
    var seekPosition: Double {

        if let nodeTime = playerNode.lastRenderTime, let playerTime = playerNode.playerTime(forNodeTime: nodeTime) {

//            var samplesPlayed: AVAudioFramePosition = playerTime.sampleTime

            lastSeekPosn = Double(startFrame + playerTime.sampleTime) / playerTime.sampleRate

            // ********** USE FIRST FRAME, LAST FRAME, AND FRAME COUNT IN LOOPING SEGMENT TO CALCULATE POSITION WHEN LOOPING ********

            // Prevent lastSeekPosn from overruning the track duration to prevent weird incorrect UI displays of seek time
            if let session = PlaybackSession.currentSession {

                // Check for complete loop
                //                if let loopEndTime = session.loop?.endTime, let loopSegment = self.loopingSegment {
//                if let loopSegment = self.loopingSegment, let loopEndTime = loopSegment.endTime  {
//
////                    print("\nSeekPos:", lastSeekPosn)
////                    print("StartFrame:", startFrame!,
////                          "SampleTime:", playerTime.sampleTime, "SampleRate:", playerTime.sampleRate)
//
//                    if samplesPlayed > loopSegment.frameCount {
//
//                        samplesPlayed = samplesPlayed % Int64(loopSegment.frameCount)
//                        lastSeekPosn = Double(loopSegment.firstFrame + samplesPlayed) / playerTime.sampleRate
//                        lastSeekPosn = min(lastSeekPosn, loopEndTime)
//
////                        print("NOW SeekPos:", lastSeekPosn)
//                    }
//
//                } else {
                    lastSeekPosn = min(max(0, lastSeekPosn), session.track.duration)
//                }
            }
        }

        // Default to last remembered position when nodeTime is nil
        return lastSeekPosn
    }

    // MARK: Loop scheduling -------------------------------------------------------------------------------------------
    
    // Starts loop playback at the beginning of the loop
    func playLoop(_ session: PlaybackSession, _ beginPlayback: Bool) {
        
//        if let loop = session.loop {
//            playLoop(session, loop.startTime, beginPlayback)
//        }
    }

    // Starts loop playback but not necessarily at the beginning of the loop (e.g. chapter loop)
    func playLoop(_ session: PlaybackSession, _ startTime: Double, _ beginPlayback: Bool) {

//        print("\nPlayLoop:", session.id, startTime, beginPlayback)
//
//        stop()
//
//        if let loop = session.loop, let loopEndTime = loop.endTime {
//
//            print("StartTime:", loop.startTime, "EndTime:", loopEndTime)
//
//            // Define the initial segment (which may not constitute the entire portion of the loop segment)
//            let segment = scheduleSegment(session, .dataRendered, {(callbackType: AVAudioPlayerNodeCompletionCallbackType) -> Void in
//
//              DispatchQueue.global(qos: .userInteractive).async {self.restartLoop(session)}
////                self.restartLoop(session)
//
//            }, startTime, loopEndTime)
//
//            self.loopingSegment = loop.startTime == startTime ? segment : nil
//
//            if loop.startTime == startTime {
//                print("EQUAL START TIMES !!!", loop.startTime)
//            }
//        }
//
//        // Don't start playing if player is paused
//        if beginPlayback {
//            playerNode.play()
//        }
    }

    private func restartLoop(_ session: PlaybackSession) {

        // Validate the session and check for a complete loop
//        if let curSession = PlaybackSession.currentSession, curSession == session,
//            let loop = session.loop, let loopEndTime = loop.endTime {
//
//            print("\nRESTARTING LOOP ...")
//
//            let wasPlaying: Bool = playerNode.isPlaying
//
//            // Reset the player's nodeTime
//            stop()
//
//            // The very first time (i.e. the first restart of the loop), this will be nil, so compute it.
//            if self.loopingSegment == nil {
//
//                print("\nCOMPUTED LOOP SEGMENT ...")
//                self.loopingSegment = computeSegment(session, loop.startTime, loopEndTime)
//            }
//
//            if let loopSegment = self.loopingSegment {
//
//                // Reschedule the looping segment
//                doScheduleSegment(loopSegment, .dataRendered, {(callbackType: AVAudioPlayerNodeCompletionCallbackType) -> Void in
////                    print("\nSEG 3 from:", Thread.current)
////                    DispatchQueue.main.async {self.restartLoop(session)}
//                    DispatchQueue.global(qos: .userInteractive).async {self.restartLoop(session)}
//                })
//
//                print("\nSCHEDULED NEW LOOP SEGMENT ...")
//
//                if wasPlaying {
//                    playerNode.play()
//                }
//            }
//
//        } // else do nothing
    }
    
    func endLoop(_ playbackSession: PlaybackSession, _ loopEndTime: Double) {

//        let wasPlaying: Bool = playerNode.isPlaying
//
//        print("Loop ended at position:", seekPosition)
//
//        stop()
//
//        // Loop's end time will be the start time for the new segment
//        _ = scheduleSegment(playbackSession, .dataPlayedBack, {(callbackType: AVAudioPlayerNodeCompletionCallbackType) -> Void in
////            DispatchQueue.global(qos: .userInteractive).async {self.segmentCompleted(session)}
//            self.segmentCompleted(playbackSession)
//
//        }, loopEndTime)
//
//        if wasPlaying {
//            playerNode.play()
//        }
    }
}

class PlaybackSegment {

    let session: PlaybackSession

    let playingFile: AVAudioFile

    let startTime: Double
    let endTime: Double?

    let firstFrame: Int64
    let lastFrame: Int64

    let frameCount: AVAudioFrameCount

    init(_ session: PlaybackSession, _ playingFile: AVAudioFile, _ firstFrame: Int64, _ lastFrame: Int64, _ frameCount: AVAudioFrameCount, _ startTime: Double, _ endTime: Double? = nil) {

        self.session = session
        self.playingFile = playingFile

        self.startTime = startTime
        self.endTime = endTime

        self.firstFrame = firstFrame
        self.lastFrame = lastFrame

        self.frameCount = frameCount
    }
}
