import Cocoa

class TuneBrowserSidebarViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    @IBOutlet weak var sidebarView: NSOutlineView!
    
    override var nibName: String? {return "Sidebar"}
    
    let mainFont_14: NSFont = NSFont(name: "Play Regular", size: 13)!
    
    let categories: [TuneBrowserSidebarCategory] = TuneBrowserSidebarCategory.allCases
    
    let musicFolder: TuneBrowserSidebarItem = TuneBrowserSidebarItem(displayName: "Music", url: tuneBrowserMusicFolderURL)
    
    func initializeUI() {
        
        categories.forEach {sidebarView.expandItem($0)}
        sidebarView.selectRowIndexes(IndexSet(integer: 1), byExtendingSelection: false)
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
                
                return FileSystemUtils.secondaryVolumes.count + 1
                
            case .folders:
                
                return TuneBrowserViewState.userFolders.count + 1
            }
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return item is TuneBrowserSidebarCategory
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {

            return categories[index]

        } else if item as? TuneBrowserSidebarCategory == .volumes {
            
            if index == 0 {
                return TuneBrowserSidebarItem(displayName: FileSystemUtils.primaryVolumeName ?? "/", url: tuneBrowserPrimaryVolumeURL)
            }

            let volume = FileSystemUtils.secondaryVolumes[index - 1]
            return TuneBrowserSidebarItem(displayName: volume.lastPathComponent, url: volume)
            
        } else if item as? TuneBrowserSidebarCategory == .folders {
            
            if index == 0 {
                return musicFolder
            } else {
                return TuneBrowserViewState.userFolders[index - 1]
            }
        }
        
        return ""
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return item is TuneBrowserSidebarCategory
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        if let category = item as? TuneBrowserSidebarCategory {
            return createNameCell(outlineView, category.description)
            
        } else if let sidebarItem = item as? TuneBrowserSidebarItem {
            return createNameCell(outlineView, sidebarItem.displayName)
        }
        
        return nil
    }
    
    private func createNameCell(_ outlineView: NSOutlineView, _ text: String) -> NSTableCellView? {
        
        guard let cell = outlineView.makeView(withIdentifier: .uid_tuneBrowserSidebarName, owner: nil)
            as? NSTableCellView else {return nil}
        
        cell.imageView?.image = nil

        cell.textField?.stringValue = text
        cell.textField?.font = mainFont_14
        
        return cell
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldSelectItem item: Any) -> Bool {
        return !(item is TuneBrowserSidebarCategory)
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        return item is TuneBrowserSidebarCategory
    }
    
//    func outlineViewSelectionDidChange(_ notification: Notification) {
//
//        guard let outlineView = notification.object as? NSOutlineView else {return}
//
//        if let selectedItem = outlineView.item(atRow: outlineView.selectedRow) as? SidebarItem {
//
////            if selectedItem.displayName == playQueueItem.displayName {
////                Messenger.publish(.browser_showTab, payload: 0)
////            } else {
////                Messenger.publish(.browser_showTab, payload: selectedItem.displayName == "Tracks" ? 1 : 2)
////            }
//        }
//    }
}

extension NSUserInterfaceItemIdentifier {
    
    static let uid_tuneBrowserSidebarName: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("tuneBrowserSidebar_name")
}
