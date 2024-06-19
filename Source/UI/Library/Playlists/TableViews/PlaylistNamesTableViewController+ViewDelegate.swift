////
////  PlaylistNamesTableViewController+ViewDelegate.swift
////  Aural
////
////  Copyright © 2024 Kartik Venugopal. All rights reserved.
////
////  This software is licensed under the MIT software license.
////  See the file "LICENSE" in the project root directory for license terms.
////  
//
//import Cocoa
//
//extension PlaylistNamesTableViewController: NSTableViewDelegate {
//    
//    var rowHeight: CGFloat {25}
//    
//    var numberOfPlaylists: Int {
//        playlistsManager.numberOfUserDefinedObjects
//    }
//    
//    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {rowHeight}
//    
//    // Returns a view for a single row
//    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
//        AuralTableRowView()
//    }
//    
//    func playlist(forRow row: Int) -> Playlist? {
//        playlistsManager.userDefinedObjects[row]
//    }
//    
//    // Returns a view for a single column
//    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
//        
//        guard let playlist = playlist(forRow: row), let columnId = tableColumn?.identifier,
//              columnId == .cid_playlistName else {return nil}
//        
//        let builder = TableCellBuilder().withText(text: playlist.name,
//                                                  inFont: systemFontScheme.normalFont,
//                                                  andColor: systemColorScheme.primaryTextColor,
//                                                  selectedTextColor: systemColorScheme.primarySelectedTextColor)
//        
//        let cell = builder.buildCell(forTableView: tableView, forColumnWithId: columnId, inRow: row)
//        cell?.textField?.delegate = self
//        
//        return cell
//    }
//    
//    func tableViewSelectionDidChange(_ notification: Notification) {
//        
//        playlistsUIState.selectedPlaylistIndices = tableView.selectedRowIndexes
//        
//        guard selectedRowCount == 1, let row = selectedRows.first else {
//            
////            playlistViewController.playlist = nil
//            controlsContainer.hideControls()
//            return
//        }
//        
//        let playlist = playlistsManager.userDefinedObjects[row]
////        playlistViewController.playlist = playlist
//        tableViewController.playlist = playlist
//        
//        controlsContainer.showControls()
//        
//        messenger.publish(.playlists_updateSummary)
//    }
//}
