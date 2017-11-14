import Cocoa

/*
    Window controller for the main window, but also controls the positioning and sizing of the playlist window. Performs any and all display (or hiding), positioning, alignment, resizing, etc. of both the main window and playlist window.
 */
class MainWindowController: NSWindowController, NSWindowDelegate, ActionMessageSubscriber {
    
    // Main application window. Contains the Now Playing info box, player controls, and effects panel. Acts as a parent for the playlist window. Not manually resizable. Changes size when toggling playlist/effects views.
    private var mainWindow: NSWindow!
    
    // Detachable/movable/resizable window that contains the playlist view. Child of the main window.
    private let playlistWindow: NSWindow = WindowManager.getPlaylistWindow()
    
    // Buttons to toggle the playlist/effects views
    @IBOutlet weak var btnToggleEffects: NSButton!
    @IBOutlet weak var btnTogglePlaylist: NSButton!
    
    // The box that encloses the effects panel
    @IBOutlet weak var fxBox: NSBox!
    
    // Remembers if/where the playlist window has been docked with the main window
    private var playlistDockState: PlaylistDockState = .bottom
    
    // Flag to indicate that a window move/resize operation was initiated by the app (as opposed to by the user)
    private var automatedPlaylistMoveOrResize: Bool = false
    
    private var visibleFrame: NSRect = {
        return NSScreen.main()!.visibleFrame
    }()
    
    convenience init() {
        self.init(windowNibName: "MainWindow")
    }
    
    // MARK: Setup
    
    override func windowDidLoad() {
        
        // Set window properties
        
        self.mainWindow = self.window!
        WindowState.window = self.mainWindow
        
        [mainWindow, playlistWindow].forEach({$0?.isMovableByWindowBackground = true})
        
        mainWindow.makeKeyAndOrderFront(self)
        playlistWindow.delegate = self
        
        // Subscribe to various messages
        SyncMessenger.subscribe(actionTypes: [.dockLeft, .dockRight, .dockBottom, .maximize, .maximizeHorizontal, .maximizeVertical, .togglePlaylist, .toggleEffects], subscriber: self)
        
        // Lay out the windows
        initialWindowLayout()
    }
    
    // One-time seutp. Lays out both windows per user preferences and saved app state.
    private func initialWindowLayout() {
        
        let appState = ObjectGraph.getUIAppState()
        
        if (appState.hideEffects) {
            toggleEffects(false)
        }
        
        // If a specific position is specified, use it
        if let mainWindowOrigin = appState.windowLocationXY {
            mainWindow.setFrameOrigin(mainWindowOrigin)
        } else {
            // Need to calculate position
            positionMainWindowRelativeToScreen(appState.windowLocationOnStartup.windowLocation, appState.playlistLocation, !appState.hidePlaylist)
        }
        
        // Show and dock the playlist, if needed
        playlistDockState = appState.playlistLocation.toPlaylistDockState()
        if (!appState.hidePlaylist) {
            showPlaylist(false)
        }
    }
    
    // Positions the main app window relative to screen, per user preference. For example, "Top Left" or "Bottom Center"
    private func positionMainWindowRelativeToScreen(_ relativeLoc: WindowLocations, _ playlistLocation: PlaylistLocations, _ playlistShown: Bool) {
        
        // Calculate total width/height, taking both possible windows into account
        let width: CGFloat = playlistShown && playlistLocation != .bottom ? mainWindow.width + playlistWindow.width : mainWindow.width
        let height: CGFloat = playlistShown && playlistLocation == .bottom ? mainWindow.height + playlistWindow.height : mainWindow.height
        
        // Calculate location from the size and relative screen location
        let location = UIUtils.windowPositionRelativeToScreen(width, height, relativeLoc)
        
        let mainWindowX = playlistShown && playlistLocation == .left ? location.x + playlistWindow.width : location.x
        let mainWindowY = playlistShown && playlistLocation == .bottom ? location.y + playlistWindow.height : location.y
        
        // Reposition the main window
        mainWindow.setFrameOrigin(NSPoint(x: mainWindowX, y: mainWindowY))
    }
    
