//
//  WindowLayoutsManager.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

fileprivate var boundingBox: NSRect {
    
    let frames: [NSRect] = NSScreen.screens.map {$0.frame}
    
    let minX = frames.map {$0.minX}.min() ?? 0
    let maxX = frames.map {$0.maxX}.max() ?? 0
    
    let minY = frames.map {$0.minY}.min() ?? 0
    let maxY = frames.map {$0.maxY}.max() ?? 0
    
    return NSMakeRect(minX, minY, maxX, maxY)
}

class WindowLayoutsManager: UserManagedObjects<WindowLayout>, Destroyable, Restorable {
    
    private var windowLoaders: [WindowLoader] = []
    
    private func loader(withID id: WindowID) -> WindowLoader {
        windowLoaders.first(where: {$0.windowID == id})!
    }
    
    private lazy var messenger = Messenger(for: self)
    
    private var savedLayout: WindowLayout? = nil
    
    var mainWindow: NSWindow {loader(withID: .main).window}
    
    private var windowGap: CGFloat {
        CGFloat(preferences.viewPreferences.windowGap.value)
    }

    init(persistentState: WindowLayoutsPersistentState?, viewPreferences: ViewPreferences) {
        
        let systemDefinedLayouts = WindowLayoutPresets.allCases.map {$0.layout(gap: CGFloat(preferences.viewPreferences.windowGap.value))}
        let userDefinedLayouts: [WindowLayout] = persistentState?.userLayouts?.compactMap
        {WindowLayout(persistentState: $0)} ?? []
        
        let mainWindowLoader = WindowLoader(windowID: .main, windowControllerType: ModularPlayerWindowController.self)
        windowLoaders.append(mainWindowLoader)
        
        for windowID in WindowID.allCases {
            
            switch windowID {
                
            case .playQueue:
                
                windowLoaders.append(WindowLoader(windowID: .playQueue, windowControllerType: PlayQueueWindowController.self))
                
            case .effects:
                
                windowLoaders.append(WindowLoader(windowID: .effects, windowControllerType: EffectsWindowController.self))
                
//            case .library:
//                
//                windowLoaders.append(WindowLoader(windowID: .library, windowControllerType: LibraryWindowController.self))
                
//            case .playlists:
//
//                windowLoaders.append(WindowLoader(windowID: .playlists, windowControllerType: PlaylistsWindowController.self))
                
            case .trackInfo:
                
                windowLoaders.append(WindowLoader(windowID: .trackInfo, windowControllerType: TrackInfoWindowController.self))
                
            case .chaptersList:
                
                windowLoaders.append(WindowLoader(windowID: .chaptersList, windowControllerType: ChaptersListWindowController.self))
                
            case .visualizer:
                
                windowLoaders.append(WindowLoader(windowID: .visualizer, windowControllerType: VisualizerWindowController.self))
                
            case .waveform:
                
                windowLoaders.append(WindowLoader(windowID: .waveform, windowControllerType: WaveformWindowController.self))
                
                
            default:
                
                continue
            }
        }
        
        super.init(systemDefinedObjects: systemDefinedLayouts, userDefinedObjects: userDefinedLayouts)
        self.savedLayout = WindowLayout(systemLayoutFrom: persistentState)
    }
    
    var defaultLayout: WindowLayout {
        systemDefinedObject(named: WindowLayoutPresets.defaultLayout.name)!
    }
    
    var auxiliaryWindows: [NSWindow] {
        NSApp.windows.filter {$0.isVisible && $0.windowID != .main}
    }
    
    var auxiliaryWindowsForModules: [NSWindow] {
        auxiliaryWindows.filter {$0.windowID != nil}
    }
    
    var windowMagnetismEnabled: Bool {
        preferences.viewPreferences.windowMagnetism.value
    }
    
    func recomputeSystemDefinedLayouts() {
        systemDefinedObjects.forEach {WindowLayoutPresets.recompute(layout: $0, gap: windowGap)}
    }
    
