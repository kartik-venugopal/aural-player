/*
    View controller for all app windows - main window and playlist window. Performs any and all display (or hiding), positioning, alignment, resizing, etc. of the windows and their constituent views.
 */

import Cocoa

// TODO: What to do if the playlist window moves off-screen ??? Should it always be resized so it is completely on-screen ???
class WindowViewController: NSViewController, NSWindowDelegate {
    
    // Main application window. Contains the Now Playing info box, player controls, and effects panel. Acts as a parent for the playlist window. Not manually resizable. Changes size when toggling playlist/effects views.
    @IBOutlet weak var mainWindow: NSWindow!
    
    // Detachable/movable/resizable window that contains the playlist view. Child of the main window.
    @IBOutlet weak var playlistWindow: NSWindow!
    
    // Buttons to toggle the playlist/effects views
    @IBOutlet weak var btnToggleEffects: NSButton!
    @IBOutlet weak var btnTogglePlaylist: NSButton!
    
    // Menu items to toggle the playlist and effects views
    @IBOutlet weak var viewPlaylistMenuItem: NSMenuItem!
    @IBOutlet weak var viewEffectsMenuItem: NSMenuItem!
    
    // The box that encloses the effects panel
    @IBOutlet weak var fxBox: NSBox!
    
    // Remembers if/where the playlist window has been docked with the main window
    private var playlistDockState: PlaylistDockState = .bottom
    
    // Flag to indicate that a window move/resize operation was initiated by the app (as opposed to by the user)
    private var automatedPlaylistMoveOrResize: Bool = false
    
    // Remembers the relationship (in terms of location co-ordinates) of the playlist window to the main window
    private var playlistWindowOffset: CGPoint?
    
    // Convenient accessor to the screen object
    private let screen: NSScreen = NSScreen.main()!
    
    // Convenient accessor to the screen's width
    private var screenWidth: CGFloat = {
        return NSScreen.main()!.frame.width
    }()
    
    // Convenient accessor to the screen's height
    private var screenHeight: CGFloat = {
        return NSScreen.main()!.frame.height
    }()
    
    override func viewDidLoad() {
        
        WindowState.window = self.mainWindow
        
        let appState = ObjectGraph.getUIAppState()
        
        if (appState.hideEffects) {
            toggleEffects(false)
        }
        
        mainWindow.setFrameOrigin(appState.windowLocation)
        mainWindow.isMovableByWindowBackground = true
        mainWindow.makeKeyAndOrderFront(self)
        
        playlistWindow.isMovableByWindowBackground = true
        playlistWindow.delegate = self
        
        let playlistLocation = appState.playlistLocation
        
        switch playlistLocation {
            
        case .bottom:
            dockPlaylistBottom()
            
        case .left:
            dockPlaylistLeft()
            
        case .right:
            dockPlaylistRight()
        }
        
        if (appState.hidePlaylist) {
            hidePlaylist(false)
        } else {
            showPlaylist(false)
        }
    }
    
    @IBAction func hideAction(_ sender: AnyObject) {
        mainWindow.miniaturize(self)
    }
    
    @IBAction func closeAction(_ sender: AnyObject) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func togglePlaylistAction(_ sender: AnyObject) {
        togglePlaylist()
    }
    
    @IBAction func dockPlaylistRightAction(_ sender: AnyObject) {
        dockPlaylistRight()
    }
    