    // MARK: Playlist docking functions
    
    // Docks the playlist below the main window
    private func dockBottom(_ animate: Bool = true) {
        
        resizeMainWindow(true, WindowState.showingEffects)
        
        playlistDockState = .bottom
        let playlistHeight = min(playlistWindow.height, mainWindow.remainingHeight)
        
        dock(mainWindow.origin
            .applying(CGAffineTransform.init(translationX: 0, y: -playlistHeight)), NSMakeSize(mainWindow.width, playlistHeight), animate)
    }
    
    // Docks the playlist to the left of the main window
    private func dockLeft(_ animate: Bool = true) {
        
        resizeMainWindow(false, WindowState.showingEffects)
        
        playlistDockState = .left
        let playlistWidth = min(mainWindow.remainingWidth, playlistWindow.width)
        
        dock(mainWindow.frame.origin
            .applying(CGAffineTransform.init(translationX: -playlistWidth, y: 0)), NSMakeSize(playlistWidth, mainWindow.height), animate)
    }
    
    // Docks the playlist to the right of the main window
    private func dockRight(_ animate: Bool = true) {
        
        resizeMainWindow(false, WindowState.showingEffects)
        
        playlistDockState = .right
        let playlistWidth = min(mainWindow.remainingWidth, playlistWindow.width)
        
        dock(mainWindow.frame.origin
            .applying(CGAffineTransform.init(translationX: mainWindow.width, y: 0)), NSMakeSize(playlistWidth, mainWindow.height), animate)
    }
    
    // Docks the playlist with the main window, at a given location and size, and ensures that the entire playlist is visible after the dock
    private func dock(_ playlistWindowOrigin: NSPoint, _ playlistWindowSize: NSSize, _ animate: Bool = true) {
        
        var playlistFrame = playlistWindow.frame
        playlistFrame.origin = playlistWindowOrigin
        playlistFrame.size = playlistWindowSize
        
        automatedPlaylistMoveOrResize = true
        
        playlistWindow.setFrame(playlistFrame, display: true, animate: animate)
        ensurePlaylistVisible()
        
        automatedPlaylistMoveOrResize = false
    }
    
    // Moves both windows, if necessary, to ensure that they are both entirely visible on screen
    private func ensurePlaylistVisible() {
        
        // NOTE - This function, because of the playlist window's size constraints, will also automatically ensure that the main window is entirely visible
        
        switch playlistDockState {
            
        case .bottom:
            
            // Move windows up
            if playlistWindow.y < visibleFrame.minY {
                moveWindows(0, visibleFrame.minY - playlistWindow.y)
            }
            
        case .left:
            
            // Move windows to the right
            if playlistWindow.x < visibleFrame.minX {
                moveWindows(visibleFrame.minX - playlistWindow.x, 0)
            }
            
        case .right:
            
            // Move windows to the left
            if playlistWindow.maxX > visibleFrame.maxX {
                moveWindows(-(playlistWindow.maxX - visibleFrame.maxX), 0)
            }
            
        // Impossible
        default: return
            
        }
    }
    
    // Moves both windows a given number of pixels along the X and Y axes
    private func moveWindows(_ dx: CGFloat, _ dy: CGFloat) {
        
        [mainWindow, playlistWindow].forEach({
            $0.setFrameOrigin($0.origin.applying(CGAffineTransform.init(translationX: dx, y: dy)))
        })
    }
    
    // MARK: Playlist maximize functions
    
    // Maximizes the playlist horizontally
    private func maximizeHorizontal() {
        maximize(true, false)
    }
    
    // Maximizes the playlist vertically
    private func maximizeVertical() {
        maximize(false, true)
    }
    
