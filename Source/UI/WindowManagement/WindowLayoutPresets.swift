//
//  WindowLayoutPresets.swift
//  Aural
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

fileprivate let playlistHeight_verticalFullStack: CGFloat = 340
fileprivate let playlistHeight_verticalPlayerAndPlaylist: CGFloat = 500
fileprivate let playlistHeight_bigBottomPlaylist: CGFloat = 500

enum WindowLayoutPresets: String, CaseIterable {
    
    case verticalFullStack
    case horizontalFullStack
    case compactCornered
    case bigBottomPlaylist
    case bigLeftPlaylist
    case bigRightPlaylist
    case verticalPlayerAndPlaylist
    case horizontalPlayerAndPlaylist
    
    static let minPlaylistWidth: CGFloat = 530
    
    // Main window size (never changes)
    static let mainWindowWidth: CGFloat = 530
    static let mainWindowHeight: CGFloat = 230
    
    // Effects window size (never changes)
    static let effectsWindowWidth: CGFloat = 530
    static let effectsWindowHeight: CGFloat = 230
    
    // Converts a user-friendly display name to an instance of PitchShiftPresets
    static func fromDisplayName(_ displayName: String) -> WindowLayoutPresets {
        return WindowLayoutPresets(rawValue: displayName.camelCased()) ?? .verticalFullStack
    }
    
    // TODO: Should also check the screen and recompute when the screen changes
    // Recomputes the layout (useful when the window gap preference changes)
    static func recompute(layout: WindowLayout, gap: CGFloat) {
        
        let preset = WindowLayoutPresets.fromDisplayName(layout.name)
        let recomputedLayout = preset.layout(gap: gap)
        
        layout.mainWindowOrigin = recomputedLayout.mainWindowOrigin
        layout.effectsWindowOrigin = recomputedLayout.effectsWindowOrigin
        layout.playlistWindowFrame = recomputedLayout.playlistWindowFrame
    }
    
    var name: String {
        rawValue.splitAsCamelCaseWord(capitalizeEachWord: false)
    }
    
    var showPlaylist: Bool {
        return self != .compactCornered
    }
    
    var showEffects: Bool {
        
        switch self {
        
        case .compactCornered, .verticalPlayerAndPlaylist, .horizontalPlayerAndPlaylist:
            
            return false
            
        default:
            
            return true
        }
    }
    
