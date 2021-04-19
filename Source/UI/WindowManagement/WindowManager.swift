import Cocoa

protocol Destroyable {
    
    func destroy()
}

class WindowManager: NSObject, NSWindowDelegate {
    
    private static var _instance: WindowManager?
    
    static var instance: WindowManager! {_instance}
    
    static func createInstance(preferences: ViewPreferences) {
        _instance = WindowManager(preferences: preferences)
    }
    
    static func destroyInstance() {
        
        _instance?.destroy()
        _instance = nil
    }
    
    private let preferences: ViewPreferences
    
    // App's main window
    private let mainWindowController: MainWindowController
    let mainWindow: NSWindow
    
    // Load these optional windows only if/when needed
    private lazy var effectsWindowLoader: LazyWindowLoader<EffectsWindowController> = LazyWindowLoader()
    private lazy var _effectsWindow: NSWindow = {[weak self] in
        
        effectsWindowLoader.window.delegate = self
        return effectsWindowLoader.window
    }()
    
    var effectsWindow: NSWindow? {effectsWindowLoader.windowLoaded ? _effectsWindow : nil}

    private lazy var playlistWindowLoader: LazyWindowLoader<PlaylistWindowController> = LazyWindowLoader()
    private lazy var _playlistWindow: NSWindow = {[weak self] in
        
        playlistWindowLoader.window.delegate = self
        return playlistWindowLoader.window
    }()
    
    var playlistWindow: NSWindow? {playlistWindowLoader.windowLoaded ? _playlistWindow : nil}

    private lazy var chaptersListWindowLoader: LazyWindowLoader<ChaptersListWindowController> = LazyWindowLoader()
    private lazy var _chaptersListWindow: NSWindow = {[weak self] in
        
        chaptersListWindowLoader.window.delegate = self
        return chaptersListWindowLoader.window
    }()
    var chaptersListWindow: NSWindow? {chaptersListWindowLoader.windowLoaded ? _chaptersListWindow : nil}
    
    private lazy var visualizerWindowLoader: LazyWindowLoader<VisualizerWindowController> = LazyWindowLoader()
    private lazy var _visualizerWindow: NSWindow = visualizerWindowLoader.window
    
    var visualizerWindow: NSWindow? {visualizerWindowLoader.windowLoaded ? _visualizerWindow : nil}
    
//    private var onTop: Bool = false
    
    // Each modal component, when it is loaded, will register itself here, which will enable tracking of modal dialogs / popovers
    private var modalComponentRegistry: [ModalComponentProtocol] = []
    
    init(preferences: ViewPreferences) {
        
        self.preferences = preferences
        
        self.mainWindowController = MainWindowController()
        self.mainWindow = mainWindowController.window!
        
        super.init()
        self.mainWindow.delegate = self
    }
    
    func registerModalComponent(_ component: ModalComponentProtocol) {
        modalComponentRegistry.append(component)
    }
    
    var isShowingModalComponent: Bool {
        return modalComponentRegistry.contains(where: {$0.isModal}) || NSApp.modalWindow != nil
    }
    
    // MARK - Core functionality ----------------------------------------------------
    
    func loadWindows() {
        
        if preferences.layoutOnStartup.option == .specific {
            
            layout(preferences.layoutOnStartup.layoutName)
            
        } else {
            
            // Remember from last app launch
            mainWindow.setFrameOrigin(WindowLayoutState.mainWindowOrigin)
            mainWindow.show()
            
            if WindowLayoutState.showEffects {
                
                mainWindow.addChildWindow(_effectsWindow, ordered: NSWindow.OrderingMode.below)
                
                if let effectsWindowOrigin = WindowLayoutState.effectsWindowOrigin {
                    
                    _effectsWindow.setFrameOrigin(effectsWindowOrigin)
                    _effectsWindow.show()
                    
                } else {
                    defaultLayout()
                }
            }
            
            if WindowLayoutState.showPlaylist {
                
                mainWindow.addChildWindow(_playlistWindow, ordered: NSWindow.OrderingMode.below)
                
                if let playlistWindowFrame = WindowLayoutState.playlistWindowFrame {
                    
                    _playlistWindow.setFrame(playlistWindowFrame, display: true)
                    _playlistWindow.show()
                    
                } else {
                    defaultLayout()
                }
            }
            
            mainWindow.makeKeyAndOrderFront(self)
            Messenger.publish(WindowLayoutChangedNotification(showingPlaylistWindow: WindowLayoutState.showPlaylist, showingEffectsWindow: WindowLayoutState.showEffects))
        }
    }
    
