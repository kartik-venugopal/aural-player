//
//  WindowLayoutsManager.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class WindowLayoutsManager: UserManagedObjects<WindowLayout>, Destroyable, Restorable {
    
    private let preferences: ViewPreferences
    
    private func initializeLoader<T>(type: T.Type) -> WindowLoader<T> where T: NSWindowController, T: Destroyable {
        
        let loader = WindowLoader<T>()
        initializedLoaders.append(loader)
        return loader
    }
    
    // TODO: Don't expose the windows, expose them and their properties through functions / vars.
    
    // MARK: Main window -------------------------------------------
    
    private lazy var mainWindowLoader: WindowLoader<MainWindowController> = initializeLoader(type: MainWindowController.self)
    var mainWindow: NSWindow {mainWindowLoader.window}
    
    // MARK: Effects window -------------------------------------------
    
    private lazy var effectsWindowLoader: WindowLoader<EffectsWindowController> = initializeLoader(type: EffectsWindowController.self)
    private var _effectsWindow: NSWindow {effectsWindowLoader.window}
    
    var effectsWindow: NSWindow? {effectsWindowLoader.isWindowLoaded ? _effectsWindow : nil}
    var effectsWindowFrame: NSRect? {effectsWindowLoaded ? _effectsWindow.frame : nil}
    var effectsWindowLoaded: Bool {effectsWindowLoader.isWindowLoaded}
    
    // MARK: Playlist window -------------------------------------------
    
    private lazy var playlistWindowLoader: WindowLoader<PlaylistWindowController> = initializeLoader(type: PlaylistWindowController.self)
    private var _playlistWindow: NSWindow {playlistWindowLoader.window}
    
    var playlistWindow: NSWindow? {playlistWindowLoader.isWindowLoaded ? _playlistWindow : nil}
    var playlistWindowFrame: NSRect? {playlistWindowLoaded ? _playlistWindow.frame : nil}
    var playlistWindowLoaded: Bool {playlistWindowLoader.isWindowLoaded}
    
    // MARK: Chapters list window -------------------------------------------

    private lazy var chaptersListWindowLoader: WindowLoader<ChaptersListWindowController> = initializeLoader(type: ChaptersListWindowController.self)
    
    private var _chaptersListWindow: NSWindow {chaptersListWindowLoader.window}
    var chaptersListWindowLoaded: Bool {chaptersListWindowLoader.isWindowLoaded}
    
    // MARK: Visualizer window -------------------------------------------
    
    private lazy var visualizerWindowLoader: WindowLoader<VisualizerWindowController> = initializeLoader(type: VisualizerWindowController.self)
    
    private var _visualizerWindow: NSWindow {visualizerWindowLoader.window}
    
    private var initializedLoaders: [DestroyableAndRestorable] = []
    
    private lazy var messenger = Messenger(for: self)
    
    private var savedLayout: WindowLayout? = nil

    init(persistentState: WindowLayoutsPersistentState?, viewPreferences: ViewPreferences) {
        
        self.preferences = viewPreferences
        
        let systemDefinedLayouts = WindowLayoutPresets.allCases.map {$0.layout(gap: CGFloat(viewPreferences.windowGap))}
        let userDefinedLayouts: [WindowLayout] = persistentState?.userLayouts?.compactMap
        {WindowLayout(persistentState: $0)} ?? []
        
        super.init(systemDefinedObjects: systemDefinedLayouts, userDefinedObjects: userDefinedLayouts)
        
        if preferences.layoutOnStartup.option == .specific, let layoutName = preferences.layoutOnStartup.layoutName {
            self.savedLayout = object(named: layoutName)
            
        } else {
            self.savedLayout = WindowLayout(systemLayoutFrom: persistentState)
        }
    }
    
    var defaultLayout: WindowLayout {
        systemDefinedObject(named: WindowLayoutPresets.verticalFullStack.name)!
    }
    
    func recomputeSystemDefinedLayouts() {
        systemDefinedObjects.forEach {WindowLayoutPresets.recompute(layout: $0, gap: CGFloat(preferences.windowGap))}
    }
    
    var isShowingModalComponent: Bool {
        
        NSApp.modalComponents.contains(where: {$0.isModal}) ||
            StringInputPopoverViewController.isShowingAPopover ||
            NSApp.modalWindow != nil
    }
    
    // MARK - Core functionality ----------------------------------------------------
    
    func restore() {
        
        initializedLoaders.forEach {$0.restore()}
        performInitialLayout()
    }
    
    func destroy() {
        
        // Save the current layout for future re-use.
        savedLayout = currentWindowLayout
        
        // Hide and release all windows.
        mainWindow.childWindows?.forEach {mainWindow.removeChildWindow($0)}
        initializedLoaders.forEach {$0.destroy()}
    }
    
    private func performInitialLayout() {
        
        if let initialLayout = self.savedLayout {
            
            // Remember from last app launch
            applyLayout(initialLayout)
            
        } else {
            performDefaultLayout()
        }
        
        (mainWindow as? SnappingWindow)?.ensureOnScreen()
        mainWindow.makeKeyAndOrderFront(self)
    }
    
    // Revert to default layout if app state is corrupted
    private func performDefaultLayout() {
        applyLayout(defaultLayout)
    }
    
    func applyLayout(named name: String) {
        
        if let layout = object(named: name) {
            applyLayout(layout)
        }
    }
    
    func applyLayout(_ layout: WindowLayout) {
        
        mainWindow.setFrameOrigin(layout.mainWindowOrigin)
        
        if layout.showEffects {
            
            // TODO: Replace .zero with proper computation of a default origin.
            let origin = layout.effectsWindowOrigin ?? .zero
            
            mainWindow.addChildWindow(_effectsWindow, ordered: .below)
            _effectsWindow.setFrameOrigin(origin)
            _effectsWindow.show()
            
        } else {
            hideEffectsWindow()
        }
        
        if layout.showPlaylist {
            
            // TODO: Replace .zero with proper computation of a default frame.
            let frame = layout.playlistWindowFrame ?? .zero
            
            mainWindow.addChildWindow(_playlistWindow, ordered: .below)
            _playlistWindow.setFrame(frame, display: true)
            _playlistWindow.show()
            
        } else {
            hidePlaylistWindow()
        }
        
        layoutChanged()
    }
    
    private func layoutChanged() {
        messenger.publish(.windowManager_layoutChanged)
    }
    
    var currentWindowLayout: WindowLayout {
        
        WindowLayout("_system_", isShowingEffects, isShowingPlaylist, mainWindow.origin,
                     effectsWindow?.origin, playlistWindow?.frame, true)
    }
    
    var isShowingEffects: Bool {
        return effectsWindowLoaded && _effectsWindow.isVisible
    }
    
    var isShowingPlaylist: Bool {
        return playlistWindowLoaded && _playlistWindow.isVisible
    }
    
    // NOTE - Boolean short-circuiting is important here. Otherwise, the chapters list window will be unnecessarily loaded.
    var isShowingChaptersList: Bool {
        return chaptersListWindowLoader.isWindowLoaded && _chaptersListWindow.isVisible
    }
    
    // NOTE - Boolean short-circuiting is important here. Otherwise, the chapters list window will be unnecessarily loaded.
    var isChaptersListWindowKey: Bool {
        return isShowingChaptersList && _chaptersListWindow == NSApp.keyWindow
    }
    
    var isShowingVisualizer: Bool {
        return visualizerWindowLoader.isWindowLoaded && _visualizerWindow.isVisible
    }
    
    var mainWindowFrame: NSRect {
        return mainWindow.frame
    }
    
    // MARK: View toggling code ----------------------------------------------------
    
    // Shows/hides the effects window
    func toggleEffectsWindow() {
        isShowingEffects ? hideEffectsWindow() : showEffectsWindow()
    }
    
    // Shows the effects window
    func showEffectsWindow() {
        
        mainWindow.addChildWindow(_effectsWindow, ordered: .above)
        _effectsWindow.show()
        _effectsWindow.orderFront(self)
        
        layoutChanged()
    }
    
    // Hides the effects window
    func hideEffectsWindow() {
        
        if effectsWindowLoaded {
            
            _effectsWindow.hide()
            layoutChanged()
        }
    }
    
    // Shows/hides the playlist window
    func togglePlaylistWindow() {
        isShowingPlaylist ? hidePlaylistWindow() : showPlaylistWindow()
    }
    
    // Shows the playlist window
    func showPlaylistWindow() {
        
        mainWindow.addChildWindow(_playlistWindow, ordered: .above)
        _playlistWindow.show()
        _playlistWindow.orderFront(self)
        
        layoutChanged()
    }
    
    // Hides the playlist window
    func hidePlaylistWindow() {
        
        if playlistWindowLoaded {
            
            _playlistWindow.hide()
            layoutChanged()
        }
    }
    
    func toggleChaptersListWindow() {
        isShowingChaptersList ? hideChaptersListWindow() : showChaptersListWindow()
    }
    
    func showChaptersListWindow() {
        
        let shouldCenterChaptersListWindow = !chaptersListWindowLoader.isWindowLoaded
        
        mainWindow.addChildWindow(_chaptersListWindow, ordered: .above)
        _chaptersListWindow.makeKeyAndOrderFront(self)
        
        // This will happen only once after each app launch - the very first time the window is shown.
        // After that, the window will be restored to its previous on-screen location
        if shouldCenterChaptersListWindow && playlistWindowLoaded {
            _chaptersListWindow.showCentered(relativeTo: _playlistWindow)
        }
    }
    
    func hideChaptersListWindow() {
        
        if chaptersListWindowLoaded {
            _chaptersListWindow.hide()
        }
    }
    
    func toggleVisualizerWindow() {
        isShowingVisualizer ? hideVisualizerWindow() : showVisualizerWindow()
    }
    
    private func showVisualizerWindow() {
        
        mainWindow.addChildWindow(_visualizerWindow, ordered: .above)
        visualizerWindowLoader.showWindow()
    }
    
    private func hideVisualizerWindow() {
        visualizerWindowLoader.close()
    }
    
    // MARK: Miscellaneous functions ------------------------------------

    func addChildWindow(_ window: NSWindow) {
        mainWindow.addChildWindow(window, ordered: .above)
    }
    
    var persistentState: WindowLayoutsPersistentState {
        
        var effectsWindowOrigin: NSPointPersistentState? = nil
        var playlistWindowFrame: NSRectPersistentState? = nil
        
        let userLayouts = userDefinedObjects.map {UserWindowLayoutPersistentState(layout: $0)}
        
        let currentAppMode = objectGraph.appModeManager.currentMode
        
        if currentAppMode == .windowed {
            
            if let origin = self.effectsWindow?.origin {
                effectsWindowOrigin = NSPointPersistentState(point: origin)
            }
            
            if let frame = self.playlistWindowFrame {
                playlistWindowFrame = NSRectPersistentState(rect: frame)
            }
            
            return WindowLayoutsPersistentState(showEffects: isShowingEffects,
                                                showPlaylist: isShowingPlaylist,
                                                mainWindowOrigin: NSPointPersistentState(point: mainWindow.origin),
                                                effectsWindowOrigin: effectsWindowOrigin,
                                                playlistWindowFrame: playlistWindowFrame,
                                                userLayouts: userLayouts)
        } else {
            
            if let origin = savedLayout?.effectsWindowOrigin ?? defaultLayout.effectsWindowOrigin {
                effectsWindowOrigin = NSPointPersistentState(point: origin)
            }
            
            if let frame = savedLayout?.playlistWindowFrame ?? defaultLayout.playlistWindowFrame {
                playlistWindowFrame = NSRectPersistentState(rect: frame)
            }
            
            return WindowLayoutsPersistentState(showEffects: savedLayout?.showEffects ?? defaultLayout.showEffects,
                                                showPlaylist: savedLayout?.showPlaylist ?? defaultLayout.showPlaylist,
                                                mainWindowOrigin: NSPointPersistentState(point: savedLayout?.mainWindowOrigin ?? defaultLayout.mainWindowOrigin),
                                                effectsWindowOrigin: effectsWindowOrigin,
                                                playlistWindowFrame: playlistWindowFrame,
                                                userLayouts: userLayouts)
        }
    }
}
