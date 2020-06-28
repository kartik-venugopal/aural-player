import Cocoa

/*
    A customized NSOutlineView that overrides contextual menu behavior
 */
class AuralPlaylistOutlineView: NSOutlineView {
    
    // TODO - Can these be static so that only one copy is made for all playlists ? Not 3.
    static var cachedDisclosureIcon_collapsed: NSImage!
    static var cachedDisclosureIcon_expanded: NSImage!
    
    static var cachedGroupIcon: NSImage!
    static var cachedGapImage: NSImage!
    
    static var disclosureButtons: [NSButton] = []
    
    static func updateCachedImages() {
        
        cachedDisclosureIcon_collapsed = Images.imgDisclosure_collapsed.applyingTint(Colors.Playlist.groupDisclosureTriangleColor)
        cachedDisclosureIcon_expanded = Images.imgDisclosure_expanded.applyingTint(Colors.Playlist.groupDisclosureTriangleColor)
        
        cachedGroupIcon = Images.imgGroup.applyingTint(Colors.Playlist.groupIconColor)
        cachedGapImage = Images.imgGap.applyingTint(Colors.Playlist.trackNameTextColor)
    }
    
    static func changeDisclosureTriangleColor(_ color: NSColor) {
        
        cachedDisclosureIcon_collapsed = Images.imgDisclosure_collapsed.applyingTint(color)
        cachedDisclosureIcon_expanded = Images.imgDisclosure_expanded.applyingTint(color)
        
        for button in disclosureButtons {
            
            button.image = cachedDisclosureIcon_collapsed
            button.alternateImage = cachedDisclosureIcon_expanded
        }
    }
    
    static func changeGroupIconColor(_ color: NSColor) {
        cachedGroupIcon = Images.imgGroup.applyingTint(color)
    }
    
    static func changeGapIndicatorColor(_ color: NSColor) {
        cachedGapImage = Images.imgGap.applyingTint(Colors.Playlist.trackNameTextColor)
    }
    
    override func menu(for event: NSEvent) -> NSMenu? {
        return menuHandler(for: event)
    }
    
    // Customize the disclosure triangle image
    override func makeView(withIdentifier identifier: NSUserInterfaceItemIdentifier, owner: Any?) -> NSView? {
        
        let view = super.makeView(withIdentifier: identifier, owner: owner)
        
        if identifier == NSOutlineView.disclosureButtonIdentifier, let disclosureButton = view as? NSButton {
            
            disclosureButton.image = Self.cachedDisclosureIcon_collapsed
            disclosureButton.alternateImage = Self.cachedDisclosureIcon_expanded
            
            Self.disclosureButtons.append(disclosureButton)
        }
        
        return view
    }
}

class GroupedItemCellView: NSTableCellView {
    
    // Whether or not this cell is contained within a row that represents a group (as opposed to a track)
    var isGroup: Bool = false
    
    // This is used to determine which NSOutlineView contains this cell
    var playlistType: PlaylistType = .artists
    
    // The item represented by the row containing this cell
    var item: PlaylistItem?
    
    func updateText(_ font: NSFont, _ text: String) {
        
        textField?.font = font
        textField?.stringValue = text
        textField?.show()
    }
    
    func adjustConstraints_mainFieldCentered() {
        
        let main = self.textField!
        
        for con in self.constraints {
            
            if con.firstItem === main && (con.firstAttribute == .top || con.firstAttribute == .centerY) {
                
                con.isActive = false
                self.removeConstraint(con)
            }
            
            if con.secondItem === main && (con.secondAttribute == .top || con.secondAttribute == .centerY) {
                
                con.isActive = false
                self.removeConstraint(con)
            }
        }
        
        let mainFieldCentered = NSLayoutConstraint(item: main, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0)
        mainFieldCentered.isActive = true
        self.addConstraint(mainFieldCentered)
        
        if let imgView = self.imageView {
        
            let imgFieldCentered = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: main, attribute: .centerY, multiplier: 1.0, constant: 1)
            imgFieldCentered.isActive = true
            self.addConstraint(imgFieldCentered)
        }
    }
    
    func adjustConstraints_mainFieldOnTop(_ topOffset: CGFloat = 0) {
        
        let main = self.textField!
        
        for con in self.constraints {
            
            if con.firstItem === main && (con.firstAttribute == .top || con.firstAttribute == .centerY) {
                
                con.isActive = false
                self.removeConstraint(con)
            }
            
            if con.secondItem === main && (con.secondAttribute == .top || con.secondAttribute == .centerY) {
                
                con.isActive = false
                self.removeConstraint(con)
            }
        }
        
        let mainFieldOnTop = NSLayoutConstraint(item: main, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: topOffset)
        mainFieldOnTop.isActive = true
        self.addConstraint(mainFieldOnTop)
        
        if let imgView = self.imageView {
            
            let imgFieldCentered = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: main, attribute: .centerY, multiplier: 1.0, constant: 3)
            imgFieldCentered.isActive = true
            self.addConstraint(imgFieldCentered)
        }
    }
    
    func adjustConstraints_beforeGapFieldOnTop(_ gapView: NSView) {
        
        let main = self.textField!
        
        for con in self.constraints {
            
            if con.firstItem === main && (con.firstAttribute == .top || con.firstAttribute == .centerY) {
                
                con.isActive = false
                self.removeConstraint(con)
            }
            
            if con.secondItem === main && (con.secondAttribute == .top || con.secondAttribute == .centerY) {
                
                con.isActive = false
                self.removeConstraint(con)
            }
        }
        
        let befFieldOnTop = NSLayoutConstraint(item: main, attribute: .top, relatedBy: .equal, toItem: gapView, attribute: .bottom, multiplier: 1.0, constant: -2)
        befFieldOnTop.isActive = true
        self.addConstraint(befFieldOnTop)
        
        if let imgView = self.imageView {
            
            let imgFieldCentered = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal, toItem: main, attribute: .centerY, multiplier: 1.0, constant: 2)
            imgFieldCentered.isActive = true
            self.addConstraint(imgFieldCentered)
        }
    }
}

