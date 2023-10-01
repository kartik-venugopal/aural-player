//
//  GroupingPlaylistTableViews.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/*
    A customized NSOutlineView that overrides contextual menu behavior
 */
class AuralPlaylistOutlineView: NSOutlineView, Destroyable {
    
    static var cachedDisclosureIcon_collapsed: NSImage = Images.imgDisclosure_collapsed.filledWithColor(Colors.Playlist.groupDisclosureTriangleColor)
    static var cachedDisclosureIcon_expanded: NSImage = Images.imgDisclosure_expanded.filledWithColor(Colors.Playlist.groupDisclosureTriangleColor)
    static var cachedGroupIcon: NSImage = Images.imgGroup.filledWithColor(Colors.Playlist.groupIconColor)
    
    static var disclosureButtons: [NSButton] = []
    
    // Enable drag/drop.
    override func awakeFromNib() {
        self.registerForDraggedTypes([.data, .file_URL])
    }
    
    static func destroy() {
        disclosureButtons.removeAll()
    }
    
    static func updateCachedImages() {
        
        cachedDisclosureIcon_collapsed = Images.imgDisclosure_collapsed.filledWithColor(Colors.Playlist.groupDisclosureTriangleColor)
        cachedDisclosureIcon_expanded = Images.imgDisclosure_expanded.filledWithColor(Colors.Playlist.groupDisclosureTriangleColor)
        
        cachedGroupIcon = Images.imgGroup.filledWithColor(Colors.Playlist.groupIconColor)
    }
    
    static func changeDisclosureTriangleColor(_ color: NSColor) {
        
        cachedDisclosureIcon_collapsed = Images.imgDisclosure_collapsed.filledWithColor(color)
        cachedDisclosureIcon_expanded = Images.imgDisclosure_expanded.filledWithColor(color)
        
        for button in disclosureButtons {
            
            button.image = cachedDisclosureIcon_collapsed
            button.alternateImage = cachedDisclosureIcon_expanded
        }
    }
    
    static func changeGroupIconColor(_ color: NSColor) {
        cachedGroupIcon = Images.imgGroup.filledWithColor(color)
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
                disclosureButton.topAnchor.constraint(equalTo: topAnchor, constant: System.isBigSur ? 12 : 9),
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
    
    lazy var textFieldConstraintsManager = LayoutConstraintsManager(for: textField!)
    
    func updateText(_ font: NSFont, _ text: String) {
        
        self.textFont = font
        self.text = text
        textField?.show()
    }
    
    // Constraints
    func realignText(yOffset: CGFloat) {
        
        textFieldConstraintsManager.removeAll(withAttributes: [.bottom])
        textFieldConstraintsManager.setBottom(relatedToBottomOf: self, offset: yOffset)
    }
}

class GroupedItemNameCellView: GroupedItemCellView {
    
    lazy var imgViewConstraintsManager = LayoutConstraintsManager(for: imageView!)
    
    // When the background changes (as a result of selection/deselection) switch to the appropriate colors/fonts
    override var backgroundStyle: NSView.BackgroundStyle {
        
        didSet {
            
            // Check if this row is selected
            textColor = rowIsSelected ?
                isGroup ? Colors.Playlist.groupNameSelectedTextColor : Colors.Playlist.trackNameSelectedTextColor :
                isGroup ? Colors.Playlist.groupNameTextColor : Colors.Playlist.trackNameTextColor

            textFont = isGroup ? Fonts.Playlist.groupTextFont : Fonts.Playlist.trackTextFont
        }
    }
    
    func reActivateConstraints(imgViewCenterY: CGFloat, imgViewLeading: CGFloat, textFieldLeading: CGFloat) {
        
        textFieldConstraintsManager.removeAll(withAttributes: [.leading])
        imgViewConstraintsManager.removeAll(withAttributes: [.centerY, .leading])
        
        textFieldConstraintsManager.setLeading(relatedToTrailingOf: imageView!, offset: textFieldLeading)
        
        imgViewConstraintsManager.centerVerticallyInSuperview(offset: imgViewCenterY)
        imgViewConstraintsManager.setLeading(relatedToLeadingOf: self, offset: imgViewLeading)
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
            
            textColor = isSelectedRow ? Colors.Playlist.indexDurationSelectedTextColor : Colors.Playlist.indexDurationTextColor
            textFont = isGroup ? Fonts.Playlist.groupTextFont : Fonts.Playlist.trackTextFont
        }
    }
}
