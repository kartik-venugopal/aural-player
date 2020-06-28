import Cocoa

/*
    A customized NSTableView that overrides contextual menu behavior
 */
class AuralPlaylistTableView: NSTableView {
    
    // See extension below
    override func menu(for event: NSEvent) -> NSMenu? {
        return menuHandler(for: event)
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

class FlatPlaylistRowView: NSTableRowView {
    
    // Draws a fancy rounded rectangle around the selected track in the playlist view
    override func drawSelection(in dirtyRect: NSRect) {
        
        if self.selectionHighlightStyle != NSTableView.SelectionHighlightStyle.none {
            
            let selectionRect = self.bounds.insetBy(dx: 1, dy: 0)
            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 2, yRadius: 2)
            
            Colors.Playlist.selectionBoxColor.setFill()
            selectionPath.fill()
        }
    }
}

/*
    A customized NSOutlineView that overrides contextual menu behavior
 */
class AuralPlaylistOutlineView: NSOutlineView {
    
    // TODO - Can these be static so that only one copy is made for all playlists ? Not 3.
    var cachedDisclosureIcon_collapsed: NSImage!
    var cachedDisclosureIcon_expanded: NSImage!
    
    var disclosureButtons: [NSButton] = []
    
    override func awakeFromNib() {
        
        cachedDisclosureIcon_collapsed = Images.imgDisclosure_collapsed.applyingTint(Colors.Playlist.groupDisclosureTriangleColor)
        cachedDisclosureIcon_expanded = Images.imgDisclosure_expanded.applyingTint(Colors.Playlist.groupDisclosureTriangleColor)
    }
    
    // See extension below
    override func menu(for event: NSEvent) -> NSMenu? {
        return menuHandler(for: event)
    }
    
    func changeDisclosureIconColor(_ color: NSColor) {
        
        cachedDisclosureIcon_collapsed = Images.imgDisclosure_collapsed.applyingTint(color)
        cachedDisclosureIcon_expanded = Images.imgDisclosure_expanded.applyingTint(color)
        
        disclosureButtons.forEach({
            $0.image = cachedDisclosureIcon_collapsed
            $0.alternateImage = cachedDisclosureIcon_expanded
        })
    }
    
    // Customize the disclosure triangle image
    override func makeView(withIdentifier identifier: NSUserInterfaceItemIdentifier, owner: Any?) -> NSView? {
        
        let view = super.makeView(withIdentifier: identifier, owner: owner)
        
        if identifier == NSOutlineView.disclosureButtonIdentifier, let disclosureButton = view as? NSButton {
            
            disclosureButton.image = cachedDisclosureIcon_collapsed
            disclosureButton.alternateImage = cachedDisclosureIcon_expanded
            
            disclosureButtons.append(disclosureButton)
        }
        
        return view
    }
}

extension NSTableView {
    
    func enableDragDrop() {
        self.registerForDraggedTypes([.data, .file_URL])
    }
    
    /*
        An event handler for customized contextual menu behavior.
        This function needs to be overriden in order to:
     
        1 - Only display the contextual menu when at least one row is available, and the click occurred within a playlist row view (i.e. not in empty table view space)
        2 - Capture the row for which the contextual menu was requested, and select it
        3 - Disable the row highlight displayed when presenting the contextual menu
     */
    func menuHandler(for event: NSEvent) -> NSMenu? {
        
        // If tableView has no rows, don't show the menu
        if (self.numberOfRows == 0) {
            return nil
        }
        
        // Calculate the clicked row
        let row = self.row(at: self.convert(event.locationInWindow, from: nil))
        
        // If the click occurred outside of any of the playlist rows (i.e. empty space), don't show the menu
        if (row == -1) {
            return nil
        }
        
        // Select the clicked row, implicitly clearing the previous selection
        self.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        
        // Note that this view was clicked (this is required by the contextual menu)
        PlaylistViewContext.noteViewClicked(self)
        
        return self.menu
    }
    
