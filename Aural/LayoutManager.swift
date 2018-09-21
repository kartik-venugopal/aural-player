import Cocoa

class LayoutManager: NSObject {
    
    static let mainWindow: NSWindow = WindowFactory.getMainWindow()
    
    static let effectsWindow: NSWindow = WindowFactory.getEffectsWindow()
    
    static let playlistWindow: NSWindow = WindowFactory.getPlaylistWindow()
    
    static func layout(_ preset: WindowLayoutPresets) {
        
        effectsWindow.setIsVisible(preset.showEffects)
        playlistWindow.setIsVisible(preset.showPlaylist)
        
        mainWindow.setFrameOrigin(preset.mainWindowOrigin)
        effectsWindow.setFrameOrigin(preset.effectsWindowOrigin)
        playlistWindow.setFrame(preset.playlistWindowFrame, display: preset.showPlaylist)
    }
}