@IBDesignable
class GroupedTrackNameCellView: GroupedItemCellView {
    
    var gapImage: NSImage!
    
    @IBInspectable @IBOutlet weak var gapBeforeImg: NSImageView!
    @IBInspectable @IBOutlet weak var gapAfterImg: NSImageView!
    
    // When the background changes (as a result of selection/deselection) switch to the appropriate colors/fonts
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            
            // Check if this row is selected
            let outlineView = OutlineViewHolder.instances[self.playlistType]!
            let isSelRow = outlineView.selectedRowIndexes.contains(outlineView.row(forItem: item))
            
            textField?.textColor = isSelRow ?
                isGroup ? Colors.Playlist.groupNameSelectedTextColor : Colors.Playlist.trackNameSelectedTextColor :
                isGroup ? Colors.Playlist.groupNameTextColor : Colors.Playlist.trackNameTextColor
            
            textField?.font = isGroup ? Fonts.Playlist.groupNameFont : Fonts.Playlist.trackNameFont
        }
    }
    
    func updateForGaps(_ gapBeforeTrack: Bool, _ gapAfterTrack: Bool) {

        gapBeforeImg.image = gapBeforeTrack ? gapImage : nil
        gapBeforeImg.showIf(gapBeforeTrack)

        gapAfterImg.image = gapAfterTrack ? gapImage : nil
        gapAfterImg.showIf(gapAfterTrack)

        gapBeforeTrack ? adjustConstraints_beforeGapFieldOnTop(gapBeforeImg) : adjustConstraints_mainFieldOnTop(gapAfterTrack ? 0 : -2)
    }
}

/*
    Custom view for a single NSTableView self. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
class GroupedTrackDurationCellView: GroupedItemCellView {
    
    @IBInspectable @IBOutlet weak var gapBeforeTextField: NSTextField!
    @IBInspectable @IBOutlet weak var gapAfterTextField: NSTextField!
    
    // When the background changes (as a result of selection/deselection) switch to the appropriate colors/fonts
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            
            // Check if this row is selected
            let outlineView = OutlineViewHolder.instances[self.playlistType]!
            let isSelRow = outlineView.selectedRowIndexes.contains(outlineView.row(forItem: item))
            
            textField?.textColor = isSelRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
            
            textField?.font = isGroup ? Fonts.Playlist.groupDurationFont : Fonts.Playlist.indexFont
            
            if !isGroup {
            
                gapBeforeTextField.textColor = isSelRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
                gapBeforeTextField.font = Fonts.Playlist.indexFont
            
                gapAfterTextField.textColor = isSelRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
                gapAfterTextField.font = Fonts.Playlist.indexFont
            }
        }
    }
    
    func updateForGaps(_ gapBeforeTrack: Bool, _ gapAfterTrack: Bool, _ gapBeforeDuration: Double? = nil, _ gapAfterDuration: Double? = nil) {
        
        gapBeforeTextField.showIf(gapBeforeTrack)
        gapBeforeTextField.stringValue = gapBeforeTrack ? ValueFormatter.formatSecondsToHMS(gapBeforeDuration!) : ""
        
        gapAfterTextField.showIf(gapAfterTrack)
        gapAfterTextField.stringValue = gapAfterTrack ? ValueFormatter.formatSecondsToHMS(gapAfterDuration!) : ""
        
        gapBeforeTrack ? adjustConstraints_beforeGapFieldOnTop(gapBeforeTextField) : adjustConstraints_mainFieldOnTop(gapAfterTrack ? 0 : (isGroup ? 1.5 : -2))
    }
}

// Utility class to hold NSOutlineView instances for convenient access
class OutlineViewHolder {
    
    // Mapping of playlist types to their corresponding outline views
    static var instances = [PlaylistType: NSOutlineView]()
}
