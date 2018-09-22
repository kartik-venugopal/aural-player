import Cocoa

class LayoutManager: NSObject {
    
    static let mainWindow: NSWindow = WindowFactory.getMainWindow()
    
    static let effectsWindow: NSWindow = WindowFactory.getEffectsWindow()
    
    static let playlistWindow: NSWindow = WindowFactory.getPlaylistWindow()
    
    static func layout(_ name: String) {
        
        let layout = WindowLayouts.layoutByName(name)
        
        // TODO: buttons and menu items need to be updated ("toggle fx/playlist")
        mainWindow.setFrameOrigin(layout.mainWindowOrigin)
        
        if layout.showEffects {
            
            mainWindow.addChildWindow(effectsWindow, ordered: NSWindowOrderingMode.below)
            effectsWindow.setFrameOrigin(layout.effectsWindowOrigin!)
        }
        
        if layout.showPlaylist {
            
            mainWindow.addChildWindow(playlistWindow, ordered: NSWindowOrderingMode.below)
            playlistWindow.setFrame(layout.playlistWindowFrame!, display: true)
        }
        
        effectsWindow.setIsVisible(layout.showEffects)
        playlistWindow.setIsVisible(layout.showPlaylist)
    }
}
