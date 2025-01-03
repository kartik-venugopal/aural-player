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

fileprivate var screensBoundingBox: NSRect {
    NSRect.boundingBox(of: NSScreen.screens.map {$0.frame})
}

class WindowLayoutsManager: UserManagedObjects<WindowLayout>, Destroyable, Restorable {
    
    private var windowLoaders: [WindowLoader] = []
    
    private func loader(withID id: WindowID) -> WindowLoader {
        windowLoaders.first(where: {$0.windowID == id})!
    }
    
    private var savedLayout: WindowLayout? = nil
    
    var mainWindow: NSWindow {loader(withID: .main).window}
    
    private var windowGap: CGFloat {
        CGFloat(preferences.viewPreferences.windowGap.value)
    }

    init(persistentState: WindowLayoutsPersistentState?, viewPreferences: ViewPreferences) {
        
        let userDefinedLayouts: [WindowLayout] = persistentState?.userLayouts?.compactMap
        {WindowLayout(persistentState: $0)} ?? []
        
        let mainWindowLoader = WindowLoader(windowID: .main, windowControllerType: ModularPlayerWindowController.self)
        windowLoaders.append(mainWindowLoader)
        
        for windowID in WindowID.allCases {
            
            switch windowID {
                
            case .playQueue:
                
                windowLoaders.append(WindowLoader(windowID: .playQueue, windowControllerType: PlayQueueWindowController.self))

            case .lyrics:

                    windowLoaders.append(WindowLoader(windowID: .lyrics, windowControllerType: LyricsWindowController.self))

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
        
        super.init(systemDefinedObjects: [], userDefinedObjects: userDefinedLayouts)
        self.savedLayout = WindowLayout(autoSavedLayoutFrom: persistentState)
    }
    
    var defaultScreen: NSScreen {
        .main ?? .screens[0]
    }
    
    var defaultLayout: WindowLayout {
        getSystemLayout(forPreset: .defaultLayout)
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
            applyLayout(getSystemLayout(forPreset: appSetup.windowLayoutPreset))
            
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
    
    private func getSystemLayout(forPreset preset: WindowLayoutPresets) -> WindowLayout {
        
        if loader(withID: .main).isWindowLoaded {
            
            return preset.layout(on: self.mainWindow.screen ?? defaultScreen,
                                 withGap: windowGap)
        } else {
            
            return preset.layout(on: defaultScreen,
                                 withGap: windowGap)
        }
    }
    
    func applyLayout(named name: String) {
        
        if let systemLayout = WindowLayoutPresets.allCases.first(where: {$0.name == name}) {
            applyLayout(getSystemLayout(forPreset: systemLayout))
            
        } else if let userLayout = object(named: name) {
            applyLayout(userLayout)
        }
    }
    
    func applyLayout(_ layout: WindowLayout) {
        layout.type == .computed ? applyValidLayout(layout) : applyUserDefinedLayout(layout)
    }
    
    func placeWindow(window: LayoutWindow, at origin: NSPoint) {
        
        let actualWindow = getWindow(forId: window.id)
        
        if window.id != .main, windowMagnetismEnabled {
            mainWindow.addChildWindow(actualWindow, ordered: .below)
        }
        
        let newFrame = NSRect(origin: origin, size: window.size)
        actualWindow.setFrame(newFrame, display: true)
        
        loader(withID: window.id).showWindow()
    }
    
    func applyValidLayout(_ layout: WindowLayout) {
        
        auxiliaryWindowsForModules.forEach {
            $0.hide()
        }
        
        for window in [layout.mainWindow] + layout.auxiliaryWindows {
            
            var origin: NSPoint = .zero

            if let screen = window.screen, let offset = window.screenOffset {
                origin = screen.visibleFrame.origin.translating(offset.width, offset.height)
            }
            
            placeWindow(window: window, at: origin)
        }
        
        mainWindow.makeKeyAndOrderFront(self)
        appDelegate.playQueueMenuRootItem.enableIf(isShowingPlayQueue)
    }
    
    func applyUserDefinedLayout(_ layout: WindowLayout) {
        
        let allScreensExist = layout.screens.count == layout.numberOfWindows
        
        if allScreensExist {
            
            applyValidLayout(layout)
            return
        }
        
        auxiliaryWindowsForModules.forEach {
            $0.hide()
        }
        
        let screenFrames = layout.screenFrames
        let allWindowsHaveScreenFrames = screenFrames.count == layout.numberOfWindows
        let allOnSameScreen = Set(screenFrames).count == 1
        
        // Use bounding box and center on default screen
        if allWindowsHaveScreenFrames && allOnSameScreen, let layoutBoundingBox = layout.layoutBoundingBox {
            
            let targetScreen = NSScreen.main ?? NSScreen.screens[0]
            
            let boundingBox = layoutBoundingBox.boundingBox
            let targetScreenX = (targetScreen.frame.width - boundingBox.width) / 2
            let targetScreenY = (targetScreen.frame.height - boundingBox.height) / 2
            let targetBoxOrigin = NSMakePoint(targetScreenX, targetScreenY)
            
            for window in [layout.mainWindow] + layout.auxiliaryWindows {
                
                if let offset = layoutBoundingBox.windowOffsets[window.id] {
                    placeWindow(window: window, at: targetBoxOrigin.translating(offset.width, offset.height))
                }
            }
            
        } else {
            
            // Apply default window layout
            applyValidLayout(getSystemLayout(forPreset: .defaultLayout))
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
                screenOffset = child.frame.origin.distanceFrom(screen.visibleFrame.origin)
            }
            
            windows.append(LayoutWindow(id: windowID, screen: child.screen,
                                        screenFrame: child.screen?.frame,
                                        screenOffset: screenOffset, 
                                        offsetFromMainWindow: child.frame.origin.distanceFrom(mainWindow.frame.origin),
                                        size: child.frame.size))
        }
        
        let mainWindow = self.mainWindow
        
        var screenOffset: NSSize? = nil
        
        if let screen = mainWindow.screen {
            screenOffset = mainWindow.frame.origin.distanceFrom(screen.visibleFrame.origin)
        }
        
        return WindowLayout(name: "_autoSaved_", type: .autoSaved, 
                            mainWindow: LayoutWindow(id: .main, screen: mainWindow.screen,
                                                     screenFrame: mainWindow.screen?.frame,
                                                     screenOffset: screenOffset,
                                                     offsetFromMainWindow: .zero,
                                                     size: mainWindow.size),
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
