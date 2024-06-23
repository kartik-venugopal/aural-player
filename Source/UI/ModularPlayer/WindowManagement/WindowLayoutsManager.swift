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
    
    func recomputeSystemDefinedLayouts() {
        systemDefinedObjects.forEach {WindowLayoutPresets.recompute(layout: $0, gap: windowGap)}
    }
    
    var isShowingModalComponent: Bool {
        
        NSApp.modalComponents.contains(where: {$0.isModal}) ||
            StringInputPopoverViewController.isShowingAPopover ||
            NSApp.modalWindow != nil
    }
    
    // MARK - Core functionality ----------------------------------------------------
    
    func restore() {
        
        let layout = savedLayout ?? defaultLayout
        
        // NOTE - No need to include main window loader here as that will be lazily loaded
        // through the 'mainWindow' reference in performInitialLayout().
        let loaders = (([WindowID.main] + layout.displayedWindows.map {$0.id}).map {loader(withID: $0)})
        
        loaders.forEach {$0.restore()}
        performInitialLayout()
    }
    
    func destroy() {
        
        // Save the current layout for future re-use.
        savedLayout = currentWindowLayout
        
        // Hide and release all windows.
        mainWindow.childWindows?.forEach {mainWindow.removeChildWindow($0)}
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
        
        mainWindow.setFrameOrigin(layout.mainWindowFrame.origin)
        
        mainWindow.childWindows?.forEach {
            $0.hide()
        }
        
        for window in layout.displayedWindows {
            
            let actualWindow = getWindow(forId: window.id)
            
            mainWindow.addChildWindow(actualWindow, ordered: .below)
            actualWindow.setFrame(window.frame, display: true)
            loader(withID: window.id).showWindow()
        }
        
        mainWindow.makeKeyAndOrderFront(self)
        appDelegate.playQueueMenuRootItem.enableIf(isShowingPlayQueue)
    }
    
    var currentWindowLayout: WindowLayout {
        
        var windows: [LayoutWindow] = []
        
        for child in mainWindow.childWindows ?? [] {
            
            if let windowID = child.windowID {
                windows.append(LayoutWindow(id: windowID, frame: child.frame))
            }
        }
        
        return WindowLayout(name: "_system_", systemDefined: true, mainWindowFrame: self.mainWindowFrame, displayedWindows: windows)
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
            
            mainWindow.addChildWindow(window, ordered: .below)
            loader(withID: id).showWindow()
            window.orderFront(self)
        }
    }
    
    func showWindow(withId id: WindowID) {
        
        let childWindow = getWindow(forId: id)
        mainWindow.addChildWindow(childWindow, ordered: .below)
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
        mainWindow.addChildWindow(window, ordered: .above)
    }
    
    var persistentState: WindowLayoutsPersistentState {
        
        let userLayoutsState = userDefinedObjects.map {WindowLayoutPersistentState(layout: $0)}
        
        let systemLayout = appModeManager.currentMode == .modular ? currentWindowLayout : (savedLayout ?? defaultLayout)
        let systemLayoutState = WindowLayoutPersistentState(layout: systemLayout)
        
        return WindowLayoutsPersistentState(systemLayout: systemLayoutState, userLayouts: userLayoutsState)
    }
}
