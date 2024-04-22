//
//  SearchViewController+TableViewDelegate.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension SearchViewController: NSTableViewDataSource {
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        searchResults?.count ?? 0
    }
}
    
extension SearchViewController: NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let columnId = tableColumn?.identifier,
              let cell = tableView.makeView(withIdentifier: columnId, owner: nil) as? NSTableCellView,
              let result = searchResults?.results[row] else {return nil}
        
        switch columnId {
            
        case .cid_searchResultTrackColumn:
            cell.text = result.location.track.displayName
            
        case .cid_searchResultLocationColumn:
            cell.text = result.location.description
            
        case .cid_searchResultMatchedFieldColumn:
            cell.text = result.match.fieldKey
            
        default:
            return nil
        }
        
        return cell
    }
    
    // Adjust row height based on if the text wraps over to the next line
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        26
    }
}

extension NSUserInterfaceItemIdentifier {
    
    // Table view column identifiers
    static let cid_searchResultIndexColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_searchResultIndex")
    static let cid_searchResultTrackColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_searchResultTrack")
    static let cid_searchResultLocationColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_searchResultLocation")
    static let cid_searchResultMatchedFieldColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_searchResultMatchedField")
}
