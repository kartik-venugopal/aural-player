import Cocoa

/*
    Window controller for the Chapters list window.
    Contains the Chapters list view and performs window snapping.
 */
class ChaptersListWindowController: NSWindowController, NSWindowDelegate {
    
    override var windowNibName: String? {return "ChaptersList"}
    
    private lazy var mainWindow: NSWindow = WindowFactory.getMainWindow()
    private lazy var playlistWindow: NSWindow = WindowFactory.getPlaylistWindow()
    private lazy var effectsWindow: NSWindow = WindowFactory.getEffectsWindow()
    
    private lazy var layoutManager: LayoutManagerProtocol = ObjectGraph.layoutManager
    
    private var theWindow: SnappingWindow {
        return self.window! as! SnappingWindow
    }
    
    private let viewPreferences: ViewPreferences = ObjectGraph.preferencesDelegate.getPreferences().viewPreferences
    
    @IBAction func closeWindowAction(_ sender: AnyObject) {
        SyncMessenger.publishActionMessage(ViewActionMessage(.toggleChaptersList))
    }
    
    // MARK - Window delegate functions
    
    func windowDidMove(_ notification: Notification) {
        
        // Check if movement was user-initiated (flag on window)
        if !theWindow.userMovingWindow {
            return
        }
        
        var snapped = false
        
        if viewPreferences.snapToWindows {
            
            // First check if window can be snapped to another app window
            snapped = UIUtils.checkForSnapToWindow(theWindow, mainWindow)
            
            if (!snapped) && layoutManager.isShowingPlaylist() {
                snapped = UIUtils.checkForSnapToWindow(theWindow, playlistWindow)
            }
            
            if (!snapped) && layoutManager.isShowingEffects() {
                snapped = UIUtils.checkForSnapToWindow(theWindow, effectsWindow)
            }
        }
        
        // If window doesn't need to be snapped to another window, check if it needs to be snapped to the visible frame
        if viewPreferences.snapToScreen && !snapped {
            UIUtils.checkForSnapToVisibleFrame(theWindow)
        }
    }
}
