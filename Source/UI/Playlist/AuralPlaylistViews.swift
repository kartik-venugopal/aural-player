//
//  AuralPlaylistViews.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

extension NSTableView {
    
    /*
        An event handler for customized contextual menu behavior.
        This function needs to be overriden in order to:
     
        1 - Only display the contextual menu when at least one row is available, and the click occurred within a playlist row view (i.e. not in empty table view space)
        2 - Capture the row for which the contextual menu was requested, and select it
        3 - Disable the row highlight displayed when presenting the contextual menu
     */
    func menuHandler(for event: NSEvent) -> NSMenu? {
        
        // If tableView has no rows, don't show the menu
        if self.numberOfRows == 0 {return nil}
        
        // Calculate the clicked row
        let row = self.row(at: self.convert(event.locationInWindow, from: nil))
        
        // If the click occurred outside of any of the playlist rows (i.e. empty space), don't show the menu
        if row == -1 {return nil}
        
        // Select the clicked row, implicitly clearing the previous selection
        self.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        
        // TODO: Shouldn't this be moved to AuralPlaylistTableView and AuralPlaylistOutlineView ?
        // Note that this view was clicked (this is required by the contextual menu)
        PlaylistViewState.registerTableViewClick(self)
        
        return self.menu
    }
}

/*
    Custom view for a NSTableView row that displays a single playlist track. Customizes the selection look and feel.
 */
class GenericTableRowView: NSTableRowView {
    
    // Draws a fancy rounded rectangle around the selected track in the playlist view
    override func drawSelection(in dirtyRect: NSRect) {
        
        if self.selectionHighlightStyle != NSTableView.SelectionHighlightStyle.none {
            
            let selectionRect = self.bounds.insetBy(dx: 1, dy: 0)
            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 2, yRadius: 2)
            
            Colors.playlistSelectionBoxColor.setFill()
            selectionPath.fill()
        }
    }
}

class BasicTableCellView: NSTableCellView {
    
    var rowSelectionStateFunction: () -> Bool = {false}
    
    var textFont: NSFont = Fonts.Standard.mainFont_10
    var selectedTextFont: NSFont = Fonts.Standard.mainFont_10
    
    var textColor: NSColor = Colors.defaultLightTextColor
    var selectedTextColor: NSColor = Colors.defaultSelectedLightTextColor
    
    var rowIsSelected: Bool {rowSelectionStateFunction()}
    
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            backgroundStyleChanged()
        }
    }
    
    func backgroundStyleChanged() {
        
        let isSelectedRow = rowIsSelected
        
        // Check if this row is selected, change font and color accordingly
        textField?.textColor = isSelectedRow ?  selectedTextColor : textColor
        textField?.font = isSelectedRow ? selectedTextFont : textFont
    }
}

extension NSUserInterfaceItemIdentifier {
    
    // Playlist view column identifiers
    
    static let uid_index: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Index")
    
    static let uid_trackName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Name")
    
    static let uid_duration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Duration")
    
    static let uid_chapterIndex: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_chapterIndex")
    
    static let uid_chapterTitle: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_chapterTitle")
    
    static let uid_chapterStartTime: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_chapterStartTime")
    
    static let uid_chapterDuration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_chapterDuration")
}
