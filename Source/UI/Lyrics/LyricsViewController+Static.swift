//
// LyricsViewController+Static.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

extension LyricsViewController {
    
    func updateStaticLyricsText() {
        
        tabView.selectTabViewItem(at: 0)
        textView.string = ""
        
        if let staticLyrics {
            
            textView.textStorage?.append(staticLyrics.attributed(font: systemFontScheme.prominentFont,
                                                                 color: systemColorScheme.secondaryTextColor,
                                                                 lineSpacing: 15))
        }
    }
}
