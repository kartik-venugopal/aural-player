//
// WindowLayoutPresets+Compute.swift
// Aural
//
// Copyright © 2024 Kartik Venugopal. All rights reserved.
//
// This software is licensed under the MIT software license.
// See the file "LICENSE" in the project root directory for license terms.
//

import Foundation

fileprivate let playQueueHeight_verticalFullStack: CGFloat = 225
fileprivate let playQueueHeight_verticalPlayerAndPlayQueue: CGFloat = 500
fileprivate let playQueueHeight_bigBottomPlayQueue: CGFloat = 500

extension WindowLayoutPresets {
    
    func computeMinimal(visibleFrame: NSRect, gap: CGFloat) -> WindowLayout {
        
        let xPadding = visibleFrame.width - Self.mainWindowWidth
        let yPadding = visibleFrame.height - Self.mainWindowHeight
        
        let mainWindowOffset = NSMakeSize(xPadding / 2,
                                          visibleFrame.height - (yPadding / 2) - Self.mainWindowHeight)
        
        let mainWindow = LayoutWindow(id: .main, screen: .main, screenOffset: mainWindowOffset, size: NSMakeSize(Self.mainWindowWidth, Self.mainWindowHeight))
        
        return WindowLayout(name: self.name, systemDefined: true, mainWindow: mainWindow, auxiliaryWindows: [])
    }
    
    func computeVerticalStack(visibleFrame: NSRect, gap: CGFloat) -> WindowLayout {
        
        let twoGaps = 2 * gap
        
        let screenWidth = visibleFrame.width
        let screenHeight = visibleFrame.height
        
        let playQueueHeight = min(playQueueHeight_verticalFullStack,
                                  screenHeight - (Self.mainWindowHeight + Self.effectsWindowHeight + twoGaps))
        
        let xPadding = screenWidth - Self.mainWindowWidth
        let totalStackHeight = Self.mainWindowHeight + Self.effectsWindowHeight + twoGaps + playQueueHeight
        let yPadding = screenHeight - totalStackHeight
        
        let mainWindowOffset = NSMakeSize(xPadding / 2,
                                          screenHeight - (yPadding / 2) - Self.mainWindowHeight)
        
        let effectsWindowOffset = NSMakeSize(mainWindowOffset.width, mainWindowOffset.height - gap - Self.effectsWindowHeight)
        
        let playQueueWidth = Self.mainWindowWidth
        let playQueueWindowOffset = NSMakeSize(mainWindowOffset.width, effectsWindowOffset.height - gap - playQueueHeight)
        
        let mainWindow = LayoutWindow(id: .main, screen: .main, screenOffset: mainWindowOffset, size: NSMakeSize(Self.mainWindowWidth, Self.mainWindowHeight))
        let effectsWindow = LayoutWindow(id: .effects, screen: .main, screenOffset: effectsWindowOffset, size: NSMakeSize(Self.effectsWindowWidth, Self.effectsWindowHeight))
        let playQueueWindow = LayoutWindow(id: .playQueue, screen: .main, screenOffset: playQueueWindowOffset, size: NSMakeSize(playQueueWidth, playQueueHeight))
        
        return WindowLayout(name: self.name, systemDefined: true, mainWindow: mainWindow, auxiliaryWindows: [effectsWindow, playQueueWindow])
    }
    
    func computeHorizontalStack(visibleFrame: NSRect, gap: CGFloat) -> WindowLayout {
        
        let twoGaps = 2 * gap
        
        let playQueueWidth = max(visibleFrame.width - (Self.mainWindowWidth + Self.effectsWindowWidth + twoGaps), Self.minPlayQueueWidth)
        let xPadding = visibleFrame.width - (Self.mainWindowWidth + Self.effectsWindowWidth + playQueueWidth + twoGaps)
        let yPadding = visibleFrame.height - Self.mainWindowHeight
        
        let mainWindowOffset = NSMakeSize(max(xPadding / 2, 0),
                                          yPadding / 2)
        
        let effectsWindowOffset = NSMakeSize(mainWindowOffset.width + Self.mainWindowWidth + gap,
                                             mainWindowOffset.height)
        
        let playQueueHeight = Self.mainWindowHeight
        
        let playQueueWindowOffset = NSMakeSize(mainWindowOffset.width + Self.mainWindowWidth + Self.effectsWindowWidth + twoGaps,
                                               mainWindowOffset.height)
        
        let mainWindow = LayoutWindow(id: .main, screen: .main, screenOffset: mainWindowOffset, size: NSMakeSize(Self.mainWindowWidth, Self.mainWindowHeight))
        
        let effectsWindow = LayoutWindow(id: .effects, screen: .main, screenOffset: effectsWindowOffset, size: NSMakeSize(Self.effectsWindowWidth, Self.effectsWindowHeight))
        
        let playQueueWindow = LayoutWindow(id: .playQueue, screen: .main, screenOffset: playQueueWindowOffset, size: NSMakeSize(playQueueWidth, playQueueHeight))
        
        return WindowLayout(name: self.name, systemDefined: true, mainWindow: mainWindow, auxiliaryWindows: [effectsWindow, playQueueWindow])
    }
    
