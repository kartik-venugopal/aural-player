//
//  MenuBarThemesTableViewDelegate.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class MenuBarThemesTableViewDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        themesManager.totalNumberOfObjects
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        26
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let theme: Theme = theme(forRow: row)
        guard let cell = tableView.makeView(withIdentifier: .cid_schemeName, owner: nil) as? NSTableCellView else {return nil}
        
        cell.text = theme.name
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        guard let tableView = notification.object as? NSTableView,
                  tableView.selectedRow >= 0 else {return}
        
        let row = tableView.selectedRow
        let theme: Theme = theme(forRow: row)
        
        themesManager.applyTheme(theme)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            tableView.clearSelection()
        }
    }
    
    private func theme(forRow row: Int) -> Theme {
        
        // Show user-defined themes first
        
        if row < themesManager.numberOfUserDefinedObjects {
            return themesManager.userDefinedObjects[row]
            
        } else {
            
            let index = row - themesManager.numberOfUserDefinedObjects
            return themesManager.systemDefinedObjects[index]
        }
    }
}
