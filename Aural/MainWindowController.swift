import Cocoa

/*
    Window controller for the main window, but also controls the positioning and sizing of the playlist window. Performs any and all display (or hiding), positioning, alignment, resizing, etc. of both the main window and playlist window.
 */
class MainWindowController: NSWindowController, NSWindowDelegate, ActionMessageSubscriber {
    
    // Main application window. Contains the Now Playing info box, player controls, and effects panel. Acts as a parent for the playlist window. Not manually resizable. Changes size when toggling playlist/effects views.
    private var mainWindow: NSWindow!
    
    // Detachable/movable/resizable window that contains the playlist view. Child of the main window.
    private let playlistWindow: NSWindow = WindowFactory.getPlaylistWindow()
    
    // Buttons to toggle the playlist/effects views
    @IBOutlet weak var btnToggleEffects: OnOffImageButton!
    @IBOutlet weak var btnTogglePlaylist: OnOffImageButton!
    
    // The box that encloses the Now Playing info section
    @IBOutlet weak var nowPlayingBox: NSBox!
    private lazy var nowPlayingView: NSView = ViewFactory.getNowPlayingView()
    
    // The box that encloses the player controls
    @IBOutlet weak var playerBox: NSBox!
    private lazy var playerView: NSView = ViewFactory.getPlayerView()
    
    // The box that encloses the Effects panel
    @IBOutlet weak var effectsBox: NSBox!
    private lazy var effectsView: NSView = ViewFactory.getEffectsView()
    
    // Remembers if/where the playlist window has been docked with the main window
    private var playlistDockState: PlaylistDockState = .bottom
    
    // Flag to indicate that a window move/resize operation was initiated by the app (as opposed to by the user)
    private var automatedPlaylistMoveOrResize: Bool = false
    
    private lazy var visibleFrame: NSRect = {
        return NSScreen.main()!.visibleFrame
    }()
    
    convenience init() {
        self.init(windowNibName: "MainWindow")
    }
    
    // MARK: Setup
    
    override func windowDidLoad() {
        
        initWindows()
        addSubViews()
        
        // Set up the toggle button images
        btnTogglePlaylist.offStateImage = Images.imgPlaylistOff
        btnTogglePlaylist.onStateImage = Images.imgPlaylistOn
        
        btnToggleEffects.offStateImage = Images.imgEffectsOff
        btnToggleEffects.onStateImage = Images.imgEffectsOn
        
        // Register a handler for trackpad/MagicMouse gestures
        
        let gestureHandler = GestureHandler()
        NSEvent.addLocalMonitorForEvents(matching: [.swipe, .scrollWheel], handler: {(event: NSEvent!) -> NSEvent in
            gestureHandler.handle(event)
            return event;
        });
        
        // Subscribe to various messages
        SyncMessenger.subscribe(actionTypes: [.dockLeft, .dockRight, .dockBottom, .maximize, .maximizeHorizontal, .maximizeVertical, .togglePlaylist, .toggleEffects], subscriber: self)
        
        // Lay out the windows
        initialWindowLayout()
    }
    
    // Set window properties
    private func initWindows() {
        
        self.mainWindow = self.window!
        WindowState.window = self.mainWindow
        WindowState.playlistWindow = self.playlistWindow
        [mainWindow, playlistWindow].forEach({$0?.isMovableByWindowBackground = true})
        
        mainWindow.makeKeyAndOrderFront(self)
        playlistWindow.delegate = self
    }
    
    // Add the sub-views that make up the main window
    private func addSubViews() {
        
        nowPlayingBox.addSubview(nowPlayingView)
        playerBox.addSubview(playerView)
        effectsBox.addSubview(effectsView)
    }
    
