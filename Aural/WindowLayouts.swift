import Cocoa

fileprivate var screenVisibleFrame: NSRect {
    return NSScreen.main!.visibleFrame
}

class WindowLayouts {
    
    private static var layouts: [String: WindowLayout] = {
        
        var map = [String: WindowLayout]()
        
        WindowLayoutPresets.allCases.forEach({
            
            let presetName = $0.description
            
            // TODO: each variable is computed multiple times ... make this more efficient
            map[presetName] = WindowLayout(presetName, $0.showEffects, $0.showPlaylist, $0.mainWindowOrigin, $0.effectsWindowOrigin, $0.playlistWindowFrame, true)
        })
        
        return map
    }()
    
    private static var windowManager: WindowManagerProtocol = ObjectGraph.windowManager
    
    static var userDefinedLayouts: [WindowLayout] {
        return layouts.values.filter({$0.systemDefined == false})
    }
    
    static var systemDefinedLayouts: [WindowLayout] {
        return layouts.values.filter({$0.systemDefined == true})
    }
    
    static var defaultLayout: WindowLayout {
        return layoutByName(WindowLayoutPresets.verticalFullStack.description)!
    }
    
    static func layoutByName(_ name: String, _ acceptDefault: Bool = true) -> WindowLayout? {
        
        let layout = layouts[name] ?? (acceptDefault ? defaultLayout : nil)
        
        if let lt = layout, lt.systemDefined {
            lt.recompute()
        }
        
        return layout
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
        
        let showEffects = windowManager.isShowingEffects
        let showPlaylist = windowManager.isShowingPlaylist
        
        let mainWindowOrigin = windowManager.mainWindowFrame.origin
        let effectsWindowOrigin = showEffects ? windowManager.effectsWindowFrame.origin : nil
        let playlistWindowFrame = showPlaylist ? windowManager.playlistWindowFrame : nil
        
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

enum WindowLayoutPresets: String, CaseIterable {
    
    case verticalFullStack
    case horizontalFullStack
    case compactCornered
    case bigBottomPlaylist
    case bigLeftPlaylist
    case bigRightPlaylist
    case verticalPlayerAndPlaylist
    case horizontalPlayerAndPlaylist
    
    // Converts a user-friendly display name to an instance of PitchPresets
    static func fromDisplayName(_ displayName: String) -> WindowLayoutPresets {
        return WindowLayoutPresets(rawValue: StringUtils.camelCase(displayName)) ?? .verticalFullStack
    }
    
    // TODO: Write a generic split camel case function to convert rawValue to description
    var description: String {
        
        switch self {
            
        case .verticalFullStack: return "Vertical full stack"
        case .horizontalFullStack: return "Horizontal full stack"
        case .compactCornered: return "Compact cornered"
        case .bigBottomPlaylist: return "Big bottom playlist"
        case .bigLeftPlaylist: return "Big left playlist"
        case .bigRightPlaylist: return "Big right playlist"
        case .verticalPlayerAndPlaylist: return "Vertical player and playlist"
        case .horizontalPlayerAndPlaylist: return "Horizontal player and playlist"
            
        }
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
        
        return CGFloat(ObjectGraph.preferencesDelegate.preferences.viewPreferences.windowGap)
    }
    
    var mainWindowOrigin: NSPoint {
        
//        if self == .verticalFullStack {
//            print("MainWindowOrigin")
//        }
        
        let mainWindowWidth: CGFloat = Dimensions.mainWindowWidth
        let mainWindowHeight: CGFloat = Dimensions.mainWindowHeight
        
        let effectsWindowWidth: CGFloat = Dimensions.effectsWindowWidth
        let effectsWindowHeight: CGFloat = Dimensions.effectsWindowHeight
        
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
            y = visibleFrame.maxY - mainWindowHeight
            
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
        
//        if self == .verticalFullStack {
//            print("EffectsWindowOrigin")
//        }
        
        let mainWindowWidth: CGFloat = Dimensions.mainWindowWidth
        let effectsWindowHeight: CGFloat = Dimensions.effectsWindowHeight
        
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
        
//        if self == .verticalFullStack {
//            print("PlaylistHeight")
//        }
        
        let mainWindowHeight: CGFloat = Dimensions.mainWindowHeight
        let effectsWindowHeight: CGFloat = Dimensions.effectsWindowHeight
        
        let gap = gapBetweenWindows
        let twoGaps = 2 * gap
        
        // Compute this only once
        let visibleFrame = screenVisibleFrame
        
        switch self {
            
        case .verticalFullStack:    return visibleFrame.height - (mainWindowHeight + effectsWindowHeight + twoGaps)
            
        case .horizontalFullStack, .horizontalPlayerAndPlaylist:  return mainWindowHeight
            
        case .bigLeftPlaylist, .bigRightPlaylist:   return mainWindowHeight + gap + effectsWindowHeight
            
        case .verticalPlayerAndPlaylist:   return visibleFrame.height - (mainWindowHeight + gap)
            
        default:    return 500
            
        }
    }
    
    var playlistWidth: CGFloat {
        
//        if self == .verticalFullStack {
//            print("PlaylistWidth")
//        }
        
        let mainWindowWidth: CGFloat = Dimensions.mainWindowWidth
        let effectsWindowWidth: CGFloat = Dimensions.effectsWindowWidth
        
        let gap = gapBetweenWindows
        let twoGaps = 2 * gap
        let minWidth = Dimensions.minPlaylistWidth
        
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
        
//        if self == .verticalFullStack {
//            print("PlaylistWindowOrigin")
//        }
        
        let mainWindowWidth: CGFloat = Dimensions.mainWindowWidth
        let effectsWindowWidth: CGFloat = Dimensions.effectsWindowWidth
        let effectsWindowHeight: CGFloat = Dimensions.effectsWindowHeight
        
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
            y = visibleFrame.minY
            
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
        
//        if self == .verticalFullStack {
//            print("PlaylistWindowFrame")
//        }
        
        let origin = playlistWindowOrigin
        return NSRect(x: origin.x, y: origin.y, width: playlistWidth, height: playlistHeight)
    }
}
