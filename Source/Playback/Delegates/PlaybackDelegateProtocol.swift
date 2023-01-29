//
//  PlaybackDelegateProtocol.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for a delegate that represents the Player.
///
/// Acts as a middleman between the Player UI and the Player, providing a simplified
/// interface / facade for the UI layer to control the Player.
///
/// - SeeAlso: `Player`
///
protocol PlaybackDelegateProtocol: PlaybackInfoDelegateProtocol {
    
    /*
     Toggles
     
     var playingChapter: Int?
     between the play and pause states, as long as a file is available to play. Returns playback state information the UI can use to update itself following the operation.
    
        Throws an error if playback begins with a track that cannot be played back.
     */
    func togglePlayPause()
    
    /* 
        Plays the track at a given index in the player playlist.
 
        NOTE - When a single index is specified, it is implied that the playlist from which this request originated was the flat "Tracks" playlist, because this playlist locates tracks by a single absolute index. Hence, this function is intended to be called only when playback originates from the "Tracks" playlist.
     */
    func play(_ index: Int, _ params: PlaybackParams)
    
    /*
        Plays the given track.
        
        NOTE - When a track is specified, it is implied that the playlist from which this request originated was a grouping/hierarchical playlist, because such a playlist does not provide a single index to locate an item. It provides either a track or a group. Hence, this function is intended to be called only when playback originates from one of the grouping/hierarchical playlists.
     */
    func play(_ track: Track, _ params: PlaybackParams)
    
    /*
        Initiates playback of (tracks within) the given group. Returns complete track information for the track that is chosen to play first.
 
        Throws an error if the track that is chosen to play first within the given group cannot be played back
     
        NOTE - When a group is specified, it is implied that the playlist from which this request originated was a grouping/hierarchical playlist, because such a playlist does not provide a single index to locate an item. It provides either a track or a group. Hence, this function is intended to be called only when playback originates from one of the grouping/hierarchical playlists.
     */
    func play(_ group: Group, _ params: PlaybackParams)
    
    // Restarts the current track, if there is one (i.e. seek to 0)
    func replay()
    
    // Stops playback.
    func stop()
    
    // Plays (and returns) the next track, if there is one. Throws an error if the next track cannot be played back
    func nextTrack()
    
    // Plays (and returns) the previous track, if there is one. Throws an error if the previous track cannot be played back
    func previousTrack()
    
    /*
        Seeks backward by a preset time interval, within the current track.
     
        The "inputMode" parameter specifies whether this action is part of a larger continuous sequence of such actions (such as when performing a trackpad gesture) or a single discrete operation (such as when clicking a menu item). The input mode will affect the time interval of the seek.
     */
    func seekBackward(_ inputMode: UserInputMode)
    
    func seekBackward(by interval: Double)
    
    /*
        Seeks backward by a preset time interval, within the current track.
     */
    func seekBackwardSecondary()
    
    /*
        Seeks forward by a preset time interval, within the current track.
     
        The "inputMode" parameter specifies whether this action is part of a larger continuous sequence of such actions (such as when performing a trackpad gesture) or a single discrete operation (such as when clicking a menu item). The input mode will affect the time interval of the seek.
     */
    func seekForward(_ inputMode: UserInputMode)
    
    func seekForward(by interval: Double)
    
    /*
        Seeks forward by a preset time interval, within the current track.
     */
    func seekForwardSecondary()
    
    // Seeks to a specific percentage of the track duration, within the current track
    func seekToPercentage(_ percentage: Double)
    
    // Seeks to a specific time position, expressed in seconds, within the current track
    func seekToTime(_ seconds: Double)
    
    /*
        Toggles the state of an A ⇋ B playback loop for the currently playing track. There are 3 possible states:
     
        1 - loop started: the start of the loop has been marked
        2 - loop ended: the end (and start) of the loop has been marked, completing the definition of the playback loop. Any subsequent playback will now proceed within the scope of the loop, i.e. between the 2 loop points: start and end
        3 - loop removed: any previous loop definition has been removed/cleared. Playback will proceed normally from start -> end of the playing track
     
        Returns the definition of the current loop, if one is defined, after the execution of this function
     */
    func toggleLoop() -> PlaybackLoop?
    
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
    func toggleChapterLoop() -> Bool
    
    // Whether or not a loop exists for the currently playing chapter
    var chapterLoopExists: Bool {get}
    
    var profiles: PlaybackProfiles {get}
}

// Default function implementations
extension PlaybackDelegateProtocol {

    func play(_ index: Int, _ params: PlaybackParams = .defaultParams()) {
        play(index, params)
    }
    
    func play(_ track: Track, _ params: PlaybackParams = .defaultParams()) {
        play(track, params)
    }
    
    func play(_ group: Group, _ params: PlaybackParams = .defaultParams()) {
        play(group, params)
    }
}
