//
//  FlatPlaylistTableViews.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A customized NSTableView that overrides contextual menu behavior
 */
class AuralPlaylistTableView: NSTableView {
    
    // Enable drag/drop.
    override func awakeFromNib() {
        self.registerForDraggedTypes([.data, .file_URL])
    }
    
    override func menu(for event: NSEvent) -> NSMenu? {
        return menuHandler(for: event)
    }
}

/*
    Custom view for a NSTableView row that displays a single playlist track or group. Customizes the selection look and feel.
 */
class PlaylistRowView: NSTableRowView {
    
    // Draws a fancy rounded rectangle around the selected track in the playlist view
    override func drawSelection(in dirtyRect: NSRect) {
        
        if self.selectionHighlightStyle != .none {
            
            NSBezierPath.fillRoundedRect(self.bounds.insetBy(dx: 1, dy: 0),
                                         radius: 2,
                                         withColor: Colors.Playlist.selectionBoxColor)
        }
    }
}

class BasicFlatPlaylistCellView: NSTableCellView {
    
    // Used to determine whether or not this cell is selected.
    var rowSelectionStateFunction: () -> Bool = {false}
    
    var rowIsSelected: Bool {rowSelectionStateFunction()}
    
    lazy var textFieldConstraintsManager = LayoutConstraintsManager(for: textField!)
    
    func updateText(_ font: NSFont, _ text: String) {
        
        textFont = font
        self.text = text
        textField?.show()
        
        imageView?.hide()
    }
    
    func updateImage(_ image: NSImage) {
        
        self.image = image
        imageView?.show()
        
        textField?.hide()
    }

    // Constraints
    func realignText(yOffset: CGFloat) {

        textFieldConstraintsManager.removeAll(withAttributes: [.bottom])
        textFieldConstraintsManager.setBottom(relatedToBottomOf: self, offset: yOffset)
    }
    
    override var backgroundStyle: NSView.BackgroundStyle {
        didSet {backgroundStyleChanged()}
    }

    // Check if this row is selected, change font and color accordingly
    func backgroundStyleChanged() {
        
        textColor = rowIsSelected ? Colors.Playlist.trackNameSelectedTextColor : Colors.Playlist.trackNameTextColor
        textFont = Fonts.Playlist.trackTextFont
    }
}

/*
    Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
@IBDesignable
class TrackNameCellView: BasicFlatPlaylistCellView {}

/*
    Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
@IBDesignable
class DurationCellView: BasicFlatPlaylistCellView {
    
    override func backgroundStyleChanged() {
        
        let isSelectedRow = rowIsSelected
        
        // Check if this row is selected, change font and color accordingly
        textField?.textColor = isSelectedRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
        textField?.font = Fonts.Playlist.trackTextFont
    }
}

/*
    Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
class IndexCellView: BasicFlatPlaylistCellView {
    
    override func backgroundStyleChanged() {
        
        // Check if this row is selected, change font and color accordingly
        textField?.textColor = rowIsSelected ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
        textField?.font = Fonts.Playlist.trackTextFont
    }
}
