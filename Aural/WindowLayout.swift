import Cocoa

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
