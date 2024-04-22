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

fileprivate let playQueueHeight_verticalFullStack: CGFloat = 340
fileprivate let playQueueHeight_verticalPlayerAndPlayQueue: CGFloat = 500
fileprivate let playQueueHeight_bigBottomPlayQueue: CGFloat = 500

enum WindowLayoutPresets: String, CaseIterable {
    
    case verticalStack
    case horizontalStack
    case compactCornered
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
        
        layout.mainWindowFrame = recomputedLayout.mainWindowFrame
        layout.displayedWindows = recomputedLayout.displayedWindows
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
            
        case .compactCornered:
            return "Only the Player positioned at the top-left corner"
            
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
        !self.equalsOneOf(.compactCornered, .verticalPlayerAndPlayQueue, .horizontalPlayerAndPlayQueue)
    }
    
    func layout(gap: CGFloat) -> WindowLayout {
        
        let twoGaps = 2 * gap
        
        // Compute this only once
        let visibleFrame = screenVisibleFrame
        
        var mainWindowOrigin: NSPoint = .zero
        var playQueueWindowOrigin: NSPoint? = nil
        var effectsWindowOrigin: NSPoint? = nil
        
        var playQueueHeight: CGFloat = 0
        var playQueueWidth: CGFloat = 0
        
        switch self {
        
        // Top left corner
        case .compactCornered:
            
            mainWindowOrigin = NSMakePoint(visibleFrame.minX, visibleFrame.maxY - Self.mainWindowHeight)
            
        case .verticalStack:
            
            playQueueHeight = min(playQueueHeight_verticalFullStack,
                                 visibleFrame.height - (Self.mainWindowHeight + Self.effectsWindowHeight + twoGaps))
            
            let xPadding = visibleFrame.width - Self.mainWindowWidth
            let totalStackHeight = Self.mainWindowHeight + Self.effectsWindowHeight + twoGaps + playQueueHeight
            let yPadding = visibleFrame.height - totalStackHeight
            
            mainWindowOrigin = NSMakePoint(visibleFrame.minX + (xPadding / 2),
                                           visibleFrame.maxY - (yPadding / 2) - Self.mainWindowHeight)
            
            effectsWindowOrigin = NSMakePoint(mainWindowOrigin.x, mainWindowOrigin.y - gap - Self.effectsWindowHeight)
            
            playQueueWidth = Self.mainWindowWidth
            
            playQueueWindowOrigin = NSMakePoint(mainWindowOrigin.x, effectsWindowOrigin!.y - gap - playQueueHeight)
            
        case .horizontalStack:
            
            // Sometimes, xPadding is negative, never go to the left of minX
            playQueueWidth = max(visibleFrame.width - (Self.mainWindowWidth + Self.effectsWindowWidth + twoGaps), Self.minPlayQueueWidth)
            let xPadding = visibleFrame.width - (Self.mainWindowWidth + Self.effectsWindowWidth + playQueueWidth + twoGaps)
            let yPadding = visibleFrame.height - Self.mainWindowHeight
            
            mainWindowOrigin = NSMakePoint(max(visibleFrame.minX + (xPadding / 2), visibleFrame.minX),
                                           visibleFrame.minY + (yPadding / 2))
            
            effectsWindowOrigin = NSMakePoint(mainWindowOrigin.x + Self.mainWindowWidth + gap,
                                              mainWindowOrigin.y)
            
            playQueueHeight = Self.mainWindowHeight
            
            playQueueWindowOrigin = NSMakePoint(mainWindowOrigin.x + Self.mainWindowWidth + Self.effectsWindowWidth + twoGaps,
                                               mainWindowOrigin.y)
            
        case .bigBottomPlayQueue:
            
            let xPadding = visibleFrame.width - (Self.mainWindowWidth + gap + Self.effectsWindowWidth)
            playQueueHeight = playQueueHeight_bigBottomPlayQueue
            let yPadding = visibleFrame.height - (Self.mainWindowHeight + gap + playQueueHeight)
            
            mainWindowOrigin = NSMakePoint(visibleFrame.minX + (xPadding / 2),
                                           visibleFrame.minY + (yPadding / 2) + playQueueHeight + gap)
            
            effectsWindowOrigin = NSMakePoint(mainWindowOrigin.x + Self.mainWindowWidth + gap,
                                              mainWindowOrigin.y)
            
            playQueueWidth = Self.mainWindowWidth + gap + Self.effectsWindowWidth
            playQueueWindowOrigin = NSMakePoint(mainWindowOrigin.x,
                                               mainWindowOrigin.y - gap - playQueueHeight)
            
        case .bigLeftPlayQueue:
            
            let pWidth = Self.mainWindowWidth
            let xPadding = visibleFrame.width - (Self.mainWindowWidth + gap + pWidth)
            let yPadding = visibleFrame.height - (Self.mainWindowHeight + gap + Self.effectsWindowHeight)
            
            mainWindowOrigin = NSMakePoint(visibleFrame.minX + (xPadding / 2) + pWidth + gap,
                                           visibleFrame.minY + (yPadding / 2) + Self.effectsWindowHeight + gap)
            
            effectsWindowOrigin = NSMakePoint(mainWindowOrigin.x,
                                              mainWindowOrigin.y - gap - Self.effectsWindowHeight)
            
            playQueueHeight = Self.mainWindowHeight + gap + Self.effectsWindowHeight
            playQueueWidth = Self.mainWindowWidth
            
            playQueueWindowOrigin = NSMakePoint(mainWindowOrigin.x - gap - playQueueWidth,
                                               mainWindowOrigin.y - gap - Self.effectsWindowHeight)
            
        case .bigRightPlayQueue:
            
            let xPadding = visibleFrame.width - (Self.mainWindowWidth + gap + Self.mainWindowWidth)
            let yPadding = visibleFrame.height - (Self.mainWindowHeight + gap + Self.effectsWindowHeight)
            
            mainWindowOrigin = NSMakePoint(visibleFrame.minX + (xPadding / 2),
                                           visibleFrame.minY + (yPadding / 2) + Self.effectsWindowHeight + gap)
            
            effectsWindowOrigin = NSMakePoint(mainWindowOrigin.x, mainWindowOrigin.y - gap - Self.effectsWindowHeight)
            
            playQueueHeight = Self.mainWindowHeight + gap + Self.effectsWindowHeight
            playQueueWidth = Self.mainWindowWidth
            
            playQueueWindowOrigin = NSMakePoint(mainWindowOrigin.x + Self.mainWindowWidth + gap,
                                               mainWindowOrigin.y - gap - Self.effectsWindowHeight)
            
        case .verticalPlayerAndPlayQueue:
            
            let xPadding = visibleFrame.width - Self.mainWindowWidth
            
            playQueueHeight = playQueueHeight_verticalPlayerAndPlayQueue
            let yPadding = (visibleFrame.height - Self.mainWindowHeight - playQueueHeight - gap)
            let halfYPadding = yPadding / 2
            
            mainWindowOrigin = NSMakePoint(visibleFrame.minX + (xPadding / 2),
                                           visibleFrame.maxY - halfYPadding - Self.mainWindowHeight)
            
            
            playQueueWidth = Self.mainWindowWidth
            
            playQueueWindowOrigin = NSMakePoint(mainWindowOrigin.x, visibleFrame.minY + halfYPadding)
            
        case .horizontalPlayerAndPlayQueue:
            
            playQueueHeight = Self.mainWindowHeight
            playQueueWidth = Self.mainWindowWidth
            
            let xPadding = visibleFrame.width - (Self.mainWindowWidth + gap + playQueueWidth)
            let yPadding = visibleFrame.height - Self.mainWindowHeight
            
            mainWindowOrigin = NSMakePoint(visibleFrame.minX + (xPadding / 2), visibleFrame.minY + (yPadding / 2))
            
            playQueueWindowOrigin = NSMakePoint(mainWindowOrigin.x + Self.mainWindowWidth + gap, mainWindowOrigin.y)
        }
        
        let mainWindowFrame: NSRect = NSRect(origin: mainWindowOrigin, size: NSMakeSize(Self.mainWindowWidth, Self.mainWindowHeight))
        
        var displayedWindows: [LayoutWindow] = []
        
        if let playQueueWindowOrigin = playQueueWindowOrigin {
            
            let playQueueWindowFrame: NSRect = NSMakeRect(playQueueWindowOrigin.x, playQueueWindowOrigin.y, playQueueWidth, playQueueHeight)
            let playQueueWindow: LayoutWindow = .init(id: .playQueue, frame: playQueueWindowFrame)
            
            displayedWindows.append(playQueueWindow)
        }
        
        if let effectsWindowOrigin = effectsWindowOrigin {
            
            let effectsWindowFrame: NSRect = NSRect(origin: effectsWindowOrigin, size: NSMakeSize(Self.effectsWindowWidth, Self.effectsWindowHeight))
            let effectsWindow: LayoutWindow = .init(id: .effects, frame: effectsWindowFrame)
            
            displayedWindows.append(effectsWindow)
        }
        
        return WindowLayout(name: name, systemDefined: true, mainWindowFrame: mainWindowFrame, displayedWindows: displayedWindows)
    }
}
