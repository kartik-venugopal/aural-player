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
    
    func numberOfRows(in tableView: NSTableView) -> Int {lyrics?.lines.count ?? 0}
}

extension LyricsViewController: NSTableViewDelegate {
    
    private static let rowHeight: CGFloat = 35
    
    // Returns a custom view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        AuralTableRowView()
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        Self.rowHeight
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        
        // Seek to clicked line.
        if let lyrics, lyrics.lines.indices.contains(row) {
            messenger.publish(.Player.jumpToTime, payload: max(0, lyrics.lines[row].position))
        }
        
        return false
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let lyrics,
              let cell = tableView.makeView(withIdentifier: .cid_lyricsLine, owner: nil) as? AuralTableCellView
        else {return nil}
        
        let isCurrentLine = row == self.curLine
        
        cell.text = lyrics.lines[row].content
        cell.textFont = isCurrentLine ? systemFontScheme.lyricsHighlightFont : systemFontScheme.prominentFont
        cell.textColor = isCurrentLine ? systemColorScheme.activeControlColor : systemColorScheme.secondaryTextColor
        
        cell.textField?.show()
        cell.textField?.lineBreakMode = .byTruncatingTail
        
        return cell
    }
}
