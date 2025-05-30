////
////  PlayQueueDelegate+Sequencing.swift
////  Aural
////
////  Copyright © 2025 Kartik Venugopal. All rights reserved.
////
////  This software is licensed under the MIT software license.
////  See the file "LICENSE" in the project root directory for license terms.
////  
//
//import Foundation
//
//extension PlayQueueDelegate {
//    
//    var repeatAndShuffleModes: (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
//        playQueue.repeatAndShuffleModes
//    }
//    
//    func toggleRepeatMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
//        
//        defer {Messenger.publish(.PlayQueue.shuffleModeUpdated)}
//        return playQueue.toggleRepeatMode()
//    }
//    
//    func toggleShuffleMode() -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
//        
//        defer {Messenger.publish(.PlayQueue.shuffleModeUpdated)}
//        return playQueue.toggleShuffleMode()
//    }
//    
//    func setRepeatMode(_ repeatMode: RepeatMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
//
//        defer {Messenger.publish(.PlayQueue.shuffleModeUpdated)}
//        return playQueue.setRepeatMode(repeatMode)
//    }
//    
//    func setShuffleMode(_ shuffleMode: ShuffleMode) -> (repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
//        
//        defer {Messenger.publish(.PlayQueue.shuffleModeUpdated)}
//        return playQueue.setShuffleMode(shuffleMode)
//    }
//    
//    func setRepeatAndShuffleModes(repeatMode: RepeatMode, shuffleMode: ShuffleMode) {
//
//        defer {Messenger.publish(.PlayQueue.shuffleModeUpdated)}
//        return playQueue.setRepeatAndShuffleModes(repeatMode: repeatMode, shuffleMode: shuffleMode)
//    }
//    
//    func start() -> Track? {
//        playQueue.start()
//    }
//    
//    func stop() {
//        playQueue.stop()
//    }
//    
//    func sequenceEnded() {
//        playQueue.sequenceEnded()
//    }
//    
//    func subsequent() -> Track? {
//        playQueue.subsequent()
//    }
//    
//    func previous() -> Track? {
//        playQueue.previous()
//    }
//    
//    func next() -> Track? {
//        playQueue.next()
//    }
//    
//    func peekSubsequent() -> Track? {
//        playQueue.peekSubsequent()
//    }
//    
//    func peekPrevious() -> Track? {
//        playQueue.peekPrevious()
//    }
//    
//    func peekNext() -> Track? {
//        playQueue.peekNext()
//    }
//    
//    func select(trackAt index: Int) -> Track? {
//        playQueue.select(trackAt: index)
//    }
//    
//    func selectTrack(_ track: Track) -> Track? {
//        playQueue.selectTrack(track)
//    }
//    
//    func resumeShuffleSequence(with track: Track) -> Track? {
//        playQueue.resumeShuffleSequence(with: track)
//    }
//}
