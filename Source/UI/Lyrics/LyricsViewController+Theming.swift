//
// LyricsViewController+Theming.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

extension LyricsViewController: ThemeInitialization {
    
    func initTheme() {
        
        imgLyrics.contentTintColor = systemColorScheme.buttonColor
     
        lblCaption.font = systemFontScheme.captionFont
        lblCaption.textColor = systemColorScheme.captionTextColor
        
        lblDragDrop.font = systemFontScheme.prominentFont
        lblDragDrop.textColor = systemColorScheme.primaryTextColor
        
        lblSearching.font = systemFontScheme.prominentFont
        lblSearching.textColor = systemColorScheme.primaryTextColor
        
        view.layer?.backgroundColor = systemColorScheme.backgroundColor.cgColor
        textView.backgroundColor = systemColorScheme.backgroundColor
        tableView.setBackgroundColor(systemColorScheme.backgroundColor)
        
        textVertScroller.redraw()
        tableVertScroller.redraw()
        
        if showingTimedLyrics {
            updateTimedLyricsText()
        } else {
            updateStaticLyricsText()
        }
    }
}

extension LyricsViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        lblCaption.font = systemFontScheme.captionFont
        lblDragDrop.font = systemFontScheme.prominentFont
        lblSearching.font = systemFontScheme.prominentFont
        
        if showingTimedLyrics {
            updateTimedLyricsText()
        } else {
            updateStaticLyricsText()
        }
        
        [btnChooseFile, btnSearchOnline].forEach {$0?.redraw()}
    }
}

extension LyricsViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        imgLyrics.contentTintColor = systemColorScheme.buttonColor

        lblCaption.textColor = systemColorScheme.captionTextColor
        lblDragDrop.textColor = systemColorScheme.primaryTextColor
        lblSearching.textColor = systemColorScheme.primaryTextColor

        view.layer?.backgroundColor = systemColorScheme.backgroundColor.cgColor
        textView.backgroundColor = systemColorScheme.backgroundColor
        tableView.setBackgroundColor(systemColorScheme.backgroundColor)
        
        textVertScroller.redraw()
        tableVertScroller.redraw()
        
        [btnChooseFile, btnSearchOnline].forEach {$0?.redraw()}
        
        if showingStaticLyrics {
            updateStaticLyricsText()
        } else if showingTimedLyrics {
            updateTimedLyricsText()
        }
    }
}
