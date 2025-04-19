//
//  ApplyPlaybackProfileAction.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Chain of responsibility action that applies a playback profile for a track (i.e. any previously
/// remembered playback settings, e.g. seek position) to the current playback request context.
/// This action implements the "remember last playback position" feature.
///
/// For example, if a track has a playback profile associated with it, containing a seek position
/// of 30.5 seconds, this action will ensure that when playback for the track begins, it will resume
/// from 30.5 seconds.
///
class ApplyPlaybackProfileAction: PlaybackChainAction {
    
    private let profiles: PlaybackProfiles
    private let preferences: PlaybackPreferences
    
    init(_ profiles: PlaybackProfiles, _ preferences: PlaybackPreferences) {
        
        self.profiles = profiles
        self.preferences = preferences
    }
    
    func execute(_ context: PlaybackRequestContext, _ chain: PlaybackChain) {
        
        if let newTrack = context.requestedTrack {
            
            let params = context.requestParams
            
            // Check for an existing playback profile for the requested track, and only apply the profile
            // if no start position is defined in the request params.
            if let profile = profiles[newTrack], params.startPosition == nil {
                
                // Validate the playback profile before applying it
                params.startPosition = (profile.lastPosition >= newTrack.duration ? 0 : profile.lastPosition)
            }
        }
        
        chain.proceed(context)
    }
}