    // Maximizes the playlist
    private func maximize(_ horizontal: Bool = true, _ vertical: Bool = true) {
        
        switch playlistDockState {
            
        case .bottom:   maximizeBottom(horizontal, vertical)
        
        case .right:    maximizeRight(horizontal, vertical)
            
        case .left:     maximizeLeft(horizontal, vertical)
            
        case .none:
            
            // When the playlist is not docked, vertical maximizing will take preference over horizontal maximizing (i.e. portrait orientation)
            
            // Figure out where the playlist window is, in relation to the main window
            if (playlistWindow.maxX < mainWindow.x) {
                
                // Playlist window is to the left of the main window. Maximize to the left of the main window.
                maximizeLeft(horizontal, vertical)
                
            } else if (playlistWindow.x >= mainWindow.maxX) {
                
                // Playlist window is to the right of the main window. Maximize to the right of the main window.
                maximizeRight(horizontal, vertical)
                
            } else if (playlistWindow.maxY < mainWindow.y) {
                
                // Entire playlist window is below the main window. Maximize below the main window.
                maximizeBottom(horizontal, vertical)
                
            } else if (playlistWindow.y >= mainWindow.maxY) {
                
                // Entire playlist window is above the main window. Maximize above the main window.
                maximizeTop(horizontal, vertical)

            } else if (playlistWindow.x < mainWindow.x) {
                
                // Left edge of playlist window is to the left of the left edge of the main window, and the 2 windows overlap. Maximize to the left of the main window.
                maximizeLeft(horizontal, vertical)
                
            } else if (playlistWindow.x >= mainWindow.x) {
                
                // Left edge of playlist window is to the right of the left edge of the main window, and the 2 windows overlap. Maximize to the right of the main window.
                maximizeRight(horizontal, vertical)
            }
        }
    }
    
    // Maximizes the playlist window to the left of the main window
    private func maximizeLeft(_ horizontal: Bool, _ vertical: Bool) {
        
        let playlistWidth = horizontal ? mainWindow.remainingWidth : playlistWindow.width
        let playlistHeight = vertical ? visibleFrame.height : playlistWindow.height
        
        let playlistX = horizontal ? visibleFrame.minX : playlistWindow.x
        let playlistY = vertical ? visibleFrame.minY : playlistWindow.y
        
        let mainWindowX = horizontal ? visibleFrame.minX + playlistWidth : mainWindow.x
        
        setWindowFrames(mainWindowX, mainWindow.y, playlistX, playlistY, playlistWidth, playlistHeight)
    }
    
    // Maximizes the playlist window to the right of the main window
    private func maximizeRight(_ horizontal: Bool, _ vertical: Bool) {
        
        let playlistWidth = horizontal ? mainWindow.remainingWidth : playlistWindow.width
        let playlistHeight = vertical ? visibleFrame.height : playlistWindow.height
        
        let playlistX = horizontal ? visibleFrame.minX + mainWindow.width : playlistWindow.x
        let playlistY = vertical ? visibleFrame.minY : playlistWindow.y
        
        let mainWindowX = horizontal ? visibleFrame.minX : mainWindow.x
        
        setWindowFrames(mainWindowX, mainWindow.y, playlistX, playlistY, playlistWidth, playlistHeight)
    }
    
    // Maximizes the playlist window below the main window
    private func maximizeBottom(_ horizontal: Bool, _ vertical: Bool) {
        
        let playlistWidth = horizontal ? visibleFrame.width : playlistWindow.width
        let playlistHeight = vertical ? mainWindow.remainingHeight : playlistWindow.height
        
        let playlistX = horizontal ? visibleFrame.minX : playlistWindow.x
        let playlistY = vertical ? visibleFrame.minY : playlistWindow.y
        
        let mainWindowY = vertical ? visibleFrame.height - mainWindow.height : mainWindow.y
        
        setWindowFrames(mainWindow.x, mainWindowY, playlistX, playlistY, playlistWidth, playlistHeight)
    }
    
    // Maximizes the playlist window above the main window
    private func maximizeTop(_ horizontal: Bool, _ vertical: Bool) {
        
        let playlistWidth = horizontal ? visibleFrame.width : playlistWindow.width
        let playlistHeight = vertical ? mainWindow.remainingHeight : playlistWindow.height
        
        let playlistX = horizontal ? visibleFrame.minX : playlistWindow.x
        let playlistY = vertical ? visibleFrame.height - mainWindow.height : playlistWindow.y
        
        let mainWindowY = vertical ? visibleFrame.minY : mainWindow.y
        
        setWindowFrames(mainWindow.x, mainWindowY, playlistX, playlistY, playlistWidth, playlistHeight)
    }
    