    // MARK - Core functionality ----------------------------------------------------
    
    func restore() {
        
        let layout = savedLayout ?? defaultLayout
        
        // NOTE - No need to include main window loader here as that will be lazily loaded
        // through the 'mainWindow' reference in performInitialLayout().
        let loaders = (([WindowID.main] + layout.auxiliaryWindows.map {$0.id}).map {loader(withID: $0)})
        
        loaders.forEach {$0.restore()}
        performInitialLayout()
    }
    
    func destroy() {
        
        // Save the current layout for future re-use.
        savedLayout = currentWindowLayout
        
        // Hide and release all windows.
        mainWindow.childWindows?.forEach {
            
            mainWindow.removeChildWindow($0)
            $0.close()
        }
        
        windowLoaders.forEach {$0.destroy()}
    }
    
    private func performInitialLayout() {
        
        // Remember from last app launch, reverting to default layout if app state is corrupted
        if appSetup.setupCompleted {
            applyLayout(appSetup.windowLayoutPreset.layout(gap: windowGap))
            
        } else {
            applyLayout(savedLayout ?? defaultLayout)
        }
        
        (mainWindow as? SnappingWindow)?.ensureOnScreen()
        mainWindow.makeKeyAndOrderFront(self)
    }
    
    private func getWindow(forId id: WindowID) -> NSWindow {
        
        let loader = (windowLoaders.first(where: {$0.windowID == id}))!
        loader.restore()
        return loader.window
    }
    
    func applyLayout(named name: String) {
        
        if let layout = object(named: name) {
            applyLayout(layout)
        }
    }
    
    func applyLayout(_ layout: WindowLayout) {
        
        func placeWindow(window: LayoutWindow) {
            
            let actualWindow = getWindow(forId: window.id)
            
            if window.id != .main, windowMagnetismEnabled {
                mainWindow.addChildWindow(actualWindow, ordered: .below)
            }

            if let screen = window.screen, let offset = window.screenOffset {
                
                let origin = screen.frame.origin.translating(offset.width, offset.height)
                let newFrame = NSRect(origin: origin, size: window.size)
                
                actualWindow.setFrame(newFrame, display: true)
                
            } else {
                
            }
            
            loader(withID: window.id).showWindow()
        }
        
        auxiliaryWindowsForModules.forEach {
            $0.hide()
        }
        
        for window in [layout.mainWindow] + layout.auxiliaryWindows {
            placeWindow(window: window)
        }
        
        mainWindow.makeKeyAndOrderFront(self)
        appDelegate.playQueueMenuRootItem.enableIf(isShowingPlayQueue)
    }
    
    var currentWindowLayout: WindowLayout {
        
        var windows: [LayoutWindow] = []
        
        for child in auxiliaryWindowsForModules {
            
            guard let windowID = child.windowID else {continue}
            
            var screenOffset: NSSize? = nil
            
            if let screen = child.screen {
                screenOffset = child.frame.origin.distanceFrom(screen.frame.origin)
            }
            
            windows.append(LayoutWindow(id: windowID, screen: child.screen,
                                        screenFrame: child.screen?.frame,
                                        screenOffset: screenOffset, size: child.frame.size))
        }
        
        let mainWindow = self.mainWindow
        
        var screenOffset: NSSize? = nil
        
        if let screen = mainWindow.screen {
            screenOffset = mainWindow.frame.origin.distanceFrom(screen.frame.origin)
        }
        
        return WindowLayout(name: "_system_", systemDefined: true, 
                            mainWindow: LayoutWindow(id: .main, screen: mainWindow.screen,
                                                     screenFrame: mainWindow.screen?.frame,
                                                     screenOffset: screenOffset, size: mainWindow.size),
                            auxiliaryWindows: windows)
    }
    
//    var isShowingEffects: Bool {
//        return effectsWindowLoaded && _effectsWindow.isVisible
//    }
//
//    // NOTE - Boolean short-circuiting is important here. Otherwise, the chapters list window will be unnecessarily loaded.
//    var isShowingChaptersList: Bool {
//        return chaptersListWindowLoader.isWindowLoaded && _chaptersListWindow.isVisible
//    }
//
//    // NOTE - Boolean short-circuiting is important here. Otherwise, the chapters list window will be unnecessarily loaded.
//    var isChaptersListWindowKey: Bool {
//        return isShowingChaptersList && _chaptersListWindow == NSApp.keyWindow
//    }
//
//    var isShowingVisualizer: Bool {
//        return visualizerWindowLoader.isWindowLoaded && _visualizerWindow.isVisible
//    }
    
