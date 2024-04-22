//
//  HistoryPreferencesViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class HistoryPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var recentlyAddedListSizeMenu: NSPopUpButton!
    @IBOutlet weak var recentlyPlayedListSizeMenu: NSPopUpButton!
    
    override var nibName: String? {"HistoryPreferences"}
    
    var preferencesView: NSView {
        return self.view
    }
    
    func resetFields() {
        
//        let historyPrefs = preferences.historyPreferences
//        
//        let recentlyAddedListSize = historyPrefs.recentlyAddedListSize
//        let recentlyPlayedListSize = historyPrefs.recentlyPlayedListSize
//        
//        selectItemWithTag(recentlyAddedListSizeMenu, recentlyAddedListSize)
//        selectItemWithTag(recentlyPlayedListSizeMenu, recentlyPlayedListSize)
    }
    
    private func selectItemWithTag(_ list: NSPopUpButton, _ tag: Int) {
        list.selectItem(withTag: tag)
    }
    
    func save() throws {
        
//        let historyPrefs = preferences.historyPreferences
//        
//        historyPrefs.recentlyAddedListSize = recentlyAddedListSizeMenu.selectedTag()
//        historyPrefs.recentlyPlayedListSize = recentlyPlayedListSizeMenu.selectedTag()
//        
//        historyDelegate.resizeLists(historyPrefs.recentlyAddedListSize, historyPrefs.recentlyPlayedListSize)
    }
}
