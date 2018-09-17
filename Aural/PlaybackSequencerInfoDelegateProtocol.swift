import Foundation

/*
    Contract for a middleman/delegate that retrieves information about playback sequence state
 */

protocol PlaybackSequencerInfoDelegateProtocol {
    
    /*
     
     NOTE - "Subsequent track" is the track in the sequence that will be selected automatically by the app if playback of a track completes. It involves no user input.
     
     By contrast, "Next track" is the track in the sequence that will be selected if the user requests the next track in the sequence. This may or may not be the same as the "Subsequent track"
     */
    
    // NOTE - Nil return values mean no applicable track
    
    // Peeks at (without selecting for playback) the subsequent track in the sequence
    func peekSubsequent() -> IndexedTrack?
    
    // Peeks at (without selecting for playback) the previous track in the sequence
    func peekPrevious() -> IndexedTrack?
    
    // Peeks at (without selecting for playback) the next track in the sequence
    func peekNext() -> IndexedTrack?
}
