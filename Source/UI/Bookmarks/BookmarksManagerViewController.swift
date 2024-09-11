//
//  BookmarksManagerViewController.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class BookmarksManagerViewController: NSViewController {
    
    override var nibName: NSNib.Name? {"BookmarksManager"}
    
    @IBOutlet weak var containerBox: NSBox!
    
    @IBOutlet weak var lblCaption: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var lblSummary: NSTextField!
    
    lazy var messenger: Messenger = .init(for: self)
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        updateSummary()
        
        fontSchemesManager.registerObserver(self)
        
        colorSchemesManager.registerSchemeObserver(self)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.backgroundColor, changeReceivers: [containerBox, tableView])
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.captionTextColor, changeReceiver: lblCaption)
        colorSchemesManager.registerPropertyObserver(self, forProperty: \.secondaryTextColor, changeReceiver: lblSummary)
        
        messenger.subscribe(to: .Bookmarks.added, handler: updateSummary)
        messenger.subscribe(to: .Bookmarks.removed, handler: updateSummary)
    }
    
    func updateSummary() {
        
        let numBookmarks = bookmarksDelegate.count
        lblSummary.stringValue = "\(numBookmarks)  \(numBookmarks == 1 ? "bookmark" : "bookmarks")"
    }
    
    @IBAction func playSelectedBookmarkAction(_ sender: Any) {
        
        let index = tableView.selectedRow
        guard index >= 0 else {return}
        
        do {
            try bookmarksDelegate.playBookmark(bookmarksDelegate[index])
        } catch {
            // TODO: Log the error
        }
    }
}

extension BookmarksManagerViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        30
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {bookmarksDelegate.count}
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        AuralTableRowView()
    }

//    override func renamePreset(named name: String, to newName: String) {
//        bookmarksDelegate.renameBookmark(named: name, to: newName)
//    }
//    
    // MARK: View delegate functions
    
    // Returns a view for a single column
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let column = tableColumn else {return nil}
        let colID = column.identifier
        
        let bookmark = bookmarksDelegate[row]
        
        switch colID {
            
        case .cid_bookmarkNameColumn:
            
            return createNameCell(tableView, column, row, bookmark.name)
            
        case .cid_bookmarkTrackColumn:
            
            return createTrackCell(tableView, column, row, bookmark.track)
            
        case .cid_bookmarkStartPositionColumn:
            
            return createTimeCell(tableView, column, row, time: bookmark.startPosition)

        case .cid_bookmarkEndPositionColumn:
            
            return createTimeCell(tableView, column, row, time: bookmark.endPosition)
//
//            var formattedPosition: String = ""
//            
//            if let endPos = bookmark.endPosition {
//                formattedPosition = ValueFormatter.formatSecondsToHMS(endPos)
//            } else {
//                formattedPosition = "-"
//            }
//            
//            return createTextCell(tableView, tableColumn!, row, formattedPosition, false)
//            
        default:    return nil
        }
    }
    
    // Creates a cell view containing text
    func createNameCell(_ tableView: NSTableView, _ column: NSTableColumn, _ row: Int, _ name: String) -> AuralTableCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: column.identifier, owner: nil) as? AuralTableCellView,
              let textField = cell.textField else {return nil}
        
        // Name column is editable
        textField.delegate = self
        
        let builder = TableCellBuilder()
        
        builder.withAttributedText(strings: [(text: name,
                                              font: systemFontScheme.normalFont,
                                              color: systemColorScheme.primaryTextColor)],
                                   selectedTextColors: [systemColorScheme.primarySelectedTextColor],
                                   bottomYOffset: systemFontScheme.tableYOffset)
        
        return builder.buildCell(forTableView: tableView, forColumnWithId: column.identifier, inRow: row)
    }
    
    // Creates a cell view containing text
    func createTrackCell(_ tableView: NSTableView, _ column: NSTableColumn, _ row: Int, _ track: Track) -> AuralTableCellView? {
        
        let builder = TableCellBuilder()
        let titleAndArtist = track.titleAndArtist
        
//        if let artist = titleAndArtist.artist {
//            
//            builder.withAttributedText(strings: [(text: artist + "  ", font: systemFontScheme.normalFont, color: systemColorScheme.secondaryTextColor),
//                                                        (text: titleAndArtist.title, font: systemFontScheme.normalFont, color: systemColorScheme.primaryTextColor)],
//                                              selectedTextColors: [systemColorScheme.secondarySelectedTextColor, systemColorScheme.primarySelectedTextColor],
//                                              bottomYOffset: systemFontScheme.tableYOffset)
//            
//        } else {
            
            builder.withAttributedText(strings: [(text: titleAndArtist.title,
                                                         font: systemFontScheme.normalFont,
                                                         color: systemColorScheme.primaryTextColor)], selectedTextColors: [systemColorScheme.primarySelectedTextColor],
                                              bottomYOffset: systemFontScheme.tableYOffset)
//        }
        
        builder.withImage(image: track.art?.downscaledOrOriginalImage ?? .imgPlayingArt)
        
        let cell = builder.buildCell(forTableView: tableView, forColumnWithId: column.identifier, inRow: row)
        cell?.textField?.lineBreakMode = .byTruncatingTail
        return cell
    }
    
    func createTimeCell(_ tableView: NSTableView, _ column: NSTableColumn, _ row: Int, time: Double?) -> AuralTableCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: column.identifier, owner: nil) as? AuralTableCellView else {return nil}
        
        let timeText: String
        
        if let time = time {
            timeText = ValueFormatter.formatSecondsToHMS(time)
        } else {
            timeText = "-"
        }
        
        let builder = TableCellBuilder()
        
        builder.withAttributedText(strings: [(text: timeText,
                                              font: systemFontScheme.normalFont,
                                              color: systemColorScheme.primaryTextColor)],
                                   selectedTextColors: [systemColorScheme.primarySelectedTextColor],
                                   bottomYOffset: systemFontScheme.tableYOffset)
        
        return builder.buildCell(forTableView: tableView, forColumnWithId: column.identifier, inRow: row)
    }
}

