import Cocoa

/*
    Manages and provides actions for the Bookmarks menu that displays bookmarks that can be opened by the player.
 */
class BookmarksMenuController: NSObject, NSMenuDelegate {
    
    private var bookmarks: BookmarksDelegateProtocol = ObjectGraph.bookmarksDelegate
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol = ObjectGraph.playbackDelegate
    
    @IBOutlet weak var theMenu: NSMenu!
    
    @IBOutlet weak var bookmarkTrackPositionMenuItem: NSMenuItem!
    @IBOutlet weak var bookmarkTrackSegmentLoopMenuItem: NSMenuItem!
    @IBOutlet weak var manageBookmarksMenuItem: NSMenuItem!
    
    private lazy var editorWindowController: EditorWindowController = WindowFactory.getEditorWindowController()
    
    // Before the menu opens, re-create the menu items from the model
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Can't add a bookmark if no track is playing or if the popover is currently being shown
        let playingOrPaused = player.state.playingOrPaused()
        
        bookmarkTrackPositionMenuItem.enableIf(playingOrPaused && !WindowState.showingPopover)
        
        let loop = player.playbackLoop
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
        
        menuItem.image = Images.imgPlayedTrack
        menuItem.image?.size = Images.historyMenuItemImageSize
        
        DispatchQueue.global(qos: .userInteractive).async {
            
            if let img = AlbumArtManager.getArtForFile(bookmark.file), let imgCopy = img.copy() as? NSImage {
                
                DispatchQueue.main.async {
                    
                    imgCopy.size = Images.historyMenuItemImageSize
                    menuItem.image = imgCopy
                }
            }
        }
        
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
        
        do {
            
            try bookmarks.playBookmark(sender.bookmark!)
            
        } catch let error {
            
            if let fnfError = error as? FileNotFoundError {
                
                // This needs to be done async. Otherwise, other open dialogs could hang.
                DispatchQueue.main.async {
                    
                    // Position and display an alert with error info
                    _ = UIUtils.showAlert(DialogsAndAlerts.trackNotPlayedAlertWithError(fnfError, "Remove bookmark"))
                    self.bookmarks.deleteBookmarkWithName(sender.bookmark.name)
                }
            }
        }
        
        // TODO: Offer more options like "Point to the new location of the file". See RecorderViewController for reference.
    }
    
    @IBAction func manageBookmarksAction(_ sender: Any) {
        editorWindowController.showBookmarksEditor()
    }
}

// Helper class that stores a Bookmark for convenience (when playing it)
class BookmarksMenuItem: NSMenuItem {
    
    var bookmark: Bookmark!
}
