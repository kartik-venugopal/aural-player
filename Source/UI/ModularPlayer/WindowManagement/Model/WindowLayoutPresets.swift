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
    
    var name: String {
        rawValue.splitAsCamelCaseWord(capitalizeEachWord: false)
    }
    
    var description: String {
        
        switch self {
            
        case .minimal:
            return "Only the Player, centered on the screen"
            
        case .verticalStack:
            return "A vertical arrangement of all 3 core components:\nPlayer, Effects, and Play Queue"
            
        case .horizontalStack:
            return "A horizontal arrangement of all 3 core components:\nPlayer, Effects, and Play Queue"
            
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
    
    func layout(on screen: NSScreen, withGap gap: CGFloat) -> WindowLayout {
        
        let visibleFrame = screen.visibleFrame
        let twoGaps = 2 * gap
        
        var mainWindowOffset: NSSize = .zero
        var playQueueWindowOffset: NSSize = .zero
        var effectsWindowOffset: NSSize = .zero
        
        var playQueueWidth: CGFloat = 0
        var playQueueHeight: CGFloat = 0
        
        var xPadding: CGFloat = 0, yPadding: CGFloat = 0
        
        switch self {
            
        case .minimal:
            
            xPadding = visibleFrame.width - Self.mainWindowWidth
            yPadding = visibleFrame.height - Self.mainWindowHeight
            
            mainWindowOffset = NSMakeSize(xPadding / 2,
                                          visibleFrame.height - (yPadding / 2) - Self.mainWindowHeight)
            
        case .verticalStack:
            
            let screenWidth = visibleFrame.width
            let screenHeight = visibleFrame.height
            
            playQueueHeight = min(playQueueHeight_verticalFullStack,
                                  screenHeight - (Self.mainWindowHeight + Self.effectsWindowHeight + twoGaps))
            
            xPadding = screenWidth - Self.mainWindowWidth
            let totalStackHeight = Self.mainWindowHeight + Self.effectsWindowHeight + twoGaps + playQueueHeight
            yPadding = screenHeight - totalStackHeight
            
            mainWindowOffset = NSMakeSize(xPadding / 2,
                                          screenHeight - (yPadding / 2) - Self.mainWindowHeight)
            
            effectsWindowOffset = NSMakeSize(mainWindowOffset.width, mainWindowOffset.height - gap - Self.effectsWindowHeight)
            
            playQueueWidth = Self.mainWindowWidth
            playQueueWindowOffset = NSMakeSize(mainWindowOffset.width, effectsWindowOffset.height - gap - playQueueHeight)
            
        case .horizontalStack:
            
            playQueueWidth = max(visibleFrame.width - (Self.mainWindowWidth + Self.effectsWindowWidth + twoGaps), Self.minPlayQueueWidth)
            xPadding = visibleFrame.width - (Self.mainWindowWidth + Self.effectsWindowWidth + playQueueWidth + twoGaps)
            yPadding = visibleFrame.height - Self.mainWindowHeight
            
            mainWindowOffset = NSMakeSize(max(xPadding / 2, 0),
                                          yPadding / 2)
            
            effectsWindowOffset = NSMakeSize(mainWindowOffset.width + Self.mainWindowWidth + gap,
                                             mainWindowOffset.height)
            
            playQueueHeight = Self.mainWindowHeight
            
            playQueueWindowOffset = NSMakeSize(mainWindowOffset.width + Self.mainWindowWidth + Self.effectsWindowWidth + twoGaps,
                                               mainWindowOffset.height)
            
        case .bigBottomPlayQueue:
            
            xPadding = visibleFrame.width - (Self.mainWindowWidth + gap + Self.effectsWindowWidth)
            playQueueHeight = playQueueHeight_bigBottomPlayQueue
            yPadding = visibleFrame.height - (Self.mainWindowHeight + gap + playQueueHeight)
            
            mainWindowOffset = NSMakeSize(xPadding / 2,
                                          (yPadding / 2) + playQueueHeight + gap)
            
            effectsWindowOffset = NSMakeSize(mainWindowOffset.width + Self.mainWindowWidth + gap,
                                             mainWindowOffset.height)
            
            playQueueWidth = Self.mainWindowWidth + gap + Self.effectsWindowWidth
            playQueueWindowOffset = NSMakeSize(mainWindowOffset.width,
                                               mainWindowOffset.height - gap - playQueueHeight)
            
        case .bigLeftPlayQueue:
            
            playQueueWidth = Self.mainWindowWidth
            xPadding = visibleFrame.width - (Self.mainWindowWidth + gap + playQueueWidth)
            yPadding = visibleFrame.height - (Self.mainWindowHeight + gap + Self.effectsWindowHeight)
            
            mainWindowOffset = NSMakeSize((xPadding / 2) + playQueueWidth + gap,
                                          (yPadding / 2) + Self.effectsWindowHeight + gap)
            
            effectsWindowOffset = NSMakeSize(mainWindowOffset.width,
                                             mainWindowOffset.height - gap - Self.effectsWindowHeight)
            
            playQueueHeight = Self.mainWindowHeight + gap + Self.effectsWindowHeight
            
            playQueueWindowOffset = NSMakeSize(mainWindowOffset.width - gap - playQueueWidth,
                                               mainWindowOffset.height - gap - Self.effectsWindowHeight)
            
        case .bigRightPlayQueue:
            
            xPadding = visibleFrame.width - (Self.mainWindowWidth + gap + Self.mainWindowWidth)
            yPadding = visibleFrame.height - (Self.mainWindowHeight + gap + Self.effectsWindowHeight)
            
            mainWindowOffset = NSMakeSize((xPadding / 2),
                                          (yPadding / 2) + Self.effectsWindowHeight + gap)
            
            effectsWindowOffset = NSMakeSize(mainWindowOffset.width,
                                             mainWindowOffset.height - gap - Self.effectsWindowHeight)
            
            playQueueHeight = Self.mainWindowHeight + gap + Self.effectsWindowHeight
            playQueueWidth = Self.mainWindowWidth
            
            playQueueWindowOffset = NSMakeSize(mainWindowOffset.width + Self.mainWindowWidth + gap,
                                               mainWindowOffset.height - gap - Self.effectsWindowHeight)
            
        case .verticalPlayerAndPlayQueue:
            
            xPadding = visibleFrame.width - Self.mainWindowWidth
            
            playQueueHeight = playQueueHeight_verticalPlayerAndPlayQueue
            yPadding = (visibleFrame.height - Self.mainWindowHeight - playQueueHeight - gap)
            let halfYPadding = yPadding / 2
            
            mainWindowOffset = NSMakeSize(xPadding / 2,
                                          visibleFrame.height - halfYPadding - Self.mainWindowHeight)
            
            playQueueWidth = Self.mainWindowWidth
            playQueueWindowOffset = NSMakeSize(mainWindowOffset.width, halfYPadding)
            
        case .horizontalPlayerAndPlayQueue:
            
            playQueueHeight = Self.mainWindowHeight
            playQueueWidth = Self.mainWindowWidth
            
            xPadding = visibleFrame.width - (Self.mainWindowWidth + gap + playQueueWidth)
            yPadding = visibleFrame.height - Self.mainWindowHeight
            
            mainWindowOffset = NSMakeSize(xPadding / 2,
                                          yPadding / 2)
            
            playQueueWindowOffset = NSMakeSize(mainWindowOffset.width + Self.mainWindowWidth + gap,
                                               mainWindowOffset.height)
        }
        
        let mainWindow = LayoutWindow(id: .main, screen: screen,
                                      screenFrame: screen.frame,
                                      screenOffset: mainWindowOffset,
                                      size: NSMakeSize(Self.mainWindowWidth, Self.mainWindowHeight))
        
        var auxiliaryWindows: [LayoutWindow] = []
        
        if playQueueWindowOffset != .zero {
            
            let playQueueWindow = LayoutWindow(id: .playQueue, screen: screen,
                                               screenFrame: screen.frame,
                                               screenOffset: playQueueWindowOffset,
                                               size: NSMakeSize(playQueueWidth, playQueueHeight))
            
            auxiliaryWindows.append(playQueueWindow)
        }
        
        if effectsWindowOffset != .zero {
            
            let effectsWindow = LayoutWindow(id: .effects, screen: screen,
                                             screenFrame: screen.frame,
                                             screenOffset: effectsWindowOffset,
                                             size: NSMakeSize(Self.effectsWindowWidth, Self.effectsWindowHeight))
            
            auxiliaryWindows.append(effectsWindow)
        }
        
        return WindowLayout(name: self.name, systemDefined: true, mainWindow: mainWindow, auxiliaryWindows: auxiliaryWindows)
    }
}
