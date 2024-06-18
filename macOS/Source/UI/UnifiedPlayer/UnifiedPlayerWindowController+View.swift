//
//  UnifiedPlayerWindowController+View.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension UnifiedPlayerWindowController {
    
    var isShowingPlayQueue: Bool {
        tabGroup.selectedIndex == 0
    }
    
    var isShowingEffects: Bool {
        attachedSheetViewController == effectsSheetViewController
    }
    
    var isShowingChaptersList: Bool {
        tabGroup.selectedIndex == 1
    }
    
    // TODO: Viz
    var isShowingVisualizer: Bool {
        false
    }
    
    var isShowingTrackInfo: Bool {
        playerViewController.isShowingTrackInfo
    }
}
