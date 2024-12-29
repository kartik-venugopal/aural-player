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
              let result = searchResults?.results[row],
              let cell = tableView.makeView(withIdentifier: column, owner: nil) as? AuralTableCellView else {return nil}
        
        let track = result.location.track
        
        switch column {
            
        case .cid_index:
            
            cell.text = "\(row + 1)"
            cell.textFont = systemFontScheme.normalFont
            cell.textColor = systemColorScheme.tertiaryTextColor
            cell.realignTextBottom(yOffset: systemFontScheme.tableYOffset)
            
            // Used by play button action (to play the search result)
            
            if let pqResultCell = cell as? CompactPlayQueueSearchResultIndexCell {
                
                pqResultCell.index = row + 1
                pqResultCell.playQueueTrackIndex = (result.location as? PlayQueueSearchResultLocation)?.index ?? 0
            }
            
        case .cid_trackName:
            
            let titleAndArtist = track.titleAndArtist
            
            if let artist = titleAndArtist.artist {
                
                let attrText = "\(artist)  ".attributed(font: systemFontScheme.normalFont, color: systemColorScheme.secondaryTextColor) + titleAndArtist.title.attributed(font: systemFontScheme.normalFont, color: systemColorScheme.primaryTextColor)
                
                attrText.addAttribute(.paragraphStyle, value: NSMutableParagraphStyle.byTruncatingTail, range: NSMakeRange(0, attrText.length))
                
                cell.attributedText = attrText
                cell.textField?.lineBreakMode = .byTruncatingTail
                cell.textField?.usesSingleLineMode = true
                
            } else {
                
                cell.text = titleAndArtist.title
                cell.textFont = systemFontScheme.normalFont
                cell.textColor = systemColorScheme.primaryTextColor
            }
            
            cell.realignTextBottom(yOffset: systemFontScheme.tableYOffset)
            
        default:
            
            return nil
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
