//
//  PlaybackInfoDelegateProtocol.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for a delegate that represents the Player and retrieves information
/// about the Player, including its playback state, which track is playing, etc.
///
/// Acts as a middleman between the Player UI and the Player, providing a simplified
/// interface / facade for the UI layer to access information from the Player.
///
/// This contract only defines accessors, no mutators, so clients of this protocol cannot make
/// any changes to the Player's state. It is intended to be used by components that display
/// Player information.
///
/// - SeeAlso: `Player`
///
protocol PlaybackInfoDelegateProtocol {
    
    // Returns the current playback state of the player. See PlaybackState for more details
    var state: PlaybackState {get}
    
    // Returns the current seek position of the player, for the current track, i.e. time elapsed, in terms of seconds and percentage (of the total duration), and the total track duration (also in seconds)
    var seekPosition: PlaybackPosition {get}
    
    // Returns the currently playing (or paused) track, if there is one
    var playingTrack: Track? {get}
    
    // For the currently playing track, returns the total number of defined chapter markings
    var chapterCount: Int {get}
    
    // For the currently playing track, returns the index of the currently playing chapter. Returns nil if:
    // 1 - There are no chapter markings for the current track
    // 2 - There are chapter markings but the current seek position is not within the time bounds of any of the chapters
    var playingChapter: IndexedChapter? {get}
    
    /*
        Returns a TimeInterval indicating when the currently playing track began playing. Returns nil if no track is playing.
     
        The TimeInterval is relative to the last system start time, i.e. it is the systemUpTime. See ProcessInfo.processInfo.systemUpTime
    */
    var playingTrackStartTime: TimeInterval? {get}
    
    // Retrieves information about the playback loop defined on a segment of the currently playing track, if there is a playing track and a loop for it
    var playbackLoop: PlaybackLoop? {get}
}

///
/// Encapsulates information about the playback position of the currently playing track.
///
struct PlaybackPosition {
    
    let timeElapsed: Double
    let percentageElapsed: Double
    let trackDuration: Double
    
    static let zero: PlaybackPosition = PlaybackPosition(timeElapsed: 0, percentageElapsed: 0, trackDuration: 0)
}
