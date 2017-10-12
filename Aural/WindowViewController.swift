/*
    View controller for the main app window
 */

import Cocoa

class WindowViewController: NSViewController, NSWindowDelegate {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var playlistWindow: NSWindow!
    
    // Buttons to toggle (collapsible) playlist/effects views
    @IBOutlet weak var btnToggleEffects: NSButton!
    @IBOutlet weak var btnTogglePlaylist: NSButton!
    
    @IBOutlet weak var viewPlaylistMenuItem: NSMenuItem!
    @IBOutlet weak var viewEffectsMenuItem: NSMenuItem!
    
    // Views that are collapsible (hide/show)
    @IBOutlet weak var fxBox: NSBox!
    
    private var playlistDockState: PlaylistDockState = .none
    
    private var playlistWindowDocking: Bool = false
    
    private let screen: NSScreen = NSScreen.main()!
    
    private var screenWidth: CGFloat = {
        return NSScreen.main()!.frame.width
    }()
    
    private var screenHeight: CGFloat = {
        return NSScreen.main()!.frame.height
    }()
    
    override func viewDidLoad() {
        
        WindowState.window = self.window
        
        let appState = ObjectGraph.getUIAppState()
        
        if (appState.hideEffects) {
            toggleEffects(false)
        }
        
        window.setFrameOrigin(appState.windowLocation)
        window.isMovableByWindowBackground = true
        window.makeKeyAndOrderFront(self)
        
        playlistWindow.isMovableByWindowBackground = true
        playlistWindow.delegate = self
        
        if (appState.hidePlaylist) {
            hidePlaylist()
            
            // TODO: Make this configurable in preferences
            // Whenever the playlist is shown, dock it at the bottom
            playlistDockState = .bottom
            
        } else {
            showPlaylist()
            dockPlaylistBottomAction(self)
        }
    }
    
    @IBAction func hideAction(_ sender: AnyObject) {
        window.miniaturize(self)
    }
    
    @IBAction func closeAction(_ sender: AnyObject) {
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func togglePlaylistAction(_ sender: AnyObject) {
        togglePlaylist()
    }
    
    @IBAction func dockPlaylistRightAction(_ sender: AnyObject) {
        
        playlistWindowDocking = true
        
        resizeWindow(playlistShown: false, effectsShown: !fxBox.isHidden, true)
        
        var pFrame = playlistWindow.frame
     
        let pwX = window.frame.origin.x + window.frame.width
        let pwY = window.frame.origin.y
        pFrame.origin = NSPoint(x: pwX, y: pwY)
        
        let maxWd = max(screenWidth - pwX, UIConstants.minPlaylistWidth)
        
        let pwWd = min(playlistWindow.frame.width, maxWd)
        let pwHt = window.frame.height
        pFrame.size = NSMakeSize(pwWd, pwHt)
        
        playlistWindow.setFrame(pFrame, display: true, animate: false)
        playlistDockState = .right
        
        playlistWindowDocking = false
    }
    
    @IBAction func dockPlaylistLeftAction(_ sender: AnyObject) {
        
        playlistWindowDocking = true
        
        resizeWindow(playlistShown: false, effectsShown: !fxBox.isHidden, true)
        
        var pFrame = playlistWindow.frame
        
        let pwHt = window.frame.height
        let maxWd = max(window.frame.origin.x, UIConstants.minPlaylistWidth)
        let pwWd = min(playlistWindow.frame.width, maxWd)
        pFrame.size = NSMakeSize(pwWd, pwHt)
        
        let pwX = window.frame.origin.x - pwWd
        let pwY = window.frame.origin.y
        pFrame.origin = NSPoint(x: pwX, y: pwY)
        
        playlistWindow.setFrame(pFrame, display: true, animate: false)
        playlistDockState = .left
        
        playlistWindowDocking = false
    }
    
    @IBAction func dockPlaylistBottomAction(_ sender: AnyObject) {
        
        playlistWindowDocking = true
        
        resizeWindow(playlistShown: true, effectsShown: !fxBox.isHidden, true)
        
        var pFrame = playlistWindow.frame
        
        let pwWd = window.frame.width
        let maxHt = max(window.frame.origin.y, UIConstants.minPlaylistHeight)
        let pwHt = min(playlistWindow.frame.height, maxHt)
        pFrame.size = NSMakeSize(pwWd, pwHt)
        
        let pwX = window.frame.origin.x
        let pwY = window.frame.origin.y - pwHt
        pFrame.origin = NSPoint(x: pwX, y: pwY)
        
        playlistWindow.setFrame(pFrame, display: true, animate: false)
        playlistDockState = .bottom
        
        playlistWindowDocking = false
    }
    
    @IBAction func maximizePlaylistAction(_ sender: AnyObject) {
        
        playlistWindowDocking = true
        
        var pFrame = playlistWindow.frame
        var pwWd: CGFloat, pwHt: CGFloat
        var pwX: CGFloat, pwY: CGFloat
        
        let winX: CGFloat = window.frame.origin.x
        let winY: CGFloat = window.frame.origin.y
        
        switch playlistDockState {
            
        case .bottom:
            
            pwWd = screenWidth
            let maxHt = max(winY, UIConstants.minPlaylistHeight)
            pwHt = max(playlistWindow.frame.height, maxHt)
            
            pwX = 0
            pwY = 0
            
        case .right:
            
            pwWd = screenWidth - (winX + window.frame.width)
            pwHt = screenHeight
            
            pwX = playlistWindow.frame.origin.x
            pwY = 0
            
        case .left:
            
            pwWd = winX
            pwHt = screenHeight
            
            pwX = 0
            pwY = 0
            
        case .none:
            
            pwWd = playlistWindow.frame.width
            pwHt = playlistWindow.frame.height
            
            pwX = playlistWindow.frame.origin.x
            pwY = playlistWindow.frame.origin.y
            
            var minX: CGFloat = 0, minY: CGFloat = 0, maxX: CGFloat = screenWidth, maxY: CGFloat = screenHeight
            
            if ((pwX + pwWd) < winX) {
                // Left
                maxX = winX
            } else if (pwX > winX + window.frame.width) {
                // Right
                minX = winX + window.frame.width
            } else if ((pwY + pwHt) < winY) {
                // Below
                maxY = winY
            } else if (pwY > (winY + window.frame.height)) {
                // Above
                minY = winY + window.frame.height
            }
            
            pwX = minX
            pwY = minY
            
            pwWd = maxX - minX + 1
            pwHt = maxY - minY + 1
        }
        
        pFrame.origin = NSPoint(x: pwX, y: pwY)
        pFrame.size = NSMakeSize(pwWd, pwHt)
        
        playlistWindow.setFrame(pFrame.intersection(screen.visibleFrame), display: true, animate: false)

        playlistWindowDocking = false
    }
    
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        toggleEffects(true)
    }
    
