import Cocoa

class WindowManager: NSObject, WindowManagerProtocol, ActionMessageSubscriber {
    
    private let appState: WindowLayoutState
    private let preferences: ViewPreferences
    
    // App's main window
    lazy var mainWindow: NSWindow = WindowFactory.mainWindow

    // Load these optional windows only if/when needed
    lazy var effectsWindow: NSWindow = WindowFactory.effectsWindow
    lazy var playlistWindow: NSWindow = WindowFactory.playlistWindow
    lazy var chaptersListWindow: NSWindow = WindowFactory.chaptersListWindow
    
//    private var onTop: Bool = false
    
    // Each modal component, when it is loaded, will register itself here, which will enable tracking of modal dialogs / popovers
    private var modalComponentRegistry: [ModalComponentProtocol] = []
    
    func registerModalComponent(_ component: ModalComponentProtocol) {
        modalComponentRegistry.append(component)
    }
    
    var isShowingModalComponent: Bool {
        return modalComponentRegistry.contains(where: {$0.isModal})
    }
    
    init(_ appState: WindowLayoutState, _ preferences: ViewPreferences) {
        
        // Use appState and prefs to determine initial layout
        self.appState = appState
        self.preferences = preferences
        
        super.init()
        SyncMessenger.subscribe(actionTypes: [.toggleEffects, .togglePlaylist, .toggleChaptersList], subscriber: self)
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
    
    var isShowingEffects: Bool {
        return effectsWindow.isVisible
    }
    
    var isShowingPlaylist: Bool {
        return playlistWindow.isVisible
    }
    
    var isShowingChaptersList: Bool {
        return chaptersListWindow.isVisible
    }
    
    var mainWindowFrame: NSRect {
        return mainWindow.frame
    }
    
    var effectsWindowFrame: NSRect {
        return effectsWindow.frame
    }
    
    var playlistWindowFrame: NSRect {
        return playlistWindow.frame
    }
    
    // MARK ----------- View toggling code ----------------------------------------------------
    
    func toggleAlwaysOnTop() {
        
//        onTop = !onTop
//        mainWindow.level = NSWindow.Level(Int(CGWindowLevelForKey(onTop ? .floatingWindow : .normalWindow)))
    }
    
    // Shows/hides the effects window
    func toggleEffects() {
        
        isShowingEffects ? hideEffects() : showEffects()
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
        
        isShowingPlaylist ? hidePlaylist() : showPlaylist()
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
    
    func toggleChaptersList() {
        
        isShowingChaptersList ? hideChaptersList() : showChaptersList()
    }
    
    // Flag indicating whether or not the chapters list window was ever shown
    private var chaptersListWindowShown: Bool = false
    
    func showChaptersList() {
        
        playlistWindow.addChildWindow(chaptersListWindow, ordered: NSWindow.OrderingMode.above)
        chaptersListWindow.makeKeyAndOrderFront(self)
        
        // This will happen only once after each app launch - the very first time the window is shown.
        // After that, the window will be restored to its previous on-screen location
        if !chaptersListWindowShown {
            UIUtils.centerDialogWRTWindow(chaptersListWindow, playlistWindow)
        }
        
        chaptersListWindowShown = true
    }
    
    func hideChaptersList() {
        chaptersListWindow.setIsVisible(false)
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
            
        case .toggleChaptersList: toggleChaptersList()
            
        default: return
            
        }
    }
    
    var persistentState: WindowLayoutState {
        
        let uiState = WindowLayoutState()
        
        uiState.showEffects = effectsWindow.isVisible
        uiState.showPlaylist = playlistWindow.isVisible
        
        uiState.mainWindowOrigin = mainWindow.origin
        
        uiState.effectsWindowOrigin = effectsWindow.origin
        uiState.playlistWindowFrame = playlistWindow.frame
        
        uiState.userLayouts = WindowLayouts.userDefinedLayouts
        
        return uiState
    }
    
    // MARK: NSWindowDelegate functions
    
    func windowDidMove(_ notification: Notification) {
        
        // Only respond if movement was user-initiated (flag on window)
        if let movedWindow = notification.object as? SnappingWindow, movedWindow.userMovingWindow {
            
            var snapped = false
            
            if preferences.snapToWindows {
                
                // First check if window can be snapped to another app window
                for mate in getCandidateWindowsForSnap(movedWindow) {
                    
                    if mate.isVisible && UIUtils.checkForSnapToWindow(movedWindow, mate) {
                        
                        snapped = true
                        break
                    }
                }
            }

            // If window doesn't need to be snapped to another window, check if it needs to be snapped to the visible frame
            if preferences.snapToScreen && !snapped {
                UIUtils.checkForSnapToVisibleFrame(movedWindow)
            }
        }
    }
    
    // Sorted by order of relevance
    private func getCandidateWindowsForSnap(_ movedWindow: SnappingWindow) -> [NSWindow] {
        
        if movedWindow === playlistWindow {
            return [mainWindow, effectsWindow]
            
        } else if movedWindow === effectsWindow {
            return [mainWindow, playlistWindow]
            
        } else if movedWindow === chaptersListWindow {
            return [playlistWindow, mainWindow, effectsWindow]
        }
        
        // Main window
        return []
    }
}