extension BookmarksManagerViewController: NSTextFieldDelegate {
    
    // Renames the selected preset.
    func controlTextDidEndEditing(_ obj: Notification) {
        
        let rowIndex = tableView.selectedRow
        let rowView = tableView.rowView(atRow: rowIndex, makeIfNecessary: true)

        guard let cell = rowView?.view(atColumn: 0) as? NSTableCellView,
              let editedTextField = cell.textField as? EditableTextField else {return}
        
        let oldPresetName = bookmarksDelegate[rowIndex].name
        let newPresetName = editedTextField.stringValue
        
        editedTextField.restoreTextColor()
        
        // No change in preset name. Nothing to be done.
        if newPresetName == oldPresetName {return}
        
        // Empty string is invalid, revert to old value
//        if newPresetName.isEmptyAfterTrimming {
//
//            editedTextField.stringValue = oldPresetName
//
//            _ = DialogsAndAlerts.genericErrorAlert("Can't rename preset", "Preset name must have at least one non-whitespace character.", "Please type a valid name.").showModal()
//
//        } else if presetExists(named: newPresetName) {
//
//            // Another theme with that name exists, can't rename
//            editedTextField.stringValue = oldPresetName
//
//            _ = DialogsAndAlerts.genericErrorAlert("Can't rename preset", "Another preset with that name already exists.", "Please type a unique name.").showModal()
//
//        } else {
//
//            // Update the preset name
//            renamePreset(named: oldPresetName, to: newPresetName)
//        }
    }
}

extension BookmarksManagerViewController: FontSchemeObserver {
    
    func fontSchemeChanged() {
        
        lblCaption.font = systemFontScheme.captionFont
        lblSummary.font = systemFontScheme.smallFont
    }
}

extension BookmarksManagerViewController: ColorSchemeObserver {
    
    func colorSchemeChanged() {
        
        lblCaption.textColor = systemColorScheme.captionTextColor
        lblSummary.textColor = systemColorScheme.secondaryTextColor
    }
}

fileprivate extension NSUserInterfaceItemIdentifier {
    
    // Table view column identifiers
    
    static let cid_bookmarkNameColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_BookmarkName")
    static let cid_bookmarkTrackColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_BookmarkTrack")
    static let cid_bookmarkStartPositionColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_BookmarkStartPosition")
    static let cid_bookmarkEndPositionColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_BookmarkEndPosition")
}
