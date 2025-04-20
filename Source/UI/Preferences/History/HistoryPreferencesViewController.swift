//
//  HistoryPreferencesViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class HistoryPreferencesViewController: NSViewController, PreferencesViewProtocol {
    
    @IBOutlet weak var btnLimitRecentItemsListSize: CheckBox!
    @IBOutlet weak var recentItemsListSizeMenu: NSPopUpButton!
    
    override var nibName: NSNib.Name? {"HistoryPreferences"}
    
    var preferencesView: NSView {
        view
    }
    
    func resetFields() {
        
        let historyPrefs = preferences.historyPreferences
        
        if let recentItemsListSize = historyPrefs.recentItemsListSize {
            
            btnLimitRecentItemsListSize.on()
            recentItemsListSizeMenu.selectItem(withTag: recentItemsListSize)
            recentItemsListSizeMenu.enable()
            
        } else {
            
            btnLimitRecentItemsListSize.off()
            recentItemsListSizeMenu.disable()
        }
    }
    
    @IBAction func limitRecentItemsListSizeAction(_ sender: CheckBox) {
        recentItemsListSizeMenu.enableIf(btnLimitRecentItemsListSize.isOn)
    }
    
    private func selectItemWithTag(_ list: NSPopUpButton, _ tag: Int) {
        list.selectItem(withTag: tag)
    }
    
    func save() throws {
        
        let historyPrefs = preferences.historyPreferences
        
        let listSizeBeforeChange = historyPrefs.recentItemsListSize ?? Int.max
        historyPrefs.recentItemsListSize = btnLimitRecentItemsListSize.isOn ? recentItemsListSizeMenu.selectedTag() : nil
        let listSizeAfterChange = historyPrefs.recentItemsListSize ?? Int.max
        
        if listSizeAfterChange < listSizeBeforeChange {
            
            // Need to trim "Recent Items" list
            history.resizeRecentItemsList(to: listSizeAfterChange)
        }
    }
}
