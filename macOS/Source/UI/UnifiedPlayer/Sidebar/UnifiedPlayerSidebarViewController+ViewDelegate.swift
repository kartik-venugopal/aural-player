//
//  UnifiedPlayerSidebarViewController+ViewDelegate.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension UnifiedPlayerSidebarViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        item is UnifiedPlayerSidebarCategory ? 31: 27
    }
    
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        UnifiedPlayerSidebarRowView()
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        item is UnifiedPlayerSidebarCategory && (sidebarView.numberOfChildren(ofItem: item) > 0)
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        if let category = item as? UnifiedPlayerSidebarCategory {
            
            //            return category == .playlists ?
            //            createPlaylistCategoryCell(outlineView, category.description, font: systemFontScheme.normalFont, textColor: systemColorScheme.secondaryTextColor, image: category.image) :
            return createNameCell(outlineView, category.description, font: systemFontScheme.normalFont, textColor: systemColorScheme.secondaryTextColor, image: category.image)
        }
            
//        } else if let sidebarItem = item as? UnifiedPlayerSidebarItem {
//            
//            if sidebarItem.browserTab == .playlists {
//                
//                return createPlaylistNameCell(outlineView, sidebarItem.displayName, font: systemFontScheme.normalFont, textColor: systemColorScheme.primaryTextColor, image: sidebarItem.image)
//            }
//            
//            return createNameCell(outlineView, sidebarItem.displayName, font: systemFontScheme.normalFont, textColor: systemColorScheme.primaryTextColor, image: sidebarItem.image)
//        }
//        
        return nil
    }
    
    private func createNameCell(_ outlineView: NSOutlineView, _ text: String, font: NSFont, textColor: NSColor, image: NSImage? = nil) -> NSTableCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("name"), owner: nil)
            as? NSTableCellView else {return nil}
        
        cell.text = text
        cell.textFont = font
        cell.textColor = textColor
        
        cell.image = image
        cell.imageColor = textColor
        
        return cell
    }
    
//    private func createPlaylistCategoryCell(_ outlineView: NSOutlineView, _ text: String, font: NSFont, textColor: NSColor, image: NSImage? = nil) -> NSTableCellView? {
//        
//        guard let cell = outlineView.makeView(withIdentifier: .cid_SidebarPlaylistCategory, owner: nil)
//            as? PlaylistSidebarCategoryCell else {return nil}
//        
//        cell.text = text
//        cell.textFont = font
//        cell.textColor = textColor
//        
//        cell.image = image
//        cell.imageColor = textColor
//        
//        cell.updateAddButton(withAction: #selector(createEmptyPlaylistAction(_:)), onTarget: self)
//        
//        return cell
//    }
//    
//    private func createPlaylistNameCell(_ outlineView: NSOutlineView, _ text: String, font: NSFont, textColor: NSColor, image: NSImage? = nil) -> NSTableCellView? {
//        
//        guard let cell = outlineView.makeView(withIdentifier: .cid_SidebarPlaylistName, owner: nil)
//            as? NSTableCellView else {return nil}
//        
//        cell.text = text
//        cell.textFont = font
//        cell.textColor = textColor
//
//        cell.image = image
//        cell.imageColor = textColor
//        
//        cell.textField?.delegate = self
//        
//        return cell
//    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        
        if let category = item as? UnifiedPlayerSidebarCategory {
//            return category.equalsOneOf(.playQueue, .favorites, .bookmarks)
            return category.equalsOneOf(.playQueue)
        }
        
        return true
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        
        guard let outlineView = notification.object as? NSOutlineView else {return}
        
        let item = outlineView.item(atRow: outlineView.selectedRow)
        
        if let selectedItem = item as? UnifiedPlayerSidebarItem {
            
            unifiedPlayerUIState.sidebarSelectedModule = selectedItem.category
            
            if respondToSelectionChange {
                messenger.publish(.unifiedPlayer_showBrowserTabForItem, payload: selectedItem)
            }
            
        } else if let selectedCategory = item as? UnifiedPlayerSidebarCategory {
            
            unifiedPlayerUIState.sidebarSelectedModule = selectedCategory
            
            if respondToSelectionChange {
                messenger.publish(.unifiedPlayer_showBrowserTabForCategory, payload: selectedCategory)
            }
        }
    }
}

class UnifiedPlayerSidebarRowView: AuralTableRowView {

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
