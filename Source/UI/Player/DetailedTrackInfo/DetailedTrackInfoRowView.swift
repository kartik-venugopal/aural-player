//
//  DetailedTrackInfoRowView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
/*
    Custom view for a single NSTableView row that displays a single piece of track info. Creates table cells with the necessary track information.
*/

import Cocoa

class DetailedTrackInfoRowView: NSTableRowView {
    
    // A single key-value pair
    var key: String?
    var value: String?
    var tableId: TrackInfoTab?
    
    var keyTextAlignment: NSTextAlignment?
    var valueTextAlignment: NSTextAlignment?
    
    // Track info view column identifiers (popover)
    static let trackInfoKeyColumnID: String = "cid_TrackInfoKey"
    static let trackInfoValueColumnID: String = "cid_TrackInfoValue"
    
    // Factory method
    static func fromKeyAndValue(_ key: String, _ value: String, _ tableId: TrackInfoTab, _ keyTextAlignment: NSTextAlignment? = nil, _ valueTextAlignment: NSTextAlignment? = nil) -> DetailedTrackInfoRowView {
        
        let view = DetailedTrackInfoRowView()
        view.key = key
        view.value = value
        view.tableId = tableId
        view.keyTextAlignment = keyTextAlignment
        view.valueTextAlignment = valueTextAlignment
        
        return view
    }
    
    override func view(atColumn column: Int) -> Any? {
        
        if (column == 0) {
            
            // Key
            return createCell(Self.trackInfoKeyColumnID, key! + ":", keyTextAlignment)
            
        } else {
            
            // Value
            return createCell(Self.trackInfoValueColumnID, value!, valueTextAlignment)
        }
    }
    
    private func createCell(_ id: String, _ text: String, _ alignment: NSTextAlignment?) -> NSTableCellView? {
        
        if let cell = TrackInfoViewHolder.tablesMap[tableId!]?.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: id), owner: nil) as? NSTableCellView {
            
            cell.textField?.stringValue = text
            
            if let alignment = alignment {
                cell.textField?.alignment = alignment
            }
            
            return cell
        }
        
        return nil
    }
}
