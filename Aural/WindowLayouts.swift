import Cocoa

fileprivate var visibleFrame: NSRect = {
    return NSScreen.main()!.visibleFrame
}()

fileprivate let mainWindow: NSWindow = WindowFactory.getMainWindow()
fileprivate let effectsWindow: NSWindow = WindowFactory.getEffectsWindow()
fileprivate let playlistWindow: NSWindow = WindowFactory.getPlaylistWindow()

class WindowLayouts {
    
    private static var layouts: [String: WindowLayout] = {
        
        var map = [String: WindowLayout]()
        
        WindowLayoutPresets.allValues.forEach({
            
            map[$0.rawValue] = WindowLayout(name: $0.rawValue, showEffects: $0.showEffects, showPlaylist: $0.showPlaylist, mainWindowOrigin: $0.mainWindowOrigin, effectsWindowOrigin: $0.effectsWindowOrigin, playlistWindowFrame: $0.playlistWindowFrame, systemDefined: true)
        })
        
        return map
    }()
    
    static var userDefinedLayouts: [WindowLayout] {
        return layouts.values.filter({$0.systemDefined == false})
    }
    
    static var systemDefinedLayouts: [WindowLayout] {
        return layouts.values.filter({$0.systemDefined == true})
    }
    
    static var defaultLayout: WindowLayout {
        return layoutByName(WindowLayoutPresets.verticalFullStack.rawValue)
    }
    
    static func layoutByName(_ name: String) -> WindowLayout {
        return layouts[name] ?? defaultLayout
    }
    
    static func loadUserDefinedLayouts(_ userDefinedLayouts: [WindowLayout]) {
        userDefinedLayouts.forEach({layouts[$0.name] = $0})
    }

    // Assume preset with this name doesn't already exist
    static func addUserDefinedLayout(_ name: String) {
        
        let showEffects = effectsWindow.isVisible
        let showPlaylist = playlistWindow.isVisible
        
        let mainWindowOrigin = mainWindow.origin
        let effectsWindowOrigin = showEffects ? effectsWindow.origin : nil
        let playlistWindowFrame = showPlaylist ? playlistWindow.frame: nil
        
        layouts[name] = WindowLayout(name: name, showEffects: showEffects, showPlaylist: showPlaylist, mainWindowOrigin: mainWindowOrigin, effectsWindowOrigin: effectsWindowOrigin, playlistWindowFrame: playlistWindowFrame, systemDefined: false)
    }

    static func layoutWithNameExists(_ name: String) -> Bool {
        return layouts[name] != nil
    }
}

struct WindowLayout {
    
    let name: String
    let showEffects: Bool
    let showPlaylist: Bool
    
    let mainWindowOrigin: NSPoint
    let effectsWindowOrigin: NSPoint?
    let playlistWindowFrame: NSRect?
    
    let systemDefined: Bool
}

enum WindowLayoutPresets: String {
    
    case verticalFullStack = "Vertical full stack"
    case horizontalFullStack = "Horizontal full stack"
    case compactCornered = "Compact cornered"
    case bigBottomPlaylist = "Big bottom playlist"
    case bigLeftPlaylist = "Big left playlist"
    case bigRightPlaylist = "Big right playlist"
    case verticalPlayerAndPlaylistStack = "Vertical player and playlist"
    case horizontalPlayerAndPlaylistStack = "Horizontal player and playlist"
    
    static var allValues: [WindowLayoutPresets] = [.verticalFullStack, .horizontalFullStack, .compactCornered, .bigBottomPlaylist, .bigLeftPlaylist, .bigRightPlaylist, .verticalPlayerAndPlaylistStack, .horizontalPlayerAndPlaylistStack]
    
    // Converts a user-friendly display name to an instance of PitchPresets
    static func fromDisplayName(_ displayName: String) -> WindowLayoutPresets {
        return WindowLayoutPresets(rawValue: displayName) ?? .verticalFullStack
    }
    
    var showPlaylist: Bool {
        return self != .compactCornered
    }
    
    var showEffects: Bool {
        
        switch self {
            
        case .compactCornered, .verticalPlayerAndPlaylistStack, .horizontalPlayerAndPlaylistStack:
            
            return false
            
        default:    return true
            
        }
    }
    
