import Cocoa

class ColorSchemes {
    
    static let defaultScheme: ColorScheme = ColorScheme("_default_", ColorSchemePreset.defaultScheme)
    static var systemScheme: ColorScheme = ColorScheme("_system_") {
        
        didSet {
            
            // Update slider gradient cache
            Colors.Player.updateSliderBackgroundColor()
            Colors.Player.updateSliderForegroundColor()
        }
    }
    
    static func initialize(_ schemesState: ColorSchemesState) {
        
        loadUserDefinedSchemes(schemesState.userSchemes.map {ColorScheme($0.name, $0, false)})
        systemScheme = ColorScheme("_system_", schemesState.systemScheme, true)
    }
    
    private static var userDefinedSchemesByName: [String: ColorScheme] = [:]
    
    static var userDefinedSchemes: [ColorScheme] {
        return userDefinedSchemesByName.values.filter({$0.systemDefined == false})
    }
    
    static var systemDefinedSchemes: [ColorScheme] {
        return userDefinedSchemesByName.values.filter({$0.systemDefined == true})
    }
    
    static func applyScheme(_ name: String) -> ColorScheme? {
        
        if let scheme = userDefinedSchemesByName[name] {
            
            systemScheme.applyScheme(scheme)
            
            // Update slider gradient cache
            Colors.Player.updateSliderBackgroundColor()
            Colors.Player.updateSliderForegroundColor()
            
            return systemScheme
            
        } else if let preset = ColorSchemePreset.presetByName(name) {
            
            systemScheme.applyPreset(preset)
            
            // Update slider gradient cache
            Colors.Player.updateSliderBackgroundColor()
            Colors.Player.updateSliderForegroundColor()
            
            return systemScheme
        }
        
        return nil
    }
    
    static func schemeByName(_ name: String, _ acceptDefault: Bool = true) -> ColorScheme? {
        return userDefinedSchemesByName[name] ?? (acceptDefault ? defaultScheme : nil)
    }
    
    static func deleteScheme(_ name: String) {
        
        // User cannot modify/delete system-defined schemes
        if let scheme = schemeByName(name), !scheme.systemDefined {
            userDefinedSchemesByName.removeValue(forKey: name)
        }
    }
    
    static func renameScheme(_ oldName: String, _ newName: String) {
        
        if let scheme = schemeByName(oldName, false) {
            
            userDefinedSchemesByName.removeValue(forKey: oldName)
            scheme.name = newName
            userDefinedSchemesByName[newName] = scheme
        }
    }
    
    static func loadUserDefinedSchemes(_ userDefinedSchemes: [ColorScheme]) {
        userDefinedSchemes.forEach({userDefinedSchemesByName[$0.name] = $0})
    }
    
    // Assume preset with this name doesn't already exist
    static func addUserDefinedScheme(_ scheme: ColorScheme) {
        userDefinedSchemesByName[scheme.name] = scheme
    }
    
    static func schemeWithNameExists(_ name: String) -> Bool {
        return userDefinedSchemesByName[name] != nil
    }
    
    static var persistentState: ColorSchemesState {
        return ColorSchemesState(ColorSchemeState(systemScheme.name, systemScheme), userDefinedSchemes.map {ColorSchemeState($0.name, $0)})
    }
}
