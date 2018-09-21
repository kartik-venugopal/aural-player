import Cocoa

fileprivate var visibleFrame: NSRect = {
    return NSScreen.main()!.visibleFrame
}()

fileprivate let mainWindow: NSWindow = WindowFactory.getMainWindow()

fileprivate let effectsWindow: NSWindow = WindowFactory.getEffectsWindow()

fileprivate let playlistWindow: NSWindow = WindowFactory.getPlaylistWindow()

struct CustomWindowLayout {
    
    let name: String
    let showPlaylist: Bool
    let showEffects: Bool
    
    let mainWindowOrigin: NSPoint
    let effectsWindowOrigin: NSPoint?
    let playlistWindowFrame: NSRect?
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
            
            let yPadding = visibleFrame.height - (mainWindow.height + effectsWindow.height + playlistHeight)
            y = visibleFrame.minY + (yPadding / 2) + (effectsWindow.height + playlistHeight)
            
        case .horizontalFullStack:
            
            let xPadding = visibleFrame.width - (mainWindow.width + effectsWindow.width + playlistWidth)
            x = visibleFrame.minX + (xPadding / 2)
            
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
            
        default:
            
            x = 0
            y = 0
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
            
        case .horizontalFullStack:  return mainWindow.height
            
        case .bigLeftPlaylist, .bigRightPlaylist:   return mainWindow.height + effectsWindow.height
            
        default:    return 500
            
        }
    }
    
    var playlistWidth: CGFloat {
        
        switch self {
            
        case .verticalFullStack:    return mainWindow.width
            
        case .horizontalFullStack:    return visibleFrame.width - (mainWindow.width + effectsWindow.width)
            
        case .bigBottomPlaylist:    return mainWindow.width + effectsWindow.width
            
        case .bigLeftPlaylist, .bigRightPlaylist:   return 500
            
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
            y = mwo.y - effectsWindow.height - playlistHeight
            
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
