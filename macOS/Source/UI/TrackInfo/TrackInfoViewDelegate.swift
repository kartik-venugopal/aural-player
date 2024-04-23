//
//  TrackInfoViewDelegate.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

typealias KeyValuePair = (key: String, value: String)

struct TrackInfoConstants {
    
    static let value_unknown: String = "<Unknown>"
}

protocol TrackInfoSource {
    
    func loadTrackInfo(for track: Track)
    
    var trackInfo: [KeyValuePair] {get}
}

/*
    Data source and delegate for the Detailed Track Info popover view
 */
class TrackInfoViewDelegate: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    // The table view that displays the track info
    @IBOutlet weak var table: NSTableView!
    
    var trackInfoSource: TrackInfoSource!
    
    // Container for the key-value pairs of info displayed
    var keyValuePairs: [KeyValuePair] {
        trackInfoSource.trackInfo
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        keyValuePairs.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let columnId = tableColumn?.identifier,
              let cell = tableView.makeView(withIdentifier: columnId, owner: nil) as? NSTableCellView else {return nil}
        
        let kvPair = keyValuePairs[row]
        
        switch columnId {
        
        case .cid_trackInfoKeyColumn:
            
            cell.text = "\(kvPair.key):"
            cell.textFont = systemFontScheme.normalFont
            cell.textColor = systemColorScheme.secondaryTextColor
            return cell
            
        case .cid_trackInfoValueColumn:
            
            cell.text = kvPair.value
            cell.textFont = systemFontScheme.normalFont
            cell.textColor = systemColorScheme.primaryTextColor
            return cell
            
        default:
            
            return nil
        }
    }
    
    // Adjust row height based on if the text wraps over to the next line
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        30
    }
    
    ///
    /// Disables drawing of the row selection marker.
    ///
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        TrackInfoRowView()
    }
    
    // Should be overriden by subclasses.
    func infoForTrack(_ track: Track) -> [KeyValuePair] {[]}
}

///
/// Custom view for a NSTableView row that displays a single row of track info (eg. metadata). Customizes the selection look and feel.
///
class TrackInfoRowView: NSTableRowView {
    
    /// Draws nothing (i.e. disables drawing of the row selection marker).
    override func drawSelection(in dirtyRect: NSRect) {}
}

extension NSUserInterfaceItemIdentifier {
    
    // Table view column identifiers
    static let cid_trackInfoKeyColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_TrackInfoKey")
    static let cid_trackInfoValueColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_TrackInfoValue")
}

class CompactPlayerTrackInfoViewDelegate: TrackInfoViewDelegate {
    
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let columnId = tableColumn?.identifier,
              let cell = tableView.makeView(withIdentifier: columnId, owner: nil) as? CompactPlayerTrackInfoCell else {return nil}
        
        let kvPair = keyValuePairs[row]
        
        cell.keyField.stringValue = "\(kvPair.key):"
        cell.keyField.font = systemFontScheme.normalFont
        cell.keyField.textColor = systemColorScheme.secondaryTextColor
        
        cell.valueField.stringValue = kvPair.value
        cell.valueField.font = systemFontScheme.normalFont
        cell.valueField.textColor = systemColorScheme.primaryTextColor
        
        return cell
    }
    
    override func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        57
    }
}

class CompactPlayerTrackInfoCell: NSTableCellView {
    
    @IBOutlet weak var keyField: NSTextField!
    @IBOutlet weak var valueField: NSTextField!
}

extension NSUserInterfaceItemIdentifier {
    
    // Table view column identifiers
    static let cid_compactPlayerTrackInfoColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_CompactPlayerTrackInfo")
}