    var mainWindowOrigin: NSPoint {
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        switch self {
            
        // Top left corner
        case .compactCornered:
            
            x = visibleFrame.minX
            y = visibleFrame.maxY - mainWindow.height
            
        case .verticalFullStack:
            
            let xPadding = visibleFrame.width - mainWindow.width
            x = visibleFrame.minX + (xPadding / 2)
            y = visibleFrame.minY + (effectsWindow.height + playlistHeight)
            
        case .horizontalFullStack:
            
            let xPadding = visibleFrame.width - (mainWindow.width + effectsWindow.width + playlistWidth)
            
            // Sometimes, xPadding is negative, never go to the left of minX
            x = max(visibleFrame.minX + (xPadding / 2), visibleFrame.minX)
            
            let yPadding = visibleFrame.height - mainWindow.height
            y = visibleFrame.minY + (yPadding / 2)
            
        case .bigBottomPlaylist:
            
            let xPadding = visibleFrame.width - (mainWindow.width + effectsWindow.width)
            x = visibleFrame.minX + (xPadding / 2)
            
            let yPadding = visibleFrame.height - (mainWindow.height + playlistHeight)
            y = visibleFrame.minY + (yPadding / 2) + playlistHeight
            
        case .bigLeftPlaylist:
            
            let xPadding = visibleFrame.width - mainWindow.width - playlistWidth
            x = visibleFrame.minX + (xPadding / 2) + playlistWidth
            
            let yPadding = visibleFrame.height - (mainWindow.height + effectsWindow.height)
            y = visibleFrame.minY + (yPadding / 2) + effectsWindow.height
            
        case .bigRightPlaylist:
            
            let xPadding = visibleFrame.width - mainWindow.width - playlistWidth
            x = visibleFrame.minX + (xPadding / 2)
            
            let yPadding = visibleFrame.height - (mainWindow.height + effectsWindow.height)
            y = visibleFrame.minY + (yPadding / 2) + effectsWindow.height
            
        case .verticalPlayerAndPlaylistStack:
            
            let xPadding = visibleFrame.width - mainWindow.width
            x = visibleFrame.minX + (xPadding / 2)
            y = visibleFrame.height - mainWindow.height
            
        case .horizontalPlayerAndPlaylistStack:
            
            x = visibleFrame.minX
            
            let yPadding = visibleFrame.height - mainWindow.height
            y = visibleFrame.minY + (yPadding / 2)
        }
        
        return NSPoint(x: x, y: y)
    }
    
    var effectsWindowOrigin: NSPoint {
        
        let mwo = mainWindowOrigin
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        switch self {
            
        // Top left corner
        case .verticalFullStack:
            
            x = mwo.x
            y = mwo.y - effectsWindow.height
            
        case .horizontalFullStack:
            
            x = mwo.x + mainWindow.width
            y = mwo.y
            
        case .bigBottomPlaylist:
            
            x = mwo.x + mainWindow.width
            y = mwo.y
            
        case .bigLeftPlaylist:
            
            x = mwo.x
            y = mwo.y - effectsWindow.height
            
        case .bigRightPlaylist:
            
            x = mwo.x
            y = mwo.y - effectsWindow.height
            
        default:
            
            x = 0
            y = 0
        }
        
        return NSPoint(x: x, y: y)
    }
    
    var playlistHeight: CGFloat {
        
        switch self {
            
        case .verticalFullStack:    return visibleFrame.height - (mainWindow.height + effectsWindow.height)
            
        case .horizontalFullStack, .horizontalPlayerAndPlaylistStack:  return mainWindow.height
            
        case .bigLeftPlaylist, .bigRightPlaylist:   return mainWindow.height + effectsWindow.height
            
        case .verticalPlayerAndPlaylistStack:   return visibleFrame.height - mainWindow.height
            
        default:    return 500
            
        }
    }
    
    var playlistWidth: CGFloat {
        
        let minWidth = playlistWindow.minSize.width
        
        switch self {
            
        case .verticalFullStack, .verticalPlayerAndPlaylistStack:    return mainWindow.width
            
        case .horizontalFullStack:    return max(visibleFrame.width - (mainWindow.width + effectsWindow.width), minWidth)
            
        case .bigBottomPlaylist:    return mainWindow.width + effectsWindow.width
            
        case .bigLeftPlaylist, .bigRightPlaylist:   return 500
            
        case .horizontalPlayerAndPlaylistStack: return visibleFrame.width - mainWindow.width
            
        default:    return 500
            
        }
    }
    
    var playlistWindowOrigin: NSPoint {
        
        let mwo = mainWindowOrigin
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        switch self {
            
        case .verticalFullStack:
            
            x = mwo.x
            y = visibleFrame.minY
            
        case .horizontalFullStack:
            
            x = mwo.x + mainWindow.width + effectsWindow.width
            y = mwo.y
            
        case .bigBottomPlaylist:
            
            x = mwo.x
            y = mwo.y - playlistHeight
            
        case .bigLeftPlaylist:
            
            x = mwo.x - playlistWidth
            y = mwo.y - effectsWindow.height
            
        case .bigRightPlaylist:
            
            x = mwo.x + mainWindow.width
            y = mwo.y - effectsWindow.height
            
        case .verticalPlayerAndPlaylistStack:
            
            x = mwo.x
            y = visibleFrame.minY
            
        case .horizontalPlayerAndPlaylistStack:
            
            x = mwo.x + mainWindow.width
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
