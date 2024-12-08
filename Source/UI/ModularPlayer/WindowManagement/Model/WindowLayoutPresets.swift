//
//  WindowLayoutPresets.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

fileprivate var screenVisibleFrame: NSRect {
    NSScreen.main!.visibleFrame
}

fileprivate let playQueueHeight_verticalFullStack: CGFloat = 225
fileprivate let playQueueHeight_verticalPlayerAndPlayQueue: CGFloat = 500
fileprivate let playQueueHeight_bigBottomPlayQueue: CGFloat = 500

enum WindowLayoutPresets: String, CaseIterable {

    case minimal
    case verticalStack
    case horizontalStack
    case bigBottomPlayQueue
    case bigLeftPlayQueue
    case bigRightPlayQueue
    case verticalPlayerAndPlayQueue
    case horizontalPlayerAndPlayQueue
    
    static let defaultLayout: WindowLayoutPresets = .verticalStack
    
    static let minPlayQueueWidth: CGFloat = 480
    
    // Main window size (never changes)
    static let mainWindowWidth: CGFloat = 480
    static let mainWindowHeight: CGFloat = 200
    static let mainWindowSize: NSSize = NSMakeSize(mainWindowWidth, mainWindowHeight)
    
    // Effects window size (never changes)
    static let effectsWindowWidth: CGFloat = 480
    static let effectsWindowHeight: CGFloat = 200
    
    // Converts a user-friendly display name to an instance of PitchShiftPresets
    static func fromDisplayName(_ displayName: String) -> WindowLayoutPresets? {
        WindowLayoutPresets(rawValue: displayName.camelCased())
    }
    
    // TODO: Should also check the screen and recompute when the screen changes
    // Recomputes the layout (useful when the window gap preference changes)
    static func recompute(layout: WindowLayout, gap: CGFloat) {
        
        guard let preset = WindowLayoutPresets.fromDisplayName(layout.name) else {return}
        let recomputedLayout = preset.layout(gap: gap)
        
        layout.mainWindow = recomputedLayout.mainWindow
        layout.auxiliaryWindows = recomputedLayout.auxiliaryWindows
    }
    
    var name: String {
        rawValue.splitAsCamelCaseWord(capitalizeEachWord: false)
    }
    
    var description: String {
        
        switch self {
            
        case .verticalStack:
            return "A vertical arrangement of all 3 core components:\nPlayer, Effects, and Play Queue"
            
        case .horizontalStack:
            return "A horizontal arrangement of all 3 core components:\nPlayer, Effects, and Play Queue"
            
        case .minimal:
            return "Only the Player, centered on the screen"
            
        case .bigBottomPlayQueue:
            return "The Play Queue positioned below a horizontal arrangement of the Player and Effects"
            
        case .bigRightPlayQueue:
            return "The Play Queue positioned to the right of a vertical arrangement of the Player and Effects"
            
        case .bigLeftPlayQueue:
            return "The Play Queue positioned to the left of a vertical arrangement of the Player and Effects"
            
        case .verticalPlayerAndPlayQueue:
            return "A vertical arrangement of the Player and Play Queue"
            
        case .horizontalPlayerAndPlayQueue:
            return "A horizontal arrangement of the Player and Play Queue"
        }
    }
    
    var showEffects: Bool {
        !self.equalsOneOf(.minimal, .verticalPlayerAndPlayQueue, .horizontalPlayerAndPlayQueue)
    }
    
    func layout(gap: CGFloat) -> WindowLayout {
        
//        let twoGaps = 2 * gap
        
        // Compute this only once
        let visibleFrame = screenVisibleFrame
        
//        var mainWindowOrigin: NSPoint = .zero
//        var playQueueWindowOrigin: NSPoint? = nil
//        var effectsWindowOrigin: NSPoint? = nil
//        
//        var playQueueHeight: CGFloat = 0
//        var playQueueWidth: CGFloat = 0
        
        switch self {
        
        // Top left corner
        case .minimal:
            
            return computeMinimal(visibleFrame: visibleFrame, gap: gap)
            
        case .verticalStack:
            
           return computeVerticalStack(visibleFrame: visibleFrame, gap: gap)
            
        case .horizontalStack:
            
            return computeHorizontalStack(visibleFrame: visibleFrame, gap: gap)
            
        case .bigBottomPlayQueue:
            
            return computeBigBottomPlayQueue(visibleFrame: visibleFrame, gap: gap)
            
        case .bigLeftPlayQueue:
            
            return computeBigLeftPlayQueue(visibleFrame: visibleFrame, gap: gap)
            
        case .bigRightPlayQueue:
            
            return computeBigRightPlayQueue(visibleFrame: visibleFrame, gap: gap)
            
        case .verticalPlayerAndPlayQueue:
            
            return computeVerticalPlayerAndPlayQueue(visibleFrame: visibleFrame, gap: gap)
            
        case .horizontalPlayerAndPlayQueue:
            
            return computeHorizontalPlayerAndPlayQueue(visibleFrame: visibleFrame, gap: gap)
        }
//        
//        let mainWindowFrame: NSRect = NSRect(origin: mainWindowOrigin, size: NSMakeSize(Self.mainWindowWidth, Self.mainWindowHeight))
//        
//        var displayedWindows: [LayoutWindow] = []
//        
//        if let playQueueWindowOrigin = playQueueWindowOrigin {
//            
//            let playQueueWindowFrame: NSRect = NSMakeRect(playQueueWindowOrigin.x, playQueueWindowOrigin.y, playQueueWidth, playQueueHeight)
//            let playQueueWindow: LayoutWindow = .init(id: .playQueue, screen: .main!, screenOffset: .zero, size: .zero)
//            
//            displayedWindows.append(playQueueWindow)
//        }
//        
//        if let effectsWindowOrigin = effectsWindowOrigin {
//            
//            let effectsWindowFrame: NSRect = NSRect(origin: effectsWindowOrigin, size: NSMakeSize(Self.effectsWindowWidth, Self.effectsWindowHeight))
//            let effectsWindow: LayoutWindow = .init(id: .effects, screen: .main!, screenOffset: .zero, size: .zero)
//            
//            displayedWindows.append(effectsWindow)
//        }
//        
//        return self.computeVerticalStack(visibleFrame: visibleFrame, gap: gap)
//        return WindowLayout(name: name, systemDefined: true, mainWindowFrame: mainWindowFrame, displayedWindows: displayedWindows)
    }
}
