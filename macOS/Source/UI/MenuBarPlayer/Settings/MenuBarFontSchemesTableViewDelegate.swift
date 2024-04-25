//
//  MenuBarFontSchemesTableViewDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class MenuBarFontSchemesTableViewDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        fontSchemesManager.totalNumberOfObjects
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        26
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let scheme: FontScheme = scheme(forRow: row)
        guard let cell = tableView.makeView(withIdentifier: .cid_schemeName, owner: nil) as? NSTableCellView else {return nil}
        
        cell.text = scheme.name
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        guard let tableView = notification.object as? NSTableView,
                  tableView.selectedRow >= 0 else {return}
        
        let row = tableView.selectedRow
        let scheme: FontScheme = scheme(forRow: row)
        
        fontSchemesManager.applyScheme(scheme)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            tableView.clearSelection()
        }
    }
    
    private func scheme(forRow row: Int) -> FontScheme {
        
        // Show user-defined schemes first
        
        if row < fontSchemesManager.numberOfUserDefinedObjects {
            return fontSchemesManager.userDefinedObjects[row]
            
        } else {
            
            let index = row - fontSchemesManager.numberOfUserDefinedObjects
            return fontSchemesManager.systemDefinedObjects[index]
        }
    }
}
