//
//  ChaptersListViewController+Theming.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension ChaptersListViewController: ThemeInitialization {
    
    func initTheme() {
        
        chaptersListView.reloadDataMaintainingSelection()
        
        lblCaption.font = systemFontScheme.captionFont
        lblCaption.textColor = systemColorScheme.captionTextColor
        
        [lblSummary, lblNumMatches, txtSearch].forEach {$0?.font = systemFontScheme.smallFont}
        [lblSummary, lblNumMatches].forEach {$0?.textColor = systemColorScheme.secondaryTextColor}
        
        backgroundColorChanged(systemColorScheme.backgroundColor)
        buttonColorChanged(systemColorScheme.buttonColor)

        redrawSearchField()
        
        // Hack to get the search field to redraw (doesn't work)
        
        let origFrame = view.window?.frame ?? .zero
        var newFrame = view.window?.frame ?? .zero
        newFrame.size = NSSize(width: origFrame.size.width + 1, height: origFrame.size.height)
        
        view.window?.setFrame(newFrame, display: true)
    }
}

extension ChaptersListViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {

        // Don't need to do this if the window is not visible
//        guard view.window?.isVisible ?? false else {return}
        
        chaptersListView.reloadDataMaintainingSelection()
        lblCaption.font = systemFontScheme.captionFont
        
        let smallFont = systemFontScheme.smallFont
        lblSummary.font = smallFont
        txtSearch.font = smallFont
        lblNumMatches.font = smallFont
    }
}

extension ChaptersListViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        lblCaption.textColor = systemColorScheme.captionTextColor
        backgroundColorChanged(systemColorScheme.backgroundColor)
        chaptersListView.reloadData()
        buttonColorChanged(systemColorScheme.buttonColor)
        [lblSummary, lblNumMatches].forEach {$0?.textColor = systemColorScheme.secondaryTextColor}

        redrawSearchField()
        
        let origFrame = view.window?.frame ?? .zero
        var newFrame = view.window?.frame ?? .zero
        newFrame.size = NSSize(width: origFrame.size.width + 1, height: origFrame.size.height)
        
        view.window?.setFrame(newFrame, display: true)
    }
    
    func backgroundColorChanged(_ newColor: NSColor) {
        
        chaptersListView.setBackgroundColor(.clear)
        header.redraw()
    }
    
    func buttonColorChanged(_ newColor: NSColor) {
        
        [btnClose, btnPreviousChapter, btnNextChapter, btnReplayChapter, btnPreviousMatch, btnNextMatch].forEach {
            $0?.colorChanged(newColor)
        }
        
        [btnLoopChapter, btnCaseSensitive].forEach {$0?.reTint()}
    }
    
    func activeControlStateColorChanged(_ newColor: NSColor) {
        
        if let playingChapterIndex = player.playingChapter?.index {
            chaptersListView.reloadRows([playingChapterIndex], columns: [0])
        }
    }
    
    func inactiveControlStateColorChanged(_ newColor: NSColor) {
        [btnLoopChapter, btnCaseSensitive].forEach {$0?.reTint()}
    }
    
    func captionTextColorChanged(_ newColor: NSColor) {
        lblCaption.textColor = newColor
    }
    
    func primaryTextColorChanged(_ newColor: NSColor) {
        
        chaptersListView.reloadAllRows(columns: [1])
        redrawSearchField()
    }
    
    func secondaryTextColorChanged(_ newColor: NSColor) {
        
        [lblSummary, lblNumMatches].forEach {$0?.textColor = newColor}
        header.redraw()
    }
    
    func tertiaryTextColorChanged(_ newColor: NSColor) {
        chaptersListView.reloadAllRows(columns: [0, 2, 3])
    }
    
    func redrawSearchField() {
        
        let textColor = systemColorScheme.primaryTextColor
        txtSearch.textColor = textColor
        
        if let cell: NSSearchFieldCell = txtSearch.cell as? NSSearchFieldCell {

            // This is a hack to force these cells to redraw
            cell.resetCancelButtonCell()
            cell.resetSearchButtonCell()
            
            // Tint the 2 cell images according to the appropriate color.
            cell.cancelButtonCell?.image = cell.cancelButtonCell?.image?.filledWithColor(textColor)
            cell.cancelButtonCell?.image?.isTemplate = true
            
            cell.searchButtonCell?.image = cell.searchButtonCell?.image?.filledWithColor(textColor)
            cell.searchButtonCell?.image?.isTemplate = true
        }
        
        txtSearch.redraw()
    }
    
    func primarySelectedTextColorChanged(_ newColor: NSColor) {
        chaptersListView.reloadRows(chaptersListView.selectedRowIndexes, columns: [1])
    }
    
    func tertiarySelectedTextColorChanged(_ newColor: NSColor) {
        chaptersListView.reloadRows(chaptersListView.selectedRowIndexes, columns: [0, 2, 3])
    }
    
    func textSelectionColorChanged(_ newColor: NSColor) {
        chaptersListView.redoRowSelection()
    }
}
