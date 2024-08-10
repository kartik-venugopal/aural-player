//
//  FFmpegScheduler+Gapless.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

extension FFmpegScheduler {
    
    func playGapless(tracks: [Track], currentSession: PlaybackSession) {
        
        doPlayGapless(firstTrack: tracks[0],
                      otherTracks: tracks.count > 1 ? Array(tracks[1..<tracks.count]) : [],
                      currentSession: currentSession)
    }
    
    fileprivate func doPlayGapless(firstTrack: Track, fromTime time: Double? = nil, otherTracks: [Track], currentSession: PlaybackSession) {
        
        guard let thePlaybackCtx = firstTrack.playbackContext as? FFmpegPlaybackContext,
                let decoder = thePlaybackCtx.decoder else {

            // This should NEVER happen. If it does, it indicates a bug (track was not prepared for playback).
            NSLog("Unable to play track \(currentSession.track.displayName) because it has no playback context.")
            return
        }
        
        for track in otherTracks {
            gaplessTracksQueue.enqueue(track)
        }
        
        currentGaplessTrack = firstTrack
        gaplessScheduledBufferCounts[firstTrack] = AtomicIntCounter()
        
        decoder.framesNeedTimestamps.setValue(false)
        
        initiateGaplessDecodingAndScheduling(for: currentSession, context: thePlaybackCtx, decoder: decoder, from: time)
        
        // Check that at least one audio buffer was successfully scheduled, before beginning playback.
        if let bufferCount = gaplessScheduledBufferCounts[firstTrack], bufferCount.isPositive {
            playerNode.play()
            
        } else {
            
            // This should NEVER happen. If it does, it indicates a bug (some kind of race condition)
            // or that something's wrong with the file.
            NSLog("WARNING: No buffers scheduled for track \(firstTrack.displayName) ... cannot begin playback.")
        }
    }
    
    func seekGapless(toTime seconds: Double, currentSession: PlaybackSession, beginPlayback: Bool, otherTracksToSchedule: [Track]) {
        
        stop()
        doPlayGapless(firstTrack: currentSession.track, fromTime: seconds, otherTracks: otherTracksToSchedule, currentSession: currentSession)
    }
    
    // MARK: Support functions
    
    fileprivate func initiateGaplessDecodingAndScheduling(for session: PlaybackSession, context: FFmpegPlaybackContext, 
                                                          decoder: FFmpegDecoder, from seekPosition: Double? = nil) {
        
        do {
            
            // If a seek position was specified, ask the decoder to seek
            // within the stream.
            if let theSeekPosition = seekPosition {
                
                try decoder.seek(to: theSeekPosition)
                
                // If the seek took the decoder to EOF, signal completion of playback
                // and don't do any scheduling.
                if decoder.eof {
                    
                    if playerNode.isPlaying {
                        gaplessTrackCompleted(session)
                        
                    } else {
                        
                        playerNode.seekToEndOfTrack(session, frameCount: context.frameCount)
                        gaplessTrackCompletedWhilePaused = false
                    }
                    
                    // TODO: Continue scheduling the next track !!!
                }
            }
            
            // Schedule one buffer for immediate playback
            decodeAndScheduleOneGaplessBuffer(for: session, track: session.track, context: context, decoder: decoder, from: seekPosition ?? 0,
                                              immediatePlayback: true, maxSampleCount: context.sampleCountForImmediatePlayback)
            
            // Schedule a second buffer asynchronously, for later, to avoid a gap in playback.
            continueSchedulingGaplessAsync(for: session)
            
        } catch {
            
            NSLog("Decoder threw error: \(error) while seeking to position \(seekPosition ?? 0) for track \(session.track.displayName) ... cannot initiate scheduling.")
        }
    }
    
    fileprivate func continueSchedulingGaplessAsync(for session: PlaybackSession) {
        
        guard let track = currentGaplessTrack,
        let context = track.playbackContext as? FFmpegPlaybackContext,
            let decoder = context.decoder else {
            
            print("Reached past last track in queue.")
            return
        }
        
        var theTrack = track
        var theContext = context
        var theDecoder = decoder

        if decoder.eof {
            
            print("Decoder for \(session.track) reached EOF.")
            decoder.stop()
            
            currentGaplessTrack = gaplessTracksQueue.dequeue()
            print("Current track now: \(currentGaplessTrack)")
            
            guard let nextTrack = currentGaplessTrack, let newContext = nextTrack.playbackContext as? FFmpegPlaybackContext,
                  let newDecoder = newContext.decoder else {
                
                print("\(session.track) is the last track in the PQ. DONE scheduling.")
                return
            }
            
            print("Continuing gapless sch. for \(nextTrack) ...")
            
            theTrack = nextTrack
            gaplessScheduledBufferCounts[nextTrack] = AtomicIntCounter()
            
            theContext = newContext
            theDecoder = newDecoder
        }
        
        self.schedulingOpQueue.addOperation {
            self.decodeAndScheduleOneGaplessBuffer(for: session, track: theTrack, context: theContext, decoder: theDecoder,
                                                   immediatePlayback: false, maxSampleCount: theContext.sampleCountForDeferredPlayback)
        }
    }
    
    fileprivate func decodeAndScheduleOneGaplessBuffer(for session: PlaybackSession, track: Track, context: FFmpegPlaybackContext, decoder: FFmpegDecoder,
                                                       from seekPosition: Double? = nil, immediatePlayback: Bool, maxSampleCount: Int32) {
        
        // Ask the decoder to decode up to the given number of samples.
        guard let playbackBuffer = decoder.decode(maxSampleCount: maxSampleCount, intoFormat: context.audioFormat) else {
            
            print("No buffer for: \(track)")
            return
        }
        
        print("decodeAndScheduleOneGaplessBuffer: \(track), buffFrames: \(playbackBuffer.frameLength), sampRate: \(context.audioFormat.sampleRate), dur: \(Double(playbackBuffer.frameLength) / context.audioFormat.sampleRate)")
        
        playerNode.scheduleBuffer(playbackBuffer, for: session, completionHandler: self.gaplessBufferCompletionHandler(session),
                                  seekPosition, immediatePlayback)
        
        gaplessScheduledBufferCounts[track]?.increment()
    }
    
    // Computes a segment completion handler closure, given a playback session.
    fileprivate func gaplessBufferCompletionHandler(_ session: PlaybackSession) -> SessionCompletionHandler {
        
        return {(_ session: PlaybackSession) -> Void in
            self.gaplessBufferCompleted(session)
        }
    }
    
    fileprivate func gaplessBufferCompleted(_ session: PlaybackSession) {
        
        // If the buffer-associated session is not the same as the current session
        // (possible if stop() was called, eg. old buffers that complete when seeking), don't do anything.
        guard PlaybackSession.isCurrent(session), let playbackCtx = session.track.playbackContext as? FFmpegPlaybackContext,
              let decoder = playbackCtx.decoder else {return}
        
        // Audio buffer has completed playback, so decrement the counter.
        gaplessScheduledBufferCounts[session.track]?.decrement()
        
        if decoder.eof, let bufferCount = gaplessScheduledBufferCounts[session.track], bufferCount.isZero {
            
            // EOF has been reached, and all buffers have completed playback.
            // Signal playback completion (on the main thread).
            playerNode.resetSeekPositionState()
            
            DispatchQueue.main.async {
                self.gaplessTrackCompleted(session)
            }
        }
        
        self.continueSchedulingGaplessAsync(for: session)
    }
    
    fileprivate func gaplessTrackCompleted(_ session: PlaybackSession) {
        messenger.publish(.Player.gaplessTrackPlaybackCompleted, payload: session)
    }
}
