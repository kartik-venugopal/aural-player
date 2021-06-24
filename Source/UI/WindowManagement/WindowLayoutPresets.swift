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
    
    // Converts a user-friendly display name to an instance of PitchPresets
    static func fromDisplayName(_ displayName: String) -> WindowLayoutPresets {
        return WindowLayoutPresets(rawValue: displayName.camelCased()) ?? .verticalFullStack
    }

    // TODO: Should also check the screen and recompute when the screen changes
    // Recomputes the layout (useful when the window gap preference changes)
    static func recompute(_ layout: WindowLayout) {
        
        let preset = WindowLayoutPresets.fromDisplayName(layout.name)
        
        layout.mainWindowOrigin = preset.mainWindowOrigin
        layout.effectsWindowOrigin = preset.effectsWindowOrigin
        layout.playlistWindowFrame = preset.playlistWindowFrame
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
    
    private var gapBetweenWindows: CGFloat {
        
        return CGFloat(ObjectGraph.preferences.viewPreferences.windowGap)
    }
    
    var mainWindowOrigin: NSPoint {
        
        let mainWindowWidth: CGFloat = Self.mainWindowWidth
        let mainWindowHeight: CGFloat = Self.mainWindowHeight
        
        let effectsWindowWidth: CGFloat = Self.effectsWindowWidth
        let effectsWindowHeight: CGFloat = Self.effectsWindowHeight
        
        let gap = gapBetweenWindows
        let twoGaps = 2 * gap
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        // Compute this only once
        let visibleFrame = screenVisibleFrame
        
        switch self {
            
        // Top left corner
        case .compactCornered:
            
            x = visibleFrame.minX
            y = visibleFrame.maxY - mainWindowHeight
            
        case .verticalFullStack:
            
            let xPadding = visibleFrame.width - mainWindowWidth
            x = visibleFrame.minX + (xPadding / 2)
            
            let totalStackHeight = mainWindowHeight + effectsWindowHeight + twoGaps + playlistHeight_verticalFullStack
            let yPadding = visibleFrame.height - totalStackHeight
            y = visibleFrame.maxY - (yPadding / 2) - mainWindowHeight
            
        case .horizontalFullStack:
            
            let xPadding = visibleFrame.width - (mainWindowWidth + effectsWindowWidth + playlistWidth + twoGaps)
            
            // Sometimes, xPadding is negative, never go to the left of minX
            x = max(visibleFrame.minX + (xPadding / 2), visibleFrame.minX)
            
            let yPadding = visibleFrame.height - mainWindowHeight
            y = visibleFrame.minY + (yPadding / 2)
            
        case .bigBottomPlaylist:
            
            let xPadding = visibleFrame.width - (mainWindowWidth + gap + effectsWindowWidth)
            x = visibleFrame.minX + (xPadding / 2)
            
            let pHeight = playlistHeight
            let yPadding = visibleFrame.height - (mainWindowHeight + gap + pHeight)
            y = visibleFrame.minY + (yPadding / 2) + pHeight + gap
            
        case .bigLeftPlaylist:
            
            let pWidth = playlistWidth
            let xPadding = visibleFrame.width - (mainWindowWidth + gap + pWidth)
            x = visibleFrame.minX + (xPadding / 2) + pWidth + gap
            
            let yPadding = visibleFrame.height - (mainWindowHeight + gap + effectsWindowHeight)
            y = visibleFrame.minY + (yPadding / 2) + effectsWindowHeight + gap
            
        case .bigRightPlaylist:
            
            let xPadding = visibleFrame.width - (mainWindowWidth + gap + playlistWidth)
            x = visibleFrame.minX + (xPadding / 2)
            
            let yPadding = visibleFrame.height - (mainWindowHeight + gap + effectsWindowHeight)
            y = visibleFrame.minY + (yPadding / 2) + effectsWindowHeight + gap
            
        case .verticalPlayerAndPlaylist:
            
            let xPadding = visibleFrame.width - mainWindowWidth
            x = visibleFrame.minX + (xPadding / 2)
            y = visibleFrame.maxY - mainWindowHeight
            
        case .horizontalPlayerAndPlaylist:
            
            x = visibleFrame.minX
            
            let yPadding = visibleFrame.height - mainWindowHeight
            y = visibleFrame.minY + (yPadding / 2)
        }
        
        return NSPoint(x: x, y: y)
    }
    
    var effectsWindowOrigin: NSPoint {
        
        let mainWindowWidth: CGFloat = Self.mainWindowWidth
        let effectsWindowHeight: CGFloat = Self.effectsWindowHeight
        
        let gap = gapBetweenWindows
        
        let mwo = mainWindowOrigin
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        switch self {
            
        case .verticalFullStack:
            
            x = mwo.x
            y = mwo.y - gap - effectsWindowHeight
            
        case .horizontalFullStack:
            
            x = mwo.x + mainWindowWidth + gap
            y = mwo.y
            
        case .bigBottomPlaylist:
            
            x = mwo.x + mainWindowWidth + gap
            y = mwo.y
            
        case .bigLeftPlaylist:
            
            x = mwo.x
            y = mwo.y - gap - effectsWindowHeight
            
        case .bigRightPlaylist:
            
            x = mwo.x
            y = mwo.y - gap - effectsWindowHeight
            
        default:
            
            x = 0
            y = 0
        }
        
        return NSPoint(x: x, y: y)
    }
    
    var playlistHeight: CGFloat {
        
        let mainWindowHeight: CGFloat = Self.mainWindowHeight
        
        let effectsWindowHeight: CGFloat = Self.effectsWindowHeight
        
        let gap = gapBetweenWindows
        
        // Compute this only once
        let visibleFrame = screenVisibleFrame
        
        switch self {
            
        case .verticalFullStack:    return playlistHeight_verticalFullStack
            
        case .horizontalFullStack, .horizontalPlayerAndPlaylist:  return mainWindowHeight
            
        case .bigLeftPlaylist, .bigRightPlaylist:   return mainWindowHeight + gap + effectsWindowHeight
            
        case .verticalPlayerAndPlaylist:   return visibleFrame.height - (mainWindowHeight + gap)
            
        default:    return 500
            
        }
    }
    
    var playlistWidth: CGFloat {
        
        let mainWindowWidth: CGFloat = Self.mainWindowWidth
        let effectsWindowWidth: CGFloat = Self.effectsWindowWidth
        
        let gap = gapBetweenWindows
        let twoGaps = 2 * gap
        let minWidth = Self.minPlaylistWidth
        
        // Compute this only once
        let visibleFrame = screenVisibleFrame
        
        switch self {
            
        case .verticalFullStack, .verticalPlayerAndPlaylist:    return mainWindowWidth
            
        case .horizontalFullStack:    return max(visibleFrame.width - (mainWindowWidth + effectsWindowWidth + twoGaps), minWidth)
            
        case .bigBottomPlaylist:    return mainWindowWidth + gap + effectsWindowWidth
            
        case .bigLeftPlaylist, .bigRightPlaylist:   return mainWindowWidth
            
        case .horizontalPlayerAndPlaylist: return visibleFrame.width - (mainWindowWidth + gap)
            
        default:    return 500
            
        }
    }
    
    var playlistWindowOrigin: NSPoint {
        
        let mainWindowWidth: CGFloat = Self.mainWindowWidth
        
        let effectsWindowWidth: CGFloat = Self.effectsWindowWidth
        let effectsWindowHeight: CGFloat = Self.effectsWindowHeight
        
        let gap = gapBetweenWindows
        let twoGaps = 2 * gap
        let mwo = mainWindowOrigin
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        // Compute this only once
        let visibleFrame = screenVisibleFrame
        
        switch self {
            
        case .verticalFullStack:
            
            x = mwo.x
            y = mwo.y - effectsWindowHeight - twoGaps - playlistHeight
            
        case .horizontalFullStack:
            
            x = mwo.x + mainWindowWidth + effectsWindowWidth + twoGaps
            y = mwo.y
            
        case .bigBottomPlaylist:
            
            x = mwo.x
            y = mwo.y - gap - playlistHeight
            
        case .bigLeftPlaylist:
            
            x = mwo.x - gap - playlistWidth
            y = mwo.y - gap - effectsWindowHeight
            
        case .bigRightPlaylist:
            
            x = mwo.x + mainWindowWidth + gap
            y = mwo.y - gap - effectsWindowHeight
            
        case .verticalPlayerAndPlaylist:
            
            x = mwo.x
            y = visibleFrame.minY
            
        case .horizontalPlayerAndPlaylist:
            
            x = mwo.x + mainWindowWidth + gap
            y = mwo.y
            
        default:
            
            x = 0
            y = 0
        }
        
        return NSPoint(x: x, y: y)
    }
    
    var playlistWindowFrame: NSRect {
        
        let origin = playlistWindowOrigin
        return NSRect(x: origin.x, y: origin.y, width: playlistWidth, height: playlistHeight)
    }
}
