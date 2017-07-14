
import Cocoa

/*
    Contract for a middleman/facade between AppDelegate (UI) and Player, responsible for all playback control requests (play/pause/next/previous track, etc) originating from AppDelegate
*/
protocol AuralPlayerDelegate {
    
    // Add tracks (or saved playlists) to the current player playlist
    func addTracks(files: [NSURL])
    
    // Removes a single track at the specified index in the playlist. Returns the playing track index after removal (nil if playing track is the one removed)
    func removeTrack(index: Int) -> Int?
    
    // Moves the track at the specified index, up one index, in the playlist, if it is not already at the top. Returns the new index of the track (same if it didn't move)
    func moveTrackUp(index: Int) -> Int
    
    // Moves the track at the specified index, down one index, in the playlist, if it is not already at the bottom. Returns the new index of the track (same if it didn't move)
    func moveTrackDown(index: Int) -> Int
    
    // Clears the entire player playlist of all tracks
    func clearPlaylist()
    
    // Saves the current player playlist to a file
    func savePlaylist(file: NSURL)
    
    // Retrieves a summary of the current playlist - the total number of tracks and their total duration
    func getPlaylistSummary() -> (numTracks: Int, totalDuration: Double)
    
    // Toggles between the play and pause states, as long as a file is available to play. Returns playback state information the UI can use to update itself following the operation.
    func togglePlayPause() -> (playbackState: PlaybackState, playingTrack: Track?, playingTrackIndex: Int?, trackChanged: Bool)
    
    // Plays the track at a given index in the player playlist. Returns complete track information for the track.
    func play(index: Int) -> Track
    
    // Continues playback within the player playlist, according to repeat/shuffle modes. Called either before any tracks are played or after playback of a track has completed. Returns the new track, if any, that is selected for playback
    func continuePlaying() -> (playingTrack: Track?, playingTrackIndex: Int?)
    
    // Returns the currently playing track
    func getPlayingTrack() -> Track?
    
    // Returns the index within the player playlist, of the currently playing track
    func getPlayingTrackIndex() -> Int?
    
    // Returns the currently playing track, ensuring that detailed info is loaded in it. This is necessary due to lazy loading.
    func getMoreInfo() -> Track?
    
    // Retrieves saved player state, that is "remembered" by the player between app shutdown and the subsequent startup (sound settings and playlist items)
    func getPlayerState() -> SavedPlayerState?
    
    // Returns the current playback state of the player. See PlaybackState for more details
    func getPlaybackState() -> PlaybackState
    
    // Returns the current playback position of the player, for the current track, in terms of seconds and percentage (of the duration)
    func getSeekSecondsAndPercentage() -> (seconds: Double, percentage: Double)
    
    // Seeks forward a few seconds, within the current track
    func seekForward()

    // Seeks backward a few seconds, within the current track
    func seekBackward()
    
    // Seeks to a specific percentage of the track duration, within the current track
    func seekToPercentage(percentage: Double)
    
    // Plays (and returns) the next track, if there is one
    func nextTrack() -> (playingTrack: Track?, playingTrackIndex: Int?)
    
    // Plays (and returns) the previous track, if there is one
    func previousTrack() -> (playingTrack: Track?, playingTrackIndex: Int?)
    
    // Toggles between repeat modes. See RepeatMode for more details.
    func toggleRepeatMode() -> RepeatMode

    // Toggles between shuffle modes. See ShuffleMode for more details.
    func toggleShuffleMode() -> ShuffleMode
    
    // Does any deallocation that is required before the app exits
    // This includes saving "remembered" player state and releasing player resources
    func tearDown()
}