    // Adjusts both window frames to the given location and size (specified as co-ordinates)
    private func setWindowFrames(_ mainWindowX: CGFloat, _ mainWindowY: CGFloat, _ playlistX: CGFloat, _ playlistY: CGFloat, _ width: CGFloat, _ height: CGFloat) {
        
        automatedPlaylistMoveOrResize = true
        
        mainWindow.setFrameOrigin(NSPoint(x: mainWindowX, y: mainWindowY))
        
        var playlistFrame = playlistWindow.frame
        
        playlistFrame.origin = NSPoint(x: playlistX, y: playlistY)
        playlistFrame.size = NSSize(width: width, height: height)
        playlistWindow.setFrame(playlistFrame, display: true, animate: true)
        
        automatedPlaylistMoveOrResize = false
    }
    
    // MARK: View toggling functions
    
    // Shows/hides the playlist window
    @IBAction func togglePlaylistAction(_ sender: AnyObject) {
        togglePlaylist()
    }
    
    // Shows/hides the playlist window
    private func togglePlaylist() {
        
        if (!playlistWindow.isVisible) {
            showPlaylist()
        } else {
            hidePlaylist()
        }
    }
    
    // Shows the playlist window
    private func showPlaylist(_ animate: Bool = true) {
        
        resizeMainWindow(playlistDockState == .bottom, WindowState.showingEffects)
        
        // Show playlist window and update UI controls
        
        mainWindow.addChildWindow(playlistWindow, ordered: NSWindowOrderingMode.below)
        playlistWindow.setIsVisible(true)
        btnTogglePlaylist.state = 1
        btnTogglePlaylist.image = Images.imgPlaylistOn
        WindowState.showingPlaylist = true
        
        // Re-dock the playlist window, as per the previous dock state
        reDockPlaylist(animate)
    }
    
    // Docks the playlist window per its current dock state
    private func reDockPlaylist(_ animate: Bool = true) {
        
        switch playlistDockState {
            
        case .bottom, .none:    dockBottom(animate)
            
        case .left: dockLeft(animate)
            
        case .right: dockRight(animate)
            
        }
    }
   
    // Hides the playlist window
    private func hidePlaylist() {
        
        // Add bottom edge to the main window
        resizeMainWindow(false, WindowState.showingEffects)
        
        // Hide playlist window and update UI controls
        
        playlistWindow.setIsVisible(false)
        btnTogglePlaylist.state = 0
        btnTogglePlaylist.image = Images.imgPlaylistOff
        WindowState.showingPlaylist = false
    }
    
