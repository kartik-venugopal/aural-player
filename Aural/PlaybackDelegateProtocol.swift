import Foundation

/*
    Contract for a middleman/delegate that relays all necessary playback operations to the player, and allows manipulation of the playback sequence
 */
protocol PlaybackDelegateProtocol: PlaybackInfoDelegateProtocol {
    
    /*
        Toggles between the play and pause states, as long as a file is available to play. Returns playback state information the UI can use to update itself following the operation.
    
        Throws an error if playback begins with a track that cannot be played back.
     */
    func togglePlayPause()
    
    /* 
        Plays the track at a given index in the player playlist. Returns complete track information for the track.
 
        Throws an error if the selected track cannot be played back.
 
        NOTE - When a single index is specified, it is implied that the playlist from which this request originated was the flat "Tracks" playlist, because this playlist locates tracks by a single absolute index. Hence, this function is intended to be called only when playback originates from the "Tracks" playlist.
     */
    func play(_ index: Int, _ params: PlaybackParams)
    
    /*
        Plays the given track. Returns complete track information for the track.
        
        Throws an error if the selected track cannot be played back.
        
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
    
    // Stops playback
    func stop()
    
    // Plays (and returns) the next track, if there is one. Throws an error if the next track cannot be played back
    func nextTrack()
    
    // Plays (and returns) the previous track, if there is one. Throws an error if the previous track cannot be played back
    func previousTrack()
    
    /*
        Seeks forward by a preset time interval, within the current track.
     
        The "actionMode" parameter specifies whether this action is part of a larger continuous sequence of such actions (such as when performing a trackpad gesture) or a single discrete operation (such as when clicking a menu item). The action mode will affect the time interval of the seek.
     */
    func seekForward(_ actionMode: ActionMode)
    
    /*
        Seeks backward by a preset time interval, within the current track.
     
        The "actionMode" parameter specifies whether this action is part of a larger continuous sequence of such actions (such as when performing a trackpad gesture) or a single discrete operation (such as when clicking a menu item). The action mode will affect the time interval of the seek.
     */
    func seekBackward(_ actionMode: ActionMode)
    
    /*
     Seeks forward by a preset time interval, within the current track.
     
     The "actionMode" parameter specifies whether this action is part of a larger continuous sequence of such actions (such as when performing a trackpad gesture) or a single discrete operation (such as when clicking a menu item). The action mode will affect the time interval of the seek.
     */
    func seekForwardSecondary()
    
    /*
     Seeks backward by a preset time interval, within the current track.
     
     The "actionMode" parameter specifies whether this action is part of a larger continuous sequence of such actions (such as when performing a trackpad gesture) or a single discrete operation (such as when clicking a menu item). The action mode will affect the time interval of the seek.
     */
    func seekBackwardSecondary()
    
    // Seeks to a specific percentage of the track duration, within the current track
    func seekToPercentage(_ percentage: Double)
    
    // Seeks to a specific time position, expressed in seconds, within the current track
    func seekToTime(_ seconds: Double)
    
    // Toggles between repeat modes. See RepeatMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Toggles between shuffle modes. See ShuffleMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Sets the repeat mode to a specific value. Returns the new repeat and shuffle mode after performing the toggle operation.
    func setRepeatMode(_ repeatMode: RepeatMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Sets the shuffle mode to a specific value. Returns the new repeat and shuffle mode after performing the toggle operation.
    func setShuffleMode(_ shuffleMode: ShuffleMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    /*
        Toggles the state of an A->B playback loop for the currently playing track. There are 3 possible states:
     
        1 - loop started: the start of the loop has been marked
        2 - loop ended: the end (and start) of the loop has been marked, completing the definition of the playback loop. Any subsequent playback will now proceed within the scope of the loop, i.e. between the 2 loop points: start and end
        3 - loop removed: any previous loop definition has been removed/cleared. Playback will proceed normally from start -> end of the playing track
     
        Returns the definition of the current loop, if one is defined, after the execution of this function
     */
    func toggleLoop() -> PlaybackLoop?
    
    func cancelTranscoding()
    
    var profiles: PlaybackProfiles {get set}
}

// Default function implementations
extension PlaybackDelegateProtocol {

    func play(_ index: Int, _ params: PlaybackParams = PlaybackParams.defaultParams()) {
        play(index, params)
    }
    
    func play(_ track: Track, _ params: PlaybackParams = PlaybackParams.defaultParams()) {
        play(track, params)
    }
    
    func play(_ group: Group, _ params: PlaybackParams = PlaybackParams.defaultParams()) {
        play(group, params)
    }
}
