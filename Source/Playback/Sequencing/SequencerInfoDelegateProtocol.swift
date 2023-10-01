//
//  SequencerInfoDelegateProtocol.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// A functional contract for a delegate that represents the Sequencer and retrieves information
/// about the Sequencer, such as the playback sequence, current track, repeat / shuffle modes, etc.
///
/// Acts as a middleman between clients and the Sequencer, providing a simplified
/// interface / facade for clients to access information from the Sequencer.
///
/// This contract only defines accessors, no mutators, so clients of this protocol cannot make
/// any changes to the Sequencer's state. It is intended to be used by components that display
/// Player information.
///
/// - SeeAlso: `Sequencer`
///
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
