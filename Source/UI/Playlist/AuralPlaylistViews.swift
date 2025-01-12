//
//  AuralPlaylistViews.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    Custom view for a NSTableView row that displays a single playlist track. Customizes the selection look and feel.
 */
class GenericTableRowView: NSTableRowView {
    
    // Draws a fancy rounded rectangle around the selected track in the playlist view
    override func drawSelection(in dirtyRect: NSRect) {
        
        if self.selectionHighlightStyle != .none {
            
            NSBezierPath.fillRoundedRect(self.bounds.insetBy(dx: 1, dy: 0),
                                         radius: 2,
                                         withColor: .playlistSelectionBoxColor)
        }
    }
}

class BasicTableCellView: NSTableCellView {
    
    var rowSelectionStateFunction: () -> Bool = {false}
    
    var unselectedTextColor: NSColor = .defaultLightTextColor
    var selectedTextColor: NSColor = .defaultSelectedLightTextColor
    
    var rowIsSelected: Bool {rowSelectionStateFunction()}
    
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            backgroundStyleChanged()
        }
    }
    
    func backgroundStyleChanged() {
        
        let isSelectedRow = rowIsSelected
        
        // Check if this row is selected, change font and color accordingly
        textColor = isSelectedRow ?  selectedTextColor : unselectedTextColor
    }
}

extension NSUserInterfaceItemIdentifier {
    
    // Playlist view column identifiers
    
    static let cid_art: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Art")
    
    static let cid_index: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Index")
    
    static let cid_trackName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Name")
    
    static let cid_fileName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_FileName")
    
    static let cid_title: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Title")
    
    static let cid_artist: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Artist")
    
    static let cid_album: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Album")
    
    static let cid_genre: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Genre")
    
    static let cid_trackNum: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_TrackNum")
    
    static let cid_discNum: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_DiscNum")
    
    static let cid_year: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Year")
    
    static let cid_duration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Duration")
    
    static let cid_format: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Format")
    
    static let cid_playCount: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_PlayCount")
    
    static let cid_lastPlayed: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_LastPlayed")
    
    static let cid_chapterIndex: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_chapterIndex")
    
    static let cid_chapterTitle: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_chapterTitle")
    
    static let cid_chapterStartTime: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_chapterStartTime")
    
    static let cid_chapterDuration: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_chapterDuration")
    
    static let cid_lyricsLine: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_LyricsLine")
}
