//
//  PlayerProtocol.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for the Player.
///
/// The Player is responsible for initiating playback, pause / resume / stop, seeking, and segment looping.
///
protocol PlayerProtocol {
    
    // Returns the current playback state of the player. See PlaybackState for more details
    var state: PlaybackState {get}
    
    var isPlaying: Bool {get}
    
    // Returns the current seek position of the player, for the current track, i.e. time elapsed, in terms of seconds and percentage (of the total duration), and the total track duration (also in seconds)
    var seekPosition: PlaybackPosition {get}
    
    var playerPosition: TimeInterval {get}
    
    // Returns the currently playing (or paused) track, if there is one
    var playingTrack: Track? {get}
    
    var hasPlayingTrack: Bool {get}
    
    /*
        Returns a TimeInterval indicating when the currently playing track began playing. Returns nil if no track is playing.
     
        The TimeInterval is relative to the last system start time, i.e. it is the systemUpTime. See ProcessInfo.processInfo.systemUpTime
    */
    var playingTrackStartTime: TimeInterval? {get}
    
    // Retrieves information about the playback loop defined on a segment of the currently playing track, if there is a playing track and a loop for it
    var playbackLoop: PlaybackLoop? {get}
    
    var playbackLoopState: PlaybackLoopState {get}
    
    // For the currently playing track, returns the total number of defined chapter markings
    var chapterCount: Int {get}
    
    // For the currently playing track, returns the index of the currently playing chapter. Returns nil if:
    // 1 - There are no chapter markings for the current track
    // 2 - There are chapter markings but the current seek position is not within the time bounds of any of the chapters
    var playingChapter: IndexedChapter? {get}
    
    // MARK: Functions ------------------------------------------------------
    
    func togglePlayPause()
    
    func play(trackAtIndex index: Int, params: PlaybackParams)
    
    func play(track: Track, params: PlaybackParams)
    
    // Library (Tracks view) / Managed Playlists / Favorites / Bookmarks / History
    @discardableResult func playNow(tracks: [Track], clearQueue: Bool, params: PlaybackParams) -> IndexSet
    
    // Plays (and returns) the next track, if there is one. Throws an error if the next track cannot be played back
    func nextTrack()
    
    // Plays (and returns) the previous track, if there is one. Throws an error if the previous track cannot be played back
    func previousTrack()
    
    func resumeShuffleSequence(with track: Track, atPosition position: TimeInterval)
    
    // Pauses the currently playing track
    func pause()
    
    // Resumes playback of the currently playing track
    func resume()
    
    // Restarts the current track, if there is one (i.e. seek to 0)
    func replay()
    
    // Stops playback of the currently playing track
    func stop()
    
    func seekForward(by interval: TimeInterval)
    
    func seekBackward(by interval: TimeInterval)
    
    // Seeks to a specific percentage of the track duration, within the current track
    func seekTo(percentage: Double)
    
    // Seeks to a specific time position, expressed in seconds, within the current track
    func seekTo(time seconds: TimeInterval)
    
    // Define a segment loop bounded by the given start/end time values (and continue playback as before, from the current position).
    // The isChapterLoop parameter indicates whether or not this segment loop is associated with (i.e. bounded by) a chapter marking
    // of the currently playing track.
    func defineLoop(startPosition: TimeInterval, endPosition: TimeInterval, isChapterLoop: Bool)
    
    /*
        Toggles the state of an A ⇋ B segment playback loop for the currently playing track. There are 3 possible states:
     
        1 - loop started: the start of the loop has been marked
        2 - loop ended: the end (and start) of the loop has been marked, completing the definition of the playback loop. Any subsequent playback will now proceed within the scope of the loop, i.e. between the 2 loop points: start and end
        3 - loop removed: any previous loop definition has been removed/cleared. Playback will proceed normally from start -> end of the playing track
     
        Returns the definition of the current loop, if one is currently defined.
     */
    @discardableResult func toggleLoop() -> PlaybackLoop?
    
    // For the currently playing track, plays the chapter with the given index, from the start time.
    // If this chapter is already playing, it is played from the start time.
    // NOTE - If there is a segment loop defined that does not contain the chapter start time, it will be removed to allow seeking
    // to the chapter start time.
    func playChapter(_ index: Int)
    
    // For the currently playing track, plays the previous chapter (relative to the current seek position or chapter)
    func previousChapter()
    
    // For the currently playing track, plays the next chapter (relative to the current seek position or chapter)
    func nextChapter()
    
    // For the currently playing track, replays the currently playing chapter (i.e. seeks to the chapter's start time)
    func replayChapter()
    
    // For the currently playing track, toggles a segment loop bounded by the currently playing chapter's start and end time
    // Returns whether or not a loop exists for the currently playing chapter, after the toggle operation.
    @discardableResult func toggleChapterLoop() -> Bool
    
    // Whether or not a loop exists for the currently playing chapter
    var chapterLoopExists: Bool {get}
    
    // Performs any required cleanup before the app exits
    func tearDown()
    
    // MARK: Gapless -----------------------------------------------
    
    func beginGaplessPlayback() throws
    
    var isInGaplessPlaybackMode: Bool {get}
}

// Default function implementations
extension PlayerProtocol {

    func play(trackAtIndex index: Int) {
        play(trackAtIndex: index, params: .defaultParams)
    }
    
    func play(track: Track) {
        play(track: track, params: .defaultParams)
    }
    
    @discardableResult func playNow(tracks: [Track], clearQueue: Bool) -> IndexSet {
        playNow(tracks: tracks, clearQueue: clearQueue, params: .defaultParams)
    }
    
//    func play(_ group: Group, _ params: PlaybackParams = .defaultParams()) {
//        play(group, params)
//    }
}

protocol GaplessPlaybackProtocol {
    
    var isInGaplessPlaybackMode: Bool {get}
    
    func playGapless(tracks: [Track])
}

typealias PlayerPlayFunction = (Track, PlaybackParams) -> Void
typealias PlayerStopFunction = () -> Void
