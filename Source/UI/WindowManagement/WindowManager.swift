//
//  WindowManager.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

protocol Destroyable {
    
    func destroy()
    
    static func destroy()
}

extension Destroyable {
    
    func destroy() {}
    
    static func destroy() {}
}

class WindowManager: NSObject, NSWindowDelegate, Destroyable {
    
    private static var _instance: WindowManager?
    
    static var instance: WindowManager! {_instance}
    
    static func createInstance(layoutsManager: WindowLayoutsManager, preferences: ViewPreferences) -> WindowManager {
        
        _instance = WindowManager(layoutsManager: layoutsManager, preferences: preferences)
        return instance
    }
    
    static func destroy() {
        
        _instance?.destroy()
        _instance = nil
    }
    
    private let preferences: ViewPreferences
    private let layoutsManager: WindowLayoutsManager
    
    // App's main window
    private let mainWindowController: MainWindowController
    let mainWindow: NSWindow
    
    // Load these optional windows only if/when needed
    private var effectsWindowLoader: LazyWindowLoader<EffectsWindowController> = LazyWindowLoader()
    private lazy var _effectsWindow: NSWindow = {[weak self] in
        
        effectsWindowLoader.window.delegate = self
        return effectsWindowLoader.window
    }()
    
    var effectsWindow: NSWindow? {effectsWindowLoader.windowLoaded ? _effectsWindow : nil}
    var effectsWindowLoaded: Bool {effectsWindowLoader.windowLoaded}

    private var playlistWindowLoader: LazyWindowLoader<PlaylistWindowController> = LazyWindowLoader()
    private lazy var _playlistWindow: NSWindow = {[weak self] in
        
        playlistWindowLoader.window.delegate = self
        return playlistWindowLoader.window
    }()
    
    var playlistWindow: NSWindow? {playlistWindowLoader.windowLoaded ? _playlistWindow : nil}
    var playlistWindowLoaded: Bool {playlistWindowLoader.windowLoaded}

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
    
    init(layoutsManager: WindowLayoutsManager, preferences: ViewPreferences) {
        
        self.layoutsManager = layoutsManager
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
        
        if preferences.layoutOnStartup.option == .specific, let layoutName = preferences.layoutOnStartup.layoutName {
            
            layout(layoutName)
            
        } else {
            
            // Remember from last app launch
            mainWindow.setFrameOrigin(WindowLayoutState.mainWindowOrigin)
            mainWindow.show()
            
            if WindowLayoutState.showEffects {
                
                mainWindow.addChildWindow(_effectsWindow, ordered: .below)
                
                if let effectsWindowOrigin = WindowLayoutState.effectsWindowOrigin {
                    
                    _effectsWindow.setFrameOrigin(effectsWindowOrigin)
                    _effectsWindow.show()
                    
                } else {
                    defaultLayout()
                }
            }
            
            if WindowLayoutState.showPlaylist {
                
                mainWindow.addChildWindow(_playlistWindow, ordered: .below)
                
                if let playlistWindowFrame = WindowLayoutState.playlistWindowFrame {
                    
                    _playlistWindow.setFrame(playlistWindowFrame, display: true)
                    _playlistWindow.show()
                    
                } else {
                    defaultLayout()
                }
            }
            
            mainWindow.makeKeyAndOrderFront(self)
            Messenger.publish(WindowLayoutChangedNotification(showingPlaylistWindow: WindowLayoutState.showPlaylist, showingEffectsWindow: WindowLayoutState.showEffects))
            
            (mainWindow as? SnappingWindow)?.ensureOnScreen()
        }
    }
    
    func destroy() {
        
        // Before destroying this instance, transfer its state info to WindowLayoutState.
        
        WindowLayoutState.showEffects = isShowingEffects
        WindowLayoutState.showPlaylist = isShowingPlaylist
        
        WindowLayoutState.mainWindowOrigin = mainWindow.origin
        WindowLayoutState.playlistWindowFrame = playlistWindow?.frame
        WindowLayoutState.effectsWindowOrigin = effectsWindow?.origin
        
        for window in mainWindow.childWindows ?? [] {
            mainWindow.removeChildWindow(window)
        }
        
        ([mainWindowController, effectsWindowLoader, playlistWindowLoader, chaptersListWindowLoader, visualizerWindowLoader] as? [Destroyable])?.forEach {
            $0.destroy()
        }
    }
    
    // Revert to default layout if app state is corrupted
    private func defaultLayout() {
        layout(layoutsManager.defaultLayout)
    }
    
