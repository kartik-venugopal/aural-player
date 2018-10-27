import Cocoa

/*
    Manages and provides actions for the Bookmarks menu that displays bookmarks that can be opened by the player.
 */
class BookmarksMenuController: NSObject, NSMenuDelegate {
    
    private var bookmarks: BookmarksDelegateProtocol = ObjectGraph.getBookmarksDelegate()
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol = ObjectGraph.getPlaybackDelegate()
    
    @IBOutlet weak var theMenu: NSMenu!
    
    @IBOutlet weak var bookmarkTrackPositionMenuItem: NSMenuItem!
    @IBOutlet weak var bookmarkTrackSegmentLoopMenuItem: NSMenuItem!
    @IBOutlet weak var manageBookmarksMenuItem: NSMenuItem!
    
    private lazy var editorWindowController: EditorWindowController = WindowFactory.getEditorWindowController()
    
    // Before the menu opens, re-create the menu items from the model
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Can't add a bookmark if no track is playing or if the popover is currently being shown
        let playingOrPaused = player.getPlaybackState().playingOrPaused()
        
        bookmarkTrackPositionMenuItem.enableIf(playingOrPaused && !WindowState.showingPopover)
        
        let loop = player.getPlaybackLoop()
        let hasCompleteLoop = loop != nil && loop!.isComplete()
        bookmarkTrackSegmentLoopMenuItem.enableIf(playingOrPaused && hasCompleteLoop)
        
        manageBookmarksMenuItem.enableIf(bookmarks.countBookmarks() > 0)
        
        // Clear the menu first (except the topmost item)
        let items = menu.items
        items.forEach({
        
            if $0 is BookmarksMenuItem {
                menu.removeItem($0)
            }
        })
        
        // Recreate the bookmarks menu
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
    @IBAction func bookmarkTrackPositionAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(BookmarkActionMessage(.bookmarkPosition))
    }
    
    // When a bookmark menu item is clicked, the item is played
    @IBAction func bookmarkTrackSegmentLoopAction(_ sender: Any) {
        SyncMessenger.publishActionMessage(BookmarkActionMessage(.bookmarkLoop))
    }
    
    // When a bookmark menu item is clicked, the item is played
    @IBAction fileprivate func playSelectedItemAction(_ sender: BookmarksMenuItem) {
        
//        let bookmark = sender.bookmark!
//        
//        if bookmark.validateFile() {
        
            bookmarks.playBookmark(sender.bookmark!)
            
//        } else {
//            
//            // Display an error alert
//            
//            _ = UIUtils.showAlert(DialogsAndAlerts.trackNotPlayedAlertWithError(FileNotFoundError(bookmark.file), "Remove bookmark"))
//            bookmarks.deleteBookmarkWithName(bookmark.name)
//            
//            // TODO: Offer more options like "Point to the new location of the file". See RecorderViewController for reference.
//        }
    }
    
    @IBAction func manageBookmarksAction(_ sender: Any) {
        editorWindowController.showBookmarksEditor()
    }
}

// Helper class that stores a Bookmark for convenience (when playing it)
class BookmarksMenuItem: NSMenuItem {
    
    var bookmark: Bookmark!
}
