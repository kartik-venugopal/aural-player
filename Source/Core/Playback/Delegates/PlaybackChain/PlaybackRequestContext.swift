//
//  PlaybackRequestContext.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Encapsulates request parameters and other information pertinent to the
/// execution of a playback request (eg. starting/stopping track playback).
///
class PlaybackRequestContext {
    
    // The state of the player prior to execution of this reqeust.
    var currentState: PlaybackState
    
    // The current player track, if any, prior to execution of this reqeust.
    var currentTrack: Track?
    
    // The seek position of the player, if any, prior to execution of this reqeust.
    var currentSeekPosition: Double

    // The track that has been requested for playback. May be nil (e.g. when stopping the player)
    var requestedTrack: Track?
    
    var sequenceEnded: Bool
    
    // Playback-related parameters provided prior to execution of this request.
    // Request params may change as the preparation chain executes.
    var requestParams: PlaybackParams
    
    init(_ currentState: PlaybackState, _ currentTrack: Track?, _ currentSeekPosition: Double, _ requestedTrack: Track?, _ requestParams: PlaybackParams,
         sequenceEnded: Bool = false) {
        
        self.currentState = currentState
        self.currentTrack = currentTrack
        self.currentSeekPosition = currentSeekPosition
        
        self.requestedTrack = requestedTrack
        self.requestParams = requestParams
        self.sequenceEnded = sequenceEnded
    }
    
    // MARK: Static members to keep track of context instances
    
    // Keeps track of the currently executing request context, if any.
    static var currentContext: PlaybackRequestContext?

    // Marks a context as having begun execution.
    static func begun(_ context: PlaybackRequestContext) {
        currentContext = context
    }
    
    // Marks a context as having completed execution.
    static func completed(_ context: PlaybackRequestContext) {
        
        if isCurrent(context) {
            clearCurrentContext()
        }
    }
    
    // Checks if a given context matches the currently executing context.
    static func isCurrent(_ context: PlaybackRequestContext) -> Bool {
        return context === currentContext
    }
    
    // Invalidates the currently executing context.
    static func clearCurrentContext() {
        currentContext = nil
    }
}
