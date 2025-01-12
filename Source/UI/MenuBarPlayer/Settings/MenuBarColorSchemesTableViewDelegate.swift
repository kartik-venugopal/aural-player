//
//  MenuBarColorSchemesTableViewDelegate.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class MenuBarColorSchemesTableViewDelegate: NSObject, NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        colorSchemesManager.totalNumberOfObjects
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        26
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let scheme: ColorScheme = scheme(forRow: row)
        guard let cell = tableView.makeView(withIdentifier: .cid_schemeName, owner: nil) as? NSTableCellView else {return nil}
        
        cell.text = scheme.name
        return cell
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        guard let tableView = notification.object as? NSTableView,
                  tableView.selectedRow >= 0 else {return}
        
        let row = tableView.selectedRow
        let scheme: ColorScheme = scheme(forRow: row)
        
        colorSchemesManager.applyScheme(scheme)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            tableView.clearSelection()
        }
    }
    
    private func scheme(forRow row: Int) -> ColorScheme {
        
        // Show user-defined schemes first
        
        if row < colorSchemesManager.numberOfUserDefinedObjects {
            return colorSchemesManager.userDefinedObjects[row]
            
        } else {
            
            let index = row - colorSchemesManager.numberOfUserDefinedObjects
            return colorSchemesManager.systemDefinedObjects[index]
        }
    }
}

extension NSUserInterfaceItemIdentifier {
    
    static let cid_schemeName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_schemeName")
}
