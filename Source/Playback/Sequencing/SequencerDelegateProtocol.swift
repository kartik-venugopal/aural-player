import Foundation

/*
    Contract for a middleman/delegate that retrieves information about playback sequence state
 */

protocol SequencerInfoDelegateProtocol {
    
    // Returns the currently playing track, with its index
    var currentTrack: Track? {get}
    
    /*
        Returns summary information about the current playback sequence
     
        scope - the scope of the sequence which could either be an entire playlist (for ex, all tracks), or a single group (for ex, Artist "Madonna" or Genre "Pop")
     
        trackIndex - the relative index of the currently playing track within the sequence (as opposed to within the entire playlist)
     
        totalTracks - the total number of tracks in the current sequence
     */
    var sequenceInfo: (scope: SequenceScope, trackIndex: Int, totalTracks: Int) {get}
    
    /*
     
     NOTE - "Subsequent track" is the track in the sequence that will be selected automatically by the app if playback of a track completes. It involves no user input.
     
     By contrast, "Next track" is the track in the sequence that will be selected if the user requests the next track in the sequence. This may or may not be the same as the "Subsequent track"
     */
    
    // NOTE - Nil return values mean no applicable track
    
    // Peeks at (without selecting for playback) the subsequent track in the sequence
    func peekSubsequent() -> Track?
    
    // Peeks at (without selecting for playback) the previous track in the sequence
    func peekPrevious() -> Track?
    
    // Peeks at (without selecting for playback) the next track in the sequence
    func peekNext() -> Track?
    
    // Returns the current repeat and shuffle modes
    var repeatAndShuffleModes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {get}
}

protocol SequencerDelegateProtocol: SequencerInfoDelegateProtocol {
    
    // Toggles between repeat modes. See RepeatMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Toggles between shuffle modes. See ShuffleMode for more details. Returns the new repeat and shuffle mode after performing the toggle operation.
    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Sets the repeat mode to a specific value. Returns the new repeat and shuffle mode after performing the toggle operation.
    func setRepeatMode(_ repeatMode: RepeatMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
    
    // Sets the shuffle mode to a specific value. Returns the new repeat and shuffle mode after performing the toggle operation.
    func setShuffleMode(_ shuffleMode: ShuffleMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode)
}
