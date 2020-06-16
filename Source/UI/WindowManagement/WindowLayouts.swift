import Cocoa

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
            WindowLayoutPresets.recompute(lt)
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
        systemDefinedLayouts.forEach({WindowLayoutPresets.recompute($0)})
    }

    // Assume preset with this name doesn't already exist
    static func addUserDefinedLayout(_ name: String, _ layout: WindowLayout) {
        
        layout.name = name
        layouts[name] = layout
    }

    static func layoutWithNameExists(_ name: String) -> Bool {
        return layouts[name] != nil
    }
}
