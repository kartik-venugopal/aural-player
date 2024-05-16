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
        
        lblSummary.font = systemFontScheme.smallFont
        lblSummary.textColor = systemColorScheme.secondaryTextColor
        
        backgroundColorChanged(systemColorScheme.backgroundColor)
        buttonColorChanged(systemColorScheme.buttonColor)
        
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
    }
}

extension ChaptersListViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        lblCaption.textColor = systemColorScheme.captionTextColor
        backgroundColorChanged(systemColorScheme.backgroundColor)
        chaptersListView.reloadDataMaintainingSelection()
        buttonColorChanged(systemColorScheme.buttonColor)
        lblSummary.textColor = systemColorScheme.secondaryTextColor

        let origFrame = view.window?.frame ?? .zero
        var newFrame = view.window?.frame ?? .zero
        newFrame.size = NSSize(width: origFrame.size.width + 1, height: origFrame.size.height)
        
        view.window?.setFrame(newFrame, display: true)
    }
    
    func backgroundColorChanged(_ newColor: NSColor) {
        
        rootContainerBox?.fillColor = systemColorScheme.backgroundColor
        chaptersListView.setBackgroundColor(.clear)
        header?.redraw()
    }
    
    func buttonColorChanged(_ newColor: NSColor) {
        btnLoopChapter.reTint()
    }
    
    func activeControlStateColorChanged(_ newColor: NSColor) {
        
        if let playingChapterIndex = player.playingChapter?.index {
            chaptersListView.reloadRows([playingChapterIndex], columns: [0])
        }
    }
    
    func inactiveControlStateColorChanged(_ newColor: NSColor) {
        btnLoopChapter.reTint()
    }
    
    func captionTextColorChanged(_ newColor: NSColor) {
        lblCaption.textColor = newColor
    }
    
    func primaryTextColorChanged(_ newColor: NSColor) {
        chaptersListView.reloadAllRows(columns: [1])
    }
    
    func secondaryTextColorChanged(_ newColor: NSColor) {
        
        lblSummary.textColor = newColor
        header?.redraw()
    }
    
    func tertiaryTextColorChanged(_ newColor: NSColor) {
        chaptersListView.reloadAllRows(columns: [0, 2, 3])
    }
    
    func changeWindowCornerRadius(_ radius: CGFloat) {
        rootContainerBox?.cornerRadius = radius
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
