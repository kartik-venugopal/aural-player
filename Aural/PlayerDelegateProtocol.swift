import Cocoa

/*
    Contract for a middleman/facade between the UI and the audio player, to perform playback
*/
protocol PlayerDelegateProtocol {
    
    // Toggles between the play and pause states, as long as a file is available to play. Returns playback state information the UI can use to update itself following the operation.
    // Note - Throws an error if playback begins with a track that cannot be played back
    func togglePlayPause() throws -> (playbackState: PlaybackState, playingTrack: IndexedTrack?, trackChanged: Bool)
    
    // Plays the track at a given index in the player playlist. Returns complete track information for the track.
    // Note - Throws an error if the selected track cannot be played back
    func play(_ index: Int) throws -> IndexedTrack
    
    // Continues playback within the player playlist, according to repeat/shuffle modes. Called either before any tracks are played or after playback of a track has completed. Returns the new track, if any, that is selected for playback
    // Note - Throws an error if the track selected for playback cannot be played back
    func continuePlaying() throws -> IndexedTrack?
    
    // Plays (and returns) the next track, if there is one
    // Note - Throws an error if the next track cannot be played back
    func nextTrack() throws -> IndexedTrack?
    
    // Plays (and returns) the previous track, if there is one
    // Note - Throws an error if the previous track cannot be played back
    func previousTrack() throws -> IndexedTrack?
    
    // Returns the current playback state of the player. See PlaybackState for more details
    func getPlaybackState() -> PlaybackState
    
    // Returns the current playback position of the player, for the current track, in terms of seconds and percentage (of the duration)
    func getSeekSecondsAndPercentage() -> (seconds: Double, percentage: Double)
    
    // Seeks forward a few seconds, within the current track
    func seekForward()

    // Seeks backward a few seconds, within the current track
    func seekBackward()
    
    // Seeks to a specific percentage of the track duration, within the current track
    func seekToPercentage(_ percentage: Double)
    
    // Returns the currently playing track (with its index)
    func getPlayingTrack() -> IndexedTrack?
    
    // Returns the currently playing track, ensuring that detailed info is loaded in it. This is necessary due to lazy loading.
    func getMoreInfo() -> IndexedTrack?
}
