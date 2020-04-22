import Cocoa

class ColorSchemes {
    
    static let defaultScheme: ColorScheme = ColorScheme("_default_", ColorSchemePreset.defaultScheme)
    static var systemScheme: ColorScheme = ColorScheme("_system_")
    
    static func initialize(_ schemesState: ColorSchemesState) {
//        loadUserDefinedSchemes(schemesState.userSchemes.map {ColorScheme()})
    }
    
    private static var schemes: [String: ColorScheme] = {
        
        var map = [String: ColorScheme]()
        
        ColorSchemePreset.allCases.forEach({
            
            let presetName = $0.description
            map[presetName] = ColorScheme(presetName, $0)
        })
        
        return map
    }()
    
    static var userDefinedSchemes: [ColorScheme] {
        return schemes.values.filter({$0.systemDefined == false})
    }
    
    static var systemDefinedSchemes: [ColorScheme] {
        return schemes.values.filter({$0.systemDefined == true})
    }
    
    static func schemeByName(_ name: String, _ acceptDefault: Bool = true) -> ColorScheme? {
        return schemes[name] ?? (acceptDefault ? defaultScheme : nil)
    }
    
    static func deleteScheme(_ name: String) {
        
        // User cannot modify/delete system-defined schemes
        if let scheme = schemeByName(name), !scheme.systemDefined {
            schemes.removeValue(forKey: name)
        }
    }
    
    static func renameScheme(_ oldName: String, _ newName: String) {
        
        if let scheme = schemeByName(oldName, false) {
            
            schemes.removeValue(forKey: oldName)
            scheme.name = newName
            schemes[newName] = scheme
        }
    }
    
    static func loadUserDefinedSchemes(_ userDefinedSchemes: [ColorScheme]) {
        userDefinedSchemes.forEach({schemes[$0.name] = $0})
    }
    
    // Assume preset with this name doesn't already exist
    static func addUserDefinedScheme(_ scheme: ColorScheme) {
        schemes[scheme.name] = scheme
    }
    
    static func schemeWithNameExists(_ name: String) -> Bool {
        return schemes[name] != nil
    }
    
    static var persistentState: ColorSchemesState {
        return ColorSchemesState(ColorSchemeState(systemScheme), [])
    }
}
