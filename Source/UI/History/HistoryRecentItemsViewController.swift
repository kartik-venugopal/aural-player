//
//  HistoryRecentItemsViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class HistoryRecentItemsViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"HistoryRecentItems"}
    
    @IBOutlet weak var tableView: NSTableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        colorSchemesManager.registerSchemeObserver(self)
    }
}

extension HistoryRecentItemsViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        tableView.setBackgroundColor(systemColorScheme.backgroundColor)
    }
}

extension HistoryRecentItemsViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        30
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        history.numberOfItems
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        AuralTableRowView()
    }

//    override func renamePreset(named name: String, to newName: String) {
//        bookmarksDelegate.renameBookmark(named: name, to: newName)
//    }
//
    // MARK: View delegate functions
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let column = tableColumn else {return nil}
        let colID = column.identifier
        
        let item = history[row]
        
        switch colID {
            
        case .cid_historyNameColumn:
            
            if let trackItem = item as? TrackHistoryItem {
                return createTrackCell(tableView, column, row, trackItem.track)
//                
//            } else if let groupItem = item as? GroupHistoryItem {
//                return createGroupCell(tableView, column, row, groupItem)
            }
            
        case .cid_historyDateColumn:
            
            return createDateCell(tableView, column, row, item)
            
        case .cid_historyEventCountColumn:
            
            return createEventCountCell(tableView, column, row, item)
            
        default:    
            
            return nil
        }
        
        return nil
    }
    
    // Creates a cell view containing text
    func createTrackCell(_ tableView: NSTableView, _ column: NSTableColumn, _ row: Int, _ track: Track) -> AuralTableCellView? {
        
        let builder = TableCellBuilder()
        let titleAndArtist = track.titleAndArtist
        
        if let artist = titleAndArtist.artist {

            builder.withAttributedText(strings: [(text: artist + "  ", font: systemFontScheme.normalFont, color: systemColorScheme.secondaryTextColor),
                                                        (text: titleAndArtist.title, font: systemFontScheme.normalFont, color: systemColorScheme.primaryTextColor)],
                                              selectedTextColors: [systemColorScheme.secondarySelectedTextColor, systemColorScheme.primarySelectedTextColor],
                                              bottomYOffset: systemFontScheme.tableYOffset)

        } else {
            
            builder.withAttributedText(strings: [(text: titleAndArtist.title,
                                                         font: systemFontScheme.normalFont,
                                                         color: systemColorScheme.primaryTextColor)], selectedTextColors: [systemColorScheme.primarySelectedTextColor],
                                              bottomYOffset: systemFontScheme.tableYOffset)
        }
        
        builder.withImage(image: track.art?.downscaledOrOriginalImage ?? .imgPlayingArt)
        
        let cell = builder.buildCell(forTableView: tableView, forColumnWithId: column.identifier, inRow: row)
        cell?.textField?.lineBreakMode = .byTruncatingTail
        return cell
    }
    
//    // Creates a cell view containing text
//    func createGroupCell(_ tableView: NSTableView, _ column: NSTableColumn, _ row: Int, _ groupItem: GroupHistoryItem) -> AuralTableCellView? {
//        
//        let builder = TableCellBuilder()
//        
//        builder.withAttributedText(strings: [(text: groupItem.groupName,
//                                              font: systemFontScheme.normalFont,
//                                              color: systemColorScheme.primaryTextColor)], selectedTextColors: [systemColorScheme.primarySelectedTextColor],
//                                   bottomYOffset: systemFontScheme.tableYOffset)
//        .withImage(image: .imgGroup)
//        
//        // TODO: Image for group
//        //        builder.withImage(image: track.art?.image ?? .imgPlayingArt)
//        
//        return builder.buildCell(forTableView: tableView, forColumnWithId: column.identifier, inRow: row)
//    }
    
    func createDateCell(_ tableView: NSTableView, _ column: NSTableColumn, _ row: Int, _ item: HistoryItem) -> AuralTableCellView? {
        
        let builder = TableCellBuilder()
            
//        builder.withAttributedText(strings: [(text: item.lastEventTime.hmsString,
//                                                         font: systemFontScheme.normalFont,
//                                                         color: systemColorScheme.primaryTextColor)], selectedTextColors: [systemColorScheme.primarySelectedTextColor],
//                                              bottomYOffset: systemFontScheme.tableYOffset)
        
        return builder.buildCell(forTableView: tableView, forColumnWithId: column.identifier, inRow: row)
    }
    
    func createEventCountCell(_ tableView: NSTableView, _ column: NSTableColumn, _ row: Int, _ item: HistoryItem) -> AuralTableCellView? {
        
        let builder = TableCellBuilder()
        
        builder.withAttributedText(strings: [(text: "\(item.addCount)",
                                              font: systemFontScheme.normalFont,
                                              color: systemColorScheme.primaryTextColor)], selectedTextColors: [systemColorScheme.primarySelectedTextColor],
                                   bottomYOffset: systemFontScheme.tableYOffset)
        .withTextAlignment(.center)
        
        let cell = builder.buildCell(forTableView: tableView, forColumnWithId: column.identifier, inRow: row)
        (cell?.textField?.cell as? VCenteredLabelCell)?.debug = true
        return cell
    }
}

fileprivate extension NSUserInterfaceItemIdentifier {
    
    // Table view column identifiers
    
    static let cid_historyNameColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_HistoryName")
    static let cid_historyDateColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_HistoryDate")
    static let cid_historyEventCountColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_HistoryEventCount")
}
