import Foundation

protocol PlaybackDelegateProtocol: PlaybackInfoDelegateProtocol {
    
    // Toggles between the play and pause states, as long as a file is available to play. Returns playback state information the UI can use to update itself following the operation.
    // Note - Throws an error if playback begins with a track that cannot be played back
    func togglePlayPause() throws -> (playbackState: PlaybackState, playingTrack: IndexedTrack?, trackChanged: Bool)
    
    // Plays the track at a given index in the player playlist. Returns complete track information for the track.
    // Note - Throws an error if the selected track cannot be played back
    func play(_ index: Int) throws -> IndexedTrack
    
    func stop()
    
    // Plays (and returns) the next track, if there is one
    // Note - Throws an error if the next track cannot be played back
    func nextTrack() throws -> IndexedTrack?
    
    // Plays (and returns) the previous track, if there is one
    // Note - Throws an error if the previous track cannot be played back
    func previousTrack() throws -> IndexedTrack?
    
    // Seeks forward a few seconds, within the current track
    func seekForward()
    
    // Seeks backward a few seconds, within the current track
    func seekBackward()
    
    // Seeks to a specific percentage of the track duration, within the current track
    func seekToPercentage(_ percentage: Double)
    
    // Toggles between repeat modes. See RepeatMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Toggles between shuffle modes. See ShuffleMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
}

// Used for autoplay
protocol BasicPlaybackDelegateProtocol {
    
    func play(_ index: Int, _ interruptPlayback: Bool) throws -> IndexedTrack?
}
