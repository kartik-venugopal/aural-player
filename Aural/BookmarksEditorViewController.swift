import Cocoa

class BookmarksEditorViewController: NSViewController {
    
    @IBOutlet weak var editorView: NSTableView!
    
    // Delegate that relays accessor operations to the bookmarks model
    private let bookmarks: BookmarksDelegateProtocol = ObjectGraph.getBookmarksDelegate()
    
    override var nibName: String? {return "BookmarksEditor"}
    
    override func viewDidAppear() {
        editorView.reloadData()
    }
    
    @IBAction func deleteSelectedBookmarksAction(_ sender: AnyObject) {
        
        // Descending order
        let sortedSelection = editorView.selectedRowIndexes.sorted(by: {x, y -> Bool in x > y})
        
        sortedSelection.forEach({
            
            if let bookmark = bookmarks.getBookmarkAtIndex($0) {
                bookmarks.deleteBookmark(bookmark.name)
            }
        })
        
        editorView.reloadData()
    }
    
    @IBAction func doneAction(_ sender: AnyObject) {
        self.view.window?.close()
    }
}
