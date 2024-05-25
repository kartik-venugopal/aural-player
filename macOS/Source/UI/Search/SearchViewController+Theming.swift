//
//  SearchViewController+Theming.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension SearchViewController: ThemeInitialization {
    
    func initTheme() {
        
        searchField.font = systemFontScheme.normalFont
        searchField.textColor = systemColorScheme.primaryTextColor
        
        captionLabels.forEach {
            
            $0.font = systemFontScheme.smallFont
            $0.textColor = systemColorScheme.secondaryTextColor
        }
        
        checkBoxes.forEach {
            $0.font = systemFontScheme.smallFont
        }
        
        btnComparisonType.font = systemFontScheme.smallFont
        
        lblSummary.font = systemFontScheme.smallFont
        lblSummary.textColor = systemColorScheme.tertiaryTextColor
        
        resultsTable.reloadDataMaintainingSelection()
    }
}

extension SearchViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        searchField.font = systemFontScheme.normalFont
        
        captionLabels.forEach {
            $0.font = systemFontScheme.smallFont
        }
        
        checkBoxes.forEach {
            $0.font = systemFontScheme.smallFont
        }
        
        btnComparisonType.font = systemFontScheme.smallFont
        
        lblSummary.font = systemFontScheme.normalFont
        
        resultsTable.reloadDataMaintainingSelection()
    }
}

extension SearchViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        searchField.textColor = systemColorScheme.primaryTextColor
        lblSummary.textColor = systemColorScheme.tertiaryTextColor
        
        captionLabels.forEach {
            $0.textColor = systemColorScheme.secondaryTextColor
        }
        
        resultsTable.reloadDataMaintainingSelection()
    }
}
