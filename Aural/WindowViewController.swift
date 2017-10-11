/*
    View controller for the main app window
 */

import Cocoa

class WindowViewController: NSViewController {
    
    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var playlistWindow: NSWindow!
    
    // Buttons to toggle (collapsible) playlist/effects views
    @IBOutlet weak var btnToggleEffects: NSButton!
    @IBOutlet weak var btnTogglePlaylist: NSButton!
    
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
        window.addChildWindow(playlistWindow, ordered: NSWindowOrderingMode.below)
        
        if (appState.hidePlaylist) {
            hidePlaylist()
        } else {
            showPlaylist()
        }
    }
    
    private func positionPlaylistWindow() {
        
        let pwX = window.frame.origin.x
        let pwY = window.frame.origin.y - playlistWindow.frame.height
        playlistWindow.setFrameOrigin(NSPoint(x: pwX, y: pwY))
        
        window.addChildWindow(playlistWindow, ordered: NSWindowOrderingMode.below)
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
        
        positionPlaylistWindow()
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
        
//        if (fxCollapsibleView?.hidden)! {
//            
//            // Show
//            
//            resizeWindow(playlistShown: !(playlistCollapsibleView?.hidden)!, effectsShown: true, animate)
//            fxCollapsibleView!.show()
//            btnToggleEffects.state = 1
//            btnToggleEffects.image = UIConstants.imgEffectsOn
//            viewEffectsMenuItem.state = 1
//            WindowState.showingEffects = true
//            
//        } else {
//            
//            // Hide
//            
//            fxCollapsibleView!.hide()
//            resizeWindow(playlistShown: !(playlistCollapsibleView?.hidden)!, effectsShown: false, animate)
//            btnToggleEffects.state = 0
//            btnToggleEffects.image = UIConstants.imgEffectsOff
//            viewEffectsMenuItem.state = 0
//            WindowState.showingEffects = false
//        }
        
        setFocusOnPlaylist()
    }
    
    private func setFocusOnPlaylist() {
//        window.makeFirstResponder(playlistWindow)
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
        let shrinking: Bool = newHeight < oldHeight
        
        wFrame.size = NSMakeSize(window.frame.width, newHeight)
        wFrame.origin = NSMakePoint(oldOrigin.x, shrinking ? oldOrigin.y + (oldHeight - newHeight) : oldOrigin.y - (newHeight - oldHeight))
        
        window.setFrame(wFrame, display: true, animate: animate)
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