    func layout(gap: CGFloat) -> WindowLayout {
        
        let twoGaps = 2 * gap
        
        // Compute this only once
        let visibleFrame = screenVisibleFrame
        
        var mainWindowOrigin: NSPoint = .zero
        var effectsWindowOrigin: NSPoint = .zero
        var playlistHeight: CGFloat = 0
        var playlistWidth: CGFloat = 0
        var playlistWindowOrigin: NSPoint = .zero
        
        switch self {
        
        // Top left corner
        case .compactCornered:
            
            mainWindowOrigin = NSMakePoint(visibleFrame.minX, visibleFrame.maxY - Self.mainWindowHeight)
            
        case .verticalFullStack:
            
            playlistHeight = min(playlistHeight_verticalFullStack,
                                 visibleFrame.height - (Self.mainWindowHeight + Self.effectsWindowHeight + twoGaps))
            
            let xPadding = visibleFrame.width - Self.mainWindowWidth
            let totalStackHeight = Self.mainWindowHeight + Self.effectsWindowHeight + twoGaps + playlistHeight
            let yPadding = visibleFrame.height - totalStackHeight
            
            mainWindowOrigin = NSMakePoint(visibleFrame.minX + (xPadding / 2),
                                           visibleFrame.maxY - (yPadding / 2) - Self.mainWindowHeight)
            
            effectsWindowOrigin = NSMakePoint(mainWindowOrigin.x, mainWindowOrigin.y - gap - Self.effectsWindowHeight)
            
            playlistWidth = Self.mainWindowWidth
            
            playlistWindowOrigin = NSMakePoint(mainWindowOrigin.x, effectsWindowOrigin.y - gap - playlistHeight)
            
        case .horizontalFullStack:
            
            // Sometimes, xPadding is negative, never go to the left of minX
            playlistWidth = max(visibleFrame.width - (Self.mainWindowWidth + Self.effectsWindowWidth + twoGaps), Self.minPlaylistWidth)
            let xPadding = visibleFrame.width - (Self.mainWindowWidth + Self.effectsWindowWidth + playlistWidth + twoGaps)
            let yPadding = visibleFrame.height - Self.mainWindowHeight
            
            mainWindowOrigin = NSMakePoint(max(visibleFrame.minX + (xPadding / 2), visibleFrame.minX),
                                           visibleFrame.minY + (yPadding / 2))
            
            effectsWindowOrigin = NSMakePoint(mainWindowOrigin.x + Self.mainWindowWidth + gap,
                                              mainWindowOrigin.y)
            
            playlistHeight = Self.mainWindowHeight
            
            playlistWindowOrigin = NSMakePoint(mainWindowOrigin.x + Self.mainWindowWidth + Self.effectsWindowWidth + twoGaps,
                                               mainWindowOrigin.y)
            
        case .bigBottomPlaylist:
            
            let xPadding = visibleFrame.width - (Self.mainWindowWidth + gap + Self.effectsWindowWidth)
            playlistHeight = playlistHeight_bigBottomPlaylist
            let yPadding = visibleFrame.height - (Self.mainWindowHeight + gap + playlistHeight)
            
            mainWindowOrigin = NSMakePoint(visibleFrame.minX + (xPadding / 2),
                                           visibleFrame.minY + (yPadding / 2) + playlistHeight + gap)
            
            effectsWindowOrigin = NSMakePoint(mainWindowOrigin.x + Self.mainWindowWidth + gap,
                                              mainWindowOrigin.y)
            
            playlistWidth = Self.mainWindowWidth + gap + Self.effectsWindowWidth
            playlistWindowOrigin = NSMakePoint(mainWindowOrigin.x,
                                               mainWindowOrigin.y - gap - playlistHeight)
            
        case .bigLeftPlaylist:
            
            let pWidth = Self.mainWindowWidth
            let xPadding = visibleFrame.width - (Self.mainWindowWidth + gap + pWidth)
            let yPadding = visibleFrame.height - (Self.mainWindowHeight + gap + Self.effectsWindowHeight)
            
            mainWindowOrigin = NSMakePoint(visibleFrame.minX + (xPadding / 2) + pWidth + gap,
                                           visibleFrame.minY + (yPadding / 2) + Self.effectsWindowHeight + gap)
            
            effectsWindowOrigin = NSMakePoint(mainWindowOrigin.x,
                                              mainWindowOrigin.y - gap - Self.effectsWindowHeight)
            
            playlistHeight = Self.mainWindowHeight + gap + Self.effectsWindowHeight
            playlistWidth = Self.mainWindowWidth
            
            playlistWindowOrigin = NSMakePoint(mainWindowOrigin.x - gap - playlistWidth,
                                               mainWindowOrigin.y - gap - Self.effectsWindowHeight)
            
        case .bigRightPlaylist:
            
            let xPadding = visibleFrame.width - (Self.mainWindowWidth + gap + Self.mainWindowWidth)
            let yPadding = visibleFrame.height - (Self.mainWindowHeight + gap + Self.effectsWindowHeight)
            
            mainWindowOrigin = NSMakePoint(visibleFrame.minX + (xPadding / 2),
                                           visibleFrame.minY + (yPadding / 2) + Self.effectsWindowHeight + gap)
            
            effectsWindowOrigin = NSMakePoint(mainWindowOrigin.x, mainWindowOrigin.y - gap - Self.effectsWindowHeight)
            
            playlistHeight = Self.mainWindowHeight + gap + Self.effectsWindowHeight
            playlistWidth = Self.mainWindowWidth
            
            playlistWindowOrigin = NSMakePoint(mainWindowOrigin.x + Self.mainWindowWidth + gap,
                                               mainWindowOrigin.y - gap - Self.effectsWindowHeight)
            
        case .verticalPlayerAndPlaylist:
            
            let xPadding = visibleFrame.width - Self.mainWindowWidth
            
            playlistHeight = playlistHeight_verticalPlayerAndPlaylist
            let yPadding = (visibleFrame.height - Self.mainWindowHeight - playlistHeight - gap)
            let halfYPadding = yPadding / 2
            
            mainWindowOrigin = NSMakePoint(visibleFrame.minX + (xPadding / 2),
                                           visibleFrame.maxY - halfYPadding - Self.mainWindowHeight)
            
            
            playlistWidth = Self.mainWindowWidth
            
            playlistWindowOrigin = NSMakePoint(mainWindowOrigin.x, visibleFrame.minY + halfYPadding)
            
        case .horizontalPlayerAndPlaylist:
            
            let yPadding = visibleFrame.height - Self.mainWindowHeight
            mainWindowOrigin = NSMakePoint(visibleFrame.minX, visibleFrame.minY + (yPadding / 2))
            
            playlistHeight = Self.mainWindowHeight
            playlistWidth = visibleFrame.width - (Self.mainWindowWidth + gap)
            
            playlistWindowOrigin = NSMakePoint(mainWindowOrigin.x + Self.mainWindowWidth + gap, mainWindowOrigin.y)
        }
        
        let playlistWindowFrame: NSRect = NSMakeRect(playlistWindowOrigin.x, playlistWindowOrigin.y, playlistWidth, playlistHeight)
        return WindowLayout(name, showEffects, showPlaylist, mainWindowOrigin, effectsWindowOrigin, playlistWindowFrame, true)
    }
}
