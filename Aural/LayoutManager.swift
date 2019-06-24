import Cocoa

class LayoutManager: LayoutManagerProtocol, ActionMessageSubscriber {
    
    private let appState: WindowLayoutState
    private let preferences: ViewPreferences
    
    // App windows
    let mainWindow: NSWindow = WindowFactory.getMainWindow()
    let effectsWindow: NSWindow = WindowFactory.getEffectsWindow()
    let playlistWindow: NSWindow = WindowFactory.getPlaylistWindow()
    
    private var onTop: Bool = false
    
    init(_ appState: WindowLayoutState, _ preferences: ViewPreferences) {
        
        // Use appState and prefs to determine initial layout
        self.appState = appState
        self.preferences = preferences
        
        SyncMessenger.subscribe(actionTypes: [.toggleEffects, .togglePlaylist], subscriber: self)
    }
    
    // MARK - Core functionality ----------------------------------------------------
    
    func initialLayout() {
        
        if preferences.layoutOnStartup.option == .specific {
            
            layout(preferences.layoutOnStartup.layoutName)
            
        } else {
            
            // Remember from last app launch
            mainWindow.setFrameOrigin(appState.mainWindowOrigin)
            
            if appState.showEffects {
                
                mainWindow.addChildWindow(effectsWindow, ordered: NSWindow.OrderingMode.below)
                
                if let effectsWindowOrigin = appState.effectsWindowOrigin {
                    effectsWindow.setFrameOrigin(effectsWindowOrigin)
                } else {
                    defaultLayout()
                }
            }
            
            if appState.showPlaylist {
                
                mainWindow.addChildWindow(playlistWindow, ordered: NSWindow.OrderingMode.below)
                
                if let playlistWindowFrame = appState.playlistWindowFrame {
                    playlistWindow.setFrame(playlistWindowFrame, display: true)
                } else {
                    defaultLayout()
                }
            }
            
            mainWindow.setIsVisible(true)
            effectsWindow.setIsVisible(appState.showEffects)
            playlistWindow.setIsVisible(appState.showPlaylist)
            
            SyncMessenger.publishNotification(LayoutChangedNotification(appState.showEffects, appState.showPlaylist))
        }
    }
    
    // Revert to default layout if app state is corrupted
    private func defaultLayout() {
        layout(WindowLayouts.defaultLayout)
    }
    
    func layout(_ layout: WindowLayout) {
        
        mainWindow.setFrameOrigin(layout.mainWindowOrigin)
        
        if layout.showEffects {
            
            mainWindow.addChildWindow(effectsWindow, ordered: NSWindow.OrderingMode.below)
            effectsWindow.setFrameOrigin(layout.effectsWindowOrigin!)
        }
        
        if layout.showPlaylist {
            
            mainWindow.addChildWindow(playlistWindow, ordered: NSWindow.OrderingMode.below)
            playlistWindow.setFrame(layout.playlistWindowFrame!, display: true)
        }
        
        mainWindow.setIsVisible(true)
        effectsWindow.setIsVisible(layout.showEffects)
        playlistWindow.setIsVisible(layout.showPlaylist)
        
        SyncMessenger.publishNotification(LayoutChangedNotification(layout.showEffects, layout.showPlaylist))
    }
    
    func layout(_ name: String) {
        layout(WindowLayouts.layoutByName(name)!)
    }
    
    func isShowingEffects() -> Bool {
        return effectsWindow.isVisible
    }
    
    func isShowingPlaylist() -> Bool {
        return playlistWindow.isVisible
    }
    
    func getMainWindowFrame() -> NSRect {
        return mainWindow.frame
    }
    
    func getEffectsWindowFrame() -> NSRect {
        return effectsWindow.frame
    }
    
    func getPlaylistWindowFrame() -> NSRect {
        return playlistWindow.frame
    }
    
    func toggleAlwaysOnTop() {
        
        onTop = !onTop
        mainWindow.level = NSWindow.Level(Int(CGWindowLevelForKey(onTop ? .floatingWindow : .normalWindow)))
    }
    
    // MARK ----------- View toggling code ----------------------------------------------------
    
    // Shows/hides the effects window
    func toggleEffects() {
        
        !isShowingEffects() ? showEffects() : hideEffects()
    }
    
    // Shows the effects window
    private func showEffects() {
        
        mainWindow.addChildWindow(effectsWindow, ordered: NSWindow.OrderingMode.above)
        effectsWindow.setIsVisible(true)
        effectsWindow.orderFront(self)
    }
    
    // Hides the effects window
    private func hideEffects() {
        effectsWindow.setIsVisible(false)
    }
    
    // Shows/hides the playlist window
    func togglePlaylist() {
        
        !isShowingPlaylist() ? showPlaylist() : hidePlaylist()
    }
    
    // Shows the playlist window
    private func showPlaylist() {
        
        mainWindow.addChildWindow(playlistWindow, ordered: NSWindow.OrderingMode.above)
        playlistWindow.setIsVisible(true)
        playlistWindow.orderFront(self)
    }
    
    // Hides the playlist window
    private func hidePlaylist() {
        playlistWindow.setIsVisible(false)
    }
    
    func addChildWindow(_ window: NSWindow) {
        mainWindow.addChildWindow(window, ordered: .above)
    }
    
    // Adjusts both window frames to the given location and size (specified as co-ordinates)
    private func setWindowFrames(_ mainWindowX: CGFloat, _ mainWindowY: CGFloat, _ playlistX: CGFloat, _ playlistY: CGFloat, _ width: CGFloat, _ height: CGFloat) {
        
        mainWindow.setFrameOrigin(NSPoint(x: mainWindowX, y: mainWindowY))
        
        var playlistFrame = playlistWindow.frame
        
        playlistFrame.origin = NSPoint(x: playlistX, y: playlistY)
        playlistFrame.size = NSSize(width: width, height: height)
        playlistWindow.setFrame(playlistFrame, display: true)
    }
    
    // MARK ----------- Message handling ----------------------------------------------------
    
    var subscriberId: String {
        return "LayoutManager"
    }
    
    func consumeMessage(_ actionMessage: ActionMessage) {
        
        switch actionMessage.actionType {
            
        case .toggleEffects:    toggleEffects()
            
        case .togglePlaylist:   togglePlaylist()
            
        default: return
            
        }
    }
    
    func persistentState() -> WindowLayoutState {
        
        let uiState = WindowLayoutState()
        
        uiState.showEffects = effectsWindow.isVisible
        uiState.showPlaylist = playlistWindow.isVisible
        
        uiState.mainWindowOrigin = mainWindow.origin
        
        uiState.effectsWindowOrigin = effectsWindow.origin
        uiState.playlistWindowFrame = playlistWindow.frame
        
        uiState.userLayouts = WindowLayouts.userDefinedLayouts
        
        return uiState
    }
}
