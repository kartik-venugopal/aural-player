import Cocoa

class LayoutManager {
    
    private let appState: UIState
    private let preferences: ViewPreferences
    
    // App windows
    let mainWindow: NSWindow = WindowFactory.getMainWindow()
    let effectsWindow: NSWindow = WindowFactory.getEffectsWindow()
    let playlistWindow: NSWindow = WindowFactory.getPlaylistWindow()
    
    init(_ appState: UIState, _ preferences: ViewPreferences) {
        
        // Use appState and prefs to determine initial layout
        self.appState = appState
        self.preferences = preferences
    }
    
    func initialLayout() {
        
        if preferences.layoutOnStartup.option == .specific {
            
            layout(preferences.layoutOnStartup.layoutName)
            
        } else {
            
            // Remember from last app launch
            mainWindow.setFrameOrigin(appState.mainWindowOrigin)
            
            if appState.showEffects {
                
                mainWindow.addChildWindow(effectsWindow, ordered: NSWindowOrderingMode.below)
                effectsWindow.setFrameOrigin(appState.effectsWindowOrigin!)
            }
            
            if appState.showPlaylist {
                
                mainWindow.addChildWindow(playlistWindow, ordered: NSWindowOrderingMode.below)
                playlistWindow.setFrame(appState.playlistWindowFrame!, display: true)
            }
            
            mainWindow.setIsVisible(true)
            effectsWindow.setIsVisible(appState.showEffects)
            playlistWindow.setIsVisible(appState.showPlaylist)
        }
    }
    
    func layout(_ layout: WindowLayout) {
        
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
        
        mainWindow.setIsVisible(true)
        effectsWindow.setIsVisible(layout.showEffects)
        playlistWindow.setIsVisible(layout.showPlaylist)
    }
    
    func layout(_ name: String) {
        layout(WindowLayouts.layoutByName(name))
    }
    
    func persistentState() -> UIState {
        
        let uiState = UIState()
        
        uiState.showEffects = effectsWindow.isVisible
        uiState.showPlaylist = playlistWindow.isVisible
        
        uiState.mainWindowOrigin = mainWindow.origin
        
        if uiState.showEffects {
            uiState.effectsWindowOrigin = effectsWindow.origin
        }
        
        if uiState.showPlaylist {
            uiState.playlistWindowFrame = playlistWindow.frame
        }
        
        uiState.userWindowLayouts = WindowLayouts.userDefinedLayouts
        
        return uiState
    }   
}
