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
    
    var playlistCollapsibleView: CollapsibleView?
    var fxCollapsibleView: CollapsibleView?
    
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
        
        positionWindow(appState.windowLocation)
        window.isMovableByWindowBackground = true
        window.makeKeyAndOrderFront(self)
        
//        SyncMessenger.subscribe(.appExitNotification, subscriber: self)
    }
    
    func positionWindow(_ location: NSPoint) {
        window.setFrameOrigin(location)
    }
    
    @IBAction func hideAction(_ sender: AnyObject) {
        window.miniaturize(self)
    }
    
    @IBAction func closeAction(_ sender: AnyObject) {
        
        // TODO: Check if recording ongoing
        
        //        if let _ = player.getRecordingInfo() {
        //
        //            // Recording ongoing, prompt the user to save/discard it
        //            let response = UIElements.saveRecordingAlert.runModal()
        //
        //            switch response {
        //
        //            case RecordingAlertResponse.dontExit.rawValue: return
        //            case RecordingAlertResponse.saveAndExit.rawValue: stopRecording()
        //            case RecordingAlertResponse.discardAndExit.rawValue: player.deleteRecording()
        //
        //            // Impossible
        //            default: return
        //
        //            }
        //        }
        
        NSApplication.shared().terminate(self)
    }
    
    @IBAction func toggleEffectsMenuItemAction(_ sender: AnyObject) {
        toggleEffects(true)
    }
    
    @IBAction func togglePlaylistMenuItemAction(_ sender: AnyObject) {
        togglePlaylist(true)
    }
    
    // Toggle button action
    @IBAction func togglePlaylistAction(_ sender: AnyObject) {
        togglePlaylist(true)
    }
    
    // Toggle button action
    @IBAction func toggleEffectsAction(_ sender: AnyObject) {
        toggleEffects(true)
    }
    
    private func togglePlaylist(_ animate: Bool) {
        
        // Set focus on playlist view if it's visible after the toggle
        
        if (playlistCollapsibleView?.hidden)! {
            resizeWindow(playlistShown: true, effectsShown: !(fxCollapsibleView?.hidden)!, animate)
            playlistCollapsibleView!.show()
            //            window.makeFirstResponder(playlistView)
            btnTogglePlaylist.state = 1
            btnTogglePlaylist.image = UIConstants.imgPlaylistOn
            viewPlaylistMenuItem.state = 1
            WindowState.showingPlaylist = true
            
        } else {
            
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
            resizeWindow(playlistShown: !(playlistCollapsibleView?.hidden)!, effectsShown: true, animate)
            fxCollapsibleView!.show()
            btnToggleEffects.state = 1
            btnToggleEffects.image = UIConstants.imgEffectsOn
            viewEffectsMenuItem.state = 1
            WindowState.showingEffects = true
            
        } else {
            
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
    
    private func isEffectsShown() -> Bool {
        return fxCollapsibleView?.hidden == false
    }
    
    private func isPlaylistShown() -> Bool {
        return playlistCollapsibleView?.hidden == false
    }
    
//    func consumeNotification(_ notification: NotificationMessage) {
//        
//        if (notification is AppExitNotification) {
//            saveUIState()
//        }
//    }
//    
//    // This method will never get called, as this class does not process requests
//    func processRequest(_ request: RequestMessage) -> ResponseMessage {
//        return EmptyResponse.instance
//    }
//    
//    func saveUIState() {
//        
//        let appState = ObjectGraph.getAppState()
//        
//        let uiState = UIState()
//        uiState.windowLocationX = Float(window.frame.origin.x)
//        uiState.windowLocationY = Float(window.frame.origin.y)
//        uiState.showPlaylist = isPlaylistShown()
//        uiState.showEffects = isEffectsShown()
//        
//        appState.uiState = uiState
//    }
}

// Provides convenient access to the main window, across the app
class WindowState {
    
    static var window: NSWindow?
    static var showingPlaylist: Bool = true
    static var showingEffects: Bool = true
    
    static func location() -> NSPoint {
        return window!.frame.origin
    }
}
