//
//  BookmarksManagerViewController.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class BookmarksManagerViewController: PresetsManagerViewController {

    // Delegate that relays accessor operations to the bookmarks model
    private let bookmarks: BookmarksDelegateProtocol = objectGraph.bookmarksDelegate
    
    override var nibName: String? {"BookmarksManager"}
    
    override var numberOfPresets: Int {bookmarks.count}
    
    override func nameOfPreset(atIndex index: Int) -> String {bookmarks.getBookmarkAtIndex(index).name}
    
    override func presetExists(named name: String) -> Bool {
        bookmarks.bookmarkWithNameExists(name)
    }
    
    override func deletePresets(atIndices indices: IndexSet) {
        bookmarks.deleteBookmarks(atIndices: tableView.selectedRowIndexes)
    }
    
    override func applyPreset(atIndex index: Int) {
        
        let bookmark = bookmarks.getBookmarkAtIndex(index)
        
        do {
            try bookmarks.playBookmark(bookmark)
            
        } catch {
            
            if let fnfError = error as? FileNotFoundError {
                
                // This needs to be done async. Otherwise, other open dialogs could hang.
                DispatchQueue.main.async {
                    
                    // Position and display an alert with error info
                    _ = DialogsAndAlerts.trackNotPlayedAlertWithError(fnfError, "Remove bookmark").showModal()
                    self.bookmarks.deleteBookmarkWithName(bookmark.name)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    override func renamePreset(named name: String, to newName: String) {
        bookmarks.renameBookmark(named: name, to: newName)
    }
    
    // MARK: View delegate functions
    
    // Returns a view for a single column
    override func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let colID = tableColumn?.identifier else {return nil}
        
        let bookmark = bookmarks.getBookmarkAtIndex(row)
        
        switch colID {
            
        case .cid_bookmarkNameColumn:
            
            return createTextCell(tableView, tableColumn!, row, bookmark.name, true)
            
        case .cid_bookmarkTrackColumn:
            
            return createTextCell(tableView, tableColumn!, row, bookmark.file.path, false)
            
        case .cid_bookmarkStartPositionColumn:
            
            let formattedPosition = ValueFormatter.formatSecondsToHMS(bookmark.startPosition)
            return createTextCell(tableView, tableColumn!, row, formattedPosition, false)
            
        case .cid_bookmarkEndPositionColumn:
            
            var formattedPosition: String = ""
            
            if let endPos = bookmark.endPosition {
                formattedPosition = ValueFormatter.formatSecondsToHMS(endPos)
            } else {
                formattedPosition = "-"
            }
            
            return createTextCell(tableView, tableColumn!, row, formattedPosition, false)
            
        default:    return nil
            
        }
    }
}

extension NSUserInterfaceItemIdentifier {
    
    // Table view column identifiers
    
    static let cid_bookmarkNameColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_BookmarkName")
    static let cid_bookmarkTrackColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_BookmarkTrack")
    static let cid_bookmarkStartPositionColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_BookmarkStartPosition")
    static let cid_bookmarkEndPositionColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_BookmarkEndPosition")
}
