//
//  WindowLayoutsPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

fileprivate var screenVisibleFrame: NSRect {
    return NSScreen.main!.visibleFrame
}

class WindowLayoutsPersistenceTests: PersistenceTestCase {
    
    private static let systemDefinedLayouts = WindowLayoutPresets.allCases.map {$0.layout}
    
    func testPersistence_layoutConformsToPreset() {
        
        for preset in WindowLayoutPresets.allCases {
            
            // Construct a layout based on a system-defined window layout preset, to simulate
            // the user applying a system-defined layout.
            let layoutFromPreset = preset.layout(gap: 2)
            
            for _ in 1...100 {
                
                // Move the layout to a random location on-screen to simulate the user moving the
                // windows to a preferred location.
                let movedLayout = moveLayoutToRandomLocation(layout: layoutFromPreset)
                
                let state = WindowLayoutsPersistentState(layout: movedLayout, userLayouts: randomUserLayouts())
                doTestPersistence(serializedState: state)
            }
        }
    }
    
    func testPersistence_randomLayout() {
        
        for showPlaylist in [false, true] {
            
            for showEffects in [false, true] {
                
                for _ in 1...100 {
                    
                    let layout = randomLayout(name: "_system_", systemDefined: true,
                                              showPlaylist: showPlaylist, showEffects: showEffects)
                    
                    let state = WindowLayoutsPersistentState(layout: layout, userLayouts: randomUserLayouts())
                    doTestPersistence(serializedState: state)
                }
            }
        }
    }
    
    private func randomUserLayouts(count: Int? = nil) -> [UserWindowLayoutPersistentState] {
        
        let numLayouts = count ?? Int.random(in: 0...10)
        
        return numLayouts == 0 ? [] : (1...numLayouts).map {index in
            
            let layout = randomLayout(name: "Layout-\(index)", systemDefined: false)
            return UserWindowLayoutPersistentState(layout: layout)
        }
    }
    
    private func randomLayout(name: String, systemDefined: Bool,
                              showPlaylist: Bool? = nil, showEffects: Bool? = nil) -> WindowLayout {
        
        let visibleFrame = screenVisibleFrame
        
        let randomNum = Int.random(in: 1...100)
        
        // 70% probability that the playlist window is shown.
        let showPlaylist: Bool = showPlaylist ?? (randomNum > 30)
        
        // 50% probability that the effects window is shown.
        let showEffects: Bool = showEffects ?? (randomNum > 50)
        
        var effectsWindowOrigin: NSPoint? = nil
        var playlistWindowFrame: NSRect? = nil
        
        let mainWindowOrigin = visibleFrame.randomContainedRect(width: WindowLayoutPresets.mainWindowWidth,
                                                                height: WindowLayoutPresets.mainWindowHeight).origin
        
        if showEffects {
            
            let effectsWindowFrame = visibleFrame.randomContainedRect(width: WindowLayoutPresets.effectsWindowWidth,
                                                                      height: WindowLayoutPresets.effectsWindowHeight)
            
            effectsWindowOrigin = effectsWindowFrame.origin
        }
        
        if showPlaylist {
            
            let playlistWidth = CGFloat.random(in: WindowLayoutPresets.mainWindowWidth...visibleFrame.width)
            let playlistHeight = CGFloat.random(in: WindowLayoutPresets.mainWindowHeight...visibleFrame.height)
            
            playlistWindowFrame = visibleFrame.randomContainedRect(width: playlistWidth,
                                                                   height: playlistHeight)
        }
        
        return WindowLayout(name, showEffects, showPlaylist,
                            mainWindowOrigin, effectsWindowOrigin, playlistWindowFrame,
                            systemDefined)
    }
    
