import Cocoa

class TuneBrowserWindowController: NSWindowController, Destroyable {
    
    override var windowNibName: String? {"TuneBrowser"}
    
    @IBOutlet weak var browserView: TuneBrowserOutlineView!
    @IBOutlet weak var browserViewDelegate: TuneBrowserViewDelegate!
    
    @IBOutlet weak var pathControlWidget: NSPathControl!
        
    @IBAction func openFolderAction(_ sender: Any) {
        
        if let item = browserView.item(atRow: browserView.selectedRow), let fsItem = item as? FileSystemItem, fsItem.isDirectory {
            
            changeBrowserRootDir(fsItem: fsItem)
        }
    }
    
    @IBAction func pathControlAction(_ sender: Any) {
        
        
        if let item = pathControlWidget.clickedPathItem, let url = item.url {
            
            var path = url.path
            
            if path.hasSuffix("/") {
                changeBrowserRootDir(fsItem: FileSystemItem(url: url))
                
            } else {
                
                path += "/"
                changeBrowserRootDir(fsItem: FileSystemItem(url: URL(fileURLWithPath: path)))
            }
        }
    }
    
    private func changeBrowserRootDir(fsItem: FileSystemItem) {
        
        browserViewDelegate.fsRoot = fsItem
        browserView.reloadData()
        browserView.scrollRowToVisible(0)
    }
        
    @IBAction func closeAction(_ sender: Any) {
        self.window?.close()
    }
}
