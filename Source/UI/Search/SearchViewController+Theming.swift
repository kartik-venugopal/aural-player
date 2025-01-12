//
//  SearchViewController+Theming.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension SearchViewController: ThemeInitialization {
    
    func initTheme() {
        
        lblCaption.font = systemFontScheme.captionFont
        lblCaption.textColor = systemColorScheme.captionTextColor
        
        searchField.font = systemFontScheme.normalFont
        searchField.textColor = systemColorScheme.primaryTextColor
        
        lblSummary.font = systemFontScheme.smallFont
        lblSummary.textColor = systemColorScheme.tertiaryTextColor
        
        resultsTable.reloadDataMaintainingSelection()
    }
}

extension SearchViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        lblCaption.font = systemFontScheme.captionFont
        searchField.font = systemFontScheme.normalFont
        lblSummary.font = systemFontScheme.normalFont
        
        resultsTable.reloadDataMaintainingSelection()
        btnDone.redraw()
    }
}

extension SearchViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        lblCaption.textColor = systemColorScheme.captionTextColor
        
        searchField.textColor = systemColorScheme.primaryTextColor
        lblSummary.textColor = systemColorScheme.tertiaryTextColor
        
        resultsTable.reloadDataMaintainingSelection()
        btnDone.redraw()
    }
}