    var mainWindowFrame: NSRect {
        mainWindow.frame
    }
    
    // MARK: View toggling code ----------------------------------------------------
    
    func toggleWindow(withId id: WindowID) {
        
        let window = getWindow(forId: id)
        
        if window.isVisible {
            window.hide()
            
        } else {
            
            if windowMagnetismEnabled {
                mainWindow.addChildWindow(window, ordered: .below)
            }
            
            loader(withID: id).showWindow()
            window.orderFront(self)
        }
    }
    
    func showWindow(withId id: WindowID) {
        
        let childWindow = getWindow(forId: id)
        
        if windowMagnetismEnabled {
            mainWindow.addChildWindow(childWindow, ordered: .below)
        }
        
        childWindow.show()
    }
    
    func hideWindow(withId id: WindowID) {
        
        if isShowingWindow(withId: id) {
            getWindow(forId: id).hide()
        }
    }
    
    func isShowingWindow(withId id: WindowID) -> Bool {
        loader(withID: id).isWindowVisible
    }
    
    func isWindowLoaded(withId id: WindowID) -> Bool {
        loader(withID: id).isWindowLoaded
    }
    
    func showChaptersListWindow() {
        
//        let shouldCenterChaptersListWindow = !chaptersListWindowLoader.isWindowLoaded

//        mainWindow.addChildWindow(_chaptersListWindow, ordered: .above)
//        _chaptersListWindow.makeKeyAndOrderFront(self)
//
//        // This will happen only once after each app launch - the very first time the window is shown.
//        // After that, the window will be restored to its previous on-screen location
//        if shouldCenterChaptersListWindow && playlistWindowLoaded {
//            _chaptersListWindow.showCentered(relativeTo: _playlistWindow)
////        }
    }
    
    var isShowingPlayQueue: Bool {
        isShowingWindow(withId: .playQueue)
    }
    
    var isShowingEffects: Bool {
        isShowingWindow(withId: .effects)
    }
    
//    var isShowingLibrary: Bool {
//        isShowingWindow(withId: .library)
//    }
    
    // MARK: Miscellaneous functions ------------------------------------

    func addChildWindow(_ window: NSWindow) {
        
        if windowMagnetismEnabled {
            mainWindow.addChildWindow(window, ordered: .below)
        }
    }
    
    func applyMagnetism() {
        
        for window in auxiliaryWindows {
            mainWindow.addChildWindow(window, ordered: .below)
        }
    }
    
    func removeMagnetism() {
        
        mainWindow.childWindows?.forEach {
            
            mainWindow.removeChildWindow($0)
            $0.show()
        }
    }
    
    var persistentState: WindowLayoutsPersistentState {
        
        let userLayoutsState = userDefinedObjects.map {WindowLayoutPersistentState(layout: $0)}
        
        let systemLayout = appModeManager.currentMode == .modular ? currentWindowLayout : (savedLayout ?? defaultLayout)
        let systemLayoutState = WindowLayoutPersistentState(layout: systemLayout)
        
        return WindowLayoutsPersistentState(systemLayout: systemLayoutState, userLayouts: userLayoutsState)
    }
}
