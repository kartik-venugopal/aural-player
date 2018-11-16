import Cocoa

fileprivate var visibleFrame: NSRect = {
    return NSScreen.main!.visibleFrame
}()

fileprivate let mainWindow: NSWindow = WindowFactory.getMainWindow()
fileprivate let effectsWindow: NSWindow = WindowFactory.getEffectsWindow()
fileprivate let playlistWindow: NSWindow = WindowFactory.getPlaylistWindow()

class WindowLayouts {
    
    private static var layouts: [String: WindowLayout] = {
        
        var map = [String: WindowLayout]()
        
        WindowLayoutPresets.allValues.forEach({
            
            let presetName = $0.description
            
            map[presetName] = WindowLayout(presetName, $0.showEffects, $0.showPlaylist, $0.mainWindowOrigin, $0.effectsWindowOrigin, $0.playlistWindowFrame, true)
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
        return layoutByName(WindowLayoutPresets.verticalFullStack.rawValue)!
    }
    
    static func layoutByName(_ name: String, _ acceptDefault: Bool = true) -> WindowLayout? {
        return layouts[name] ?? (acceptDefault ? defaultLayout : nil)
    }
    
    static func deleteLayout(_ name: String) {
        
        if let layout = layoutByName(name) {
            
            // User cannot modify/delete system-defined layouts
            if !layout.systemDefined {
                layouts.removeValue(forKey: name)
            }
        }
    }
    
    static func renameLayout(_ oldName: String, _ newName: String) {
        
        if let layout = layoutByName(oldName, false) {
            
            layouts.removeValue(forKey: oldName)
            layout.name = newName
            layouts[newName] = layout
        }
    }
    
    static func loadUserDefinedLayouts(_ userDefinedLayouts: [WindowLayout]) {
        userDefinedLayouts.forEach({layouts[$0.name] = $0})
    }
    
    static func recomputeSystemDefinedLayouts() {
        systemDefinedLayouts.forEach({$0.recompute()})
    }

    // Assume preset with this name doesn't already exist
    static func addUserDefinedLayout(_ name: String) {
        
        let showEffects = effectsWindow.isVisible
        let showPlaylist = playlistWindow.isVisible
        
        let mainWindowOrigin = mainWindow.origin
        let effectsWindowOrigin = showEffects ? effectsWindow.origin : nil
        let playlistWindowFrame = showPlaylist ? playlistWindow.frame: nil
        
        layouts[name] = WindowLayout(name, showEffects, showPlaylist, mainWindowOrigin, effectsWindowOrigin, playlistWindowFrame, false)
    }

    static func layoutWithNameExists(_ name: String) -> Bool {
        return layouts[name] != nil
    }
}

class WindowLayout {
    
    var name: String
    let showEffects: Bool
    let showPlaylist: Bool
    
    var mainWindowOrigin: NSPoint
    var effectsWindowOrigin: NSPoint?
    var playlistWindowFrame: NSRect?
    
    let systemDefined: Bool
    
    init(_ name: String, _ showEffects: Bool, _ showPlaylist: Bool, _ mainWindowOrigin: NSPoint, _ effectsWindowOrigin: NSPoint?, _ playlistWindowFrame: NSRect?, _ systemDefined: Bool) {
        
        self.name = name
        self.showEffects = showEffects
        self.showPlaylist = showPlaylist
        self.mainWindowOrigin = mainWindowOrigin
        self.effectsWindowOrigin = effectsWindowOrigin
        self.playlistWindowFrame = playlistWindowFrame
        self.systemDefined = systemDefined
    }
    
    // Recomputes the layout (useful when the window gap preference changes)
    func recompute() {
        
        let preset = WindowLayoutPresets.fromDisplayName(self.name)
        
        self.mainWindowOrigin = preset.mainWindowOrigin
        self.effectsWindowOrigin = preset.effectsWindowOrigin
        self.playlistWindowFrame = preset.playlistWindowFrame
    }
}

enum WindowLayoutPresets: String {
    
    case verticalFullStack
    case horizontalFullStack
    case compactCornered
    case bigBottomPlaylist
    case bigLeftPlaylist
    case bigRightPlaylist
    case verticalPlayerAndPlaylistStack
    case horizontalPlayerAndPlaylistStack
    
    static var allValues: [WindowLayoutPresets] = [.verticalFullStack, .horizontalFullStack, .compactCornered, .bigBottomPlaylist, .bigLeftPlaylist, .bigRightPlaylist, .verticalPlayerAndPlaylistStack, .horizontalPlayerAndPlaylistStack]
    
    // Converts a user-friendly display name to an instance of PitchPresets
    static func fromDisplayName(_ displayName: String) -> WindowLayoutPresets {
        return WindowLayoutPresets(rawValue: displayName) ?? .verticalFullStack
    }
    
    var description: String {
        
        switch self {
            
        case .verticalFullStack: return "Vertical full stack"
        case .horizontalFullStack: return "Horizontal full stack"
        case .compactCornered: return "Compact cornered"
        case .bigBottomPlaylist: return "Big bottom playlist"
        case .bigLeftPlaylist: return "Big left playlist"
        case .bigRightPlaylist: return "Big right playlist"
        case .verticalPlayerAndPlaylistStack: return "Vertical player and playlist"
        case .horizontalPlayerAndPlaylistStack: return "Horizontal player and playlist"
            
        }
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
    
    private func gapBetweenWindows() -> CGFloat {
        
        return CGFloat(ObjectGraph.preferencesDelegate.getPreferences().viewPreferences.windowGap)
    }
    
    var mainWindowOrigin: NSPoint {
        
        let gap = gapBetweenWindows()
        let twoGaps = 2 * gap
        
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
            y = visibleFrame.maxY - mainWindow.height
            
        case .horizontalFullStack:
            
            let xPadding = visibleFrame.width - (mainWindow.width + effectsWindow.width + playlistWidth + twoGaps)
            
            // Sometimes, xPadding is negative, never go to the left of minX
            x = max(visibleFrame.minX + (xPadding / 2), visibleFrame.minX)
            
            let yPadding = visibleFrame.height - mainWindow.height
            y = visibleFrame.minY + (yPadding / 2)
            
        case .bigBottomPlaylist:
            
            let xPadding = visibleFrame.width - (mainWindow.width + gap + effectsWindow.width)
            x = visibleFrame.minX + (xPadding / 2)
            
            let pHeight = playlistHeight
            let yPadding = visibleFrame.height - (mainWindow.height + gap + pHeight)
            y = visibleFrame.minY + (yPadding / 2) + pHeight + gap
            
        case .bigLeftPlaylist:
            
            let pWidth = playlistWidth
            let xPadding = visibleFrame.width - (mainWindow.width + gap + pWidth)
            x = visibleFrame.minX + (xPadding / 2) + pWidth + gap
            
            let yPadding = visibleFrame.height - (mainWindow.height + gap + effectsWindow.height)
            y = visibleFrame.minY + (yPadding / 2) + effectsWindow.height + gap
            
        case .bigRightPlaylist:
            
            let xPadding = visibleFrame.width - (mainWindow.width + gap + playlistWidth)
            x = visibleFrame.minX + (xPadding / 2)
            
            let yPadding = visibleFrame.height - (mainWindow.height + gap + effectsWindow.height)
            y = visibleFrame.minY + (yPadding / 2) + effectsWindow.height + gap
            
        case .verticalPlayerAndPlaylistStack:
            
            let xPadding = visibleFrame.width - mainWindow.width
            x = visibleFrame.minX + (xPadding / 2)
            y = visibleFrame.maxY - mainWindow.height
            
        case .horizontalPlayerAndPlaylistStack:
            
            x = visibleFrame.minX
            
            let yPadding = visibleFrame.height - mainWindow.height
            y = visibleFrame.minY + (yPadding / 2)
        }
        
        return NSPoint(x: x, y: y)
    }
    
    var effectsWindowOrigin: NSPoint {
        
        let gap = gapBetweenWindows()
        
        let mwo = mainWindowOrigin
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        switch self {
            
        case .verticalFullStack:
            
            x = mwo.x
            y = mwo.y - gap - effectsWindow.height
            
        case .horizontalFullStack:
            
            x = mwo.x + mainWindow.width + gap
            y = mwo.y
            
        case .bigBottomPlaylist:
            
            x = mwo.x + mainWindow.width + gap
            y = mwo.y
            
        case .bigLeftPlaylist:
            
            x = mwo.x
            y = mwo.y - gap - effectsWindow.height
            
        case .bigRightPlaylist:
            
            x = mwo.x
            y = mwo.y - gap - effectsWindow.height
            
        default:
            
            x = 0
            y = 0
        }
        
        return NSPoint(x: x, y: y)
    }
    
    var playlistHeight: CGFloat {
        
        let gap = gapBetweenWindows()
        let twoGaps = 2 * gap
        
        switch self {
            
        case .verticalFullStack:    return visibleFrame.height - (mainWindow.height + effectsWindow.height + twoGaps)
            
        case .horizontalFullStack, .horizontalPlayerAndPlaylistStack:  return mainWindow.height
            
        case .bigLeftPlaylist, .bigRightPlaylist:   return mainWindow.height + gap + effectsWindow.height
            
        case .verticalPlayerAndPlaylistStack:   return visibleFrame.height - (mainWindow.height + gap)
            
        default:    return 500
            
        }
    }
    
    var playlistWidth: CGFloat {
        
        let gap = gapBetweenWindows()
        let twoGaps = 2 * gap
        let minWidth = playlistWindow.minSize.width
        
        switch self {
            
        case .verticalFullStack, .verticalPlayerAndPlaylistStack:    return mainWindow.width
            
        case .horizontalFullStack:    return max(visibleFrame.width - (mainWindow.width + effectsWindow.width + twoGaps), minWidth)
            
        case .bigBottomPlaylist:    return mainWindow.width + gap + effectsWindow.width
            
        case .bigLeftPlaylist, .bigRightPlaylist:   return mainWindow.width
            
        case .horizontalPlayerAndPlaylistStack: return visibleFrame.width - (mainWindow.width + gap)
            
        default:    return 500
            
        }
    }
    
    var playlistWindowOrigin: NSPoint {
        
        let gap = gapBetweenWindows()
        let twoGaps = 2 * gap
        let mwo = mainWindowOrigin
        
        var x: CGFloat = 0
        var y: CGFloat = 0
        
        switch self {
            
        case .verticalFullStack:
            
            x = mwo.x
            y = visibleFrame.minY
            
        case .horizontalFullStack:
            
            x = mwo.x + mainWindow.width + effectsWindow.width + twoGaps
            y = mwo.y
            
        case .bigBottomPlaylist:
            
            x = mwo.x
            y = mwo.y - gap - playlistHeight
            
        case .bigLeftPlaylist:
            
            x = mwo.x - gap - playlistWidth
            y = mwo.y - gap - effectsWindow.height
            
        case .bigRightPlaylist:
            
            x = mwo.x + mainWindow.width + gap
            y = mwo.y - gap - effectsWindow.height
            
        case .verticalPlayerAndPlaylistStack:
            
            x = mwo.x
            y = visibleFrame.minY
            
        case .horizontalPlayerAndPlaylistStack:
            
            x = mwo.x + mainWindow.width + gap
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
