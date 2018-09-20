import Cocoa

/*
    Manages and provides actions for the Bookmarks menu that displays bookmarks that can be opened by the player.
 */
class BookmarksMenuController: NSObject, NSMenuDelegate, StringInputClient {
    
    private var bookmarks: BookmarksDelegateProtocol = ObjectGraph.getBookmarksDelegate()
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol = ObjectGraph.getPlaybackDelegate()
    
    @IBOutlet weak var theMenu: NSMenu!
    
    @IBOutlet weak var addBookmarkMenuItem: NSMenuItem!
    
    // Changes whenever a bookmark is added
    private var defaultBookmarkName: String?
    private var bookmarkedTrack: Track?
    private var bookmarkedTrackPosition: Double?
    
    private lazy var bookmarkNamePopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
 
    // One-time setup, when the menu loads
    override func awakeFromNib() {
        
    }
    
    // Before the menu opens, re-create the menu items from the model
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Can't add a bookmark if no track is playing
        addBookmarkMenuItem.isEnabled = player.getPlaybackState() != .noTrack
        
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
    @IBAction func bookmarkAction(_ sender: Any) {
        
        // Mark the playing track and position
        bookmarkedTrack = player.getPlayingTrack()!.track
        bookmarkedTrackPosition = player.getSeekPosition().timeElapsed
        
        defaultBookmarkName = String(format: "%@ (%@)", bookmarkedTrack!.conciseDisplayName, StringUtils.formatSecondsToHMS(bookmarkedTrackPosition!))
        
        // Show popover
        bookmarkNamePopover.show(WindowState.window.contentView!, NSRectEdge.minX)
    }
    
    // When a bookmark menu item is clicked, the item is played
    @IBAction fileprivate func playSelectedItemAction(_ sender: BookmarksMenuItem) {
        bookmarks.playBookmark(sender.bookmark)
    }
    
    // MARK - StringInputClient functions
    
    func getInputPrompt() -> String {
        return "Enter a bookmark name:"
    }
    
    func getDefaultValue() -> String? {
        return defaultBookmarkName!
    }
    
    func validate(_ string: String) -> (valid: Bool, errorMsg: String?) {
        
        let valid = !bookmarks.bookmarkWithNameExists(string)
        
        if (!valid) {
            return (false, "A bookmark with this name already exists !")
        } else {
            return (true, nil)
        }
    }
    
    // Receives a new EQ preset name and saves the new preset
    func acceptInput(_ string: String) {
        _ = bookmarks.addBookmark(string, bookmarkedTrack!.file, bookmarkedTrackPosition!)
    }
}

class BookmarksMenuItem: NSMenuItem {
    
    var bookmark: Bookmark!
}