    // One-time seutp. Lays out both windows per user preferences and saved app state.
    private func initialWindowLayout() {
        
        let appState = ObjectGraph.getUIAppState()
        
        if (appState.hideEffects) {
            toggleEffects()
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
        if (playlistDockState == .left || playlistDockState == .right) {
            // Resize playlist
            var playlistFrame = playlistWindow.frame
            playlistFrame.size = NSMakeSize(playlistWindow.width, mainWindow.height)
            automatedPlaylistMoveOrResize = true
            playlistWindow.setFrame(playlistFrame, display: true)
            automatedPlaylistMoveOrResize = false
        }
        appState.hidePlaylist ? hidePlaylist() : showPlaylist()
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
    private func dockBottom() {
        
        resizeMainWindow(true, WindowState.showingEffects)
        
        playlistDockState = .bottom
        WindowState.playlistLocation = .bottom
        let playlistHeight = min(playlistWindow.height, mainWindow.remainingHeight)
        
        dock(mainWindow.origin
            .applying(CGAffineTransform.init(translationX: 0, y: -playlistHeight)), NSMakeSize(playlistWindow.width, playlistHeight))
    }
    
    // Docks the playlist to the left of the main window
    private func dockLeft() {
        
        resizeMainWindow(false, WindowState.showingEffects)
        
        playlistDockState = .left
        WindowState.playlistLocation = .left
        let playlistWidth = min(mainWindow.remainingWidth, playlistWindow.width)
        
        dock(mainWindow.frame.origin
            .applying(CGAffineTransform.init(translationX: -playlistWidth, y: mainWindow.height - playlistWindow.height)), NSMakeSize(playlistWidth, playlistWindow.height))
    }
    
    // Docks the playlist to the right of the main window
    private func dockRight() {
        
        resizeMainWindow(false, WindowState.showingEffects)
        
        playlistDockState = .right
        WindowState.playlistLocation = .right
        let playlistWidth = min(mainWindow.remainingWidth, playlistWindow.width)
        
        dock(mainWindow.frame.origin
            .applying(CGAffineTransform.init(translationX: mainWindow.width, y: mainWindow.height - playlistWindow.height)), NSMakeSize(playlistWidth, playlistWindow.height))
    }
    
    // Docks the playlist with the main window, at a given location and size, and ensures that the entire playlist is visible after the dock
    private func dock(_ playlistWindowOrigin: NSPoint, _ playlistWindowSize: NSSize) {
         
        var playlistFrame = playlistWindow.frame
        playlistFrame.origin = playlistWindowOrigin
        playlistFrame.size = playlistWindowSize
        
        automatedPlaylistMoveOrResize = true
        
        playlistWindow.setFrame(playlistFrame, display: true)
        
        ensureWindowsVisible()
        
        automatedPlaylistMoveOrResize = false
    }
    
    // Ensures that both the main and playlist windows are entirely visible on-screen. Moves windows if necessary.
    private func ensureWindowsVisible() {
        
        // Calculate offset of playlist window from main window
        let offsetX = playlistWindow.x - mainWindow.x
        let offsetY = playlistWindow.y - mainWindow.y
        
        let mainWindowVisisble = checkIfWindowVisible(mainWindow)
        if (!mainWindowVisisble.visible) {
            moveMainWindow(mainWindowVisisble.dx, mainWindowVisisble.dy)
        }
        
        if (WindowState.showingPlaylist) {
            
            if (!mainWindowVisisble.visible) {
                reattachPlaylistWithOffset(offsetX, offsetY)
            }
            
            let childWindowVisisble = checkIfWindowVisible(playlistWindow)
            if (!childWindowVisisble.visible) {
                
                moveMainWindow(childWindowVisisble.dx, childWindowVisisble.dy)
                reattachPlaylistWithOffset(offsetX, offsetY)
            }
        }
    }
    
    // Re-attaches the playlist window to the main window, with a given offset
    private func reattachPlaylistWithOffset(_ offsetX: CGFloat, _ offsetY: CGFloat) {
        
        playlistWindow.setFrameOrigin(mainWindow.origin.applying(CGAffineTransform.init(translationX: offsetX, y: offsetY)))
    }
    
    // Checks if a single window is entirely on-screen (i.e. visible). Returns the offset (i.e. how much the window would have to be moved to make it entirely visible), and whether or not it is visible.
    private func checkIfWindowVisible(_ window: NSWindow) -> (visible: Bool, dx: CGFloat, dy: CGFloat) {
        
        var dx: CGFloat = 0, dy: CGFloat = 0
        
        if (window.x < visibleFrame.minX) {
            dx = visibleFrame.minX - window.x
        } else if (window.maxX > visibleFrame.maxX) {
            dx = -(window.maxX - visibleFrame.maxX)
        }
        
        if (window.y < visibleFrame.minY) {
            dy = visibleFrame.minY - window.y
        } else if (window.maxY > visibleFrame.maxY) {
            dy = -(window.maxY - visibleFrame.maxY)
        }
        
        return (dx == 0 && dy == 0, dx, dy)
    }
    
    // Moves (transforms) the main window by a given offset
    private func moveMainWindow(_ dx: CGFloat, _ dy: CGFloat) {
        mainWindow.setFrameOrigin(mainWindow.origin.applying(CGAffineTransform.init(translationX: dx, y: dy)))
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
        playlistWindow.setFrame(playlistFrame, display: true)
        
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
    private func showPlaylist() {
        
        resizeMainWindow(playlistDockState == .bottom, WindowState.showingEffects)
        
        // Show playlist window and update UI controls
        
        mainWindow.addChildWindow(playlistWindow, ordered: NSWindowOrderingMode.below)
        playlistWindow.setIsVisible(true)
        btnTogglePlaylist.on()
        WindowState.showingPlaylist = true
        
        // Re-dock the playlist window, as per the previous dock state
        reDockPlaylist()
    }
    
    // Docks the playlist window per its current dock state
    private func reDockPlaylist() {
        
        switch playlistDockState {
            
        case .bottom, .none:    dockBottom()
            
        case .left: dockLeft()
            
        case .right: dockRight()
            
        }
    }
   
    // Hides the playlist window
    private func hidePlaylist() {
        
        // Add bottom edge to the main window
        resizeMainWindow(false, WindowState.showingEffects)
        
        // Hide playlist window and update UI controls
        
        playlistWindow.setIsVisible(false)
        btnTogglePlaylist.off()
        WindowState.showingPlaylist = false
    }
    
    // Shows/hides the effects panel on the main window
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        toggleEffects()
    }
    
    // Shows/hides the effects panel on the main window
    private func toggleEffects() {
        
        if (!WindowState.showingEffects) {
            
            // Show effects view and update UI controls
            
            resizeMainWindow(playlistWindow.isVisible && playlistDockState == .bottom, true)
            effectsBox.isHidden = false
            btnToggleEffects.on()
            WindowState.showingEffects = true
            
        } else {
            
            // Hide effects view and update UI controls
            
            effectsBox.isHidden = true
            resizeMainWindow(playlistWindow.isVisible && playlistDockState == .bottom, false)
            btnToggleEffects.off()
            WindowState.showingEffects = false
        }
        
        // Move the playlist window, if necessary
        if (WindowState.showingPlaylist && playlistDockState == .bottom) {
            repositionPlaylistBottom()
        } else {
            
            // Ensure that both windows are visible
            automatedPlaylistMoveOrResize = true
            ensureWindowsVisible()
            automatedPlaylistMoveOrResize = false
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
    
    /*
        Called when toggling the playlist/effects views and/or docking the playlist window. Resizes the main window depending on which views are to be shown (i.e. either displayed on the main window or attached to it).
     
        The "playlistAffectsHeight" parameter will be true only when the playlist window is visible and has been docked at the bottom of the main window, and false otherwise.
     */
    private func resizeMainWindow(_ playlistAffectsHeight: Bool, _ effectsShown: Bool) {
        
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
        mainWindow.setFrame(wFrame, display: true)
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
                resizeMainWindow(false, WindowState.showingEffects)
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
