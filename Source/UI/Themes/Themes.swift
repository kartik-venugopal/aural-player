import Cocoa

/*
    Utility class that manages all themes, including user-defined schemes, system-defined presets, and the current system theme.
 */
class Themes: MappedPresets<Theme> {
    
    init(persistentState: ThemesPersistentState?) {
        
        let systemDefinedThemes = ThemePreset.allCases.map {$0.theme}
        
        let userDefinedThemes: [Theme] = (persistentState?.userThemes ?? []).map {Theme(name: $0.name,
                                                                                    fontScheme: FontScheme($0.fontScheme, false),
                                                                                    colorScheme: ColorScheme($0.colorScheme, false),
                                                                                    windowAppearance: WindowAppearance(cornerRadius: $0.windowAppearance?.cornerRadius ?? WindowAppearanceStateDefaults.cornerRadius), userDefined: true)}
        
        super.init(systemDefinedPresets: systemDefinedThemes, userDefinedPresets: userDefinedThemes)
    }
    
    // Applies a theme to the system theme and returns the modified system scheme.
    func applyTheme(_ theme: Theme) {
        
        _ = FontSchemes.applyScheme(theme.fontScheme)
        _ = ColorSchemes.applyScheme(theme.colorScheme)
        
        WindowAppearanceState.cornerRadius = theme.windowAppearance.cornerRadius
        Messenger.publish(.windowAppearance_changeCornerRadius, payload: WindowAppearanceState.cornerRadius)
    }
    
    // Attempts to apply a theme to the system theme, looking up the scheme by the given display name, and if found, returns the modified system scheme.
    func applyTheme(named name: String) -> Bool {
        
        if let theme = preset(named: name) {
            
            applyTheme(theme)
            return true
        }
        
        return false
    }
    
    // State to be persisted to disk.
    var persistentState: ThemesPersistentState {
        ThemesPersistentState(userDefinedPresets.map {ThemePersistentState($0)})
    }
}
