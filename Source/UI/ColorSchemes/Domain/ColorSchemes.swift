import Cocoa

/*
    Utility class that manages all color schemes, including user-defined schemes, system-defined presets, and the current system color scheme.
 */
class ColorSchemes {
    
    // Default color scheme (uses colors from the default system-defined preset)
    static let defaultScheme: ColorScheme = ColorScheme("_default_", ColorSchemePreset.defaultScheme)
    
    // The current system color scheme. It is initialized with the default scheme.
    static var systemScheme: ColorScheme = ColorScheme("_system_", ColorSchemePreset.defaultScheme) {
        
        didSet {
            
            // Update the player's seek slider gradient cache whenever the system scheme changes.
            Colors.Player.updateSliderColors()
            AuralPlaylistOutlineView.updateCachedImages()
        }
    }
    
    // Loads the user-defined schemes and current system color scheme from persistent state on app startup.
    static func initialize(_ schemesState: ColorSchemesState?) {
        
        (schemesState?.userSchemes ?? []).map {ColorScheme($0, false)}.forEach {
            userDefinedSchemesByName.addItem($0)
        }
        
        systemScheme = ColorScheme(schemesState?.systemScheme, true)
    }
    
    // Mapping of user-defined color schemes by display name.
    private static var userDefinedSchemesByName: StringKeyedCollection<ColorScheme> = StringKeyedCollection()
    
    // Array of all user-defined color schemes.
    static var userDefinedSchemes: [ColorScheme] {
        return userDefinedSchemesByName.allItems
    }

    static var numberOfUserDefinedSchemes: Int {
        return userDefinedSchemesByName.count
    }
    
    // Applies a color scheme to the system color scheme and returns the modified system scheme.
    static func applyScheme(_ scheme: ColorScheme) -> ColorScheme {
        
        systemScheme.applyScheme(scheme)
        
        // Update seek slider gradient cache
        Colors.Player.updateSliderColors()
        AuralPlaylistOutlineView.updateCachedImages()
        
        return systemScheme
    }
    
    // Attempts to apply a color scheme to the system color scheme, looking up the scheme by the given display name, and if found, returns the modified system scheme.
    static func applyScheme(_ name: String) -> ColorScheme? {
        
        if let preset = ColorSchemePreset.presetByName(name) {
            
            systemScheme.applyPreset(preset)
            
            // Update seek slider gradient cache
            Colors.Player.updateSliderColors()
            AuralPlaylistOutlineView.updateCachedImages()
            
            return systemScheme
            
        } else if let scheme = userDefinedSchemesByName.itemWithKey(name) {
            
            systemScheme.applyScheme(scheme)
            
            // Update seek slider gradient cache
            Colors.Player.updateSliderColors()
            AuralPlaylistOutlineView.updateCachedImages()
            
            return systemScheme
        }
        
        return nil
    }
    
    static func schemeByName(_ name: String) -> ColorScheme? {
        
        if let colorSchemePreset = ColorSchemePreset.presetByName(name) {
            return ColorScheme(name, colorSchemePreset)
        }
        
        return userDefinedSchemesByName.itemWithKey(name)
    }
    
    // Looks up a user-defined color scheme by name, returning the default scheme if not found and if so specified by the 2nd parameter.
    static func userDefinedSchemeByName(_ name: String, _ acceptDefault: Bool = true) -> ColorScheme? {
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
    
    // Adds a new user-defined color scheme. Assume a preset with this name doesn't already exist.
    static func addUserDefinedScheme(_ scheme: ColorScheme) {
        userDefinedSchemesByName.addItem(scheme)
    }
    
    // Checks whether or not a scheme (user-defined or system-defined) with the given name exists
    static func schemeWithNameExists(_ name: String) -> Bool {
        return userDefinedSchemesByName.itemWithKeyExists(name) || ColorSchemePreset.presetByName(name) != nil
    }
    
    // State to be persisted to disk.
    static var persistentState: ColorSchemesState {
        return ColorSchemesState(ColorSchemeState(systemScheme), userDefinedSchemes.map {ColorSchemeState($0)})
    }
}