    func pageUp() {
        
        // Determine if the first row currently displayed has been truncated so it is not fully visible
        let visibleRect = self.visibleRect
        
        let firstRowShown = self.rows(in: visibleRect).lowerBound
        let firstRowShownRect = self.rect(ofRow: firstRowShown)
        
        let truncationAmount =  visibleRect.minY - firstRowShownRect.minY
        let truncationRatio = truncationAmount / firstRowShownRect.height
        
        // If the first row currently displayed has been truncated more than 10%, show it again in the next page
        
        let lastRowToShow = truncationRatio > 0.1 ? firstRowShown : firstRowShown - 1
        let lastRowToShowRect = self.rect(ofRow: lastRowToShow)
        
        // Calculate the scroll amount, as a function of the last row to show next, using the visible rect origin (i.e. the top of the first row in the playlist) as the stopping point
        
        let scrollAmount = min(visibleRect.origin.y, visibleRect.maxY - lastRowToShowRect.maxY)
        
        if scrollAmount > 0 {
            
            let up = visibleRect.origin.applying(CGAffineTransform.init(translationX: 0, y: -scrollAmount))
            self.enclosingScrollView?.contentView.scroll(to: up)
        }
    }
    
    func pageDown() {
        
        // Determine if the last row currently displayed has been truncated so it is not fully visible
        let visibleRect = self.visibleRect
        let visibleRows = self.rows(in: visibleRect)
        
        let lastRowShown = visibleRows.lowerBound + visibleRows.length - 1
        let lastRowShownRect = self.rect(ofRow: lastRowShown)
        
        let lastRowInPlaylistRect = self.rect(ofRow: self.numberOfRows - 1)
        
        // If the first row currently displayed has been truncated more than 10%, show it again in the next page
        
        let truncationAmount = lastRowShownRect.maxY - visibleRect.maxY
        let truncationRatio = truncationAmount / lastRowShownRect.height
        
        let firstRowToShow = truncationRatio > 0.1 ? lastRowShown : lastRowShown + 1
        let firstRowToShowRect = self.rect(ofRow: firstRowToShow)
        
        // Calculate the scroll amount, as a function of the first row to show next, using the visible rect maxY (i.e. the bottom of the last row in the playlist) as the stopping point

        let scrollAmount = min(firstRowToShowRect.origin.y - visibleRect.origin.y, lastRowInPlaylistRect.maxY - visibleRect.maxY)
        
        if scrollAmount > 0 {
            
            let down = visibleRect.origin.applying(CGAffineTransform.init(translationX: 0, y: scrollAmount))
            self.enclosingScrollView?.contentView.scroll(to: down)
        }
    }
}

class BasicFlatPlaylistCellView: NSTableCellView {
    
    // The table view row that this cell is contained in. Used to determine whether or not this cell is selected.
    var row: Int = -1
    
    // TODO: Store this logic in a closure passed in by the view delegate, instead of using TableViewHolder
    var isSelRow: Bool {
        return TableViewHolder.instance!.selectedRowIndexes.contains(row)
    }
    
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            backgroundStyleChanged()
        }
    }
    
    func backgroundStyleChanged() {
        
        // Check if this row is selected, change font and color accordingly
        if let textField = self.textField {
            
            textField.textColor = isSelRow ? Colors.Playlist.trackNameSelectedTextColor : Colors.Playlist.trackNameTextColor
            textField.font = Fonts.Playlist.trackNameFont
        }
    }
    
    func placeTextFieldOnTop() {
        
        let textField = self.textField!
        
        for con in self.constraints {
            
            if con.firstItem === textField && con.firstAttribute == .top {
                
                con.isActive = false
                self.removeConstraint(con)
                break
            }
        }
        
        // textField.top == self.top
        let textFieldOnTopConstraint = NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: -2)
        textFieldOnTopConstraint.isActive = true
        self.addConstraint(textFieldOnTopConstraint)
    }
    
    func placeTextFieldBelowView(_ view: NSView) {
        
        let textField = self.textField!
        
        for con in self.constraints {
            
            if con.firstItem === textField && con.firstAttribute == .top {
                
                con.isActive = false
                self.removeConstraint(con)
                break
            }
        }
        
        let textFieldBelowViewConstraint = NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -2)
        textFieldBelowViewConstraint.isActive = true
        self.addConstraint(textFieldBelowViewConstraint)
    }
}