    // The "resize" argument indicates whether or not the playlist needs to be resized. This is not necessary when simply toggling the playlist view, which only needs to restore its position on-screen, without changing its size.
    private func dockPlaylistRight(_ resize: Bool = true) {
        
        // Mark the flag to indicate that an automated move/resize operation is now taking place
        automatedPlaylistMoveOrResize = true
        
        // Add bottom edge to the main window, if necessary
        resizeMainWindow(playlistShown: false, effectsShown: !fxBox.isHidden, true)
        
        // Calculate new position and size of playlist window, in relation to the main window
        
        var playlistFrame = playlistWindow.frame
        
        // By default, the playlist window will be positioned relative to the right and bottom edges of the main window
        let playlistX = mainWindow.x + mainWindow.width
        var playlistY = mainWindow.y
        playlistFrame.origin = NSPoint(x: playlistX, y: playlistY)
        
        if (resize) {
            
            // When resizing, need to calculate new size
            
            let maxWidth = max(screenWidth - playlistX, UIConstants.minPlaylistWidth)
            let playlistWidth = min(playlistWindow.width, maxWidth)
            let playlistHeight = mainWindow.height
            playlistFrame.size = NSMakeSize(playlistWidth, playlistHeight)
            
        } else if (playlistWindowOffset != nil) {
            
            // When not resizing, need to remember the last offset of the playlist window in relation to the main window, and use it to calculate the new position
            
            playlistY = (mainWindow.y + mainWindow.height) - playlistWindowOffset!.y - playlistWindow.height
            playlistFrame.origin = NSPoint(x: playlistX, y: playlistY)
            
            // Invalidate the offset once used
            playlistWindowOffset = nil
        }
        
        // Dock the playlist window, and set the dock state variable
        playlistWindow.setFrame(playlistFrame, display: true, animate: false)
        playlistDockState = .right
        WindowState.playlistLocation = .right
        
        // Update the flag to indicate that an automated move/resize operation is no longer taking place
        automatedPlaylistMoveOrResize = false
    }
    
    @IBAction func dockPlaylistLeftAction(_ sender: AnyObject) {
        dockPlaylistLeft()
    }
    
    // The "resize" argument indicates whether or not the playlist needs to be resized. This is not necessary when simply toggling the playlist view, which only needs to restore its position on-screen, without changing its size.
    private func dockPlaylistLeft(_ resize: Bool = true) {
        
        // Mark the flag to indicate that an automated move/resize operation is now taking place
        automatedPlaylistMoveOrResize = true
        
        // Add bottom edge to the main window, if necessary
        resizeMainWindow(playlistShown: false, effectsShown: !fxBox.isHidden, true)
        
        var playlistFrame = playlistWindow.frame
        
        // Calculate new position and size of playlist window, in relation to the main window
        
        // By default, the playlist window will be positioned relative to the left and bottom edges of the main window
        var playlistWidth: CGFloat = playlistWindow.width
        var playlistX = mainWindow.x - playlistWidth
        var playlistY = mainWindow.y
        
        if (resize) {
            
            // When resizing, need to calculate new size
            
            let playlistHeight = mainWindow.height
            let maxWidth = max(mainWindow.x, UIConstants.minPlaylistWidth)
            playlistWidth = min(playlistWindow.width, maxWidth)
            playlistFrame.size = NSMakeSize(playlistWidth, playlistHeight)
            
            playlistX = mainWindow.x - playlistWidth
            
        } else if (playlistWindowOffset != nil) {
            
            // When not resizing, need to remember the last offset of the playlist window in relation to the main window, and use it to calculate the new position
            
            playlistY = (mainWindow.y + mainWindow.height) - playlistWindowOffset!.y - playlistWindow.height
            
            // Invalidate the offset once used
            playlistWindowOffset = nil
        }
        
        playlistFrame.origin = NSPoint(x: playlistX, y: playlistY)
        
        // Dock the playlist window, and set the dock state variable
        playlistWindow.setFrame(playlistFrame, display: true, animate: false)
        playlistDockState = .left
        WindowState.playlistLocation = .left
        
        // Update the flag to indicate that an automated move/resize operation is no longer taking place
        automatedPlaylistMoveOrResize = false
    }
    
    @IBAction func dockPlaylistBottomAction(_ sender: AnyObject) {
        dockPlaylistBottom()
    }
    
