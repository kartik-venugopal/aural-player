import Cocoa

/*
    Manages and provides actions for the Bookmarks menu that displays bookmarks that can be opened by the player.
 */
class BookmarksMenuController: NSObject, NSMenuDelegate {
    
    private var bookmarks: BookmarksDelegateProtocol = ObjectGraph.getBookmarksDelegate()
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol = ObjectGraph.getPlaybackDelegate()
    
    @IBOutlet weak var theMenu: NSMenu!
 
    // One-time setup, when the menu loads
    override func awakeFromNib() {
        
    }
    
    // Before the menu opens, re-create the menu items from the model
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // TODO: Clear the menu first (except the topmost item !!!)
        let items = menu.items
        items.forEach({
        
            if $0 is BookmarksMenuItem {
                menu.removeItem($0)
            }
        })
        
        let allBookmarks = bookmarks.getAllBookmarks()
        allBookmarks.forEach({
        
            let item = createBookmarkMenuItem($0)
            theMenu.addItem(item)
        })
    }
    
    // Factory method to create a single history menu item, given a model object (HistoryItem)
    private func createBookmarkMenuItem(_ bookmark: Bookmark) -> NSMenuItem {
        
        // The action for the menu item will depend on whether it is a playable item
        let action = #selector(self.playSelectedItemAction(_:))
        
        let menuItem = BookmarksMenuItem(title: "  " + bookmark.name, action: action, keyEquivalent: "")
        menuItem.target = self
        
        menuItem.image = bookmark.art
        menuItem.image?.size = Images.historyMenuItemImageSize
        
        menuItem.bookmark = bookmark
        
        return menuItem
    }
    
    // When a bookmark menu item is clicked, the item is played
    @IBAction func bookmarkAction(_ sender: Any) {
        
        // TODO: Move this logic to menuNeedsUpdate() to disable the menu item
        if (player.getPlaybackState() == .noTrack) {
            return
        }
        
        _ = bookmarks.addBookmark("")
    }
    
    // When a bookmark menu item is clicked, the item is played
    @IBAction fileprivate func playSelectedItemAction(_ sender: BookmarksMenuItem) {
        bookmarks.playBookmark(sender.bookmark)
    }
}

class BookmarksMenuItem: NSMenuItem {
    
    var bookmark: Bookmark!
}