    func destroy() {
        
        for window in mainWindow.childWindows ?? [] {
            mainWindow.removeChildWindow(window)
        }
        
        mainWindowController.destroy()
        effectsWindowLoader.destroy()
        playlistWindowLoader.destroy()
        chaptersListWindowLoader.destroy()
        visualizerWindowLoader.destroy()
    }
    
    // Revert to default layout if app state is corrupted
    private func defaultLayout() {
        layout(WindowLayouts.defaultLayout)
    }
    
    func layout(_ layout: WindowLayout) {
        
        mainWindow.setFrameOrigin(layout.mainWindowOrigin)
        
        if layout.showEffects {
            
            mainWindow.addChildWindow(_effectsWindow, ordered: NSWindow.OrderingMode.below)
            _effectsWindow.setFrameOrigin(layout.effectsWindowOrigin!)
            _effectsWindow.show()
            
        } else {
            hideEffects()
        }
        
        if layout.showPlaylist {
            
            mainWindow.addChildWindow(_playlistWindow, ordered: NSWindow.OrderingMode.below)
            _playlistWindow.setFrame(layout.playlistWindowFrame!, display: true)
            _playlistWindow.show()
            
        } else {
            hidePlaylist()
        }
        
        Messenger.publish(WindowLayoutChangedNotification(showingPlaylistWindow: layout.showPlaylist, showingEffectsWindow: layout.showEffects))
    }
    
    var currentWindowLayout: WindowLayout {
        
        let effectsWindowOrigin = isShowingEffects ? _effectsWindow.origin : nil
        let playlistWindowFrame = isShowingPlaylist ? _playlistWindow.frame : nil
        
        return WindowLayout("_currentWindowLayout_", isShowingEffects, isShowingPlaylist, mainWindow.origin, effectsWindowOrigin, playlistWindowFrame, false)
    }
    
    func layout(_ name: String) {
        layout(WindowLayouts.layoutByName(name)!)
    }
    
    var isShowingEffects: Bool {
        return effectsWindowLoader.windowLoaded && _effectsWindow.isVisible
    }
    
    var isShowingPlaylist: Bool {
        return playlistWindowLoader.windowLoaded && _playlistWindow.isVisible
    }
    
    // NOTE - Boolean short-circuiting is important here. Otherwise, the chapters list window will be unnecessarily loaded.
    var isShowingChaptersList: Bool {
        return chaptersListWindowLoader.windowLoaded && _chaptersListWindow.isVisible
    }
    
    // NOTE - Boolean short-circuiting is important here. Otherwise, the chapters list window will be unnecessarily loaded.
    var isChaptersListWindowKey: Bool {
        return isShowingChaptersList && chaptersListWindow == NSApp.keyWindow
    }
    
    var isShowingVisualizer: Bool {
        return visualizerWindowLoader.windowLoaded && _visualizerWindow.isVisible
    }
    
    var mainWindowFrame: NSRect {
        return mainWindow.frame
    }
    
    // MARK ----------- View toggling code ----------------------------------------------------
    
    // Shows/hides the effects window
    func toggleEffects() {
        isShowingEffects ? hideEffects() : showEffects()
    }
    