    private func dockPlaylistBottom(_ resize: Bool = true) {
        
        // Mark the flag to indicate that an automated move/resize operation is now taking place
        automatedPlaylistMoveOrResize = true
        
        // Add bottom edge to the main window, if necessary
        resizeMainWindow(playlistShown: true, effectsShown: !fxBox.isHidden, true)
        
        // Calculate new position and size of playlist window, in relation to the main window
        
        var playlistFrame = playlistWindow.frame
        var playlistHeight: CGFloat = playlistWindow.height
        
        if (resize) {
            
            // When resizing, need to calculate new size
            
            let playlistWidth = mainWindow.width
            let maxHeight = max(mainWindow.y, UIConstants.minPlaylistHeight)
            playlistHeight = min(playlistWindow.height, maxHeight)
            playlistFrame.size = NSMakeSize(playlistWidth, playlistHeight)
        }
        
        // Calculate the new position, which is a function of the new size
        var playlistX = mainWindow.x
        let playlistY = mainWindow.y - playlistHeight
        playlistFrame.origin = NSPoint(x: playlistX, y: playlistY)
        
        if (!resize && playlistWindowOffset != nil) {
            
            // When not resizing, need to remember the last offset of the playlist window in relation to the main window, and use it to calculate the new position
            
            playlistX = (mainWindow.x + mainWindow.width) - playlistWindowOffset!.x - playlistWindow.width
            playlistFrame.origin = NSPoint(x: playlistX, y: playlistY)
            
            // Invalidate the offset once used
            playlistWindowOffset = nil
        }
        
        // Dock the playlist window, and set the dock state variable
        playlistWindow.setFrame(playlistFrame, display: true, animate: false)
        playlistDockState = .bottom
        WindowState.playlistLocation = .bottom
        
        // Update the flag to indicate that an automated move/resize operation is no longer taking place
        automatedPlaylistMoveOrResize = false
    }
    
    // Simply repositions the playlist at the bottom of the main window (without docking it). This is useful when the playlist is already docked at the bottom, but the main window has been resized (e.g. when the effects view is toggled).
    private func repositionPlaylistBottom() {
        
        // Mark the flag to indicate that an automated move/resize operation is now taking place
        automatedPlaylistMoveOrResize = true
        
        // Calculate the new position of the playlist window, in relation to the main window
        
        var playlistFrame = playlistWindow.frame
        let playlistHeight: CGFloat = playlistWindow.height
        
        let playlistX = playlistWindow.x
        let playlistY = mainWindow.y - playlistHeight
        playlistFrame.origin = NSPoint(x: playlistX, y: playlistY)
        
        // Reposition the playlist window at the bottom of the main window
        playlistWindow.setFrame(playlistFrame, display: true, animate: false)
        
        // Update the flag to indicate that an automated move/resize operation is no longer taking place
        automatedPlaylistMoveOrResize = false
    }
    
    @IBAction func maximizePlaylistAction(_ sender: AnyObject) {
        maximizePlaylist()
    }
    
    @IBAction func maximizePlaylistHorizontalAction(_ sender: AnyObject) {
        maximizePlaylist(true, false)
    }
    
    @IBAction func maximizePlaylistVerticalAction(_ sender: AnyObject) {
        maximizePlaylist(false, true)
    }
    
