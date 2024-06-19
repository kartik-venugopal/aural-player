//
//  FlatPlaylistTableViews.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A customized NSTableView that overrides contextual menu behavior
 */
class AuralTableView: NSTableView {
    
    // Flag that indicates whether or not this view is currently tracking mouse movements.
    private(set) var isTracking: Bool = false
    
    // Enable drag/drop.
    override func awakeFromNib() {
        
        super.awakeFromNib()
        enableDragDrop()
    }
    
    // Signals the view to start tracking mouse movements.
    func startTracking() {
        
        self.removeAllTrackingAreas()
        
        isTracking = true
        self.updateTrackingAreas()
    }
    
    // Signals the view to stop tracking mouse movements.
    func stopTracking() {
        
        isTracking = false
        self.removeAllTrackingAreas()
    }
 
    override func updateTrackingAreas() {
        
        if isTracking && self.trackingAreas.isEmpty {
        
            // Create a tracking area that covers the bounds of the view. It should respond whenever the mouse enters or exits.
            addTrackingArea(NSTrackingArea(rect: self.bounds, options: [.activeAlways, .mouseEnteredAndExited, .mouseMoved], owner: self, userInfo: nil))
            
            super.updateTrackingAreas()
        }
    }
    
    override func menu(for event: NSEvent) -> NSMenu? {
        menuHandler(for: event)
    }
    
    // TODO: Rethink the right-click menu for playlists (should have different menus for single item / multi-item / empty selections)
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
        
        // If the current selection doesn't contain the right-clicked row, select it.
        if !selectedRowIndexes.contains(row) {
            selectRow(row)
        }
        
        // TODO: Shouldn't this be moved to AuralPlaylistTableView and AuralPlaylistOutlineView ?
        // Note that this view was clicked (this is required by the contextual menu)
//        uiState.registerTableViewClick(self)
        
        return self.menu
    }
    
    override func reloadData() {
        
//        if self.identifier?.rawValue == "tid_PlayQueueSimpleView" {
//            print("Reloading data for: \(self.identifier?.rawValue ?? "<???>")")
//        }
        
        super.reloadData()
    }
}

/*
    Custom view for a NSTableView row that displays a single playlist track or group. Customizes the selection look and feel.
 */
class AuralTableRowView: NSTableRowView {
    
    // Draws a fancy rounded rectangle around the selected track in the playlist view
    override func drawSelection(in dirtyRect: NSRect) {
        
        if selectionHighlightStyle != .none {
            
            NSBezierPath.fillRoundedRect(bounds.insetBy(dx: 1, dy: 0),
                                         radius: 3,
                                         withColor: systemColorScheme.textSelectionColor)
        }
    }
}

class AuralTableCellView: NSTableCellView {
    
    // Used to determine whether or not this cell is selected.
    var rowSelectionStateFunction: () -> Bool = {false}
    
    var rowIsSelected: Bool {rowSelectionStateFunction()}
    
    var unselectedTextColor: NSColor?
    var unselectedAttributedText: NSAttributedString?
    
    var selectedTextColor: NSColor?
    var selectedAttributedText: NSAttributedString?
    
    lazy var textFieldConstraintsManager = LayoutConstraintsManager(for: textField!)
    
    func updateText(_ font: NSFont, _ text: String) {
        
        textFont = font
        self.text = text
        textField?.show()
        
        imageView?.hide()
    }
    
    // Constraints
    func realignTextBottom(yOffset: CGFloat) {

        textFieldConstraintsManager.removeAll(withAttributes: [.bottom])
        textFieldConstraintsManager.setBottom(relatedToBottomOf: self, offset: yOffset)
    }
    
    // Constraints
    func realignTextCenterY(yOffset: CGFloat) {

        textFieldConstraintsManager.removeAll(withAttributes: [.centerY])
        textFieldConstraintsManager.centerVerticallyInSuperview(offset: yOffset)
    }
    
    override var backgroundStyle: NSView.BackgroundStyle {
        didSet {backgroundStyleChanged()}
    }

    // Check if this row is selected, change font and color accordingly
    func backgroundStyleChanged() {
        
        if rowIsSelected {

            if let selectedTextColor = self.selectedTextColor {
                textColor = selectedTextColor
                
            } else if let selectedAttributedText = self.selectedAttributedText {
                attributedText = selectedAttributedText
            }
            
        } else {
            
            if let unselectedTextColor = self.unselectedTextColor {
                textColor = unselectedTextColor
                
            } else if let unselectedAttributedText = self.unselectedAttributedText {
                attributedText = unselectedAttributedText
            }
            
        }
    }
}

/*
    Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
@IBDesignable
class TrackNameCellView: AuralTableCellView {}

/*
    Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
@IBDesignable
class DurationCellView: AuralTableCellView {
    
    override func backgroundStyleChanged() {
        
//        let isSelectedRow = rowIsSelected
//
//        // Check if this row is selected, change font and color accordingly
//        textField?.textColor = isSelectedRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
        textField?.font = systemFontScheme.normalFont
    }
}

/*
    Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
class IndexCellView: AuralTableCellView {
    
    override func backgroundStyleChanged() {
        
        // Check if this row is selected, change font and color accordingly
//        textField?.textColor = rowIsSelected ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
        textField?.font = systemFontScheme.normalFont
    }
}
