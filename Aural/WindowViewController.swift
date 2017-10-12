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
    
    private var playlistWindowOffset: CGPoint?
    
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
            dockPlaylistBottom()
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
        dockPlaylistRight()
    }
    
    private func dockPlaylistRight(_ resize: Bool = true) {
        
        playlistWindowDocking = true
        
        resizeWindow(playlistShown: false, effectsShown: !fxBox.isHidden, true)
        
        var pFrame = playlistWindow.frame
        
        let pwX = window.x + window.width
        var pwY = window.y
        pFrame.origin = NSPoint(x: pwX, y: pwY)
        
        if (resize) {
            let maxWd = max(screenWidth - pwX, UIConstants.minPlaylistWidth)
            let pwWd = min(playlistWindow.width, maxWd)
            let pwHt = window.height
            pFrame.size = NSMakeSize(pwWd, pwHt)
            
        } else if (playlistWindowOffset != nil) {
            
            pwY = (window.y + window.height) - playlistWindowOffset!.y - playlistWindow.height
            pFrame.origin = NSPoint(x: pwX, y: pwY)
            playlistWindowOffset = nil
        }
        
        playlistWindow.setFrame(pFrame, display: true, animate: false)
        playlistDockState = .right
        
        playlistWindowDocking = false
    }
    
    @IBAction func dockPlaylistLeftAction(_ sender: AnyObject) {
        dockPlaylistLeft()
    }
    
    private func dockPlaylistLeft(_ resize: Bool = true) {
        
        playlistWindowDocking = true
        
        resizeWindow(playlistShown: false, effectsShown: !fxBox.isHidden, true)
        
        var pFrame = playlistWindow.frame
        
        var pwWd: CGFloat = playlistWindow.width
        var pwX = window.x - pwWd
        var pwY = window.y
        
        if (resize) {
            
            let pwHt = window.height
            let maxWd = max(window.x, UIConstants.minPlaylistWidth)
            pwWd = min(playlistWindow.width, maxWd)
            pFrame.size = NSMakeSize(pwWd, pwHt)
            
            pwX = window.x - pwWd
            
        } else if (playlistWindowOffset != nil) {
            pwY = (window.y + window.height) - playlistWindowOffset!.y - playlistWindow.height
            playlistWindowOffset = nil
        }
        
        pFrame.origin = NSPoint(x: pwX, y: pwY)
        
        playlistWindow.setFrame(pFrame, display: true, animate: false)
        playlistDockState = .left
        
        playlistWindowDocking = false
    }
    
    @IBAction func dockPlaylistBottomAction(_ sender: AnyObject) {
        dockPlaylistBottom()
    }
    
    private func dockPlaylistBottom(_ resize: Bool = true) {
        
        playlistWindowDocking = true
        
        resizeWindow(playlistShown: true, effectsShown: !fxBox.isHidden, true)
        
        var pFrame = playlistWindow.frame
        var pwHt: CGFloat = playlistWindow.height
        
        if (resize) {
            let pwWd = window.width
            let maxHt = max(window.y, UIConstants.minPlaylistHeight)
            pwHt = min(playlistWindow.height, maxHt)
            pFrame.size = NSMakeSize(pwWd, pwHt)
        }
        
        var pwX = window.x
        let pwY = window.y - pwHt
        pFrame.origin = NSPoint(x: pwX, y: pwY)
        
        if (!resize && playlistWindowOffset != nil) {
            pwX = (window.x + window.width) - playlistWindowOffset!.x - playlistWindow.width
            pFrame.origin = NSPoint(x: pwX, y: pwY)
            playlistWindowOffset = nil
        }
        
        playlistWindow.setFrame(pFrame, display: true, animate: false)
        playlistDockState = .bottom
        
        playlistWindowDocking = false
    }
    
    private func shiftPlaylistBottom() {
        
        playlistWindowDocking = true
        
        var pFrame = playlistWindow.frame
        let pwHt: CGFloat = playlistWindow.height
        
        let pwX = playlistWindow.x
        let pwY = window.y - pwHt
        pFrame.origin = NSPoint(x: pwX, y: pwY)
        
        playlistWindow.setFrame(pFrame, display: true, animate: false)
        playlistWindowDocking = false
    }
    
    @IBAction func maximizePlaylistAction(_ sender: AnyObject) {
        
        playlistWindowDocking = true
        
        var pFrame = playlistWindow.frame
        var pwWd: CGFloat, pwHt: CGFloat
        var pwX: CGFloat, pwY: CGFloat
        
        let winX: CGFloat = window.x
        let winY: CGFloat = window.y
        
        switch playlistDockState {
            
        case .bottom:
            
            pwWd = screenWidth
            pwHt = winY
            
            pwX = 0
            pwY = 0
            
        case .right:
            
            pwWd = screenWidth - (winX + window.width)
            pwHt = screenHeight
            
            pwX = playlistWindow.x
            pwY = 0
            
        case .left:
            
            pwWd = winX
            pwHt = screenHeight
            
            pwX = 0
            pwY = 0
            
        case .none:
            
            pwWd = playlistWindow.width
            pwHt = playlistWindow.height
            
            pwX = playlistWindow.x
            pwY = playlistWindow.y
            
            var minX: CGFloat = 0, minY: CGFloat = 0, maxX: CGFloat = screenWidth, maxY: CGFloat = screenHeight
            
            if ((pwX + pwWd) < winX) {
                // Left
                maxX = winX - 1
            } else if (pwX > winX + window.width) {
                // Right
                minX = winX + window.width
            } else if ((pwY + pwHt) < winY) {
                // Below
                maxY = winY - 1
            } else if (pwY > (winY + window.height)) {
                // Above
                minY = winY + window.height
            } else if (pwX < winX) {
                // Left (overlapping main window)
                maxX = winX - 1
            } else if (pwX > winX) {
                // Right (overlapping main window)
                minX = winX + window.width
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
            dockPlaylistBottom(false)
        } else if (playlistDockState == .right) {
            dockPlaylistRight(false)
        } else if (playlistDockState == .left) {
            dockPlaylistLeft(false)
        } else {
            // TODO: Use the saved offset to position the pl wdw
            restorePlaylistAtOffset()
        }
    }
    
    private func restorePlaylistAtOffset() {
        
        if (playlistWindowOffset != nil) {
        
            playlistWindowDocking = true
            
            var pFrame = playlistWindow.frame
            
            let pwX = (window.x + window.width) - playlistWindowOffset!.x - playlistWindow.width
            let pwY = (window.y + window.height) - playlistWindowOffset!.y - playlistWindow.height
            playlistWindowOffset = nil
            
            pFrame.origin = NSPoint(x: pwX, y: pwY)
            
            playlistWindow.setFrame(pFrame, display: true, animate: false)
            
            playlistWindowDocking = false
        }
    }
    
    private func hidePlaylist() {
        
        // Top right corner offset
        let ox = (window.x + window.width) - (playlistWindow.x + playlistWindow.width)
        let oy = (window.y + window.height) - (playlistWindow.y + playlistWindow.height)
        playlistWindowOffset = NSPoint(x: ox, y: oy)
        
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
            shiftPlaylistBottom()
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
        
        wFrame.size = NSMakeSize(window.width, newHeight)
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
    
    func windowDidResize(_ notification: Notification) {
        
        if (playlistDockState == .none || playlistWindowDocking) {
            return
        }
        
        if (playlistDockState == .bottom) {
            
            if ((playlistWindow.y + playlistWindow.height) != window.y) {
                print("No longer docked bottom")
                playlistDockState = .none
            }
            
        } else if (playlistDockState == .right) {
            
            if ((window.x + window.width) != playlistWindow.x) {
                print("No longer docked right")
                playlistDockState = .none
            }
        } else if (playlistDockState == .left) {
            
            if ((playlistWindow.x + playlistWindow.width) != window.x) {
                print("No longer docked left")
                playlistDockState = .none
            }
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

extension NSWindow {
    
    var width: CGFloat {
        return self.frame.width
    }
    
    var height: CGFloat {
        return self.frame.height
    }
    
    var x: CGFloat {
        return self.frame.origin.x
    }
    
    var y: CGFloat {
        return self.frame.origin.y
    }
}