/*
 Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
@IBDesignable
class TrackNameCellView: BasicFlatPlaylistCellView {
    
    @IBInspectable @IBOutlet weak var gapBeforeImg: NSImageView!
    @IBInspectable @IBOutlet weak var gapAfterImg: NSImageView!
}

/*
 Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
@IBDesignable
class DurationCellView: BasicFlatPlaylistCellView {
    
    @IBInspectable @IBOutlet weak var gapBeforeTextField: NSTextField!
    @IBInspectable @IBOutlet weak var gapAfterTextField: NSTextField!
    
    override func backgroundStyleChanged() {
        
        // Check if this row is selected, change font and color accordingly
        if let textField = self.textField {
            
            textField.textColor = isSelRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
            textField.font = Fonts.Playlist.indexFont
        }
    }
    
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            
            // Check if this row is selected
//            backgroundStyleChanged()
            
            if let gapField = self.gapBeforeTextField {
                
                gapField.textColor = isSelRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
                gapField.font = Fonts.Playlist.indexFont
            }
            
            if let gapField = self.gapAfterTextField {
                
                gapField.textColor = isSelRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
                gapField.font = Fonts.Playlist.indexFont
            }
        }
    }
    
    override func placeTextFieldOnTop() {
        
        let textField = self.textField!
        
        for con in self.constraints {
            
            if con.firstItem === textField && con.firstAttribute == .top {
                
                con.isActive = false
                self.removeConstraint(con)
                break
            }
        }
        
        // textField.top == self.top
        let textFieldOnTopConstraint = NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: -2)
        textFieldOnTopConstraint.isActive = true
        self.addConstraint(textFieldOnTopConstraint)
    }
    
    override func placeTextFieldBelowView(_ view: NSView) {
        
        let textField = self.textField!
        
        for con in self.constraints {
            
            if con.firstItem === textField && con.firstAttribute == .top {
                
                con.isActive = false
                self.removeConstraint(con)
                break
            }
        }
        
        let textFieldBelowViewConstraint = NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: -2)
        textFieldBelowViewConstraint.isActive = true
        self.addConstraint(textFieldBelowViewConstraint)
    }
}

/*
 Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
class IndexCellView: BasicFlatPlaylistCellView {
    
    override func backgroundStyleChanged() {
        
        // Check if this row is selected, change font and color accordingly
        if let textField = self.textField {
            
            textField.textColor = isSelRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
            textField.font = Fonts.Playlist.indexFont
        }
    }
    
    func adjustIndexConstraints_beforeGapOnly() {
        
        let textField = self.textField!
        let imgView = self.imageView!
        
        for con in self.constraints {
            
            if con.firstItem === textField && con.firstAttribute == .centerY {
                con.isActive = false
                self.removeConstraint(con)
            }
            
            if con.firstItem === imgView && con.firstAttribute == .centerY {
                con.isActive = false
                self.removeConstraint(con)
            }
        }
        
        let indexTF = NSLayoutConstraint(item: textField, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -14.5)
        indexTF.isActive = true
        self.addConstraint(indexTF)
        
        let indexIV = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -12)
        indexIV.isActive = true
        self.addConstraint(indexIV)
    }
    
    func adjustIndexConstraints_afterGapOnly() {
        
        let textField = self.textField!
        let imgView = self.imageView!
        
        for con in self.constraints {
            
            if con.firstItem === textField && con.firstAttribute == .centerY {
                
                con.isActive = false
                self.removeConstraint(con)
            }
            
            if con.firstItem === imgView && con.firstAttribute == .centerY {
                
                con.isActive = false
                self.removeConstraint(con)
            }
        }
        
        let indexTF = NSLayoutConstraint(item: textField, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 10.5)
        indexTF.isActive = true
        self.addConstraint(indexTF)
        
        let indexIV = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -30)
        indexIV.isActive = true
        self.addConstraint(indexIV)
    }
    
    func adjustIndexConstraints_centered() {
        
        let textField = self.textField!
        let imgView = self.imageView!
        
        for con in self.constraints {
            
            if con.firstItem === textField && con.firstAttribute == .centerY {
                
                con.isActive = false
                self.removeConstraint(con)
            }
            
            if con.firstItem === imageView && con.firstAttribute == .centerY {
                
                con.isActive = false
                self.removeConstraint(con)
            }
        }
        
        let indexTF = NSLayoutConstraint(item: textField, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: -2)
        indexTF.isActive = true
        self.addConstraint(indexTF)
        
        let indexIV = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        indexIV.isActive = true
        self.addConstraint(indexIV)
    }
}

@IBDesignable
class GroupedTrackNameCellView: NSTableCellView {
    
    // The table view row that this cell is contained in. Used to determine whether or not this cell is selected.
    var row: Int = -1
    
    @IBInspectable @IBOutlet weak var gapBeforeImg: NSImageView!
    @IBInspectable @IBOutlet weak var gapAfterImg: NSImageView!
    
    // Whether or not this cell is contained within a row that represents a group (as opposed to a track)
    var isGroup: Bool = false
    
    // This is used to determine which NSOutlineView contains this cell
    var playlistType: PlaylistType = .artists
    
    // The item represented by the row containing this cell
    var item: PlaylistItem?
    
    // When the background changes (as a result of selection/deselection) switch to the appropriate colors/fonts
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            
            // Check if this row is selected
            let outlineView = OutlineViewHolder.instances[self.playlistType]!
            let isSelRow = outlineView.selectedRowIndexes.contains(outlineView.row(forItem: item))
            
            if let textField = self.textField {
                
                textField.textColor = isSelRow ? (isGroup ? Colors.Playlist.groupNameSelectedTextColor : Colors.Playlist.trackNameSelectedTextColor)
                    : (isGroup ? Colors.Playlist.groupNameTextColor : Colors.Playlist.trackNameTextColor)
                
                textField.font = isGroup ? Fonts.Playlist.groupNameFont : Fonts.Playlist.trackNameFont
            }
        }
    }
}

/*
 Custom view for a single NSTableView cell. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
class GroupedTrackDurationCellView: NSTableCellView {
    
    // Whether or not this cell is contained within a row that represents a group (as opposed to a track)
    var isGroup: Bool = false
    
    // This is used to determine which NSOutlineView contains this cell
    var playlistType: PlaylistType = .artists
    
    // The item represented by the row containing this cell
    var item: PlaylistItem?
    
    @IBInspectable @IBOutlet weak var gapBeforeTextField: NSTextField!
    @IBInspectable @IBOutlet weak var gapAfterTextField: NSTextField!
    
    // When the background changes (as a result of selection/deselection) switch to the appropriate colors/fonts
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            
            // Check if this row is selected
            let outlineView = OutlineViewHolder.instances[self.playlistType]!
            let isSelRow = outlineView.selectedRowIndexes.contains(outlineView.row(forItem: item))
            
            if let textField = self.textField {
                
                textField.textColor = isSelRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
                
                textField.font = isGroup ? Fonts.Playlist.groupDurationFont : Fonts.Playlist.indexFont
            }
            
            if !isGroup {
            
                if let gapField = self.gapBeforeTextField {
                    
                    gapField.textColor = isSelRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
                    gapField.font = Fonts.Playlist.indexFont
                }
                
                if let gapField = self.gapAfterTextField {
                    
                    gapField.textColor = isSelRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
                    gapField.font = Fonts.Playlist.indexFont
                }
            }
        }
    }
}

/*
 Custom view for a NSTableView row that displays a single playlist track or group. Customizes the selection look and feel.
 */
