//
//  PlaybackSchedulerProtocol.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for scheduling audio data from tracks for playback.
///
protocol PlaybackSchedulerProtocol: GaplessSchedulerProtocol {
    
    // Schedule and play the track (specified by the given playback session), starting at the given start position
    func playTrack(_ playbackSession: PlaybackSession, from startPosition: TimeInterval?)
    
    // Schedule playback of a segment loop (specified by the given playback session), starting at the loop's start time. Begin playback if beginPlayback is true.
    func playLoop(_ playbackSession: PlaybackSession, beginPlayback: Bool)
    
    // Schedule playback of a segment loop (specified by the given playback session), starting at the given playback start time. Begin playback if beginPlayback is true.
    func playLoop(_ playbackSession: PlaybackSession, from playbackStartTime: TimeInterval, beginPlayback: Bool)
    
    // End scheduling and playback for the segment loop (specified by the given playback session). Resume normal playback till the end of the track.
    // The loopEndTime parameter specifies the start time for the new segment: [loopEndTime, trackDuration].
    func endLoop(_ session: PlaybackSession, _ loopEndTime: TimeInterval, _ beginPlayback: Bool)
    
    // Seeks to a certain position (seconds) within the currently playing track (specified by the given playback session). Begin playback if beginPlayback is true.
    func seekToTime(_ playbackSession: PlaybackSession, _ seconds: TimeInterval, _ beginPlayback: Bool)
    
    // Pause the player.
    func pause()
    
    // Resume the player.
    func resume()

    // Clears any previously scheduled audio segments, and stops playback.
    func stop()
}

protocol GaplessSchedulerProtocol {
    
    func playGapless(tracks: [Track], currentSession: PlaybackSession)
    
    func seekGapless(toTime seconds: TimeInterval, currentSession: PlaybackSession, beginPlayback: Bool, otherTracksToSchedule: [Track])
}
