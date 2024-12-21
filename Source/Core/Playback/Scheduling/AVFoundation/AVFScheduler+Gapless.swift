//
//  AVFScheduler+Gapless.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AVFoundation

extension AVFScheduler {
    
    func playGapless(tracks: [Track], currentSession: PlaybackSession) {
        
        let otherTracksToSchedule = tracks.count > 1 ? Array(tracks[1..<tracks.count]) : []
        
        guard let playbackCtx = currentSession.track.playbackContext as? AVFPlaybackContext,
              let audioFile = playbackCtx.audioFile else {return}
        
        playerNode.resetSeekPositionState()
        
        playerNode.scheduleFile(session: currentSession,
                                completionHandler: gaplessSegmentCompletionHandler(currentSession),
                                playingFile: audioFile)
        
        playerNode.play()
        
        gaplessTracksQueue.enqueueAll(otherTracksToSchedule)
        scheduleSubsequentTrack(forSession: currentSession)
    }
    
    func seekGapless(toTime seconds: Double, currentSession: PlaybackSession, beginPlayback: Bool, otherTracksToSchedule: [Track]) {
     
        // Halt current playback
        stop()
        
        guard let playbackCtx = currentSession.track.playbackContext as? AVFPlaybackContext,
              let audioFile = playbackCtx.audioFile else {
            return
        }
        
        _ = playerNode.scheduleGaplessSegment(session: currentSession,
                                       completionHandler: gaplessSegmentCompletionHandler(currentSession),
                                       startTime: seconds, 
                                       playingFile: audioFile)

        // Don't start playing if player is paused
        if beginPlayback {
            playerNode.play()
        }
     
        gaplessTracksQueue.enqueueAll(otherTracksToSchedule)
        scheduleSubsequentTrack(forSession: currentSession)
    }
    
    private func scheduleSubsequentTrack(forSession session: PlaybackSession) {
        
        guard let subsequentTrack = gaplessTracksQueue.dequeue() else {return}
        
        do {
            try trackReader.prepareForPlayback(track: subsequentTrack)
            
        } catch {
            
            Messenger.publish(TrackNotPlayedNotification(oldTrack: session.track, errorTrack: subsequentTrack,
                                                         error: error as? DisplayableError ?? TrackNotPlayableError(subsequentTrack.file)))
            return
        }
        
        if let file = (subsequentTrack.playbackContext as? AVFPlaybackContext)?.audioFile {
            
            self.playerNode.scheduleFile(session: session,
                                         completionHandler: self.gaplessSegmentCompletionHandler(session),
                                         playingFile: file)
        }
    }
    
    func gaplessSegmentCompleted(_ session: PlaybackSession) {
        
        // If the segment-associated session is not the same as the current session
        // (possible if stop() was called, eg. old segments that complete when seeking), don't do anything
        guard PlaybackSession.isCurrent(session) else {return}
        
        if playerNode.isPlaying {
            gaplessTrackCompleted(session)
            
        } else {
            // Player is paused
            gaplessTrackCompletedWhilePaused = true
        }
    }
    
    // Computes a segment completion handler closure, given a playback session.
    func gaplessSegmentCompletionHandler(_ session: PlaybackSession) -> SessionCompletionHandler {
        
        return {(_ session: PlaybackSession) -> Void in
            self.gaplessSegmentCompleted(session)
        }
    }
    
    func gaplessTrackCompleted(_ session: PlaybackSession) {
        
        scheduleSubsequentTrack(forSession: session)
        messenger.publish(.Player.gaplessTrackPlaybackCompleted, payload: session)
    }
}
