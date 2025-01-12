//
//  LibrarySidebarViewController+ViewDelegate.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension LibrarySidebarViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        item is LibrarySidebarCategory ? 31: 27
    }
    
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        LibrarySidebarRowView()
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        item is LibrarySidebarCategory && (sidebarView.numberOfChildren(ofItem: item) > 0)
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        if let category = item as? LibrarySidebarCategory {
            
            return category == .playlists ?
            createPlaylistCategoryCell(outlineView, category.description, font: systemFontScheme.normalFont, textColor: systemColorScheme.secondaryTextColor, image: category.image) :
            createNameCell(outlineView, category.description, font: systemFontScheme.normalFont, textColor: systemColorScheme.secondaryTextColor,
                           image: category.image, imageColor: systemColorScheme.buttonColor)
            
        } else if let sidebarItem = item as? LibrarySidebarItem {
            
            if sidebarItem.browserTab == .playlists {
                
                return createPlaylistNameCell(outlineView, sidebarItem.displayName, font: systemFontScheme.normalFont, textColor: systemColorScheme.primaryTextColor, image: sidebarItem.image)
                
            } else {
                
                return createNameCell(outlineView, sidebarItem.displayName, font: systemFontScheme.normalFont, textColor: systemColorScheme.primaryTextColor,
                                      image: sidebarItem.image, imageColor: systemColorScheme.buttonColor)
            }
        }
        
        return nil
    }
    
    private func createNameCell(_ outlineView: NSOutlineView, _ text: String, font: NSFont, textColor: NSColor, image: NSImage? = nil, imageColor: NSColor? = nil) -> NSTableCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("name"), owner: nil)
            as? NSTableCellView else {return nil}
        
        cell.text = text
        cell.textFont = font
        cell.textColor = textColor
        
        cell.image = image
        cell.imageColor = imageColor
        
        return cell
    }
    
    private func createPlaylistCategoryCell(_ outlineView: NSOutlineView, _ text: String, font: NSFont, textColor: NSColor, image: NSImage? = nil) -> NSTableCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .cid_SidebarPlaylistCategory, owner: nil)
            as? PlaylistSidebarCategoryCell else {return nil}
        
        cell.text = text
        cell.textFont = font
        cell.textColor = textColor
        
        cell.image = image
        cell.imageColor = textColor
        
        cell.updateAddButton(withAction: #selector(createEmptyPlaylistAction(_:)), onTarget: self)
        
        return cell
    }
    
    private func createPlaylistNameCell(_ outlineView: NSOutlineView, _ text: String, font: NSFont, textColor: NSColor, image: NSImage? = nil) -> NSTableCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .cid_SidebarPlaylistName, owner: nil)
            as? NSTableCellView else {return nil}
        
        cell.text = text
        cell.textFont = font
        cell.textColor = textColor

        cell.image = image
        cell.imageColor = textColor
        
        cell.textField?.delegate = self
        
        return cell
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return (item is LibrarySidebarItem) || ((item as? LibrarySidebarCategory) == .bookmarks)
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        
        guard respondToSelectionChange, let outlineView = notification.object as? NSOutlineView else {return}
        
        let item = outlineView.item(atRow: outlineView.selectedRow)
        
        if let selectedItem = item as? LibrarySidebarItem {
            messenger.publish(.Library.showBrowserTabForItem, payload: selectedItem)
            
        } else if let selectedCategory = item as? LibrarySidebarCategory {
            messenger.publish(.Library.showBrowserTabForCategory, payload: selectedCategory)
        }
    }
}

class LibrarySidebarRowView: AuralTableRowView {

    override func didAddSubview(_ subview: NSView) {

        if let disclosureButton = subview as? NSButton {

            disclosureButton.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                disclosureButton.topAnchor.constraint(equalTo: topAnchor, constant: 10),
                disclosureButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 7)
            ])
        }

        super.didAddSubview(subview)
    }
}

class PlaylistSidebarCategoryCell: NSTableCellView {
    
    @IBOutlet weak var btnAddPlaylist: NSButton!
    
    func updateAddButton(withAction action: Selector, onTarget target: NSViewController) {
        
        btnAddPlaylist.contentTintColor = systemColorScheme.buttonColor
        btnAddPlaylist.action = action
        btnAddPlaylist.target = target
    }
}

extension NSUserInterfaceItemIdentifier {
    
    static let cid_SidebarPlaylistCategory: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_SidebarPlaylistCategory")
    static let cid_SidebarPlaylistName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_SidebarPlaylistName")
}
