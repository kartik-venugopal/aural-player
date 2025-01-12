//
//  UnifiedPlayerSidebarViewController+ViewDelegate.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

extension UnifiedPlayerSidebarViewController: NSOutlineViewDelegate {
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        
        if let sidebarItem = item as? UnifiedPlayerSidebarItem {
            return sidebarItem.module.isTopLevelItem ? 31 : 27
        }
        
        return 27
    }
    
    func outlineView(_ outlineView: NSOutlineView, rowViewForItem item: Any) -> NSTableRowView? {
        UnifiedPlayerSidebarRowView()
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        sidebarView.numberOfChildren(ofItem: item) > 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        if let sidebarItem = item as? UnifiedPlayerSidebarItem {
            
            //            return category == .playlists ?
            //            createPlaylistCategoryCell(outlineView, category.description, font: systemFontScheme.normalFont, textColor: systemColorScheme.secondaryTextColor, image: category.image) :
            
            return createNameCell(outlineView, sidebarItem: sidebarItem, sidebarItem.module.description, font: systemFontScheme.normalFont,
                                  textColor: systemColorScheme.secondaryTextColor,
                                  image: sidebarItem.module.image)
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
    
    private func createNameCell(_ outlineView: NSOutlineView, sidebarItem: UnifiedPlayerSidebarItem, _ text: String, font: NSFont, textColor: NSColor, image: NSImage? = nil) -> UnifiedPlayerSidebarCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("name"), owner: nil)
            as? UnifiedPlayerSidebarCellView else {return nil}
        
        cell.sidebarItem = sidebarItem
        
        cell.text = text
        cell.textFont = font
        cell.textColor = textColor
        
        cell.image = image
        cell.imageColor = textColor
        
        cell.btnClose.showIf(sidebarItem.module != .playQueue)
        cell.btnClose.toolTip = "Close \(sidebarItem.module.rawValue)"
        
        return cell
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        
        guard let sidebarItem = item as? UnifiedPlayerSidebarItem else {return true}
        
        if sidebarItem.module.isTopLevelItem {
            return sidebarItem.childItems.isEmpty
        } else {
            return true
        }
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        
        guard respondToSelectionChange, let outlineView = notification.object as? NSOutlineView else {return}
        let item = outlineView.item(atRow: outlineView.selectedRow)
        
        guard let selectedItem = item as? UnifiedPlayerSidebarItem else {
            
            unifiedPlayerUIState.sidebarSelectedItem = nil
            return
        }
            
        unifiedPlayerUIState.sidebarSelectedItem = selectedItem
        messenger.publish(.UnifiedPlayer.showModule, payload: selectedItem)
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
}

class UnifiedPlayerSidebarCellView: NSTableCellView {
    
    @IBOutlet weak var btnClose: NSButton!
    var sidebarItem: UnifiedPlayerSidebarItem!
    
    @IBAction func closeModuleAction(_ sender: NSButton) {
        
        if let sidebarItem = self.sidebarItem {
            Messenger.publish(.UnifiedPlayer.hideModule, payload: sidebarItem)
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

class PlaylistSidebarCategoryCell: NSTableCellView {
    
    @IBOutlet weak var btnAddPlaylist: NSButton!
    
    func updateAddButton(withAction action: Selector, onTarget target: NSViewController) {
        
        btnAddPlaylist.contentTintColor = systemColorScheme.buttonColor
        btnAddPlaylist.action = action
        btnAddPlaylist.target = target
    }
}
