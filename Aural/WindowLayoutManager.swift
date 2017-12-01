import Cocoa

class WindowLayoutManager: NSObject, NSWindowDelegate, ActionMessageSubscriber {
    
    private lazy var mainWindow: NSWindow = WindowFactory.getMainWindow()
    private lazy var playlistWindow: NSWindow = WindowFactory.getPlaylistWindow()
    
    // Remembers if/where the playlist window has been docked with the main window
    private var playlistDockState: PlaylistDockState {
        
        // Check if playlist window's top edge is adjacent to main window's bottom edge
        if (playlistWindow.maxY == mainWindow.y) {
            return .bottom
            
        } else if (mainWindow.maxX == playlistWindow.x) {
            return .right
            
        } else if (playlistWindow.maxX == mainWindow.x) {
            return .left
        }
        
        return .none
    }
    
    private var lastDockState: PlaylistDockState!
    
    private lazy var visibleFrame: NSRect = {
        return NSScreen.main()!.visibleFrame
    }()
    
    override init() {
        
        super.init()
        
        SyncMessenger.subscribe(actionTypes: [.dockLeft, .dockRight, .dockBottom, .maximize, .maximizeHorizontal, .maximizeVertical, .togglePlaylist], subscriber: self)
    }
    
    // One-time seutp. Lays out both windows per user preferences and saved app state.
    func initialWindowLayout() {
        
        let appState = ObjectGraph.getUIAppState()
        
        mainWindow.setIsVisible(true)
        mainWindow.delegate = self
        
        // If a specific position is specified, use it
        if let mainWindowOrigin = appState.windowLocationXY {
            mainWindow.setFrameOrigin(mainWindowOrigin)
        } else {
            // Need to calculate position
            positionMainWindowRelativeToScreen(appState.windowLocationOnStartup.windowLocation, appState.playlistLocation, !appState.hidePlaylist)
        }
        
        // Show and dock the playlist, if needed
        lastDockState = appState.playlistLocation.toPlaylistDockState()
        
        // If the playlist isn't docked to the bottom, it needs to be resized
        if (lastDockState == .left || lastDockState == .right) {
            
            var playlistFrame = playlistWindow.frame
            playlistFrame.size = NSMakeSize(playlistWindow.width, mainWindow.height)
            playlistWindow.setFrame(playlistFrame, display: true)
        }
        
        appState.hidePlaylist ? hidePlaylist() : showPlaylist()
    }
    
    func closeWindows() {
        [mainWindow, playlistWindow].forEach({$0.close()})
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
    
    // Docks the playlist below the main window
    func dockBottom() {
        
        lastDockState = .bottom
        let playlistHeight = min(playlistWindow.height, mainWindow.remainingHeight)
        
        dock(mainWindow.origin
            .applying(CGAffineTransform.init(translationX: 0, y: -playlistHeight)), NSMakeSize(playlistWindow.width, playlistHeight))
    }
    
    // Docks the playlist to the left of the main window
    func dockLeft() {
        
        lastDockState = .left
        let playlistWidth = min(mainWindow.remainingWidth, playlistWindow.width)
        
        dock(mainWindow.frame.origin
            .applying(CGAffineTransform.init(translationX: -playlistWidth, y: mainWindow.height - playlistWindow.height)), NSMakeSize(playlistWidth, playlistWindow.height))
    }
    
    // Docks the playlist to the right of the main window
    func dockRight() {
        
        lastDockState = .right
        let playlistWidth = min(mainWindow.remainingWidth, playlistWindow.width)
        
        dock(mainWindow.frame.origin
            .applying(CGAffineTransform.init(translationX: mainWindow.width, y: mainWindow.height - playlistWindow.height)), NSMakeSize(playlistWidth, playlistWindow.height))
    }
    
    // Docks the playlist with the main window, at a given location and size, and ensures that the entire playlist is visible after the dock
    func dock(_ playlistWindowOrigin: NSPoint, _ playlistWindowSize: NSSize) {
        
        var playlistFrame = playlistWindow.frame
        playlistFrame.origin = playlistWindowOrigin
        playlistFrame.size = playlistWindowSize
        
        playlistWindow.setFrame(playlistFrame, display: true)
        
        ensureWindowsVisible()
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
    func maximizeHorizontal() {
        maximize(true, false)
    }
    
    // Maximizes the playlist vertically
    func maximizeVertical() {
        maximize(false, true)
    }
    
    // Maximizes the playlist
    func maximize(_ horizontal: Bool = true, _ vertical: Bool = true) {
        
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
        
        mainWindow.setFrameOrigin(NSPoint(x: mainWindowX, y: mainWindowY))
        
        var playlistFrame = playlistWindow.frame
        
        playlistFrame.origin = NSPoint(x: playlistX, y: playlistY)
        playlistFrame.size = NSSize(width: width, height: height)
        playlistWindow.setFrame(playlistFrame, display: true)
    }
    
    // Shows/hides the playlist window
    func togglePlaylist() {
        
        if (!WindowState.showingPlaylist) {
            showPlaylist()
        } else {
            hidePlaylist()
        }
    }
    
    // Shows the playlist window
    private func showPlaylist() {
        
        // Show playlist window and update UI controls
        
        mainWindow.addChildWindow(playlistWindow, ordered: NSWindowOrderingMode.below)
        playlistWindow.setIsVisible(true)
        WindowState.showingPlaylist = true
        
        // Re-dock the playlist window, as per the previous dock state
        reDockPlaylist()
    }
    
    // Docks the playlist window per its current dock state
    private func reDockPlaylist() {
        
        switch lastDockState! {
            
        case .bottom, .none:    dockBottom()
            
        case .left: dockLeft()
            
        case .right: dockRight()
            
        }
    }
    
    // Hides the playlist window
    private func hidePlaylist() {
        
        lastDockState = playlistDockState
        
        // Hide playlist window and update UI controls
        
        playlistWindow.setIsVisible(false)
        WindowState.showingPlaylist = false
    }
    
    // Simply repositions the playlist at the bottom of the main window (without docking it). This is useful when the playlist is already docked at the bottom, but the main window has been resized (e.g. when the effects view is toggled).
    private func repositionPlaylistBottom() {
        
        // Calculate the new position of the playlist window, in relation to the main window
        let playlistHeight = min(playlistWindow.height, mainWindow.remainingHeight)
        let playlistOrigin = NSMakePoint(playlistWindow.x, mainWindow.y - playlistHeight)
        let playlistSize = NSMakeSize(playlistWindow.width, playlistHeight)
        
        dock(playlistOrigin, playlistSize)
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
            
        default: return
            
        }
    }
    
    // When the window is minimized, the app can be considered to be in the "background". Certain UI features can be disabled, because the window is not visible to the end user.
    func windowDidMiniaturize(_ notification: Notification) {
        WindowState.setMinimized(true)
    }
    
    // When the window is restored, the app can be considered to be in the "foreground" (if it is also in focus). The UI features that are disabled to reduce system resources usage, can be re-enabled, because the window is now visible to the end user.
    func windowDidDeminiaturize(_ notification: Notification) {
        WindowState.setMinimized(false)
    }
    
    func windowDidResize(_ notification: Notification) {
 
        // Move the playlist window, if necessary
        if (WindowState.showingPlaylist && lastDockState == .bottom) {
            repositionPlaylistBottom()
        } else {
            
            // Ensure that both windows are visible
            ensureWindowsVisible()
        }
    }
}