    private func maximizePlaylist(_ horizontal: Bool = true, _ vertical: Bool = true) {
    
        // Mark the flag to indicate that an automated move/resize operation is now taking place
        automatedPlaylistMoveOrResize = true
        
        var playlistFrame = playlistWindow.frame
        var playlistWidth: CGFloat, playlistHeight: CGFloat
        var playlistX: CGFloat, playlistY: CGFloat
        
        let mainWindowX: CGFloat = mainWindow.x
        let mainWindowY: CGFloat = mainWindow.y
        
        // Calculate new position and size of playlist window, in relation to the main window, depending on current dock state
        
        switch playlistDockState {
        
        case .bottom:
            
            playlistWidth = screenWidth
            playlistHeight = mainWindowY
            
            playlistX = 0
            playlistY = 0
            
        case .right:
            
            playlistWidth = screenWidth - (mainWindowX + mainWindow.width)
            playlistHeight = screenHeight
            
            playlistX = playlistWindow.x
            playlistY = 0
            
        case .left:
            
            playlistWidth = mainWindowX
            playlistHeight = screenHeight
            
            playlistX = 0
            playlistY = 0
            
        case .none:
            
            // When the playlist is not docked, vertical maximizing will take preference over horizontal maximizing (i.e. portrait orientation)
            
            playlistWidth = playlistWindow.width
            playlistHeight = playlistWindow.height
            
            playlistX = playlistWindow.x
            playlistY = playlistWindow.y
            
            // These variables will determine the bounds of the new playlist window frame
            var minX: CGFloat = 0, minY: CGFloat = 0, maxX: CGFloat = screenWidth, maxY: CGFloat = screenHeight
            
            // Figure out where the playlist window is, in relation to the main window
            if ((playlistX + playlistWidth) < mainWindowX) {
                
                // Entire playlist window is to the left of the main window. Maximize to the left of the main window.
                maxX = mainWindowX - 1
                
            } else if (playlistX > mainWindowX + mainWindow.width) {
                
                // Entire playlist window is to the right of the main window. Maximize to the right of the main window.
                minX = mainWindowX + mainWindow.width
                
            } else if ((playlistY + playlistHeight) < mainWindowY) {
                
                // Entire playlist window is below the main window. Maximize below the main window.
                maxY = mainWindowY - 1
                
            } else if (playlistY > (mainWindowY + mainWindow.height)) {
                
                // Entire playlist window is above the main window. Maximize above the main window.
                minY = mainWindowY + mainWindow.height
                
            } else if (playlistX < mainWindowX) {
                
                // Left edge of playlist window is to the left of the left edge of the main window, and the 2 windows overlap. Maximize to the left of the main window.
                maxX = mainWindowX - 1
                
            } else if (playlistX > mainWindowX) {
                
                // Left edge of playlist window is to the right of the left edge of the main window, and the 2 windows overlap. Maximize to the right of the main window.
                minX = mainWindowX + mainWindow.width
            }
            
            playlistX = minX
            playlistY = minY
            
            playlistWidth = maxX - minX + 1
            playlistHeight = maxY - minY + 1
        }
        
        if (horizontal && vertical) {
        
            playlistFrame.origin = NSPoint(x: playlistX, y: playlistY)
            playlistFrame.size = NSMakeSize(playlistWidth, playlistHeight)
            
        } else if (horizontal) {
            
            playlistFrame.origin = NSPoint(x: playlistX, y: playlistWindow.y)
            playlistFrame.size = NSMakeSize(playlistWidth, playlistWindow.height)
            
        } else {
            
            // Vertical only
            playlistFrame.origin = NSPoint(x: playlistWindow.x, y: playlistY)
            playlistFrame.size = NSMakeSize(playlistWindow.width, playlistHeight)
        }
        
        // Maximize the playlist window, within the visible frame of the screen (i.e. don't overlap with menu bar or dock)
        playlistWindow.setFrame(playlistFrame.intersection(screen.visibleFrame), display: true, animate: false)
        
        // Update the flag to indicate that an automated move/resize operation is no longer taking place
        automatedPlaylistMoveOrResize = false
    }
    
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        toggleEffects(true)
    }
    
    private func togglePlaylist() {
        
        if (!playlistWindow.isVisible) {
            showPlaylist()
        } else {
            hidePlaylist()
        }
    }
    
    private func showPlaylist(_ dock: Bool = true) {
        
        resizeMainWindow(playlistShown: playlistDockState == .bottom, effectsShown: !fxBox.isHidden, false)
        
        // Show playlist window and update UI controls
        
        mainWindow.addChildWindow(playlistWindow, ordered: NSWindowOrderingMode.below)
        playlistWindow.setIsVisible(true)
        btnTogglePlaylist.state = 1
        btnTogglePlaylist.image = UIConstants.imgPlaylistOn
        viewPlaylistMenuItem.state = 1
        WindowState.showingPlaylist = true
        
        if (dock) {
            
            // Re-dock the playlist window, as per the dock state
            
            if (playlistDockState == .bottom) {
                dockPlaylistBottom(false)
            } else if (playlistDockState == .right) {
                dockPlaylistRight(false)
            } else if (playlistDockState == .left) {
                dockPlaylistLeft(false)
            } else {
                // Not docked. Use the saved offset to position the playlist window
                repositionPlaylistWithOffset()
            }
        }
    }
    
    // Repositions the playlist window according to the remembered relationship (in terms of location co-ordinates) of the playlist window to the main window
    
    // TODO: What if the offset moves the playlist window off-screen ???
    private func repositionPlaylistWithOffset() {
        
        if (playlistWindowOffset != nil) {
        
            // Mark the flag to indicate that an automated move/resize operation is now taking place
            automatedPlaylistMoveOrResize = true
            
            var playlistFrame = playlistWindow.frame
            
            // Calculate the new playlist window position, as a function of the main window position and offset
            
            let playlistX = (mainWindow.x + mainWindow.width) - playlistWindowOffset!.x - playlistWindow.width
            let playlistY = (mainWindow.y + mainWindow.height) - playlistWindowOffset!.y - playlistWindow.height
            playlistWindowOffset = nil
            
            playlistFrame.origin = NSPoint(x: playlistX, y: playlistY)
            
            // Reposition the playlist window
            playlistWindow.setFrame(playlistFrame, display: true, animate: false)
            
            // Update the flag to indicate that an automated move/resize operation is no longer taking place
            automatedPlaylistMoveOrResize = false
        }
    }
    
    // The "noteOffset" flag indicates whether or not the offset of the playlist window in relation to the main window is valid (and to be remembered). When starting up, the offset is invalid, because this method is called automatically (i.e. not by the user).
    private func hidePlaylist(_ noteOffset: Bool = true) {
        
        if (noteOffset) {
            // Whenever the playlist window is hidden, save its top right corner offset in relation to the main window. This will be used later whent the playlist is shown again.
            let offsetX = (mainWindow.x + mainWindow.width) - (playlistWindow.x + playlistWindow.width)
            let offsetY = (mainWindow.y + mainWindow.height) - (playlistWindow.y + playlistWindow.height)
            playlistWindowOffset = NSPoint(x: offsetX, y: offsetY)
        }
        
        // Add bottom edge to the main window
        resizeMainWindow(playlistShown: false, effectsShown: !fxBox.isHidden, false)
        
        // Hide playlist window and update UI controls
        
        playlistWindow.setIsVisible(false)
        btnTogglePlaylist.state = 0
        btnTogglePlaylist.image = UIConstants.imgPlaylistOff
        viewPlaylistMenuItem.state = 0
        WindowState.showingPlaylist = false
    }
    
    private func toggleEffects(_ animate: Bool) {
        
        if (fxBox.isHidden) {
            
            // Show effects view and update UI controls
            
            resizeMainWindow(playlistShown: playlistWindow.isVisible && playlistDockState == .bottom, effectsShown: true, animate)
            fxBox.isHidden = false
            btnToggleEffects.state = 1
            btnToggleEffects.image = UIConstants.imgEffectsOn
            viewEffectsMenuItem.state = 1
            WindowState.showingEffects = true
            
        } else {
            
            // Hide effects view and update UI controls
            
            fxBox.isHidden = true
            resizeMainWindow(playlistShown: playlistWindow.isVisible && playlistDockState == .bottom, effectsShown: false, animate)
            btnToggleEffects.state = 0
            btnToggleEffects.image = UIConstants.imgEffectsOff
            viewEffectsMenuItem.state = 0
            WindowState.showingEffects = false
        }
        
        // Move the playlist window, if necessary
        if (playlistWindow.isVisible && playlistDockState == .bottom) {
            repositionPlaylistBottom()
        }
    }
    
    /* 
        Called when toggling the playlist/effects views and/or docking the playlist window. Resizes the main window depending on which views are to be shown (i.e. either displayed on the main window or attached to it).
     
        The "playlistShown" parameter will be true only when the playlist window has been docked at the bottom of the main window, and false otherwise.
     */
    private func resizeMainWindow(playlistShown: Bool, effectsShown: Bool, _ animate: Bool) {
        
        var wFrame = mainWindow.frame
        let oldOrigin = wFrame.origin
        
        var newHeight: CGFloat
        
        // Calculate the new height based on which of the 2 views are shown
        
        if (effectsShown && playlistShown) {
            newHeight = UIConstants.windowHeight_playlistAndEffects
        } else if (effectsShown) {
            newHeight = UIConstants.windowHeight_effectsOnly
        } else if (playlistShown) {
            newHeight = UIConstants.windowHeight_playlistOnly
        } else {
            newHeight = UIConstants.windowHeight_compact
        }
        
        let oldHeight = wFrame.height
        
        // If no change in height is necessary, do nothing
        if (oldHeight == newHeight) {
            return
        }
        
        let shrinking: Bool = newHeight < oldHeight
        
        wFrame.size = NSMakeSize(mainWindow.width, newHeight)
        wFrame.origin = NSMakePoint(oldOrigin.x, shrinking ? oldOrigin.y + (oldHeight - newHeight) : oldOrigin.y - (newHeight - oldHeight))
        
        // Resize the main window
        mainWindow.setFrame(wFrame, display: true, animate: false)
    }
    
    // When the playlist window is moved manually by the user, it may be moved such that it is no longer docked (i.e. positioned adjacent) to the main window. This method checks the position of the playlist window after the resize operation, invalidates the playlist window's dock state if necessary, and adds a thin bottom edge to the main window (for aesthetics) if the playlist is no longer docked.
    func windowDidMove(_ notification: Notification) {
        
        // If this is an app-initiated move operation, do nothing
        if (automatedPlaylistMoveOrResize) {
            return
        }
        
        // If the mouse cursor is within the playlist window, it means that only the playlist window is being moved. If the main window is being moved, that does not affect the playlist dock state.
        if (playlistWindow.frame.contains(NSEvent.mouseLocation())) {
            
            updatePlaylistWindowDockState()
            
            if (playlistDockState == .none) {
                
                // Add the bottom edge to the main window, if it is not already present
                resizeMainWindow(playlistShown: false, effectsShown: !fxBox.isHidden, false)
            }
        }
    }
    
    // When the playlist window is resized manually by the user, it may be resized such that it is no longer docked (i.e. positioned adjacent) to the main window.
    func windowDidResize(_ notification: Notification) {
        
        // If playlist was not docked prior to resize, or this is an app-initiated resize operation (i.e. either dock or maximize), do nothing
        if (playlistDockState == .none || automatedPlaylistMoveOrResize) {
            return
        }
        
        updatePlaylistWindowDockState()
    }
    
    // This method checks the position of the playlist window after the resize operation, and invalidates the playlist window's dock state if necessary.
    private func updatePlaylistWindowDockState() {
        
        if (playlistDockState == .bottom) {
            
            // Check if playlist window's top edge is adjacent to main window's bottom edge
            if ((playlistWindow.y + playlistWindow.height) != mainWindow.y) {
                playlistDockState = .none
                WindowState.playlistLocation = AppDefaults.playlistLocation
            }
            
        } else if (playlistDockState == .right) {
            
            // Check if playlist window's left edge is adjacent to main window's right edge
            if ((mainWindow.x + mainWindow.width) != playlistWindow.x) {
                playlistDockState = .none
                WindowState.playlistLocation = AppDefaults.playlistLocation
            }
            
        } else if (playlistDockState == .left) {
            
            // Check if playlist window's right edge is adjacent to main window's left edge
            if ((playlistWindow.x + playlistWindow.width) != mainWindow.x) {
                playlistDockState = .none
                WindowState.playlistLocation = AppDefaults.playlistLocation
            }
        }
    }
}

