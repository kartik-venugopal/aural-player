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
    
    // Adjust row height based on if the text wraps over to the next line
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        30
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        false
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let column = tableColumn?.identifier,
              let result = searchResults?.results[row] else {return nil}
        
        let builder = TableCellBuilder()
        let track = result.location.track
        
        switch column {
            
        case .cid_index:
            
//            if track == playQueueDelegate.currentTrack {
//                builder.withImage(image: .imgPlayFilled, inColor: systemColorScheme.activeControlColor)
//                
//            } else {
            
                builder.withText(text: "\(row + 1)",
                                        inFont: systemFontScheme.normalFont, andColor: systemColorScheme.tertiaryTextColor,
                                        selectedTextColor: systemColorScheme.tertiarySelectedTextColor,
                                        bottomYOffset: systemFontScheme.tableYOffset)
//            }
            
        case .cid_trackName:
            
            let titleAndArtist = track.titleAndArtist
            
            if let artist = titleAndArtist.artist {
                
                builder.withAttributedText(strings: [(text: artist + "  ", font: systemFontScheme.normalFont, color: systemColorScheme.secondaryTextColor),
                                                            (text: titleAndArtist.title, font: systemFontScheme.normalFont, color: systemColorScheme.primaryTextColor)],
                                                  selectedTextColors: [systemColorScheme.secondarySelectedTextColor, systemColorScheme.primarySelectedTextColor],
                                                  bottomYOffset: systemFontScheme.tableYOffset)
                
            } else {
                
                builder.withText(text: titleAndArtist.title, inFont: systemFontScheme.normalFont, andColor: systemColorScheme.primaryTextColor,
                                        selectedTextColor: systemColorScheme.primarySelectedTextColor, bottomYOffset: systemFontScheme.tableYOffset)
            }
            
            return builder.buildCell(forTableView: tableView, forColumnWithId: .cid_trackName, inRow: row)
            
        default:
            
            return nil
        }
        
        let cell = builder.buildGenericCell(ofType: CompactPlayQueueSearchResultIndexCell.self, forTableView: tableView, forColumnWithId: column, inRow: row)
        
        if column == .cid_index {
            cell?.index = row + 1
            cell?.playQueueTrackIndex = (result.location as? PlayQueueSearchResultLocation)?.index ?? 0
        }
        
        return cell
    }
}

extension NSUserInterfaceItemIdentifier {
    
    // Table view column identifiers
    static let cid_searchResultIndexColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_searchResultIndex")
    static let cid_searchResultTrackColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_searchResultTrack")
    static let cid_searchResultLocationColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_searchResultLocation")
    static let cid_searchResultMatchedFieldColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_searchResultMatchedField")
}
