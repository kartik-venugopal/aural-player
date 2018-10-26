import Cocoa

/*
    Manages and provides actions for the Bookmarks menu that displays bookmarks that can be opened by the player.
 */
class BookmarksMenuController: NSObject, NSMenuDelegate, StringInputClient, ActionMessageSubscriber {
    
    private var bookmarks: BookmarksDelegateProtocol = ObjectGraph.getBookmarksDelegate()
    
    // Delegate used to perform playback
    private let player: PlaybackDelegateProtocol = ObjectGraph.getPlaybackDelegate()
    
    @IBOutlet weak var theMenu: NSMenu!
    
    @IBOutlet weak var bookmarkTrackPositionMenuItem: NSMenuItem!
    @IBOutlet weak var bookmarkTrackSegmentLoopMenuItem: NSMenuItem!
    @IBOutlet weak var manageBookmarksMenuItem: NSMenuItem!
    
    // Changes whenever a bookmark is added
    private var defaultBookmarkName: String?
    private var bookmarkedTrack: Track?
    private var bookmarkedTrackStartPosition: Double?
    private var bookmarkedTrackEndPosition: Double?
    
    private lazy var editorWindowController: EditorWindowController = WindowFactory.getEditorWindowController()
    
    private lazy var bookmarkNamePopover: StringInputPopoverViewController = StringInputPopoverViewController.create(self)
 
    // One-time setup, when the menu loads
    override func awakeFromNib() {
        SyncMessenger.subscribe(actionTypes: [.bookmark], subscriber: self)
    }
    
    // Before the menu opens, re-create the menu items from the model
    func menuNeedsUpdate(_ menu: NSMenu) {
        
        // Can't add a bookmark if no track is playing or if the popover is currently being shown
        bookmarkTrackPositionMenuItem.enableIf(player.getPlaybackState() != .noTrack && !bookmarkNamePopover.isShown())
        
        let hasCompleteLoop = player.getPlaybackLoop() != nil && player.getPlaybackLoop()!.isComplete()
        bookmarkTrackSegmentLoopMenuItem.enableIf(player.getPlaybackState() != .noTrack && hasCompleteLoop)
        
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
        
        // Mark the playing track and position
        bookmarkedTrack = player.getPlayingTrack()!.track
        bookmarkedTrackStartPosition = player.getSeekPosition().timeElapsed
        bookmarkedTrackEndPosition = nil
        
        defaultBookmarkName = String(format: "%@ (%@)", bookmarkedTrack!.conciseDisplayName, StringUtils.formatSecondsToHMS(bookmarkedTrackStartPosition!))
        
        // Show popover
        let loc = ViewFactory.getLocationForBookmarkPrompt()
        bookmarkNamePopover.show(loc.view, loc.edge)
    }
    
    // When a bookmark menu item is clicked, the item is played
    @IBAction func bookmarkTrackSegmentLoopAction(_ sender: Any) {
        
        // Mark the playing track and position
        bookmarkedTrack = player.getPlayingTrack()!.track
        if let loop = player.getPlaybackLoop() {
            
            if loop.isComplete() {
                
                bookmarkedTrackStartPosition = loop.startTime
                bookmarkedTrackEndPosition = loop.endTime
                
                let startTime = StringUtils.formatSecondsToHMS(loop.startTime)
                let endTime = StringUtils.formatSecondsToHMS(loop.endTime!)
                
                defaultBookmarkName = String(format: "%@ (%@ ⇄ %@)", bookmarkedTrack!.conciseDisplayName, startTime, endTime)
                
                // Show popover
                let loc = ViewFactory.getLocationForBookmarkPrompt()
                bookmarkNamePopover.show(loc.view, loc.edge)
            }
        }
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
        
        if (bookmarkedTrackEndPosition == nil) {
            
            // Track position
            _ = bookmarks.addBookmark(string, bookmarkedTrack!.file, bookmarkedTrackStartPosition!)
            
        } else {
            
            // Loop
            _ = bookmarks.addBookmark(string, bookmarkedTrack!.file, bookmarkedTrackStartPosition!, bookmarkedTrackEndPosition!)
        }
    }
    
    // MARK - Message handling
    
    func getID() -> String {
        return self.className
    }
    
    func consumeMessage(_ message: ActionMessage) {
        
        if message.actionType == .bookmark {
            bookmarkTrackPositionAction(self)
        }
    }
}

// Helper class that stores a Bookmark for convenience (when playing it)
class BookmarksMenuItem: NSMenuItem {
    
    var bookmark: Bookmark!
}
