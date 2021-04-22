import Cocoa

class TuneBrowserSidebarViewController: NSViewController, NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    @IBOutlet weak var sidebarView: NSOutlineView!
    
    override var nibName: String? {return "Sidebar"}
    
    let mainFont_14: NSFont = NSFont(name: "Play Regular", size: 13)!
    
    let categories: [SidebarCategory] = SidebarCategory.allCases
    
    var folderItems: [SidebarItem] = [SidebarItem(displayName: "Music")]
    
    func initializeUI() {
        
        categories.forEach {sidebarView.expandItem($0)}
        sidebarView.selectRowIndexes(IndexSet(integer: 1), byExtendingSelection: false)
    }
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        30
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if item == nil {
            return categories.count
            
        } else if let sidebarCat = item as? SidebarCategory {
            
            switch sidebarCat {
                
            case .volumes:
                
                return FileSystemUtils.secondaryVolumes.count + 1
                
            case .folders:
                
                return 1
            }
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, isGroupItem item: Any) -> Bool {
        return item is SidebarCategory
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {

            return categories[index]

        } else if item as? SidebarCategory == .volumes {
            
            if index == 0 {
                return SidebarItem(displayName: FileSystemUtils.primaryVolumeName ?? "/")
            }

            return SidebarItem(displayName: FileSystemUtils.secondaryVolumes[index - 1].lastPathComponent)
            
        } else if item as? SidebarCategory == .folders {
            
            return SidebarItem(displayName: "Music")
        }
        
        return ""
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return item is SidebarCategory
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        if let category = item as? SidebarCategory {
            return createNameCell(outlineView, category.description)
            
        } else if let sidebarItem = item as? SidebarItem {
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
        return !(item is SidebarCategory)
    }
    
    func outlineView(_ outlineView: NSOutlineView, shouldShowOutlineCellForItem item: Any) -> Bool {
        return item is SidebarCategory
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
