import Cocoa

class FontSchemes {
    
    // Default color scheme (uses colors from the default system-defined preset)
    static let defaultScheme: FontScheme = FontScheme("_default_", FontSchemePreset.standard)
    
    // The current system color scheme. It is initialized with the default scheme.
    static var systemScheme: FontScheme = FontScheme("_system_", FontSchemePreset.standard)
    
    static func initialize(_ appState: FontSchemesState) {
        
        loadUserDefinedSchemes(appState.userSchemes.map {FontScheme($0, false)})
        systemScheme = FontScheme(appState.systemScheme, true)
    }
    
    static func applyScheme(named name: String) -> FontScheme? {
        
        if let fontSchemePreset = FontSchemePreset.presetByName(name) {
            
            systemScheme = FontScheme("_system_", fontSchemePreset)
            return systemScheme
            
        } else if let scheme = userDefinedSchemesByName.itemWithKey(name) {
            
            systemScheme = FontScheme("_system_", true, scheme)
            return systemScheme
        }
        
        return nil
    }
    
    static func schemeByName(_ name: String) -> FontScheme? {
        
        if let fontSchemePreset = FontSchemePreset.presetByName(name) {
            return FontScheme(name, fontSchemePreset)
        }
        
        return userDefinedSchemesByName.itemWithKey(name)
    }
    
    static func applyScheme(_ fontScheme: FontScheme) -> FontScheme {

        systemScheme = FontScheme("_system_", true, fontScheme)
        return systemScheme
    }
    
    // Mapping of user-defined color schemes by display name.
    private static var userDefinedSchemesByName: StringKeyedCollection<FontScheme> = StringKeyedCollection()
    
    // Array of all user-defined color schemes.
    static var userDefinedSchemes: [FontScheme] {
        return userDefinedSchemesByName.allItems
    }

    static var numberOfUserDefinedSchemes: Int {
        return userDefinedSchemesByName.count
    }
    
    // Looks up a user-defined color scheme by name, returning the default scheme if not found and if so specified by the 2nd parameter.
    static func userDefinedSchemeByName(_ name: String, _ acceptDefault: Bool = true) -> FontScheme? {
        return userDefinedSchemesByName.itemWithKey(name) ?? (acceptDefault ? defaultScheme : nil)
    }
    
    // Deletes a color scheme by its name (must be a user-defined scheme)
    static func deleteScheme(_ name: String) {
        
        // User cannot modify/delete system-defined schemes
        userDefinedSchemesByName.removeItemWithKey(name)
    }
    
    // Renames a user-defined color scheme
    static func renameScheme(_ oldName: String, _ newName: String) {
        
        // Update the map with the new name
        userDefinedSchemesByName.reMapForKey(oldName, newName)
    }
    
    // Maps the given user-defined color schemes by name
    static func loadUserDefinedSchemes(_ userDefinedSchemes: [FontScheme]) {
        
        // TODO: What if the scheme's name is empty ? Should we assign a default name ?
        
        userDefinedSchemes.forEach {
            userDefinedSchemesByName.addItem($0)
        }
    }
    
    // Adds a new user-defined color scheme. Assume a preset with this name doesn't already exist.
    static func addUserDefinedScheme(_ scheme: FontScheme) {
        userDefinedSchemesByName.addItem(scheme)
    }
    
    // Checks whether or not a scheme (user-defined or system-defined) with the given name exists
    static func schemeWithNameExists(_ name: String) -> Bool {
        return userDefinedSchemesByName.itemWithKeyExists(name) || FontSchemePreset.presetByName(name) != nil
    }
    
    // State to be persisted to disk.
    static var persistentState: FontSchemesState {
        return FontSchemesState(FontSchemeState(systemScheme), userDefinedSchemes.map {FontSchemeState($0)})
    }
}
