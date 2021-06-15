import Cocoa

/*
    A customized NSOutlineView that overrides contextual menu behavior
 */
class AuralPlaylistOutlineView: NSOutlineView, Destroyable {
    
    static var cachedDisclosureIcon_collapsed: NSImage!
    static var cachedDisclosureIcon_expanded: NSImage!
    
    static var cachedGroupIcon: NSImage!
    
    static var disclosureButtons: [NSButton] = []
    
    static func destroy() {
        disclosureButtons.removeAll()
    }
    
    static func updateCachedImages() {
        
        cachedDisclosureIcon_collapsed = Images.imgDisclosure_collapsed.applyingTint(Colors.Playlist.groupDisclosureTriangleColor)
        cachedDisclosureIcon_expanded = Images.imgDisclosure_expanded.applyingTint(Colors.Playlist.groupDisclosureTriangleColor)
        
        cachedGroupIcon = Images.imgGroup.applyingTint(Colors.Playlist.groupIconColor)
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

class GroupingPlaylistRowView: PlaylistRowView {
    
    override func didAddSubview(_ subview: NSView) {
        
        if let disclosureButton = subview as? NSButton {
            
            disclosureButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                disclosureButton.topAnchor.constraint(equalTo: topAnchor, constant: SystemUtils.isBigSur ? 12 : 9),
                disclosureButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10)
            ])
        }
        
        super.didAddSubview(subview)
    }
}

class GroupedItemCellView: NSTableCellView {
    
    // Used to determine whether or not this cell is selected.
    var rowSelectionStateFunction: () -> Bool = {false}
    
    var rowIsSelected: Bool {rowSelectionStateFunction()}
    
    // Whether or not this cell is contained within a row that represents a group (as opposed to a track)
    var isGroup: Bool = false
    
    // This is used to determine which NSOutlineView contains this cell
    var playlistType: PlaylistType = .artists
    
    func updateText(_ font: NSFont, _ text: String) {
        
        textField?.font = font
        textField?.stringValue = text
        textField?.show()
    }
    
    // Constraints
    func realignText(yOffset: CGFloat) {
        
        guard let textField = self.textField else {return}
        
        // Remove any existing constraints on the text field's 'bottom' attribute
        self.constraints.filter {$0.firstItem === textField && $0.firstAttribute == .bottom}.forEach {[weak self] in self?.deactivateAndRemoveConstraint($0)}

        let textFieldBottomConstraint = NSLayoutConstraint(item: textField, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: yOffset)
        
        self.activateAndAddConstraint(textFieldBottomConstraint)
    }
}

@IBDesignable
class GroupedItemNameCellView: GroupedItemCellView {
    
    // When the background changes (as a result of selection/deselection) switch to the appropriate colors/fonts
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            
            // Check if this row is selected
            textField?.textColor = rowIsSelected ?
                isGroup ? Colors.Playlist.groupNameSelectedTextColor : Colors.Playlist.trackNameSelectedTextColor :
                isGroup ? Colors.Playlist.groupNameTextColor : Colors.Playlist.trackNameTextColor
            
            textField?.font = isGroup ? FontSchemes.systemScheme.playlist.groupTextFont : FontSchemes.systemScheme.playlist.trackTextFont
        }
    }
    
    func reActivateConstraints(imgViewCenterY: CGFloat, imgViewLeading: CGFloat, textFieldLeading: CGFloat) {
        
        guard let imgView = self.imageView, let textField = self.textField else {return}
        
        self.constraints.filter {$0.firstItem === imgView && $0.firstAttribute == .centerY}.forEach {[weak self] in self?.deactivateAndRemoveConstraint($0)}
        
        self.constraints.filter {$0.firstItem === imgView && $0.firstAttribute == .leading}.forEach {[weak self] in self?.deactivateAndRemoveConstraint($0)}
        
        self.constraints.filter {$0.firstItem === textField && $0.firstAttribute == .leading}.forEach {[weak self] in self?.deactivateAndRemoveConstraint($0)}
        
        let newImgViewCenterYConstraint = NSLayoutConstraint(item: imgView, attribute: .centerY, relatedBy: .equal,
                                                          toItem: self, attribute: .centerY, multiplier: 1.0, constant: imgViewCenterY)
        
        let newImgViewLeadingConstraint = NSLayoutConstraint(item: imgView, attribute: .leading, relatedBy: .equal,
                                                          toItem: self, attribute: .leading, multiplier: 1.0, constant: imgViewLeading)
        
        let newTextFieldLeadingConstraint = NSLayoutConstraint(item: textField, attribute: .leading, relatedBy: .equal,
                                                            toItem: imgView, attribute: .trailing, multiplier: 1.0, constant: textFieldLeading)
        
        self.activateAndAddConstraints(newImgViewCenterYConstraint, newImgViewLeadingConstraint, newTextFieldLeadingConstraint)
    }
}

/*
    Custom view for a single NSTableView self. Customizes the look and feel of cells (in selected rows) - font and text color.
 */
class GroupedItemDurationCellView: GroupedItemCellView {
    
    // When the background changes (as a result of selection/deselection) switch to the appropriate colors/fonts
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            
            let isSelectedRow = rowIsSelected
            
            textField?.textColor = isSelectedRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
            textField?.font = isGroup ? FontSchemes.systemScheme.playlist.groupTextFont : FontSchemes.systemScheme.playlist.trackTextFont
        }
    }
}