    func computeBigBottomPlayQueue(visibleFrame: NSRect, gap: CGFloat) -> WindowLayout {
        
        let twoGaps = 2 * gap
        
        let xPadding = visibleFrame.width - (Self.mainWindowWidth + gap + Self.effectsWindowWidth)
        let playQueueHeight = playQueueHeight_bigBottomPlayQueue
        let yPadding = visibleFrame.height - (Self.mainWindowHeight + gap + playQueueHeight)
        
        let mainWindowOffset = NSMakeSize(xPadding / 2,
                                          (yPadding / 2) + playQueueHeight + gap)
        
        let effectsWindowOffset = NSMakeSize(mainWindowOffset.width + Self.mainWindowWidth + gap,
                                             mainWindowOffset.height)
        
        let playQueueWidth = Self.mainWindowWidth + gap + Self.effectsWindowWidth
        let playQueueWindowOffset = NSMakeSize(mainWindowOffset.width,
                                               mainWindowOffset.height - gap - playQueueHeight)
        
        let mainWindow = LayoutWindow(id: .main, screen: .main, screenOffset: mainWindowOffset, size: NSMakeSize(Self.mainWindowWidth, Self.mainWindowHeight))
        
        let effectsWindow = LayoutWindow(id: .effects, screen: .main, screenOffset: effectsWindowOffset, size: NSMakeSize(Self.effectsWindowWidth, Self.effectsWindowHeight))
        
        let playQueueWindow = LayoutWindow(id: .playQueue, screen: .main, screenOffset: playQueueWindowOffset, size: NSMakeSize(playQueueWidth, playQueueHeight))
        
        return WindowLayout(name: self.name, systemDefined: true, mainWindow: mainWindow, auxiliaryWindows: [effectsWindow, playQueueWindow])
    }
    
    func computeBigLeftPlayQueue(visibleFrame: NSRect, gap: CGFloat) -> WindowLayout {
        
        let playQueueWidth = Self.mainWindowWidth
        let xPadding = visibleFrame.width - (Self.mainWindowWidth + gap + playQueueWidth)
        let yPadding = visibleFrame.height - (Self.mainWindowHeight + gap + Self.effectsWindowHeight)
        
        let mainWindowOffset = NSMakeSize((xPadding / 2) + playQueueWidth + gap,
                                          (yPadding / 2) + Self.effectsWindowHeight + gap)
        
        let effectsWindowOffset = NSMakeSize(mainWindowOffset.width,
                                             mainWindowOffset.height - gap - Self.effectsWindowHeight)
        
        let playQueueHeight = Self.mainWindowHeight + gap + Self.effectsWindowHeight
        
        let playQueueWindowOffset = NSMakeSize(mainWindowOffset.width - gap - playQueueWidth,
                                               mainWindowOffset.height - gap - Self.effectsWindowHeight)
        
        let mainWindow = LayoutWindow(id: .main, screen: .main, screenOffset: mainWindowOffset, size: NSMakeSize(Self.mainWindowWidth, Self.mainWindowHeight))
        
        let effectsWindow = LayoutWindow(id: .effects, screen: .main, screenOffset: effectsWindowOffset, size: NSMakeSize(Self.effectsWindowWidth, Self.effectsWindowHeight))
        
        let playQueueWindow = LayoutWindow(id: .playQueue, screen: .main, screenOffset: playQueueWindowOffset, size: NSMakeSize(playQueueWidth, playQueueHeight))
        
        return WindowLayout(name: self.name, systemDefined: true, mainWindow: mainWindow, auxiliaryWindows: [effectsWindow, playQueueWindow])
    }
    
