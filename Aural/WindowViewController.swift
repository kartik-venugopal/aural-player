/*
    View controller for the main app window
 */

import Cocoa

class WindowViewController: NSViewController {
    
    @IBOutlet weak var window: NSWindow!
    
    // Buttons to toggle (collapsible) playlist/effects views
    @IBOutlet weak var btnToggleEffects: NSButton!
    @IBOutlet weak var btnTogglePlaylist: NSButton!
    
    @IBOutlet weak var viewPlaylistMenuItem: NSMenuItem!
    @IBOutlet weak var viewEffectsMenuItem: NSMenuItem!
    
    // Views that are collapsible (hide/show)
    @IBOutlet weak var playlistBox: NSBox!
    @IBOutlet weak var playlistView: NSTableView!
    @IBOutlet weak var playlistControlsBox: NSBox!
    @IBOutlet weak var fxBox: NSBox!
    
    private var playlistCollapsibleView: CollapsibleView?
    private var fxCollapsibleView: CollapsibleView?
    
    override func viewDidLoad() {
        
        WindowState.window = self.window
        
        let appState = ObjectGraph.getUIAppState()
        
        playlistCollapsibleView = CollapsibleView(views: [playlistBox, playlistControlsBox])
        fxCollapsibleView = CollapsibleView(views: [fxBox])
        
        if (appState.hidePlaylist) {
            togglePlaylist(false)
        }
        
        if (appState.hideEffects) {
            toggleEffects(false)
        }
        
        window.setFrameOrigin(appState.windowLocation)
        window.isMovableByWindowBackground = true
        window.makeKeyAndOrderFront(self)
    }
    
    @IBAction func hideAction(_ sender: AnyObject) {
        window.miniaturize(self)
    }
    
    @IBAction func closeAction(_ sender: AnyObject) {
        
        let exitResponses = SyncMessenger.publishRequest(AppExitRequest.instance)
        
        for _response in exitResponses {
            
            let response = _response as! AppExitResponse
            
            // If any of the responses says it's not ok to exit, don't exit
            if (!response.okToExit) {
                return
            }
        }
        
        // None of the responses said don't exit, so it's ok to exit
        
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func togglePlaylistAction(_ sender: AnyObject) {
        togglePlaylist(true)
    }
    
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        toggleEffects(true)
    }
    
    private func togglePlaylist(_ animate: Bool) {
        
        // Set focus on playlist view if it's visible after the toggle
        
        if (playlistCollapsibleView?.hidden)! {
            
            // Show
            
            resizeWindow(playlistShown: true, effectsShown: !(fxCollapsibleView?.hidden)!, animate)
            playlistCollapsibleView!.show()
            //            window.makeFirstResponder(playlistView)
            btnTogglePlaylist.state = 1
            btnTogglePlaylist.image = UIConstants.imgPlaylistOn
            viewPlaylistMenuItem.state = 1
            WindowState.showingPlaylist = true
            
        } else {
            
            // Hide
            
            playlistCollapsibleView!.hide()
            resizeWindow(playlistShown: false, effectsShown: !(fxCollapsibleView?.hidden)!, animate)
            btnTogglePlaylist.state = 0
            btnTogglePlaylist.image = UIConstants.imgPlaylistOff
            viewPlaylistMenuItem.state = 0
            WindowState.showingPlaylist = false
        }
        
        setFocusOnPlaylist()
    }
    
    private func toggleEffects(_ animate: Bool) {
        
        if (fxCollapsibleView?.hidden)! {
            
            // Show
            
            resizeWindow(playlistShown: !(playlistCollapsibleView?.hidden)!, effectsShown: true, animate)
            fxCollapsibleView!.show()
            btnToggleEffects.state = 1
            btnToggleEffects.image = UIConstants.imgEffectsOn
            viewEffectsMenuItem.state = 1
            WindowState.showingEffects = true
            
        } else {
            
            // Hide
            
            fxCollapsibleView!.hide()
            resizeWindow(playlistShown: !(playlistCollapsibleView?.hidden)!, effectsShown: false, animate)
            btnToggleEffects.state = 0
            btnToggleEffects.image = UIConstants.imgEffectsOff
            viewEffectsMenuItem.state = 0
            WindowState.showingEffects = false
        }
        
        setFocusOnPlaylist()
    }
    
    private func setFocusOnPlaylist() {
        window.makeFirstResponder(playlistView)
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
}
