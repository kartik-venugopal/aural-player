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
    
    private static let rowHeight: CGFloat = 30
    
    // Returns a custom view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        AuralTableRowView()
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        Self.rowHeight
    }
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard tableColumn?.identifier == .cid_lyricsLine,
              let lyrics = self.lyrics,
              let cell = tableView.makeView(withIdentifier: .cid_lyricsLine, owner: nil) as? AuralTableCellView
        else {return nil}
        
        cell.text = lyrics.lines[row].content
        cell.textFont = systemFontScheme.prominentFont
        cell.textColor = row == self.curLine ? systemColorScheme.activeControlColor : systemColorScheme.secondaryTextColor
        
        cell.textField?.show()
        cell.textField?.lineBreakMode = .byTruncatingTail
        
        return cell
    }
}
