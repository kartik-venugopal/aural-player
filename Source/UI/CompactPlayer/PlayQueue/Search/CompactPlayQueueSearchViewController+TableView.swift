//
//  CompactPlayQueueSearchViewController+TableView.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension CompactPlayQueueSearchViewController: NSTableViewDataSource {
    
    // Returns the total number of playlist rows
    func numberOfRows(in tableView: NSTableView) -> Int {
        searchResults?.count ?? 0
    }
}
    
extension CompactPlayQueueSearchViewController: NSTableViewDelegate {
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        AuralTableRowView()
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {45}
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let columnId = tableColumn?.identifier,
              let result = self.searchResults?.results[row] else {return nil}
        
        switch columnId {
            
        case .cid_searchResultIndexColumn:
            
            guard let cell = tableView.makeView(withIdentifier: .cid_searchResultIndexColumn, owner: nil) as? CompactPlayQueueSearchResultIndexCell,
                  let location = result.location as? PlayQueueSearchResultLocation else {return nil}
            
            cell.index = row + 1
            cell.playQueueTrackIndex = location.index
            return cell
            
        case .cid_searchResultTrackColumn:
            return createTrackNameCell(tableView: tableView, track: result.location.track, row: row)
            
        default:
            return nil
        }
    }
    
    // TODO: Reduce duplication. Make this a static factory method on PlayQueueListTrackNameCell
    private func createTrackNameCell(tableView: NSTableView, track: Track, row: Int) -> PlayQueueListTrackNameCell? {
        
        guard let cell = tableView.makeView(withIdentifier: .cid_searchResultTrackColumn, owner: nil) as? PlayQueueListTrackNameCell else {return nil}
        
        cell.updateForTrack(track, needsTooltip: true)
        cell.rowSelectionStateFunction = {[weak tableView] in
            tableView?.selectedRowIndexes.contains(row) ?? false
        }
        
        [cell.lblTitle, cell.lblArtistAlbum, cell.lblDefaultDisplayName].forEach {
            $0.font = systemFontScheme.smallFont
        }
        
        return cell
    }
}

class CompactPlayQueueSearchResultIndexCell: AuralTableCellView {
    
    var index: Int = 0 {
        
        didSet {
            text = "\(index)"
        }
    }
    
    var playQueueTrackIndex: Int = 0
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        textFont = systemFontScheme.smallFont
        textColor = systemColorScheme.tertiaryTextColor
    }
    
    func playSearchResult() {
        
        Messenger.publish(TrackPlaybackCommandNotification(index: playQueueTrackIndex))
        Messenger.publish(.View.CompactPlayer.showPlayer)
    }
}
