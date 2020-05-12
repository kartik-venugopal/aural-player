import Cocoa
import AVFoundation

/*
    Manages audio scheduling, and playback. See PlaybackSchedulerProtocol for more details on all the functions provided.
 */
class LegacyPlaybackScheduler: PlaybackScheduler {

    // A timer used to check if track playback has completed. This is required because the playerNode sends completion notifications prematurely, before track
    // playback has been completed. This problem has been fixed in PlaybackScheduler. It is the reason why this class is now deprecated, and only in use on macOS Sierra
    // systems.
    private var completionPollTimer: RepeatingTaskExecutor?
    
    // The interval at which the completionPollTimer repeats its task.
    static let completionPollTimerIntervalMillis: Int = 125     // 1/8th of a second
    
    // Interval used for comparing two Double values (to avoid problems with Double precision resulting in equal values being considered inequal)
    // If two Double track seek times are within 0.01 seconds of each other, we'll consider them equal (used to detect the completion of playback of a loop or segment)
    static let timeComparisonTolerance: Double = 0.01

    override init(_ playerNode: AuralPlayerNode) {
        super.init(playerNode)
        NSLog("Instantiated Legacy Scheduler")
    }
    
    override func pause() {

        playerNode.pause()
        
        // If the completion timer is running, pause it
        completionPollTimer?.pause()
    }

    override func resume() {
        
        playerNode.play()
        
        // If the completion timer is paused, resume it
        completionPollTimer?.startOrResume()
    }

    override func stop() {
        
        NSLog("stop()")

        playerNode.stop()
        
        // Completion timer is no longer relevant for this playback session which has ended.
        destroyCompletionTimer()
    }
    
    override func endLoop(_ session: PlaybackSession, _ loopEndTime: Double) {
        
        destroyCompletionTimer()
        super.endLoop(session, loopEndTime)
    }
    
    // MARK: Completion handler functions -------------------------------------------------------

    override func segmentCompleted(_ session: PlaybackSession) {
        
        NSLog("segmentCompleted( %@, %@, playing?=%@ )", session.id, PlaybackSession.isCurrent(session).description, playerNode.isPlaying.description)
        
        // If the segment-associated session is not the same as the current session
        // (possible if stop() was called, eg. old segments that complete when seeking), don't do anything
        if PlaybackSession.isCurrent(session) {
            
            // Start the completion poll timer
            completionPollTimer = RepeatingTaskExecutor(intervalMillis: LegacyPlaybackScheduler.completionPollTimerIntervalMillis, task: {
                
                self.pollForTrackCompletion()
                
            }, queue: completionHandlerQueue)
            
            NSLog("segmentCompleted() Created the timer")
            
            // Don't start the timer if player is paused
            if playerNode.isPlaying {
                completionPollTimer?.startOrResume()
                NSLog("segmentCompleted() Started the timer")
            }
            
        } else {
            destroyCompletionTimer()
        }
    }
    
    private func pollForTrackCompletion() {
        
        if let trackDuration = PlaybackSession.currentSession?.track.duration {
            
            // This will update lastSeekPosn
            let curPos = seekPosition
            
            NSLog("pollForTrackCompletion(), pos=%.2f", curPos)
            
            if curPos > (trackDuration - LegacyPlaybackScheduler.timeComparisonTolerance) && playerNode.isPlaying {
                
                // Notify observers that the track has finished playing. Don't do this if paused and seeking to the end.
                
                NSLog("pollForTrackCompletion() Track completed !")
                
                trackCompleted()
                destroyCompletionTimer()
            }
            
        } else {
            destroyCompletionTimer()
        }
    }
    
    override func loopSegmentCompleted(_ session: PlaybackSession) {

        // Validate the session and check for a complete loop
        if PlaybackSession.isCurrent(session), session.hasCompleteLoop() {
            
            // Start the completion poll timer
            completionPollTimer = RepeatingTaskExecutor(intervalMillis: LegacyPlaybackScheduler.completionPollTimerIntervalMillis, task: {
                
                self.pollForLoopCompletion()
                
            }, queue: completionHandlerQueue)
            
            // Don't start the timer if player is paused
            if playerNode.isPlaying {
                completionPollTimer?.startOrResume()
            }
            
        } else {
            destroyCompletionTimer()
        }
    }
    
    func pollForLoopCompletion() {
        
        if let session = PlaybackSession.currentSession, let loop = session.loop, let loopEndTime = loop.endTime {
            
            if seekPosition > (loopEndTime - LegacyPlaybackScheduler.timeComparisonTolerance) && playerNode.isPlaying {
                restartLoop(session, loop.startTime, loopEndTime)
            }
            
        } else {
            destroyCompletionTimer()
        }
    }
    
    private func destroyCompletionTimer() {
        
        NSLog("destroyCompletionTimer()")
        
        completionPollTimer?.stop()
        completionPollTimer = nil
    }
}
