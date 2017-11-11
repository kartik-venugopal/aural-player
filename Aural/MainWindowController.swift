import Cocoa

/*
    Window controller for the main window, but also controls the playlist window. Performs any and all display (or hiding), positioning, alignment, resizing, etc. of both the main window and playlist window.
 */

// TODO: What to do if the playlist window moves off-screen ??? Should it always be resized/moved so it is completely on-screen ???

// TODO: Cleanup !
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
    
    private var visibleFrame: NSRect = {
        return NSScreen.main()!.visibleFrame
    }()
    
    convenience init() {
        self.init(windowNibName: "MainWindow")
    }
    
    override func windowDidLoad() {
        
        self.mainWindow = self.window!
        WindowState.window = self.mainWindow
        
        [mainWindow, playlistWindow].forEach({$0?.isMovableByWindowBackground = true})
        
        mainWindow.makeKeyAndOrderFront(self)
        playlistWindow.delegate = self
        
        mainWindow.addChildWindow(playlistWindow, ordered: NSWindowOrderingMode.below)
        
        let appState = ObjectGraph.getUIAppState()
        
        if (appState.hideEffects) {
            toggleEffects(false)
        }
        
        // If a specific position is specified, use it
        if let mainWindowOrigin = appState.windowLocationXY {
//            print("MainWindow at loc:", mainWindowOrigin.x, mainWindowOrigin.y)
            mainWindow.setFrameOrigin(mainWindowOrigin)
//            print("MainWindow moved to:", mainWindow.x, mainWindow.y)
        } else {
            // Need to calculate position
            positionWindowsOnStartup(appState.windowLocationOnStartup.windowLocation, appState.playlistLocation, !appState.hidePlaylist)
        }
        
        SyncMessenger.subscribe(actionTypes: [.dockLeft, .dockRight, .dockBottom, .maximize, .maximizeHorizontal, .maximizeVertical, .togglePlaylist, .toggleEffects], subscriber: self)
    }
    
    private func positionWindowsOnStartup(_ relativeLoc: WindowLocations, _ playlistLoc: PlaylistLocations, _ playlistShown: Bool) {
        
        var height: CGFloat = mainWindow.height
        var width: CGFloat = mainWindow.width
        
        // If the playlist is shown, the total height/width will be affected by the playlist window
        if (playlistShown) {
            
            switch playlistLoc {
                
            case .bottom: height += playlistWindow.height
                
            case .left, .right: width += playlistWindow.width
                
            }
        }
        
        let location = UIUtils.windowPositionRelativeToScreen(width, height, relativeLoc)
        
        var x = location.x
        var y = location.y
        
        // If the playlist is shown, the main window origin will be affected by the playlist window
        if (playlistShown) {
            
            switch playlistLoc {
                
            case .bottom: y += playlistWindow.height
                
            case .left: x += playlistWindow.width
                
            default: break
                
            }
        }
        
        // Reposition the main window
        mainWindow.setFrameOrigin(NSPoint(x: x, y: y))
        
        if (playlistShown) {
            
            playlistWindow.setIsVisible(true)
            
            
            switch playlistLoc {
                
            case .bottom:   dockBottom()
                
            case .left: dockLeft()
                
            case.right: dockRight()
                
            }
        }
    }
    
    private func dock(_ origin: NSPoint, _ size: NSSize) {
        
        var playlistFrame = playlistWindow.frame
        playlistFrame.origin = origin
        playlistFrame.size = size
        
        playlistWindow.setFrame(playlistFrame, display: true, animate: false)
        ensureVisible()
    }
    
    private func moveUp(_ pixels: CGFloat) {
        mainWindow.setFrameOrigin(mainWindow.origin.applying(CGAffineTransform.init(translationX: 0, y: pixels)))
    }
    
    private func moveLeft(_ pixels: CGFloat) {
        mainWindow.setFrameOrigin(mainWindow.origin.applying(CGAffineTransform.init(translationX: -pixels, y: 0)))
    }
    
    private func moveRight(_ pixels: CGFloat) {
        mainWindow.setFrameOrigin(mainWindow.origin.applying(CGAffineTransform.init(translationX: pixels, y: 0)))
    }
    
    private func ensureVisible() {
        
        // For now, assume playlist shown
        
        
        switch playlistDockState {
            
        case .bottom:
            
            if playlistWindow.y < visibleFrame.minY {
                moveUp(visibleFrame.minY - playlistWindow.y)
            }
            
            // TODO: What if main window is off screen ?
            
        case .left:
            
            if playlistWindow.x < visibleFrame.minX {
                moveRight(visibleFrame.minX - playlistWindow.x)
            }
            
        case .right:
            
            if playlistWindow.maxX > visibleFrame.maxX {
                moveLeft(playlistWindow.maxX - visibleFrame.maxX)
            }
            
        default: return
            
        }
    }
    
    private func dockBottom() {
        
        resizeMainWindow(playlistShown: true, effectsShown: !fxBox.isHidden, false)
        
        playlistDockState = .bottom
        let plHt = min(playlistWindow.height, mainWindow.remainingHeight)
        
        dock(mainWindow.origin
            .applying(CGAffineTransform.init(translationX: 0, y: -plHt)), NSMakeSize(mainWindow.width, plHt))
    }
    
    private func dockLeft() {
        
        resizeMainWindow(playlistShown: false, effectsShown: !fxBox.isHidden, false)
        
        playlistDockState = .left
        let plWd = min(mainWindow.remainingWidth, playlistWindow.width)
        
        dock(mainWindow.frame.origin
            .applying(CGAffineTransform.init(translationX: -plWd, y: 0)), NSMakeSize(plWd, mainWindow.height))
    }
    
    private func dockRight() {
        
        resizeMainWindow(playlistShown: false, effectsShown: !fxBox.isHidden, false)
        
        playlistDockState = .right
        let plWd = min(mainWindow.remainingWidth, playlistWindow.width)
        
        dock(mainWindow.frame.origin
            .applying(CGAffineTransform.init(translationX: mainWindow.width, y: 0)), NSMakeSize(plWd, mainWindow.height))
    }
    
    private func maximizeHorizontal() {
        maximize(true, false)
    }
    
    private func maximizeVertical() {
        maximize(false, true)
    }
    
    private func maximize(_ horizontal: Bool = true, _ vertical: Bool = true) {
        
        var pw: CGFloat, ph: CGFloat
        var px: CGFloat, py: CGFloat
        
        var mx: CGFloat = mainWindow.x, my: CGFloat = mainWindow.y
        
        switch playlistDockState {
            
        case .bottom:
            
            pw = horizontal ? visibleFrame.width : playlistWindow.width
            ph = vertical ? mainWindow.remainingHeight : playlistWindow.height
            
            px = horizontal ? visibleFrame.minX : playlistWindow.x
            py = vertical ? visibleFrame.minY : playlistWindow.y
            
            my = vertical ? visibleFrame.height - mainWindow.height : mainWindow.y
            
            print(String(format: "\nBottom px: %.0f py: %.0f pw: %.0f ph: %.0f", px, py, pw, ph))
            
        case .right:
            
            pw = horizontal ? mainWindow.remainingWidth : playlistWindow.width
            ph = vertical ? visibleFrame.height : playlistWindow.height
            
            px = horizontal ? visibleFrame.minX + mainWindow.width : playlistWindow.x
            py = vertical ? visibleFrame.minY : playlistWindow.y
            
            mx = horizontal ? visibleFrame.minX : mainWindow.x
            
            print(String(format: "\nRight px: %.0f py: %.0f pw: %.0f ph: %.0f", px, py, pw, ph))
            
        case .left:
            
            pw = horizontal ? mainWindow.remainingWidth : playlistWindow.width
            ph = vertical ? visibleFrame.height : playlistWindow.height
            
            px = horizontal ? visibleFrame.minX : playlistWindow.x
            py = vertical ? visibleFrame.minY : playlistWindow.y
            
            mx = horizontal ? visibleFrame.minX + pw : mainWindow.x
            
            print(String(format: "\nLeft px: %.0f py: %.0f pw: %.0f ph: %.0f", px, py, pw, ph))
            
        case .none:
            
            // When the playlist is not docked, vertical maximizing will take preference over horizontal maximizing (i.e. portrait orientation)
            
            pw = playlistWindow.width
            ph = playlistWindow.height
            
            px = playlistWindow.x
            py = playlistWindow.y
            
            // These variables will determine the bounds of the new playlist window frame
            var minX: CGFloat = visibleFrame.minX, minY: CGFloat = visibleFrame.minY, maxX: CGFloat = visibleFrame.maxX, maxY: CGFloat = visibleFrame.maxY
            
            // Figure out where the playlist window is, in relation to the main window
            if (px < mx) {
                
                // Playlist window is to the left of the main window. Maximize to the left of the main window.
                maxX = mx - 1
                pw = max(maxX - minX + 1, UIConstants.minPlaylistWidth)
                ph = max(maxY - minY + 1, UIConstants.minPlaylistHeight)
                mx = px + pw
                
                playlistDockState = .left
                
            } else if (px >= mx) {
                
                // Playlist window is to the right of the main window. Maximize to the right of the main window.
                minX = mainWindow.maxX + 1
                pw = max(maxX - minX + 1, UIConstants.minPlaylistWidth)
                ph = max(maxY - minY + 1, UIConstants.minPlaylistHeight)
                
                playlistDockState = .right
                
            } else if (py < my) {
                
                // Entire playlist window is below the main window. Maximize below the main window.
                maxY = my - 1
                pw = max(maxX - minX + 1, UIConstants.minPlaylistWidth)
                ph = max(maxY - minY + 1, UIConstants.minPlaylistHeight)
                my = py + ph
                
                playlistDockState = .bottom
                
            } else if (py >= my) {
                
                // Entire playlist window is above the main window. Maximize above the main window.
                minY = mainWindow.maxY + 1
                ph = max(maxY - minY + 1, UIConstants.minPlaylistHeight)
                pw = max(maxX - minX + 1, UIConstants.minPlaylistWidth)
            }
            
            px = minX
            py = minY
        }
        
        var playlistFrame = playlistWindow.frame
        playlistFrame.origin = NSPoint(x: px, y: py)
        playlistFrame.size = NSSize(width: pw, height: ph)
        
        mainWindow.setFrameOrigin(NSPoint(x: mx, y: my))
        playlistWindow.setFrame(playlistFrame, display: true)
        
        ensureVisible()
    }
    
    @IBAction func closeAction(_ sender: AnyObject) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func minimizeAction(_ sender: AnyObject) {
        mainWindow.miniaturize(self)
    }
    
    @IBAction func togglePlaylistAction(_ sender: AnyObject) {
        togglePlaylist()
    }
    
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        toggleEffects()
    }
    
    private func toggleEffects() {
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
        btnTogglePlaylist.image = Images.imgPlaylistOn
        WindowState.showingPlaylist = true
        
        if (dock) {
            // Re-dock the playlist window, as per the previous dock state
            dockPlaylist()
        }
    }
    
    private func dockPlaylist() {
        
        if (playlistDockState == .bottom) {
            dockBottom()
        } else if (playlistDockState == .right) {
            dockRight()
        } else if (playlistDockState == .left) {
            dockLeft()
        } else {
            dockBottom()
        }
    }
   
    // The "noteOffset" flag indicates whether or not the offset of the playlist window in relation to the main window is valid (and to be remembered). When starting up, the offset is invalid, because this method is called automatically (i.e. not by the user).
    private func hidePlaylist() {
        
        // Add bottom edge to the main window
        resizeMainWindow(playlistShown: false, effectsShown: !fxBox.isHidden, false)
        
        // Hide playlist window and update UI controls
        
        playlistWindow.setIsVisible(false)
        btnTogglePlaylist.state = 0
        btnTogglePlaylist.image = Images.imgPlaylistOff
        WindowState.showingPlaylist = false
    }
    
    private func toggleEffects(_ animate: Bool) {
        
        if (fxBox.isHidden) {
            
            // Show effects view and update UI controls
            
            resizeMainWindow(playlistShown: playlistWindow.isVisible && playlistDockState == .bottom, effectsShown: true, animate)
            fxBox.isHidden = false
            btnToggleEffects.state = 1
            btnToggleEffects.image = Images.imgEffectsOn
            WindowState.showingEffects = true
            
        } else {
            
            // Hide effects view and update UI controls
            
            fxBox.isHidden = true
            resizeMainWindow(playlistShown: playlistWindow.isVisible && playlistDockState == .bottom, effectsShown: false, animate)
            btnToggleEffects.state = 0
            btnToggleEffects.image = Images.imgEffectsOff
            WindowState.showingEffects = false
        }
        
        // Move the playlist window, if necessary
        if (playlistWindow.isVisible && playlistDockState == .bottom) {
            repositionPlaylistBottom()
//            ensureVisible()
        }
    }
    
    // Simply repositions the playlist at the bottom of the main window (without docking it). This is useful when the playlist is already docked at the bottom, but the main window has been resized (e.g. when the effects view is toggled).
    private func repositionPlaylistBottom() {
        
        // Mark the flag to indicate that an automated move/resize operation is now taking place
        automatedPlaylistMoveOrResize = true
        
        // Calculate the new position of the playlist window, in relation to the main window
        let plHt = min(playlistWindow.height, mainWindow.remainingHeight)
        let plOr = NSMakePoint(playlistWindow.x, mainWindow.y - plHt)
        let size = NSMakeSize(playlistWindow.width, plHt)
        
//        var plF = playlistWindow.frame
//        plF.origin = plOr
//        plF.size = size
//        
//        playlistWindow.setFrame(plF, display: true, animate: false)
        
        dock(plOr, size)
        
        // Update the flag to indicate that an automated move/resize operation is no longer taking place
        automatedPlaylistMoveOrResize = false
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
    
    // MARK: Action Message handling
    
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
    
    // MARK: Playlist Window Delegate functions
    
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
    
    static var inForeground: Bool = true
    
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
    
    var origin: NSPoint {
        return self.frame.origin
    }
    
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
    
    var maxX: CGFloat {
        return self.frame.maxX
    }
    
    var maxY: CGFloat {
        return self.frame.maxY
    }
    
    var remainingHeight: CGFloat {
        return (NSScreen.main()!.visibleFrame.height - self.height)
    }
    
    var remainingWidth: CGFloat {
        return (NSScreen.main()!.visibleFrame.width - self.width)
    }
}
