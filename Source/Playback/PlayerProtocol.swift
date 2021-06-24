//
//  PlayerProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Contract for an audio player that performs track playback
 */
protocol PlayerProtocol {
    
    // Plays a given track, starting from a given position (used for bookmarks)
    func play(_ track: Track, _ startPosition: Double, _ endPosition: Double?)
    
    // Pauses the currently playing track
    func pause()
    
    // Resumes playback of the currently playing track
    func resume()
    
    // Stops playback of the currently playing track
    func stop()
    
    // Returns the current playback state of the player. See PlaybackState for more details
    var state: PlaybackState {get}
    
    // Attempts to seek to a certain time within the currently playing track
    // If the provided time parameter is invalid (e.g. < 0 or > track duration),
    // it will be adjusted to a valid value.
    //
    // NOTE - If a segment loop exists, it will be preserved
    func attemptSeekToTime(_ track: Track, _ time: Double) -> PlayerSeekResult
    
    // Seeks to an exact time within the currently playing track.
    //
    // NOTE - If a segment loop exists, and the requested seek time is outside the
    // loop's time bounds, the loop will be removed.
    func forceSeekToTime(_ track: Track, _ time: Double) -> PlayerSeekResult
    
    // Gets the playback position (in seconds) of the currently playing track
    var seekPosition: Double {get}
    
    // Define a segment loop bounded by the given start/end time values (and continue playback as before, from the current position).
    // The isChapterLoop parameter indicates whether or not this segment loop is associated with (i.e. bounded by) a chapter marking
    // of the currently playing track.
    func defineLoop(_ loopStartPosition: Double, _ loopEndPosition: Double, _ isChapterLoop: Bool)
    
    /*
        Toggles the state of an A->B segment playback loop for the currently playing track. There are 3 possible states:
     
        1 - loop started: the start of the loop has been marked
        2 - loop ended: the end (and start) of the loop has been marked, completing the definition of the playback loop. Any subsequent playback will now proceed within the scope of the loop, i.e. between the 2 loop points: start and end
        3 - loop removed: any previous loop definition has been removed/cleared. Playback will proceed normally from start -> end of the playing track
     
        Returns the definition of the current loop, if one is currently defined.
     */
    func toggleLoop() -> PlaybackLoop?
    
    // Retrieves information about the playback loop defined on a segment of the
    // currently playing track, if there is a playing track and a loop for it.
    var playbackLoop: PlaybackLoop? {get}
    
    // Performs any required cleanup before the app exits
    func tearDown()
    
    /*
        Returns a TimeInterval indicating when the currently playing track began playing. Returns nil if no track is playing.
     
        The TimeInterval is relative to the last system start time, i.e. it is the systemUpTime. See ProcessInfo.processInfo.systemUpTime.
     */
    var playingTrackStartTime: TimeInterval? {get}
}

// Defines objects that encapsulate the result of a seek operation.
struct PlayerSeekResult {
    
    // The potentially adjusted seek position (eg. if attempted seek time was < 0, it will be adjusted to 0).
    // This is the seek position actually used in the seek operation.
    // If no adjustment took place, this will be equal to the attempted seek position.
    let actualSeekPosition: Double
    
    // Whether or not a previously defined segment loop was removed as a result of the seek.
    let loopRemoved: Bool
    
    // Whether or not the seek resulted in track playback completion (i.e. reached the end of the track).
    let trackPlaybackCompleted: Bool
}
