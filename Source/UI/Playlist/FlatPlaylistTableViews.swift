import Cocoa

/*
    A customized NSTableView that overrides contextual menu behavior
 */
class AuralPlaylistTableView: NSTableView {
    
    override func menu(for event: NSEvent) -> NSMenu? {
        return menuHandler(for: event)
    }
}

// Utility class to hold an NSTableView instance for convenient access
class TableViewHolder {
    
    static var instance: NSTableView?
}

/*
    Custom view for a NSTableView row that displays a single playlist track or group. Customizes the selection look and feel.
 */
class PlaylistRowView: NSTableRowView {
    
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

class BasicFlatPlaylistCellView: NSTableCellView {
    
    // The table view row that this cell is contained in. Used to determine whether or not this cell is selected.
    var row: Int = -1
    
    // TODO: Store this logic in a closure passed in by the view delegate, instead of using TableViewHolder
    var isSelRow: Bool {
        return TableViewHolder.instance!.selectedRowIndexes.contains(row)
    }
    
    func updateText(_ font: NSFont, _ text: String) {
        
        textField?.font = font
        textField?.stringValue = text
        textField?.show()
        
        imageView?.hide()
    }
    
    func updateImage(_ image: NSImage) {
        
        imageView?.image = image
        imageView?.show()
        
        textField?.hide()
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
    
    var gapImage: NSImage!
    
    @IBInspectable @IBOutlet weak var gapBeforeImg: NSImageView!
    @IBInspectable @IBOutlet weak var gapAfterImg: NSImageView!
    
    func updateForGaps(_ gapBeforeTrack: Bool, _ gapAfterTrack: Bool) {

        gapBeforeImg.image = gapBeforeTrack ? gapImage : nil
        gapBeforeImg.showIf(gapBeforeTrack)

        gapAfterImg.image = gapAfterTrack ? gapImage : nil
        gapAfterImg.showIf(gapAfterTrack)

        gapBeforeTrack ? placeTextFieldBelowView(gapBeforeImg) : placeTextFieldOnTop()
    }
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
        textField?.textColor = isSelRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
        textField?.font = Fonts.Playlist.indexFont
    }
    
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            
            gapBeforeTextField.textColor = isSelRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
            gapBeforeTextField.font = Fonts.Playlist.indexFont
        
            gapAfterTextField.textColor = isSelRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
            gapAfterTextField.font = Fonts.Playlist.indexFont
        }
    }
    
    func updateForGaps(_ gapBeforeTrack: Bool, _ gapAfterTrack: Bool, _ gapBeforeDuration: Double?, _ gapAfterDuration: Double?) {
        
        gapBeforeTextField.showIf(gapBeforeTrack)
        gapBeforeTextField.stringValue = gapBeforeTrack ? ValueFormatter.formatSecondsToHMS(gapBeforeDuration!) : ""
        
        gapAfterTextField.showIf(gapAfterTrack)
        gapAfterTextField.stringValue = gapAfterTrack ? ValueFormatter.formatSecondsToHMS(gapAfterDuration!) : ""
        
        gapBeforeTrack ? placeTextFieldBelowView(gapBeforeTextField) : placeTextFieldOnTop()
    }
    
    override func placeTextFieldOnTop() {
        
        if let textField = self.textField {
            
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
    
    func updateForGaps(_ gapBeforeTrack: Bool, _ gapAfterTrack: Bool) {

        switch (gapBeforeTrack, gapAfterTrack) {

        case (false, false), (true, true):
            
            adjustIndexConstraints_centered()
            
        case (false, true):

            adjustIndexConstraints_afterGapOnly()

        case (true, false):
            
            adjustIndexConstraints_beforeGapOnly()
        }
    }
    
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
