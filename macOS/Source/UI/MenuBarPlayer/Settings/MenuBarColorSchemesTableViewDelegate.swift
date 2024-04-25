//
//  MenuBarColorSchemesTableViewDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
    }
    
    private func scheme(forRow row: Int) -> ColorScheme {
        
        if row < colorSchemesManager.numberOfSystemDefinedObjects {
            return colorSchemesManager.systemDefinedObjects[row]
            
        } else {
            
            let index = row - colorSchemesManager.numberOfSystemDefinedObjects
            return colorSchemesManager.userDefinedObjects[index]
        }
    }
}

extension NSUserInterfaceItemIdentifier {
    
    static let cid_schemeName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_schemeName")
}
