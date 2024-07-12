//
//  AVFScheduler+Gapless.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AVFoundation

extension AVFScheduler {
    
    func playGapless(tracks: [Track], currentSession: PlaybackSession) {
        
        seekGapless(toTime: 0, currentSession: currentSession, beginPlayback: true,
                    otherTracksToSchedule: tracks.count > 1 ? Array(tracks[1..<tracks.count]) : [])
    }
    
    func seekGapless(toTime seconds: Double, currentSession: PlaybackSession, beginPlayback: Bool, otherTracksToSchedule: [Track]) {
     
        // Halt current playback
        stop()
        
        guard let playbackCtx = currentSession.track.playbackContext as? AVFPlaybackContext,
              let audioFile = playbackCtx.audioFile else {
            return
        }
        
        _ = playerNode.scheduleSegment(session: currentSession, completionHandler: gaplessSegmentCompletionHandler(currentSession),
                                       startTime: seconds, playingFile: audioFile)

        // Don't start playing if player is paused
        if beginPlayback {
            playerNode.play()
        }
     
        scheduleSubsequentTracks(otherTracksToSchedule)
    }
    
    private func scheduleSubsequentTracks(_ tracks: [Track]) {
        
        guard let session = PlaybackSession.currentSession else {return}
        
        DispatchQueue.global(qos: .background).async {
            
            for track in tracks {
                
                if let file = (track.playbackContext as? AVFPlaybackContext)?.audioFile {
                    
                    _ = self.playerNode.scheduleSegment(session: session,
                                                        completionHandler: self.gaplessSegmentCompletionHandler(session),
                                                        startTime: 0,
                                                        playingFile: file)
                    
                    print("Scheduled \(track)")
                }
            }
        }
    }
    
    func gaplessSegmentCompleted(_ session: PlaybackSession) {
        
        // If the segment-associated session is not the same as the current session
        // (possible if stop() was called, eg. old segments that complete when seeking), don't do anything
        guard PlaybackSession.isCurrent(session) else {return}
        
        if playerNode.isPlaying {
            trackCompletedGapless(session)
            
        } else {
            // Player is paused
            trackCompletedWhilePaused = true
        }
    }
    
    // Signal track playback completion
    func trackCompletedGapless(_ session: PlaybackSession) {
        messenger.publish(.Player.trackPlaybackCompleted, payload: session)
    }
    
    // Computes a segment completion handler closure, given a playback session.
    func gaplessSegmentCompletionHandler(_ session: PlaybackSession) -> SessionCompletionHandler {
        
        return {(_ session: PlaybackSession) -> Void in
            self.gaplessSegmentCompleted(session)
        }
    }
}