    private func togglePlaylist() {
        
        // Set focus on playlist view if it's visible after the toggle
        
        if (!playlistWindow.isVisible) {
            showPlaylist()
        } else {
            hidePlaylist()
        }
    }
    
    private func showPlaylist() {
        
        resizeWindow(playlistShown: playlistDockState == .bottom, effectsShown: !fxBox.isHidden, false)
        
        window.addChildWindow(playlistWindow, ordered: NSWindowOrderingMode.below)
        playlistWindow.setIsVisible(true)
        btnTogglePlaylist.state = 1
        btnTogglePlaylist.image = UIConstants.imgPlaylistOn
        viewPlaylistMenuItem.state = 1
        WindowState.showingPlaylist = true
        
        if (playlistDockState == .bottom) {
            dockPlaylistBottomAction(self)
        }
    }
    
    private func hidePlaylist() {
        
        resizeWindow(playlistShown: false, effectsShown: !fxBox.isHidden, false)
        
        playlistWindow.setIsVisible(false)
        btnTogglePlaylist.state = 0
        btnTogglePlaylist.image = UIConstants.imgPlaylistOff
        viewPlaylistMenuItem.state = 0
        WindowState.showingPlaylist = false
    }
    
    private func toggleEffects(_ animate: Bool) {
        
        if (fxBox.isHidden) {
            
            // Show
            
            resizeWindow(playlistShown: playlistWindow.isVisible && playlistDockState == .bottom, effectsShown: true, animate)
            fxBox.isHidden = false
            btnToggleEffects.state = 1
            btnToggleEffects.image = UIConstants.imgEffectsOn
            viewEffectsMenuItem.state = 1
            WindowState.showingEffects = true
            
        } else {
            
            // Hide
            
            fxBox.isHidden = true
            resizeWindow(playlistShown: playlistWindow.isVisible && playlistDockState == .bottom, effectsShown: false, animate)
            btnToggleEffects.state = 0
            btnToggleEffects.image = UIConstants.imgEffectsOff
            viewEffectsMenuItem.state = 0
            WindowState.showingEffects = false
        }
        
        if (playlistWindow.isVisible && playlistDockState == .bottom) {
            dockPlaylistBottomAction(self)
        }
    }
    
    // Called when toggling views
    private func resizeWindow(playlistShown: Bool, effectsShown: Bool, _ animate: Bool) {
        
        var wFrame = window.frame
        let oldOrigin = wFrame.origin
        
        var newHeight: CGFloat
        
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
        
        if (oldHeight == newHeight) {
            return
        }
        
        let shrinking: Bool = newHeight < oldHeight
        
        wFrame.size = NSMakeSize(window.frame.width, newHeight)
        wFrame.origin = NSMakePoint(oldOrigin.x, shrinking ? oldOrigin.y + (oldHeight - newHeight) : oldOrigin.y - (newHeight - oldHeight))
        
        window.setFrame(wFrame, display: true, animate: false)
    }
    
    // This is to handle only user-initiated (manual) mouse drags on the playlist window
    func windowDidMove(_ notification: Notification) {
        
        // If the window move was initiated by a dock/maximize operation, no further action is required, ignore this notification
        if (playlistWindowDocking) {
            return
        }
        
        // If the mouse cursor is within the playlist window, it means that only the playlist window is being moved, which invalidates its dock state. If the whole window is being moved, that does not affect the playlist dock state
        if (playlistWindow.frame.contains(NSEvent.mouseLocation())) {
            
            resizeWindow(playlistShown: false, effectsShown: !fxBox.isHidden, false)
            playlistDockState = .none
        }
    }
}

// Provides convenient access to the state of the main window, across the app
class WindowState {
    
    static var window: NSWindow?
    static var showingPlaylist: Bool = true
    static var showingEffects: Bool = true
    
    static func location() -> NSPoint {
        return window!.frame.origin
    }
    
    static func getPersistentState() -> UIState {
        
        let uiState = UIState()
        
        let windowOrigin = window!.frame.origin
        uiState.windowLocationX = Float(windowOrigin.x)
        uiState.windowLocationY = Float(windowOrigin.y)
        
        uiState.showEffects = WindowState.showingEffects
        uiState.showPlaylist = WindowState.showingPlaylist
        
        return uiState
    }
}

enum PlaylistDockState: String {
    
    case bottom
    case right
    case left
    case none
}
