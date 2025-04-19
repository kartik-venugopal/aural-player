//
// DiscretePlayer+Chapters.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

extension DiscretePlayer {
    
    ///
    /// A small margin of time that is added to the start time of a chapter to prevent an
    /// "overlap" with the previous chapter.
    ///
    private static let chapterPlaybackStartTimeMargin: TimeInterval = 0.001
    
    var chapterCount: Int {0}
    
    var playingChapter: IndexedChapter? {nil}
    
    func playChapter(_ index: Int) {
        
    }
    
    func previousChapter() {
        
    }
    
    func nextChapter() {
        
    }
    
    func replayChapter() {
        
    }
    
    func toggleChapterLoop() -> Bool {
        false
    }
    
    var chapterLoopExists: Bool {
        false
    }
}
