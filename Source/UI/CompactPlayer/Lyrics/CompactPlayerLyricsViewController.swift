//
// CompactPlayerLyricsViewController.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

class CompactPlayerLyricsViewController: LyricsViewController {
    
    @IBOutlet weak var prototypeTextField: NSTextField!
    
    override var nibName: NSNib.Name? {"CompactPlayerLyrics"}
    
    override var lineBreakMode: NSLineBreakMode {.byWordWrapping}
    
    // Adjust row height based on if the text wraps over to the next line
    override func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        
        guard let text = self.timedLyrics?.lines[row].content else {return 30}
        
        prototypeTextField.font = systemFontScheme.lyricsHighlightFont
        prototypeTextField.stringValue = text
        
        let columnWidth = tableView.tableColumn(withIdentifier: .cid_lyricsLine)?.width ?? 270
        let columnBounds = NSMakeRect(.zero, .zero, columnWidth, .greatestFiniteMagnitude)
        
        // And then compute row height from their cell sizes
        let rowHeight = prototypeTextField.cell!.cellSize(forBounds: columnBounds).height
        
        // The desired row height is the maximum of the two heights, plus some padding
        return max(30, rowHeight + 5)
    }
}