    func computeBigRightPlayQueue(visibleFrame: NSRect, gap: CGFloat) -> WindowLayout {
        
        let xPadding = visibleFrame.width - (Self.mainWindowWidth + gap + Self.mainWindowWidth)
        let yPadding = visibleFrame.height - (Self.mainWindowHeight + gap + Self.effectsWindowHeight)
        
        let mainWindowOffset = NSMakeSize((xPadding / 2),
                                          (yPadding / 2) + Self.effectsWindowHeight + gap)
        
        let effectsWindowOffset = NSMakeSize(mainWindowOffset.width,
                                             mainWindowOffset.height - gap - Self.effectsWindowHeight)
        
        let playQueueHeight = Self.mainWindowHeight + gap + Self.effectsWindowHeight
        let playQueueWidth = Self.mainWindowWidth
        
        let playQueueWindowOffset = NSMakeSize(mainWindowOffset.width + Self.mainWindowWidth + gap,
                                               mainWindowOffset.height - gap - Self.effectsWindowHeight)
        
        let mainWindow = LayoutWindow(id: .main, screen: .main, screenOffset: mainWindowOffset, size: NSMakeSize(Self.mainWindowWidth, Self.mainWindowHeight))
        
        let effectsWindow = LayoutWindow(id: .effects, screen: .main, screenOffset: effectsWindowOffset, size: NSMakeSize(Self.effectsWindowWidth, Self.effectsWindowHeight))
        
        let playQueueWindow = LayoutWindow(id: .playQueue, screen: .main, screenOffset: playQueueWindowOffset, size: NSMakeSize(playQueueWidth, playQueueHeight))
        
        return WindowLayout(name: self.name, systemDefined: true, mainWindow: mainWindow, auxiliaryWindows: [effectsWindow, playQueueWindow])
    }
    
    func computeVerticalPlayerAndPlayQueue(visibleFrame: NSRect, gap: CGFloat) -> WindowLayout {
        
        let xPadding = visibleFrame.width - Self.mainWindowWidth
        
        let playQueueHeight = playQueueHeight_verticalPlayerAndPlayQueue
        let yPadding = (visibleFrame.height - Self.mainWindowHeight - playQueueHeight - gap)
        let halfYPadding = yPadding / 2
        
        let mainWindowOffset = NSMakeSize(xPadding / 2,
                                       visibleFrame.height - halfYPadding - Self.mainWindowHeight)
        
        let playQueueWidth = Self.mainWindowWidth
        let playQueueWindowOffset = NSMakeSize(mainWindowOffset.width, halfYPadding)
        
        let mainWindow = LayoutWindow(id: .main, screen: .main, screenOffset: mainWindowOffset, size: NSMakeSize(Self.mainWindowWidth, Self.mainWindowHeight))
        
        let playQueueWindow = LayoutWindow(id: .playQueue, screen: .main, screenOffset: playQueueWindowOffset, size: NSMakeSize(playQueueWidth, playQueueHeight))
        
        return WindowLayout(name: self.name, systemDefined: true, mainWindow: mainWindow, auxiliaryWindows: [playQueueWindow])
    }
    
    func computeHorizontalPlayerAndPlayQueue(visibleFrame: NSRect, gap: CGFloat) -> WindowLayout {
        
        let playQueueHeight = Self.mainWindowHeight
        let playQueueWidth = Self.mainWindowWidth
        
        let xPadding = visibleFrame.width - (Self.mainWindowWidth + gap + playQueueWidth)
        let yPadding = visibleFrame.height - Self.mainWindowHeight
        
        let mainWindowOffset = NSMakeSize(xPadding / 2,
                                          yPadding / 2)
        
        let playQueueWindowOffset = NSMakeSize(mainWindowOffset.width + Self.mainWindowWidth + gap,
                                               mainWindowOffset.height)
        
        let mainWindow = LayoutWindow(id: .main, screen: .main, screenOffset: mainWindowOffset, size: NSMakeSize(Self.mainWindowWidth, Self.mainWindowHeight))
        
        let playQueueWindow = LayoutWindow(id: .playQueue, screen: .main, screenOffset: playQueueWindowOffset, size: NSMakeSize(playQueueWidth, playQueueHeight))
        
        return WindowLayout(name: self.name, systemDefined: true, mainWindow: mainWindow, auxiliaryWindows: [playQueueWindow])
    }
}
