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
    
    func playTrack(atIndex index: Int, params: PlaybackParams)
    
    @discardableResult func previousTrack() -> PlaybackCommandResult
    
    @discardableResult func nextTrack() -> PlaybackCommandResult
    
    @discardableResult func replayTrack() -> PlaybackCommandResult
    
    @discardableResult func seekTo(percentage: Double) -> PlaybackCommandResult
    
    @discardableResult func seekTo(position: TimeInterval) -> PlaybackCommandResult
    
    @discardableResult func seekBackward(userInputMode: UserInputMode) -> PlaybackCommandResult
    
    @discardableResult func seekForward(userInputMode: UserInputMode) -> PlaybackCommandResult
    
    @discardableResult func seekBackwardSecondary() -> PlaybackCommandResult
    
    @discardableResult func seekForwardSecondary() -> PlaybackCommandResult
    
    func toggleLoop()
    
    @discardableResult func stop() -> PlaybackCommandResult
    
    var repeatMode: RepeatMode {get}
    
    func toggleRepeatMode()
    
    func setRepeatMode(_ repeatMode: RepeatMode)
    
    var shuffleMode: ShuffleMode {get}
    
    func toggleShuffleMode()
    
    func setShuffleMode(_ shuffleMode: ShuffleMode)
    
    func registerUI(ui: PlaybackUI)
    
    func deregisterUI(ui: PlaybackUI)
    
    var state: PlaybackState {get}
    
    var isPlaying: Bool {get}
    
    var playbackPosition: PlaybackPosition? {get}
    
    var playingTrack: Track? {get}
    
    var playbackLoop: PlaybackLoop? {get}
    
    var playbackLoopState: PlaybackLoopState {get}
    
    // For the currently playing track, returns the total number of defined chapter markings
    var chapterCount: Int {get}
    
    // For the currently playing track, returns the index of the currently playing chapter. Returns nil if:
    // 1 - There are no chapter markings for the current track
    // 2 - There are chapter markings but the current seek position is not within the time bounds of any of the chapters
    var playingChapter: IndexedChapter? {get}
    
    // For the currently playing track, plays the chapter with the given index, from the start time.
    // If this chapter is already playing, it is played from the start time.
    // NOTE - If there is a segment loop defined that does not contain the chapter start time, it will be removed to allow seeking
    // to the chapter start time.
    func playChapter(index: Int)
    
    // For the currently playing track, plays the previous chapter (relative to the current seek position or chapter)
    func previousChapter()
    
    // For the currently playing track, plays the next chapter (relative to the current seek position or chapter)
    func nextChapter()
    
    // For the currently playing track, replays the currently playing chapter (i.e. seeks to the chapter's start time)
    func replayChapter()
    
    // For the currently playing track, toggles a segment loop bounded by the currently playing chapter's start and end time
    // Returns whether or not a loop exists for the currently playing chapter, after the toggle operation.
    @discardableResult func toggleChapterLoop() -> Bool
    
    // Whether or not a loop exists for the currently playing chapter
    var chapterLoopExists: Bool {get}
}

extension PlaybackOrchestratorProtocol {
    
    func playTrack(atIndex index: Int) {
        playTrack(atIndex: index, params: .defaultParams)
    }
    
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
    
    func chapterChanged(state: PlaybackState, position: PlaybackPosition, loop: PlaybackLoop?, loopState: PlaybackLoopState)
    
    func playbackLoopChanged(newLoop: PlaybackLoop?, newLoopState: PlaybackLoopState)
    
    func repeatAndShuffleModesChanged(newRepeatMode: RepeatMode, newShuffleMode: ShuffleMode)
}

struct PlaybackCommandResult {
    
    let state: PlaybackState
    let playingTrackInfo: PlayingTrackInfo?
    
    static let noTrack: PlaybackCommandResult = .init(state: .stopped, playingTrackInfo: nil)
}