    func layout(_ layout: WindowLayout) {
        
        mainWindow.setFrameOrigin(layout.mainWindowOrigin)
        
        if layout.showEffects {
            
            // TODO: Replace .zero with proper computation of a default origin.
            let origin = layout.effectsWindowOrigin ?? .zero
            
            mainWindow.addChildWindow(_effectsWindow, ordered: .below)
            _effectsWindow.setFrameOrigin(origin)
            _effectsWindow.show()
            
        } else {
            hideEffects()
        }
        
        if layout.showPlaylist {
            
            // TODO: Replace .zero with proper computation of a default frame.
            let frame = layout.playlistWindowFrame ?? .zero
            
            mainWindow.addChildWindow(_playlistWindow, ordered: .below)
            _playlistWindow.setFrame(frame, display: true)
            _playlistWindow.show()
            
        } else {
            hidePlaylist()
        }
        
        Messenger.publish(WindowLayoutChangedNotification(showingPlaylistWindow: layout.showPlaylist,
                                                          showingEffectsWindow: layout.showEffects))
    }
    
    var currentWindowLayout: WindowLayout {
        
        let effectsWindowOrigin = isShowingEffects ? _effectsWindow.origin : nil
        let playlistWindowFrame = isShowingPlaylist ? _playlistWindow.frame : nil
        
        return WindowLayout("_currentWindowLayout_", isShowingEffects, isShowingPlaylist, mainWindow.origin, effectsWindowOrigin, playlistWindowFrame, false)
    }
    
    func layout(_ name: String) {
        
        if let theLayout = layoutsManager.preset(named: name) {
            layout(theLayout)
        }
    }
    
    var isShowingEffects: Bool {
        return effectsWindowLoaded && _effectsWindow.isVisible
    }
    
    var isShowingPlaylist: Bool {
        return playlistWindowLoaded && _playlistWindow.isVisible
    }
    
    // NOTE - Boolean short-circuiting is important here. Otherwise, the chapters list window will be unnecessarily loaded.
    var isShowingChaptersList: Bool {
        return chaptersListWindowLoader.windowLoaded && _chaptersListWindow.isVisible
    }
    
    // NOTE - Boolean short-circuiting is important here. Otherwise, the chapters list window will be unnecessarily loaded.
    var isChaptersListWindowKey: Bool {
        return isShowingChaptersList && _chaptersListWindow == NSApp.keyWindow
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
        
        if effectsWindowLoaded {
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
        
        if playlistWindowLoaded {
            _playlistWindow.hide()
        }
    }
    
    func toggleChaptersList() {
        isShowingChaptersList ? hideChaptersList() : showChaptersList()
    }
    
    func showChaptersList() {
        
        let shouldCenterChaptersListWindow = !chaptersListWindowLoader.windowLoaded
        
        mainWindow.addChildWindow(_chaptersListWindow, ordered: NSWindow.OrderingMode.above)
        _chaptersListWindow.makeKeyAndOrderFront(self)
        
        // This will happen only once after each app launch - the very first time the window is shown.
        // After that, the window will be restored to its previous on-screen location
        if shouldCenterChaptersListWindow && playlistWindowLoaded {
            _chaptersListWindow.showCentered(relativeTo: _playlistWindow)
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

                    if mate.isVisible && movedWindow.checkForSnap(to: mate) {

                        snapped = true
                        break
                    }
                }
            }

            // If window doesn't need to be snapped to another window, check if it needs to be snapped to the visible frame
            if preferences.snapToScreen && !snapped {
                movedWindow.checkForSnapToVisibleFrame()
            }
        }
    }
    
    // Sorted by order of relevance
    private func getCandidateWindowsForSnap(_ movedWindow: SnappingWindow) -> [NSWindow] {
        
        if isShowingPlaylist && movedWindow === _playlistWindow {
            return isShowingEffects ? [mainWindow, _effectsWindow] : [mainWindow]
            
        } else if isShowingEffects && movedWindow === _effectsWindow {
            return isShowingPlaylist ? [mainWindow, _playlistWindow] : [mainWindow]
            
        } else if isShowingChaptersList && movedWindow === _chaptersListWindow {
            
            var candidates: [NSWindow] = [mainWindow]
            
            if isShowingEffects {candidates.append(_effectsWindow)}
            if isShowingPlaylist {candidates.append(_playlistWindow)}
            
            return candidates
        }
        
        // Main window
        return []
    }
}