    // Shows the effects window
    private func showEffects() {
        
        mainWindow.addChildWindow(_effectsWindow, ordered: NSWindow.OrderingMode.above)
        _effectsWindow.show()
        _effectsWindow.orderFront(self)
    }
    
    // Hides the effects window
    private func hideEffects() {
        
        if effectsWindowLoader.windowLoaded {
            _effectsWindow.hide()
        }
    }
    
    // Shows/hides the playlist window
    func togglePlaylist() {
        isShowingPlaylist ? hidePlaylist() : showPlaylist()
    }
    
    // Shows the playlist window
    private func showPlaylist() {
        
        mainWindow.addChildWindow(_playlistWindow, ordered: NSWindow.OrderingMode.above)
        _playlistWindow.show()
        _playlistWindow.orderFront(self)
    }
    
    // Hides the playlist window
    private func hidePlaylist() {
        
        if playlistWindowLoader.windowLoaded {
            _playlistWindow.hide()
        }
    }
    
    func toggleChaptersList() {
        isShowingChaptersList ? hideChaptersList() : showChaptersList()
    }
    
    func showChaptersList() {
        
        let shouldCenterChaptersListWindow = !chaptersListWindowLoader.windowLoaded
        
        _playlistWindow.addChildWindow(_chaptersListWindow, ordered: NSWindow.OrderingMode.above)
        _chaptersListWindow.makeKeyAndOrderFront(self)
        
        // This will happen only once after each app launch - the very first time the window is shown.
        // After that, the window will be restored to its previous on-screen location
        if shouldCenterChaptersListWindow {
            UIUtils.centerDialogWRTWindow(_chaptersListWindow, _playlistWindow)
        }
    }
    
    func hideChaptersList() {
        
        if chaptersListWindowLoader.windowLoaded {
            _chaptersListWindow.hide()
        }
    }
    
    func toggleVisualizer() {
        isShowingVisualizer ? hideVisualizer() : showVisualizer()
    }
    
    private func showVisualizer() {
        
        mainWindow.addChildWindow(_visualizerWindow, ordered: NSWindow.OrderingMode.above)
        visualizerWindowLoader.controller.showWindow(self)
    }
    
    private func hideVisualizer() {
        visualizerWindowLoader.controller.close()
    }
    
    func addChildWindow(_ window: NSWindow) {
        mainWindow.addChildWindow(window, ordered: .above)
    }
    
    //    func toggleAlwaysOnTop() {
    //
    //        onTop = !onTop
    //        mainWindow.level = NSWindow.Level(Int(CGWindowLevelForKey(onTop ? .floatingWindow : .normalWindow)))
    //    }
    
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
        
        if isShowingPlaylist && movedWindow === _playlistWindow {
            return isShowingEffects ? [mainWindow, _effectsWindow] : [mainWindow]
            
        } else if isShowingEffects && movedWindow === _effectsWindow {
            return isShowingPlaylist ? [mainWindow, _playlistWindow] : [mainWindow]
            
        } else if isShowingChaptersList && movedWindow === chaptersListWindow {
            
            var candidates: [NSWindow] = [mainWindow]
            
            if isShowingEffects {candidates.append(_effectsWindow)}
            if isShowingPlaylist {candidates.append(_playlistWindow)}
            
            return candidates
        }
        
        // Main window
        return []
    }
}

class WindowLayoutState {
    
    static var showEffects: Bool = true
    static var showPlaylist: Bool = true
    
    static var mainWindowOrigin: NSPoint = NSPoint.zero
    static var effectsWindowOrigin: NSPoint? = nil
    static var playlistWindowFrame: NSRect? = nil
}

// Convenient accessor for information about the current appearance settings for the app's main windows.
class WindowAppearanceState {
    static var cornerRadius: CGFloat = AppDefaults.windowCornerRadius
}

// A snapshot of WindowAppearanceState
struct WindowAppearance {
    let cornerRadius: CGFloat
}
