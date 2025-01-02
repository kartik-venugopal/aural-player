//
// LyricsViewController+TableViewDelegate.swift
// Aural
// 
// Copyright © 2025 Kartik Venugopal. All rights reserved.
// 
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import AppKit

extension LyricsViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {timedLyrics?.lines.count ?? 0}
}

extension LyricsViewController: NSTableViewDelegate {
    
    private static let rowHeight: CGFloat = 30
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        Self.rowHeight
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        
        // Seek to clicked line.
        if let timedLyrics, timedLyrics.lines.indices.contains(row) {
            messenger.publish(.Player.jumpToTime, payload: max(0, timedLyrics.lines[row].position))
        }
        
        return false
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let timedLyrics,
              let cell = tableView.makeView(withIdentifier: .cid_lyricsLine, owner: nil) as? AuralTableCellView
        else {return nil}
        
        let isCurrentLine = row == self.curLine
        
        cell.text = timedLyrics.lines[row].content
        cell.textFont = isCurrentLine ? systemFontScheme.lyricsHighlightFont : systemFontScheme.prominentFont
        cell.textColor = isCurrentLine ? systemColorScheme.activeControlColor : systemColorScheme.secondaryTextColor
        
        cell.textField?.show()
        cell.textField?.lineBreakMode = .byTruncatingTail
        
        return cell
    }
}