// Provides convenient access to the state of the main and playlist windows, across the app
class WindowState {
    
    static var window: NSWindow?
    static var showingPlaylist: Bool = AppDefaults.showPlaylist
    static var showingEffects: Bool = AppDefaults.showEffects
    static var playlistLocation: PlaylistLocations = AppDefaults.playlistLocation
    
    static func location() -> NSPoint {
        return window!.frame.origin
    }
    
    static func getPersistentState() -> UIState {
        
        let uiState = UIState()
        
        let windowOrigin = window!.frame.origin
        uiState.windowLocationX = Float(windowOrigin.x)
        uiState.windowLocationY = Float(windowOrigin.y)
        
        uiState.showEffects = showingEffects
        uiState.showPlaylist = showingPlaylist
        
        uiState.playlistLocation = playlistLocation
        
        return uiState
    }
}

// Enumerates all possible dock states of the playlist window, in relation to the main window
enum PlaylistDockState: String {
    
    // Playlist has been docked on the bottom of the main window
    case bottom
    
    // Playlist has been docked on the right side of the main window
    case right
    
    // Playlist has been docked on the left side of the main window
    case left
    
    // Playlist is not docked
    case none
}

// Accessors for convenience/conciseness
extension NSWindow {
    
    var width: CGFloat {
        return self.frame.width
    }
    
    var height: CGFloat {
        return self.frame.height
    }
    
    // X co-ordinate of location
    var x: CGFloat {
        return self.frame.origin.x
    }
    
    // Y co-ordinate of location
    var y: CGFloat {
        return self.frame.origin.y
    }
}
