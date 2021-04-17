import Cocoa

/*
    Utility class that manages all themes, including user-defined schemes, system-defined presets, and the current system theme.
 */
class Themes {

    // Loads the user-defined schemes and current system theme from persistent state on app startup.
    static func initialize(_ themesState: ThemesState) {
        
        loadUserDefinedThemes(themesState.userThemes.map {Theme(name: $0.name, fontScheme: FontScheme($0.fontScheme, false), colorScheme: ColorScheme($0.colorScheme, false), windowAppearance: WindowAppearance(cornerRadius: CGFloat($0.windowAppearance.cornerRadius)))})
    }
    
    // Mapping of user-defined themes by display name.
    private static var userDefinedThemesByName: StringKeyedCollection<Theme> = StringKeyedCollection()
    
    // Array of all user-defined themes.
    static var userDefinedThemes: [Theme] {
        return userDefinedThemesByName.allItems
    }

    static var numberOfUserDefinedThemes: Int {
        return userDefinedThemesByName.count
    }
    
    // Applies a theme to the system theme and returns the modified system scheme.
    static func applyTheme(_ theme: Theme) {
        
        _ = FontSchemes.applyScheme(theme.fontScheme)
        _ = ColorSchemes.applyScheme(theme.colorScheme)
        
        WindowAppearanceState.cornerRadius = theme.windowAppearance.cornerRadius
        Messenger.publish(.windowAppearance_changeCornerRadius, payload: WindowAppearanceState.cornerRadius)
    }
    
    // Attempts to apply a theme to the system theme, looking up the scheme by the given display name, and if found, returns the modified system scheme.
    static func applyTheme(named name: String) -> Bool {
        
        if let preset = ThemePreset.presetByName(name) {

            _ = FontSchemes.applyScheme(preset.fontScheme)
            _ = ColorSchemes.applyScheme(preset.colorScheme)
            
            WindowAppearanceState.cornerRadius = preset.windowCornerRadius
            Messenger.publish(.windowAppearance_changeCornerRadius, payload: WindowAppearanceState.cornerRadius)
            
            return true

        } else if let theme = userDefinedThemesByName.itemWithKey(name) {
            
            applyTheme(theme)
            return true
        }
        
        return false
    }
    
    // Looks up a user-defined theme by name
    static func userDefinedThemeByName(_ name: String) -> Theme? {
        userDefinedThemesByName.itemWithKey(name)
    }
    
    // Deletes a theme by its name (must be a user-defined theme)
    static func deleteTheme(_ name: String) {
        
        // User cannot modify/delete system-defined schemes
        userDefinedThemesByName.removeItemWithKey(name)
    }
    
    // Renames a user-defined theme
    static func renameTheme(_ oldName: String, _ newName: String) {
        
        // Update the map with the new name
        userDefinedThemesByName.reMapForKey(oldName, newName)
    }
    
    // Maps the given user-defined themes by name
    static func loadUserDefinedThemes(_ userDefinedThemes: [Theme]) {
        
        userDefinedThemes.forEach {
            userDefinedThemesByName.addItem($0)
        }
    }
    
    // Adds a new user-defined theme. Assume a preset with this name doesn't already exist.
    static func addUserDefinedTheme(_ theme: Theme) {
        userDefinedThemesByName.addItem(theme)
    }

    // Checks whether or not a scheme (user-defined or system-defined) with the given name exists
    static func themeWithNameExists(_ name: String) -> Bool {
        return userDefinedThemesByName.itemWithKeyExists(name) || ThemePreset.presetByName(name) != nil
    }
    
    // State to be persisted to disk.
    static var persistentState: ThemesState {
        return ThemesState(userDefinedThemes.map {ThemeState($0)})
    }
}