    // Shows/hides the effects panel on the main window
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        toggleEffects()
    }
    
    // Shows/hides the effects panel on the main window
    private func toggleEffects(_ animate: Bool = true) {
        
        if (!WindowState.showingEffects) {
            
            // Show effects view and update UI controls
            
            resizeMainWindow(playlistWindow.isVisible && playlistDockState == .bottom, true, animate)
            fxBox.isHidden = false
            btnToggleEffects.state = 1
            btnToggleEffects.image = Images.imgEffectsOn
            WindowState.showingEffects = true
            
            ensureMainWindowVisible()
            
        } else {
            
            // Hide effects view and update UI controls
            
            fxBox.isHidden = true
            resizeMainWindow(playlistWindow.isVisible && playlistDockState == .bottom, false, animate)
            btnToggleEffects.state = 0
            btnToggleEffects.image = Images.imgEffectsOff
            WindowState.showingEffects = false
        }
        
        // Move the playlist window, if necessary
        if (WindowState.showingPlaylist && playlistDockState == .bottom) {
            repositionPlaylistBottom()
        }
    }
    
    // Simply repositions the playlist at the bottom of the main window (without docking it). This is useful when the playlist is already docked at the bottom, but the main window has been resized (e.g. when the effects view is toggled).
    private func repositionPlaylistBottom() {
        
        // Calculate the new position of the playlist window, in relation to the main window
        let playlistHeight = min(playlistWindow.height, mainWindow.remainingHeight)
        let playlistOrigin = NSMakePoint(playlistWindow.x, mainWindow.y - playlistHeight)
        let playlistSize = NSMakeSize(playlistWindow.width, playlistHeight)
        
        dock(playlistOrigin, playlistSize)
    }
    
    // Moves both windows, if necessary, to ensure that they are both entirely visible on screen
    private func ensureMainWindowVisible() {
        
        // Check vertical position
        if mainWindow.y < visibleFrame.minY {
            moveWindows(0, visibleFrame.minY - mainWindow.y)
        } else if mainWindow.maxY > visibleFrame.maxY {
            moveWindows(0, -(mainWindow.maxY - visibleFrame.maxY))
        }
        
        // Check horizontal position
        if mainWindow.x < visibleFrame.minX {
            moveWindows(visibleFrame.minX - mainWindow.x, 0)
        } else if mainWindow.maxX > visibleFrame.maxX {
            moveWindows(-(mainWindow.maxX - visibleFrame.maxX), 0)
        }
    }
    
    /*
        Called when toggling the playlist/effects views and/or docking the playlist window. Resizes the main window depending on which views are to be shown (i.e. either displayed on the main window or attached to it).
     
        The "playlistAffectsHeight" parameter will be true only when the playlist window is visible and has been docked at the bottom of the main window, and false otherwise.
     */
    private func resizeMainWindow(_ playlistAffectsHeight: Bool, _ effectsShown: Bool, _ animate: Bool = false) {
        
        var wFrame = mainWindow.frame
        let oldOrigin = wFrame.origin
        
        var newHeight: CGFloat
        
        // Calculate the new height based on which of the 2 views are shown
        
        if (effectsShown && playlistAffectsHeight) {
            newHeight = UIConstants.windowHeight_playlistAndEffects
        } else if (effectsShown) {
            newHeight = UIConstants.windowHeight_effectsOnly
        } else if (playlistAffectsHeight) {
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
        mainWindow.setFrame(wFrame, display: true, animate: animate)
    }
    
    // MARK: Other window functions
    
    // Closes the window, and quits the app
    @IBAction func closeAction(_ sender: AnyObject) {
        NSApplication.shared().terminate(self)
    }
    
    // Minimizes the app
    @IBAction func minimizeAction(_ sender: AnyObject) {
        mainWindow.miniaturize(self)
    }
    
    // MARK: Message handling
    
    func consumeMessage(_ message: ActionMessage) {
        
        switch message.actionType {
            
        case .dockLeft: dockLeft()

        case .dockRight: dockRight()

        case .dockBottom: dockBottom()

        case .maximize: maximize()
            
        case .maximizeHorizontal: maximizeHorizontal()
            
        case .maximizeVertical: maximizeVertical()
            
        case .togglePlaylist: togglePlaylist()
            
        case .toggleEffects: toggleEffects()
            
        default: return
            
        }
    }
    
    // MARK: Playlist window delegate functions
    
    /*
        When the playlist window is moved manually by the user, it may be moved such that it is no longer docked (i.e. positioned adjacent) to the main window. This method checks the position of the playlist window after the resize operation, invalidates the playlist window's dock state if necessary, and adds a thin bottom edge to the main window (for aesthetics) if the playlist is no longer docked.
     */
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
                resizeMainWindow(false, WindowState.showingEffects, false)
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

/*
    Responds to main window events, and uses the notifications to trigger actions to optimize app performance and resource usage.
 */
class MainWindowDelegate: NSObject, NSWindowDelegate {

    // When the window is minimized, the app can be considered to be in the "background". Certain UI features can be disabled, because the window is not visible to the end user.
    func windowDidMiniaturize(_ notification: Notification) {
        WindowState.setMinimized(true)
    }

    // When the window is restored, the app can be considered to be in the "foreground" (if it is also in focus). The UI features that are disabled to reduce system resources usage, can be re-enabled, because the window is now visible to the end user.
    func windowDidDeminiaturize(_ notification: Notification) {
        WindowState.setMinimized(false)
    }
}
