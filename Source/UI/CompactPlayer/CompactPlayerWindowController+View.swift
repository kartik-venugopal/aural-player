//
//  CompactPlayerWindowController+View.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension CompactPlayerWindowController {
    
    var isShowingPlayer: Bool {
        compactPlayerUIState.displayedView == .player
    }
    
    var isShowingPlayQueue: Bool {
        compactPlayerUIState.displayedView == .playQueue
    }

    var isShowingLyrics: Bool {
        compactPlayerUIState.displayedView == .lyrics
    }

    var isShowingEffects: Bool {
        compactPlayerUIState.displayedView == .effects
    }
    
    var isShowingChaptersList: Bool {
        compactPlayerUIState.displayedView == .chaptersList
    }
    
    var isShowingTrackInfo: Bool {
        compactPlayerUIState.displayedView == .trackInfo
    }
    
    // TODO: Viz
    var isShowingVisualizer: Bool {
        false
    }
    
    var isShowingWaveform: Bool {
        false
    }
}