    private func moveLayoutToRandomLocation(layout: WindowLayout) -> WindowLayout {
        
        let visibleFrame = screenVisibleFrame
        
        let layoutBoundingBox = layout.boundingBox
        let movedBoundingBox = visibleFrame.randomContainedRect(width: layoutBoundingBox.width,
                                                                height: layoutBoundingBox.height)
        
        let distanceMovedX = movedBoundingBox.minX - layoutBoundingBox.minX
        let distanceMovedY = movedBoundingBox.minY - layoutBoundingBox.minY
        
        let movedMainWindowOrigin = layout.mainWindowOrigin.translating(distanceMovedX, distanceMovedY)
        let movedEffectsWindowOrigin = layout.effectsWindowOrigin?.translating(distanceMovedX, distanceMovedY)
        let movedPlaylistWindowFrame = layout.playlistWindowFrame?.offsetBy(dx: distanceMovedX, dy: distanceMovedY)
        
        return WindowLayout(layout.name, layout.showEffects, layout.showPlaylist, movedMainWindowOrigin, movedEffectsWindowOrigin, movedPlaylistWindowFrame, layout.systemDefined)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension WindowLayoutsPersistentState: Equatable {
    
    init(layout: WindowLayout, userLayouts: [UserWindowLayoutPersistentState]?) {
        
        self.showEffects = layout.showEffects
        self.showPlaylist = layout.showPlaylist
        self.mainWindowOrigin = NSPointPersistentState(point: layout.mainWindowOrigin)
        
        if let effectsWindowOrigin = layout.effectsWindowOrigin {
            self.effectsWindowOrigin = NSPointPersistentState(point: effectsWindowOrigin)
        } else {
            self.effectsWindowOrigin = nil
        }
        
        if let playlistWindowFrame = layout.playlistWindowFrame {
            self.playlistWindowFrame = NSRectPersistentState(rect: playlistWindowFrame)
        } else {
            self.playlistWindowFrame = nil
        }
        
        self.userLayouts = userLayouts
    }
    
    static func == (lhs: WindowLayoutsPersistentState, rhs: WindowLayoutsPersistentState) -> Bool {
        
        lhs.mainWindowOrigin == rhs.mainWindowOrigin &&
            lhs.showPlaylist == rhs.showPlaylist &&
            lhs.showEffects == rhs.showEffects &&
            lhs.effectsWindowOrigin == rhs.effectsWindowOrigin &&
            lhs.playlistWindowFrame == rhs.playlistWindowFrame &&
            lhs.userLayouts == rhs.userLayouts
    }
}

extension UserWindowLayoutPersistentState: Equatable {
    
    init(name: String?, showEffects: Bool?, showPlaylist: Bool?,
         mainWindowOrigin: NSPointPersistentState?,
         effectsWindowOrigin: NSPointPersistentState?,
         playlistWindowFrame: NSRectPersistentState?) {
        
        self.name = name
        self.showEffects = showEffects
        self.showPlaylist = showPlaylist
        self.mainWindowOrigin = mainWindowOrigin
        self.effectsWindowOrigin = effectsWindowOrigin
        self.playlistWindowFrame = playlistWindowFrame
    }
    
    static func == (lhs: UserWindowLayoutPersistentState, rhs: UserWindowLayoutPersistentState) -> Bool {
        
        lhs.name == rhs.name &&
            lhs.mainWindowOrigin == rhs.mainWindowOrigin &&
            lhs.showPlaylist == rhs.showPlaylist &&
            lhs.showEffects == rhs.showEffects &&
            lhs.effectsWindowOrigin == rhs.effectsWindowOrigin &&
            lhs.playlistWindowFrame == rhs.playlistWindowFrame
    }
}

extension NSPointPersistentState: Equatable {
    
    static func == (lhs: NSPointPersistentState, rhs: NSPointPersistentState) -> Bool {
        
        CGFloat.approxEquals(lhs.x, rhs.x, accuracy: 0.001) &&
            CGFloat.approxEquals(lhs.y, rhs.y, accuracy: 0.001)
    }
}

extension NSSizePersistentState: Equatable {
    
    static func == (lhs: NSSizePersistentState, rhs: NSSizePersistentState) -> Bool {
        
        CGFloat.approxEquals(lhs.width, rhs.width, accuracy: 0.001) &&
            CGFloat.approxEquals(lhs.height, rhs.height, accuracy: 0.001)
    }
}

extension NSRectPersistentState: Equatable {
    
    static func == (lhs: NSRectPersistentState, rhs: NSRectPersistentState) -> Bool {
        lhs.origin == rhs.origin && lhs.size == rhs.size
    }
}

extension NSRect {
    
    func randomContainedRect(width: CGFloat, height: CGFloat) -> NSRect {
        
        let randomX: CGFloat = maxX == width ? 0 : CGFloat.random(in: 0...(maxX - width))
        let randomY: CGFloat = maxY == height ? 0 : CGFloat.random(in: 0...(maxY - height))
        
        return NSMakeRect(randomX, randomY, width, height)
    }
}

extension WindowLayout {
    
    var boundingBox: NSRect {
        
        let minX = max(mainWindowOrigin.x,
                       effectsWindowOrigin?.x ?? -1000,
                       playlistWindowFrame?.minX ?? -1000)
        
        let minY = max(mainWindowOrigin.y,
                       effectsWindowOrigin?.y ?? -1000,
                       playlistWindowFrame?.minY ?? -1000)
        
        let maxX = max(mainWindowOrigin.x + WindowLayoutPresets.mainWindowWidth,
                       (effectsWindowOrigin?.x ?? -1000) + WindowLayoutPresets.effectsWindowWidth,
                       playlistWindowFrame?.maxX ?? -1000)
        
        let maxY = max(mainWindowOrigin.y + WindowLayoutPresets.mainWindowHeight,
                       (effectsWindowOrigin?.y ?? -1000) + WindowLayoutPresets.effectsWindowHeight,
                       playlistWindowFrame?.maxY ?? -1000)
        
        return NSMakeRect(minX, minY, maxX - minX, maxY - minY)
    }
}