class GroupingPlaylistRowView: NSTableRowView {
    
    // Draws a fancy rounded rectangle around the selected track in the playlist view
    override func drawSelection(in dirtyRect: NSRect) {
        
        if self.selectionHighlightStyle != NSTableView.SelectionHighlightStyle.none {
            
            let selectionRect = self.bounds.insetBy(dx: 1, dy: 0)
            let selectionPath = NSBezierPath.init(roundedRect: selectionRect, xRadius: 2, yRadius: 2)
            
            Colors.Playlist.selectionBoxColor.setFill()
            selectionPath.fill()
        }
    }
}

// Utility class to hold NSOutlineView instances for convenient access
class OutlineViewHolder {
    
    // Mapping of playlist types to their corresponding outline views
    static var instances = [PlaylistType: NSOutlineView]()
}

class BasicTableCellView: NSTableCellView {
    
    var selectionFunction: (() -> Bool) = {() -> Bool in return false}
    
    var textFont: NSFont = Fonts.Constants.mainFont_10
    var selectedTextFont: NSFont = Fonts.Constants.mainFont_10
    
    var textColor: NSColor = Colors.playlistTextColor
    var selectedTextColor: NSColor = Colors.playlistSelectedTextColor
    
    var isSelRow: Bool {
        return selectionFunction()
    }
    
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            backgroundStyleChanged()
        }
    }
    
    func backgroundStyleChanged() {
        
        // Check if this row is selected, change font and color accordingly
        if let textField = self.textField {
            
            textField.textColor = isSelRow ?  selectedTextColor : textColor
            textField.font = isSelRow ? selectedTextFont : textFont
        }
    }
}

// Utility class to hold an NSTableView instance for convenient access
class TableViewHolder {
    
    static var instance: NSTableView?
}

extension NSPasteboard.PasteboardType {

    // Enables drag/drop reordering of playlist rows
    static let data: NSPasteboard.PasteboardType = NSPasteboard.PasteboardType(rawValue: String(kUTTypeData))
    
    // Enables drag/drop adding of tracks into the playlist from Finder
    static let file_URL: NSPasteboard.PasteboardType = NSPasteboard.PasteboardType(rawValue: String(kUTTypeFileURL))
}
