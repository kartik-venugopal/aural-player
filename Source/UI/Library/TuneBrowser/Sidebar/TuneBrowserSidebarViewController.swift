//
//  TuneBrowserSidebarViewController.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class TuneBrowserSidebarViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    @IBOutlet weak var sidebarView: TuneBrowserOutlineView!
    
    override var nibName: NSNib.Name? {"Sidebar"}
    
    private let size14: NSFont = NSFont(name: "Play Regular", size: 13)!
    
    private let categories: [TuneBrowserSidebarCategory] = TuneBrowserSidebarCategory.allCases
    
    private lazy var messenger = Messenger(for: self)
    
    // TODO: Where / when should this be called ?
    func initializeUI() {
        
        categories.forEach {sidebarView.expandItem($0)}
        sidebarView.selectRow(1)
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        item is TuneBrowserSidebarCategory ? 30 : 26
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if item == nil {
            return categories.count
            
        } else if let sidebarCat = item as? TuneBrowserSidebarCategory {
            
            switch sidebarCat {
                
            case .volumes:
                
                return System.secondaryVolumes.count + 1
                
            case .folders:
                
                return tuneBrowserUIState.sidebarUserFolders.count + 1
            }
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        item is TuneBrowserSidebarCategory
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {
            return categories[index]
        }

//        } else if item as? TuneBrowserSidebarCategory == .volumes {
//            
//            if index == 0 {
//                return TuneBrowserSidebarItem(folder: item.)
//            }
//
//            let volume = System.secondaryVolumes[index - 1]
//            return TuneBrowserSidebarItem(url: volume)
//            
//        } else if item as? TuneBrowserSidebarCategory == .folders {
//            
//            if index == 0 {
//                return tuneBrowserSidebarMusicFolder
//            } else {
//                return tuneBrowserUIState.sidebarUserFolders.elements[index - 1].value
//            }
//        }
        
        return ""
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        item is TuneBrowserSidebarCategory
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        if let category = item as? TuneBrowserSidebarCategory {
            return createNameCell(outlineView, category.description)
            
        } else if let sidebarItem = item as? TuneBrowserSidebarItem {
            return createNameCell(outlineView, sidebarItem.folder.name)
        }
        
        return nil
    }
    
    private func createNameCell(_ outlineView: NSOutlineView, _ text: String) -> NSTableCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .cid_tuneBrowserSidebarName, owner: nil)
            as? NSTableCellView else {return nil}
        
        cell.image = nil
        cell.text = text
        cell.textFont = size14
        
        return cell
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        !(item is TuneBrowserSidebarCategory)
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        item is TuneBrowserSidebarCategory
    }
   
    func outlineViewSelectionDidChange(_ notification: Notification) {
        
        guard let outlineView = notification.object as? NSOutlineView else {return}

        if let selectedItem = outlineView.item(atRow: outlineView.selectedRow) as? TuneBrowserSidebarItem {
            messenger.publish(.tuneBrowser_sidebarSelectionChanged, payload: selectedItem)
        }
    }
}

extension NSUserInterfaceItemIdentifier {
    
    static let cid_tuneBrowserSidebarName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowserSidebar_name")
}
