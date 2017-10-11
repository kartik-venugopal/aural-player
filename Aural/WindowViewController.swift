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
    
    @IBOutlet weak var btnPlaylistDockRight: NSButton!
    @IBOutlet weak var btnPlaylistDockBottom: NSButton!
    private var playlistDockState: PlaylistDockState = .bottom
    
    @IBOutlet weak var viewPlaylistMenuItem: NSMenuItem!
    @IBOutlet weak var viewEffectsMenuItem: NSMenuItem!
    
    // Views that are collapsible (hide/show)
    @IBOutlet weak var fxBox: NSBox!
    
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
        } else {
            window.addChildWindow(playlistWindow, ordered: NSWindowOrderingMode.below)
            dockPlaylistBottomAction(self)
            showPlaylist()
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
        
        var pFrame = playlistWindow.frame
     
        let pwX = window.frame.origin.x + window.frame.width
        let pwY = window.frame.origin.y
        pFrame.origin = NSPoint(x: pwX, y: pwY)
        
        let pwWd = playlistWindow.frame.width
        let pwHt = window.frame.height
        pFrame.size = NSMakeSize(pwWd, pwHt)
        
        playlistWindow.setFrame(pFrame, display: true, animate: true)
    }
    
    @IBAction func dockPlaylistBottomAction(_ sender: AnyObject) {
        
        var pFrame = playlistWindow.frame
        
        let pwX = window.frame.origin.x
        let pwY = window.frame.origin.y - playlistWindow.frame.height
        pFrame.origin = NSPoint(x: pwX, y: pwY)
        
        let pwWd = window.frame.width
        let pwHt = playlistWindow.frame.height
        pFrame.size = NSMakeSize(pwWd, pwHt)
        
        playlistWindow.setFrame(pFrame, display: true, animate: true)
    }
    
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        toggleEffects(false)
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
        
        window.addChildWindow(playlistWindow, ordered: NSWindowOrderingMode.below)
        playlistWindow.setIsVisible(true)
        btnTogglePlaylist.state = 1
        btnTogglePlaylist.image = UIConstants.imgPlaylistOn
        viewPlaylistMenuItem.state = 1
        WindowState.showingPlaylist = true
        
        setFocusOnPlaylist()
    }
    
    private func hidePlaylist() {
        
        playlistWindow.setIsVisible(false)
        btnTogglePlaylist.state = 0
        btnTogglePlaylist.image = UIConstants.imgPlaylistOff
        viewPlaylistMenuItem.state = 0
        WindowState.showingPlaylist = false
    }
    
    private func toggleEffects(_ animate: Bool) {
        
        if (fxBox.isHidden) {
            
            // Show
            
            resizeWindow(true, animate)
            fxBox.isHidden = false
            btnToggleEffects.state = 1
            btnToggleEffects.image = UIConstants.imgEffectsOn
            viewEffectsMenuItem.state = 1
            WindowState.showingEffects = true
            
        } else {
            
            // Hide
            
            fxBox.isHidden = true
            resizeWindow(false, animate)
            btnToggleEffects.state = 0
            btnToggleEffects.image = UIConstants.imgEffectsOff
            viewEffectsMenuItem.state = 0
            WindowState.showingEffects = false
        }
        
        if (playlistWindow.isVisible) {
//            positionPlaylistWindow()
            // TODO: If playlist is docked at the bottom, move it up
            if (playlistDockState == .bottom) {
                dockPlaylistBottomAction(self)
            }
            setFocusOnPlaylist()
        }
    }
    
    private func setFocusOnPlaylist() {
//        window.makeFirstResponder(playlistWindow)
    }
    
    // Called when toggling views
    private func resizeWindow(_ effectsShown: Bool, _ animate: Bool) {
        
        var wFrame = window.frame
        let oldOrigin = wFrame.origin
        
        let newHeight: CGFloat = effectsShown ? UIConstants.windowHeight_effectsOnly : UIConstants.windowHeight_compact
        let oldHeight = wFrame.height
        let shrinking: Bool = newHeight < oldHeight
        
        wFrame.size = NSMakeSize(window.frame.width, newHeight)
        wFrame.origin = NSMakePoint(oldOrigin.x, shrinking ? oldOrigin.y + (oldHeight - newHeight) : oldOrigin.y - (newHeight - oldHeight))
        
        window.setFrame(wFrame, display: true, animate: animate)
    }
    
    func windowDidMove(_ notification: Notification) {
        playlistDockState = .none
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

enum PlaylistDockState {
    
    case bottom
    case right
    case left
    case none
}
