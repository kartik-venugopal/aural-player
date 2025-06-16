//
// PlaybackOrchestratorProtocol.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

protocol PlaybackOrchestratorProtocol {
    
    @discardableResult func togglePlayPause() -> PlaybackCommandResult
    
    @discardableResult func previousTrack() -> PlaybackCommandResult
    
    @discardableResult func nextTrack() -> PlaybackCommandResult
    
    @discardableResult func seekBackward() -> PlaybackCommandResult
    
    @discardableResult func seekBackwardSecondary() -> PlaybackCommandResult
    
    @discardableResult func seekForward() -> PlaybackCommandResult
    
    @discardableResult func seekForwardSecondary() -> PlaybackCommandResult
    
    var state: PlaybackState {get}
    
    var playbackPosition: PlaybackPosition? {get}
    
    var playingTrack: Track? {get}
}

struct PlaybackCommandResult {
    
    let state: PlaybackState
    let playingTrackInfo: PlayingTrackInfo?
    
    static let noTrack: PlaybackCommandResult = .init(state: .stopped, playingTrackInfo: nil)
}
