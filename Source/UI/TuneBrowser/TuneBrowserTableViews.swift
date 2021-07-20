//
//  TuneBrowserTableViews.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class TuneBrowserOutlineView: NSOutlineView {
    
    var rightClickedItem: Any?
    
    override func menu(for event: NSEvent) -> NSMenu? {
        
        let clickedRow = self.rowForEvent(event)

        // If the click occurred outside of any of the playlist rows (i.e. empty space), don't show the menu
        if clickedRow == -1 {return nil}
        
        self.rightClickedItem = self.item(atRow: clickedRow)
        
        if !self.isRowSelected(clickedRow) {
            self.selectRow(clickedRow)
        }
        
        return self.menu
    }
}

class TuneBrowserSidebarOutlineView: NSOutlineView {
    
    var rightClickedItem: Any?
    
    func resetRightClick() {
        rightClickedItem = nil
    }
    
    override func menu(for event: NSEvent) -> NSMenu? {
        
        let clickedRow = self.rowForEvent(event)

        // If the click occurred outside of any of the playlist rows (i.e. empty space), don't show the menu
        if clickedRow == -1 {return nil}

        self.rightClickedItem = self.item(atRow: clickedRow)
        return super.menu(for: event)
    }
}

class TuneBrowserItemNameCell: NSTableCellView {
 
    @IBInspectable @IBOutlet weak var icon: NSImageView!
    @IBInspectable @IBOutlet weak var lblName: NSTextField!
    
    func initializeForFile(_ file: FileSystemItem) {
        
        lblName.stringValue = file.url.lastPathComponent
        
        if file.isDirectory {
            icon.image = Images.imgGroup
            
        } else if file.isTrack {
            icon.image = file.metadata?.coverArt ?? Images.imgPlayingArt
            
        } else if file.isPlaylist {
            icon.image = Images.imgPlaylistPreview
        }
    }
}

class TuneBrowserItemTextCell: NSTableCellView {}

class TuneBrowserItemTypeCell: NSTableCellView {
 
    func initializeForFile(_ file: FileSystemItem) {
        
        if file.isDirectory {
            textField?.stringValue = "Folder"
            
        } else if file.isTrack {
            textField?.stringValue = "Track"
            
        } else if file.isPlaylist {
            textField?.stringValue = "Playlist"
        }
    }
}

extension NSTableView {
    
    func rowForEvent(_ event: NSEvent) -> Int {self.row(at: self.convert(event.locationInWindow, from: nil))}
}
