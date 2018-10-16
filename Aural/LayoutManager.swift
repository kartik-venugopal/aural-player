import Cocoa

class LayoutManager: LayoutManagerProtocol, ActionMessageSubscriber {
    
    private let appState: WindowLayoutState
    private let preferences: ViewPreferences
    
    // App windows
    let mainWindow: NSWindow = WindowFactory.getMainWindow()
    let effectsWindow: NSWindow = WindowFactory.getEffectsWindow()
    let playlistWindow: NSWindow = WindowFactory.getPlaylistWindow()
    
    private lazy var visibleFrame: NSRect = {
        return NSScreen.main!.visibleFrame
    }()
    
    init(_ appState: WindowLayoutState, _ preferences: ViewPreferences) {
        
        // Use appState and prefs to determine initial layout
        self.appState = appState
        self.preferences = preferences
        
        SyncMessenger.subscribe(actionTypes: [.dockLeft, .dockRight, .dockBottom, .maximize, .maximizeVertical, .maximizeHorizontal, .toggleEffects, .togglePlaylist], subscriber: self)
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
    
    // MARK ----------- Playlist window docking ----------------------------------------------------
    
    // Docks the playlist below the main window
    func dockBottom() {
        
        let playlistHeight = min(playlistWindow.height, mainWindow.remainingHeight)
        
        dock(mainWindow.origin
            .applying(CGAffineTransform.init(translationX: 0, y: -playlistHeight)), NSMakeSize(playlistWindow.width, playlistHeight))
    }
    
    // Docks the playlist to the left of the main window
    func dockLeft() {
        
        let playlistWidth = min(mainWindow.remainingWidth, playlistWindow.width)
        
        dock(mainWindow.frame.origin
            .applying(CGAffineTransform.init(translationX: -playlistWidth, y: mainWindow.height - playlistWindow.height)), NSMakeSize(playlistWidth, playlistWindow.height))
    }
    
    // Docks the playlist to the right of the main window
    func dockRight() {
        
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
    }
    
    // MARK ----------- Playlist window maximizing ----------------------------------------------------
    
    // Maximizes the playlist horizontally
    func maximizeHorizontal() {
        maximize(true, false)
    }
    
    // Maximizes the playlist vertically
    func maximizeVertical() {
        maximize(false, true)
    }
    
    // Maximizes the playlist both horizontally and vertically
    func maximize(_ horizontal: Bool = true, _ vertical: Bool = true) {
        
        // When the playlist is not docked, vertical maximizing will take preference over horizontal maximizing (i.e. portrait orientation)
        
        // Figure out where the playlist window is, in relation to the main window
        if (playlistWindow.maxX < mainWindow.x) {
            
            // Playlist window is to the left of the main window. Maximize to the left of the main window.
            maximizeLeft(horizontal, vertical)
            
        } else if (playlistWindow.x >= mainWindow.maxX) {
            
            // Playlist window is to the right of the main window. Maximize to the right of the main window.
            maximizeRight(horizontal, vertical)
            
        } else if (playlistWindow.maxY <= mainWindow.y) {
            
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
    
    // MARK ----------- Message handling ----------------------------------------------------
    
    func getID() -> String {
        return "LayoutManager"
    }
    
    func consumeMessage(_ actionMessage: ActionMessage) {
        
        switch actionMessage.actionType {
            
        case .dockLeft: dockLeft()
            
        case .dockRight: dockRight()
            
        case .dockBottom: dockBottom()
            
        case .maximize: maximize()
            
        case .maximizeHorizontal: maximizeHorizontal()
            
        case .maximizeVertical: maximizeVertical()
            
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
        
        uiState.userWindowLayouts = WindowLayouts.userDefinedLayouts
        
        return uiState
    }
}
