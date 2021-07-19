//
//  PlaybackParams.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates request parameters related to the playback of a track.
///
class PlaybackParams {
    
    // An optional seek time at which playback will start for the relevant track.
    // e.g. used when playing a bookmark
    var startPosition: Double? = nil
    
    // An optional seek time at which playback will end for the relevant track.
    // The presence of a non-nil value in this parameter indicates a segment loop
    // bounded by startPosition/endPosition.
    var endPosition: Double? = nil
    
    // Whether or not this request can interrupt (i.e. stop) the playback
    // of a currently playing track, if there is one.
    // If false, playback will occur only if no track is currently playing.
    // e.g. used for autoplay
    var interruptPlayback: Bool = true
    
    // Builder pattern function to set a start/end position, i.e. a segment loop.
    func withStartAndEndPosition(_ startPosition: Double, _ endPosition: Double?) -> PlaybackParams {
        
        self.startPosition = startPosition
        self.endPosition = endPosition
        
        return self
    }
    
    // Builder pattern function to set the interruptPlayback parameter.
    func withInterruptPlayback(_ interruptPlayback: Bool) -> PlaybackParams {
        
        self.interruptPlayback = interruptPlayback
        return self
    }
    
    // Factory method to create an instance with default request parameters.
    static func defaultParams() -> PlaybackParams {
        return PlaybackParams()
    }
}
