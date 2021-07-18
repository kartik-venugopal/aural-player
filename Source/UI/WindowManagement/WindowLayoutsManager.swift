//
//  WindowLayoutsManager.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class WindowLayoutsManager: MappedPresets<WindowLayout>, Destroyable, Restorable {
    
    private let preferences: ViewPreferences
    
    // App's main window
    private let mainWindowLoader: WindowLoader<MainWindowController> = WindowLoader()
    lazy var mainWindow: NSWindow = loadWindowFromLoader(mainWindowLoader)
    
    // Load these optional windows only if/when needed
    private var effectsWindowLoader: WindowLoader<EffectsWindowController> = WindowLoader()
    private lazy var _effectsWindow: NSWindow = loadWindowFromLoader(effectsWindowLoader)
    
    var effectsWindow: NSWindow? {effectsWindowLoader.windowLoaded ? _effectsWindow : nil}
    var effectsWindowFrame: NSRect? {effectsWindowLoaded ? _effectsWindow.frame : nil}
    var effectsWindowLoaded: Bool {effectsWindowLoader.windowLoaded}

    private var playlistWindowLoader: WindowLoader<PlaylistWindowController> = WindowLoader()
    private lazy var _playlistWindow: NSWindow = loadWindowFromLoader(playlistWindowLoader)
    
    var playlistWindow: NSWindow? {playlistWindowLoader.windowLoaded ? _playlistWindow : nil}
    var playlistWindowFrame: NSRect? {playlistWindowLoaded ? _playlistWindow.frame : nil}
    var playlistWindowLoaded: Bool {playlistWindowLoader.windowLoaded}

    private lazy var chaptersListWindowLoader: WindowLoader<ChaptersListWindowController> = WindowLoader()
    private lazy var _chaptersListWindow: NSWindow = loadWindowFromLoader(chaptersListWindowLoader)
    var chaptersListWindow: NSWindow? {chaptersListWindowLoader.windowLoaded ? _chaptersListWindow : nil}
    
    private lazy var visualizerWindowLoader: WindowLoader<VisualizerWindowController> = WindowLoader()
    private lazy var _visualizerWindow: NSWindow = visualizerWindowLoader.window
    
    var visualizerWindow: NSWindow? {visualizerWindowLoader.windowLoaded ? _visualizerWindow : nil}
    
    private lazy var tuneBrowserWindowLoader: WindowLoader<TuneBrowserWindowController> = WindowLoader()
    private lazy var _tuneBrowserWindow: NSWindow = tuneBrowserWindowLoader.window
    
    private var windowDelegates: [NSWindowDelegate] = []
    
    // Each modal component, when it is loaded, will register itself here, which will enable tracking of modal dialogs / popovers
    private var modalComponentRegistry: [ModalComponentProtocol] = []
    
    private lazy var messenger = Messenger(for: self)
    
    private let initialLayout: WindowLayout?
    
    private func loadWindowFromLoader<T>(_ loader: WindowLoader<T>) -> NSWindow where T: NSWindowController, T: Destroyable {
        
        let window = loader.window
        let windowDelegate = SnappingWindowDelegate(window: window as! SnappingWindow)
        windowDelegates.append(windowDelegate)
        
        window.delegate = windowDelegate
        return window
    }
    
    init(persistentState: WindowLayoutsPersistentState?, viewPreferences: ViewPreferences) {
        
        self.preferences = viewPreferences
        self.initialLayout = WindowLayout(systemLayoutFrom: persistentState)
        
        let systemDefinedLayouts = WindowLayoutPresets.allCases.map {$0.layout(gap: CGFloat(viewPreferences.windowGap))}
        let userDefinedLayouts: [WindowLayout] = persistentState?.userLayouts?.compactMap
        {WindowLayout(persistentState: $0)} ?? []
        
        super.init(systemDefinedPresets: systemDefinedLayouts, userDefinedPresets: userDefinedLayouts)
    }
    
    var defaultLayout: WindowLayout {
        systemDefinedPreset(named: WindowLayoutPresets.verticalFullStack.name)!
    }
    
    func recomputeSystemDefinedLayouts() {
        systemDefinedPresets.forEach {WindowLayoutPresets.recompute(layout: $0, gap: CGFloat(preferences.windowGap))}
    }
    
    func registerModalComponent(_ component: ModalComponentProtocol) {
        modalComponentRegistry.append(component)
    }
    
    var isShowingModalComponent: Bool {
        modalComponentRegistry.contains(where: {$0.isModal}) || NSApp.modalWindow != nil
    }
    
    // MARK - Core functionality ----------------------------------------------------
    
    func restore() {
        
        ([mainWindowLoader, effectsWindowLoader, playlistWindowLoader,
          chaptersListWindowLoader, visualizerWindowLoader] as? [Restorable])?.forEach {
            
            $0.restore()
        }
        
        performInitialLayout()
        
        messenger.subscribe(to: .windowManager_togglePlaylistWindow, handler: togglePlaylist)
        messenger.subscribe(to: .windowManager_toggleEffectsWindow, handler: toggleEffects)
    }
    
    func destroy() {
        
        messenger.unsubscribeFromAll()
        modalComponentRegistry.removeAll()
        
        for window in mainWindow.childWindows ?? [] {
            mainWindow.removeChildWindow(window)
        }
        
        ([mainWindowLoader, effectsWindowLoader, playlistWindowLoader,
          chaptersListWindowLoader, visualizerWindowLoader] as? [Destroyable])?.forEach {
            
            $0.destroy()
        }
        
        windowDelegates.removeAll()
    }
    
    func performInitialLayout() {
        
        if preferences.layoutOnStartup.option == .specific, let layoutName = preferences.layoutOnStartup.layoutName {
            
            layout(layoutName)
            
        } else if let initialLayout = self.initialLayout {
            
            // Remember from last app launch
            layout(initialLayout)
            
        } else {
            performDefaultLayout()
        }
        
        (mainWindow as? SnappingWindow)?.ensureOnScreen()
        mainWindow.makeKeyAndOrderFront(self)
    }
    
    // Revert to default layout if app state is corrupted
    private func performDefaultLayout() {
        layout(defaultLayout)
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
        
        layoutChanged()
    }
    
    private func layoutChanged() {
        
        messenger.publish(WindowLayoutChangedNotification(showingPlaylistWindow: isShowingPlaylist,
                                                          showingEffectsWindow: isShowingEffects))
    }
    
    var currentWindowLayout: WindowLayout {
        
        let effectsWindowOrigin = isShowingEffects ? _effectsWindow.origin : nil
        let playlistWindowFrame = isShowingPlaylist ? _playlistWindow.frame : nil
        
        return WindowLayout("_currentWindowLayout_", isShowingEffects, isShowingPlaylist, mainWindow.origin, effectsWindowOrigin, playlistWindowFrame, false)
    }
    
    func layout(_ name: String) {
        
        if let theLayout = preset(named: name) {
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
    
    var isShowingTuneBrowser: Bool {
        return tuneBrowserWindowLoader.windowLoaded && _tuneBrowserWindow.isVisible
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
        
        layoutChanged()
    }
    
    // Hides the effects window
    private func hideEffects() {
        
        if effectsWindowLoaded {
            
            _effectsWindow.hide()
            layoutChanged()
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
        
        layoutChanged()
    }
    
    // Hides the playlist window
    private func hidePlaylist() {
        
        if playlistWindowLoaded {
            
            _playlistWindow.hide()
            layoutChanged()
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
        visualizerWindowLoader.showWindow()
    }
    
    private func hideVisualizer() {
        visualizerWindowLoader.close()
    }
    
    func toggleTuneBrowser() {
        isShowingTuneBrowser ? hideTuneBrowser() : showTuneBrowser()
    }
    
    private func showTuneBrowser() {
        
        mainWindow.addChildWindow(_tuneBrowserWindow, ordered: NSWindow.OrderingMode.above)
        _tuneBrowserWindow.makeKeyAndOrderFront(self)
    }
    
    private func hideTuneBrowser() {
        
        if tuneBrowserWindowLoader.windowLoaded {
            _tuneBrowserWindow.hide()
        }
    }

    func addChildWindow(_ window: NSWindow) {
        mainWindow.addChildWindow(window, ordered: .above)
    }
    
    var persistentState: WindowLayoutsPersistentState {
        
        let userLayouts = objectGraph.windowLayoutsManager.userDefinedPresets.map {UserWindowLayoutPersistentState(layout: $0)}
        
        var effectsWindowOrigin: NSPointPersistentState? = nil
        var playlistWindowFrame: NSRectPersistentState? = nil
        
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
    }
}
