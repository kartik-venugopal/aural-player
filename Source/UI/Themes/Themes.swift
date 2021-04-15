//import Cocoa
//
///*
//    Utility class that manages all themes, including user-defined schemes, system-defined presets, and the current system theme.
// */
//class Themes {
//
//    // Loads the user-defined schemes and current system theme from persistent state on app startup.
////    static func initialize(_ themesState: ThemesState) {
////        loadUserDefinedSchemes(themesState.userSchemes.map {Theme($0, false)})
////    }
//    
//    // Mapping of user-defined themes by display name.
//    private static var userDefinedThemesByName: StringKeyedCollection<Theme> = StringKeyedCollection()
//    
//    // Array of all user-defined themes.
//    static var userDefinedTheme: [Theme] {
//        return userDefinedThemesByName.allItems
//    }
//
//    static var numberOfUserDefinedSchemes: Int {
//        return userDefinedThemesByName.count
//    }
//    
//    // Applies a theme to the system theme and returns the modified system scheme.
//    static func applyTheme(_ theme: Theme) {
//        
//        _ = FontSchemes.applyScheme(theme.fontScheme)
//        _ = ColorSchemes.applyScheme(theme.colorScheme)
//    }
//    
//    // Attempts to apply a theme to the system theme, looking up the scheme by the given display name, and if found, returns the modified system scheme.
//    static func applyTheme(_ name: String) {
//        
////        if let preset = ThemePreset.presetByName(name) {
////Ô
////            // Update seek slider gradient cache
////            Colors.Player.updateSliderColors()
////            AuralPlaylistOutlineView.updateCachedImages()
////
////        } else if let theme = userDefinedThemesByName.itemWithKey(name) {
////
////            // Update seek slider gradient cache
////            Colors.Player.updateSliderColors()
////            AuralPlaylistOutlineView.updateCachedImages()
////        }
//    }
//    
//    // Looks up a user-defined theme by name
//    static func userDefinedThemeByName(_ name: String) -> Theme? {
//        userDefinedThemesByName.itemWithKey(name)
//    }
//    
//    // Deletes a theme by its name (must be a user-defined theme)
//    static func deleteTheme(_ name: String) {
//        
//        // User cannot modify/delete system-defined schemes
//        userDefinedThemesByName.removeItemWithKey(name)
//    }
//    
//    // Renames a user-defined theme
//    static func renameTheme(_ oldName: String, _ newName: String) {
//        
//        // Update the map with the new name
//        userDefinedThemesByName.reMapForKey(oldName, newName)
//    }
//    
//    // Maps the given user-defined themes by name
//    static func loadUserDefinedThemes(_ userDefinedThemes: [Theme]) {
//        
//        // TODO: What if the scheme's name is empty ? Should we assign a default name ?
//        
//        userDefinedThemes.forEach {
//            userDefinedThemesByName.addItem($0)
//        }
//    }
//    
//    // Adds a new user-defined theme. Assume a preset with this name doesn't already exist.
////    static func addUserDefinedScheme(_ scheme: ColorScheme) {
////        userDefinedThemesByName.addItem(scheme)
////    }
////
////    // Checks whether or not a scheme (user-defined or system-defined) with the given name exists
////    static func schemeWithNameExists(_ name: String) -> Bool {
////        return userDefinedThemesByName.itemWithKeyExists(name) || ThemePreset.presetByName(name) != nil
////    }
//    
//    // State to be persisted to disk.
////    static var persistentState: ColorSchemesState {
////        return ThemesState(ColorSchemeState(systemScheme), userDefinedThemesByName.map {ThemeState($0)})
////    }
//}
