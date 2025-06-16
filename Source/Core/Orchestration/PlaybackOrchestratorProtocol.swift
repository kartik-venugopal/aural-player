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
    
    @discardableResult func seekTo(percentage: Double) -> PlaybackCommandResult
    
    @discardableResult func seekTo(position: TimeInterval) -> PlaybackCommandResult
    
    @discardableResult func seekBackward(userInputMode: UserInputMode) -> PlaybackCommandResult
    
    @discardableResult func seekForward(userInputMode: UserInputMode) -> PlaybackCommandResult
    
    @discardableResult func seekBackwardSecondary() -> PlaybackCommandResult
    
    @discardableResult func seekForwardSecondary() -> PlaybackCommandResult
    
    @discardableResult func replayTrack() -> PlaybackCommandResult
    
    @discardableResult func stop() -> PlaybackCommandResult
    
    // TODO: Segment looping
    
    func registerUI(ui: PlaybackUI)
    
    func deregisterUI(ui: PlaybackUI)
    
    var state: PlaybackState {get}
    
    var playbackPosition: PlaybackPosition? {get}
    
    var playingTrack: Track? {get}
}

extension PlaybackOrchestratorProtocol {
    
    @discardableResult func seekBackward() -> PlaybackCommandResult {
        seekBackward(userInputMode: .discrete)
    }
    
    @discardableResult func seekForward() -> PlaybackCommandResult {
        seekForward(userInputMode: .discrete)
    }
}

protocol PlaybackUI {
    
    var id: String {get}
    
    func playbackStateChanged(newState: PlaybackState)
    
    func playingTrackChanged(newTrack: Track?)
    
    func playbackPositionChanged(newPosition: PlaybackPosition?)
}

struct PlaybackCommandResult {
    
    let state: PlaybackState
    let playingTrackInfo: PlayingTrackInfo?
    
    static let noTrack: PlaybackCommandResult = .init(state: .stopped, playingTrackInfo: nil)
}
