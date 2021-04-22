import Cocoa

class TuneBrowserViewDelegate: NSObject, NSOutlineViewDelegate, NSOutlineViewDataSource {
    
    let textFont: NSFont = Fonts.Auxiliary.size13
    
    private lazy var fsRoot: FileSystemItem = FileSystemItem(url: AppConstants.FilesAndPaths.musicDir)
    
    func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
        return 30
    }
    
    func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
        
        if item == nil {

            return fsRoot.children.count

        } else if let fsItem = item as? FileSystemItem {

            return fsItem.children.count
        }
        
        return 0
    }
    
    func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
        
        if item == nil {
            
            return fsRoot.children[index]
            
        } else if let fsItem = item as? FileSystemItem {
            
            return fsItem.children[index]
        }
        
        return ""
    }
    
    func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
        return (item as? FileSystemItem)?.isDirectory ?? false
    }
    
    func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        
        if tableColumn?.identifier.rawValue == "tuneBrowser_name", let fsItem = item as? FileSystemItem {
            return createNameCell(outlineView, fsItem)
        }
        
        if tableColumn?.identifier.rawValue == "tuneBrowser_type", let fsItem = item as? FileSystemItem {
            return createTypeCell(outlineView, fsItem)
        }
        
        return nil
    }
    
    private func createNameCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemNameCell? {
        
        guard let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("tuneBrowser_name"), owner: nil)
            as? TuneBrowserItemNameCell else {return nil}
        
        cell.initializeForFile(item)
        cell.lblName.font = textFont
        
        return cell
    }
    
    private func createTypeCell(_ outlineView: NSOutlineView, _ item: FileSystemItem) -> TuneBrowserItemTypeCell? {
        
        guard let cell = outlineView.makeView(withIdentifier: NSUserInterfaceItemIdentifier("tuneBrowser_type"), owner: nil)
            as? TuneBrowserItemTypeCell else {return nil}
        
        cell.initializeForFile(item)
        cell.textField?.font = textFont
        
        return cell
    }
    
    func outlineViewItemWillExpand(_ notification: Notification) {
        
        // TODO: Load folder contents (1 level deep) lazily
    }
}
