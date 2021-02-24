import Cocoa

class WindowManager {
    
    private static var appState: WindowLayoutState!
    private static var preferences: ViewPreferences!
    
    static func initialize(_ appState: WindowLayoutState, _ preferences: ViewPreferences) {
        
        WindowManager.appState = appState
        WindowManager.preferences = preferences
    }
    
    // App's main window
    static var mainWindow: NSWindow = WindowFactory.mainWindow

    // Load these optional windows only if/when needed
    static var effectsWindow: NSWindow = WindowFactory.effectsWindow
    
    static var playlistWindow: NSWindow = WindowFactory.playlistWindow
    
    static var visualizerWindowController: VisualizerWindowController = VisualizerWindowController()
    static var vizWindow: NSWindow = visualizerWindowController.window!
    
    // Helps with lazy loading of chapters list window
    private static var chaptersListWindowLoaded: Bool = false
    
    static var chaptersListWindow: NSWindow = WindowFactory.chaptersListWindow
    
    static let windowDelegate: SnappingWindowDelegate = SnappingWindowDelegate()
    
//    private static var onTop: Bool = false
    
    // Each modal component, when it is loaded, will register itself here, which will enable tracking of modal dialogs / popovers
    private static var modalComponentRegistry: [ModalComponentProtocol] = []
    
    static func registerModalComponent(_ component: ModalComponentProtocol) {
        modalComponentRegistry.append(component)
    }
    
    static var isShowingModalComponent: Bool {
        return modalComponentRegistry.contains(where: {$0.isModal}) || NSApp.modalWindow != nil
    }
    
    // MARK - Core functionality ----------------------------------------------------
    
    static func initializeWindows() {
        
        if preferences.layoutOnStartup.option == .specific {
            
            layout(preferences.layoutOnStartup.layoutName)
            
        } else {
            
            // TODO: Improve the logic for defaultLayout ... maybe do a guard check at the beginning to see if defaultLayout is required ???
            
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
            
            Messenger.publish(WindowLayoutChangedNotification(showingPlaylistWindow: appState.showPlaylist, showingEffectsWindow: appState.showEffects))
        }
    }
    
    // Revert to default layout if app state is corrupted
    private static func defaultLayout() {
        layout(WindowLayouts.defaultLayout)
    }
    
    static func layout(_ layout: WindowLayout) {
        
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
        
        Messenger.publish(WindowLayoutChangedNotification(showingPlaylistWindow: layout.showPlaylist, showingEffectsWindow: layout.showEffects))
    }
    
    static var currentWindowLayout: WindowLayout {
        
        let effectsWindowOrigin = isShowingEffects ? effectsWindow.origin : nil
        let playlistWindowFrame = isShowingPlaylist ? playlistWindow.frame : nil
        
        return WindowLayout("_currentWindowLayout_", isShowingEffects, isShowingPlaylist, mainWindow.origin, effectsWindowOrigin, playlistWindowFrame, false)
    }
    
    static func layout(_ name: String) {
        layout(WindowLayouts.layoutByName(name)!)
    }
    
    static var isShowingEffects: Bool {
        return effectsWindow.isVisible
    }
    
    static var isShowingPlaylist: Bool {
        return playlistWindow.isVisible
    }
    
    // NOTE - Boolean short-circuiting is important here. Otherwise, the chapters list window will be unnecessarily loaded.
    static var isShowingChaptersList: Bool {
        return chaptersListWindowLoaded && chaptersListWindow.isVisible
    }
    
    // NOTE - Boolean short-circuiting is important here. Otherwise, the chapters list window will be unnecessarily loaded.
    static var isChaptersListWindowKey: Bool {
        return isShowingChaptersList && chaptersListWindow == NSApp.keyWindow
    }
    
    static var mainWindowFrame: NSRect {
        return mainWindow.frame
    }
    
    static var effectsWindowFrame: NSRect {
        return effectsWindow.frame
    }
    
    static var playlistWindowFrame: NSRect {
        return playlistWindow.frame
    }
    
    // MARK ----------- View toggling code ----------------------------------------------------
    
    // Shows/hides the effects window
    static func toggleEffects() {
        
        isShowingEffects ? hideEffects() : showEffects()
    }
    
    // Shows the effects window
    private static func showEffects() {
        
        mainWindow.addChildWindow(effectsWindow, ordered: NSWindow.OrderingMode.above)
        effectsWindow.setIsVisible(true)
        effectsWindow.orderFront(self)
    }
    
    // Hides the effects window
    private static func hideEffects() {
        effectsWindow.setIsVisible(false)
    }
    
    // Shows/hides the playlist window
    static func togglePlaylist() {
        
        isShowingPlaylist ? hidePlaylist() : showPlaylist()
    }
    
    // Shows the playlist window
    private static func showPlaylist() {
        
        mainWindow.addChildWindow(playlistWindow, ordered: NSWindow.OrderingMode.above)
        playlistWindow.setIsVisible(true)
        playlistWindow.orderFront(self)
    }
    
    // Hides the playlist window
    private static func hidePlaylist() {
        playlistWindow.setIsVisible(false)
    }
    
    static func toggleChaptersList() {
        
        isShowingChaptersList ? hideChaptersList() : showChaptersList()
    }
    
    static func showChaptersList() {
        
        playlistWindow.addChildWindow(chaptersListWindow, ordered: NSWindow.OrderingMode.above)
        chaptersListWindow.makeKeyAndOrderFront(self)
        
        // This will happen only once after each app launch - the very first time the window is shown.
        // After that, the window will be restored to its previous on-screen location
        if !chaptersListWindowLoaded {
            
            UIUtils.centerDialogWRTWindow(chaptersListWindow, playlistWindow)
            chaptersListWindowLoaded = true
        }
    }
    
    static func hideChaptersList() {
        
        if chaptersListWindowLoaded {
            chaptersListWindow.setIsVisible(false)
        }
    }
    
    static func showViz() {
        
        mainWindow.addChildWindow(vizWindow, ordered: NSWindow.OrderingMode.above)
        visualizerWindowController.showWindow(self)
        vizWindow.orderFront(self)
    }
    
    static func addChildWindow(_ window: NSWindow) {
        mainWindow.addChildWindow(window, ordered: .above)
    }
    
    //    static func toggleAlwaysOnTop() {
    //
    //        onTop = !onTop
    //        mainWindow.level = NSWindow.Level(Int(CGWindowLevelForKey(onTop ? .floatingWindow : .normalWindow)))
    //    }
    
    // Adjusts both window frames to the given location and size (specified as co-ordinates)
    private static func setWindowFrames(_ mainWindowX: CGFloat, _ mainWindowY: CGFloat, _ playlistX: CGFloat, _ playlistY: CGFloat, _ width: CGFloat, _ height: CGFloat) {
        
        mainWindow.setFrameOrigin(NSPoint(x: mainWindowX, y: mainWindowY))
        
        var playlistFrame = playlistWindow.frame
        
        playlistFrame.origin = NSPoint(x: playlistX, y: playlistY)
        playlistFrame.size = NSSize(width: width, height: height)
        playlistWindow.setFrame(playlistFrame, display: true)
    }
    
    // MARK ----------- Message handling ----------------------------------------------------
    
    static var persistentState: WindowLayoutState {
        
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
    
    fileprivate static func windowDidMove(_ notification: Notification) {
        
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
    private static func getCandidateWindowsForSnap(_ movedWindow: SnappingWindow) -> [NSWindow] {
        
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

class SnappingWindowDelegate: NSObject, NSWindowDelegate {
 
    func windowDidMove(_ notification: Notification) {
        WindowManager.windowDidMove(notification)
    }
}
