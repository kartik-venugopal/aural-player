//
//  AVFScheduler+Looping.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AVFoundation

extension AVFScheduler {
    
    // Starts loop playback at the beginning of the loop
    func playLoop(_ session: PlaybackSession, _ beginPlayback: Bool) {
        
        if let loop = session.loop {
            playLoop(session, loop.startTime, beginPlayback)
        }
    }

    // Starts loop playback but not necessarily at the beginning of the loop (e.g. chapter loop)
    func playLoop(_ session: PlaybackSession, _ startTime: Double, _ beginPlayback: Bool) {

        stop()

        // Validate the loop before proceeding
        guard let loop = session.loop, let loopEndTime = loop.endTime, loop.containsPosition(startTime),
              let playbackCtx = session.track.playbackContext as? AVFPlaybackContext,
              let audioFile = playbackCtx.audioFile else {return}

        // Define the initial segment (which may not constitute the entire portion of the loop segment)
        let segment = playerNode.scheduleSegment(session: session, completionHandler: loopCompletionHandler(session),
                                                 startTime: startTime, endTime: loopEndTime, playingFile: audioFile)
        
        // If this segment constitutes the entire loop segment, cache it for reuse later when restarting the loop.
        self.loopingSegment = loop.startTime == startTime ? segment : nil
        
        // Don't start playing if player is paused
        if beginPlayback {
            playerNode.play()
        }
        
        messenger.publish(.Player.loopRestarted)
    }
    
    func endLoop(_ session: PlaybackSession, _ loopEndTime: Double, _ beginPlayback: Bool) {
        
        var newSegmentStartFrame: AVAudioFramePosition? = nil
        
        // If a cached loop segment is present, use it to compute an exact start frame for the new segment.
        if let loopSegment = self.loopingSegment {
            
            newSegmentStartFrame = loopSegment.lastFrame + 1
            self.loopingSegment = nil
        }
        
        // Schedule a new segment starting from the loop's end time, up to the end of the track.
        
        guard let playbackCtx = session.track.playbackContext as? AVFPlaybackContext,
              let audioFile = playbackCtx.audioFile else {return}

        // nil parameter indicates no specific end time (i.e. end of track is implied).
        // immediatePlayback is set to false because this segment will play only after the current loop segment
        // is finished.
        _ = playerNode.scheduleSegment(session: session, completionHandler: segmentCompletionHandler(session),
                                       startTime: loopEndTime, endTime: nil, playingFile: audioFile,
                                       startFrame: newSegmentStartFrame, immediatePlayback: false)
    }
    
    func loopSegmentCompleted(_ session: PlaybackSession) {

        // Validate the session and check for a complete loop
        if PlaybackSession.isCurrent(session), let loop = session.loop, let loopEndTime = loop.endTime {
            restartLoop(session, loop.startTime, loopEndTime)
        }
    }
    
    func restartLoop(_ session: PlaybackSession, _ startTime: Double, _ endTime: Double) {
        
        let wasPlaying: Bool = playerNode.isPlaying
        stop()

        // Check if a loop segment was cached previously.
        // The very first time (i.e. the first restart of the loop), this may be nil, so compute it.
        if self.loopingSegment == nil {
            
            guard let playbackCtx = session.track.playbackContext as? AVFPlaybackContext,
                  let audioFile = playbackCtx.audioFile else {return}
            
            self.loopingSegment = playerNode.scheduleSegment(session: session,
                                                             completionHandler: loopCompletionHandler(session),
                                                             startTime: startTime, endTime: endTime,
                                                             playingFile: audioFile)
            
        } else if let loopSegment = self.loopingSegment {
            
            // Use the cached/compute segment to schedule another loop iteration.
            playerNode.scheduleSegment(loopSegment, loopCompletionHandler(session))
        }

        if wasPlaying {
            playerNode.play()
        }
        
        messenger.publish(.Player.loopRestarted)
    }
    
    // Computes a loop segment completion handler closure, given a playback session.
    func loopCompletionHandler(_ session: PlaybackSession) -> SessionCompletionHandler {
        
        return {(_ session: PlaybackSession) -> Void in
            self.loopSegmentCompleted(session)
        }
    }
}
