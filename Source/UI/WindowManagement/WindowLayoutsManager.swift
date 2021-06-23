import Cocoa

class WindowLayoutsManager: MappedPresets<WindowLayout> {
    
    init(persistentState: WindowLayoutsPersistentState?) {
        
        let systemDefinedLayouts = WindowLayoutPresets.allCases.map {
            
            // TODO: each variable is computed multiple times ... make this more efficient
            return WindowLayout($0.name, $0.showEffects, $0.showPlaylist, $0.mainWindowOrigin, $0.effectsWindowOrigin, $0.playlistWindowFrame, true)
        }
        
        let userDefinedLayouts: [WindowLayout] = (persistentState?.userLayouts ?? []).map {
            WindowLayout($0.name, $0.showEffects, $0.showPlaylist, $0.mainWindowOrigin, $0.effectsWindowOrigin, $0.playlistWindowFrame, false)
        }
        
        super.init(systemDefinedPresets: systemDefinedLayouts, userDefinedPresets: userDefinedLayouts)
    }
    
    var defaultLayout: WindowLayout {
        systemDefinedPreset(named: WindowLayoutPresets.verticalFullStack.name)!
    }
    
    func recomputeSystemDefinedLayouts() {
        systemDefinedPresets.forEach {WindowLayoutPresets.recompute($0)}
    }
}
