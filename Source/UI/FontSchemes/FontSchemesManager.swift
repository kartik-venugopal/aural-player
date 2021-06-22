import Cocoa

class FontSchemesManager: MappedPresets<FontScheme> {
    
    // The current system color scheme. It is initialized with the default scheme.
    private(set) var systemScheme: FontScheme
    
    init(persistentState: FontSchemesPersistentState?) {
        
        let systemDefinedSchemes = FontSchemePreset.allCases.map {FontScheme($0.name, $0)}
        let userDefinedSchemes = (persistentState?.userSchemes ?? []).map {FontScheme($0, false)}
        
        if let persistentSystemScheme = persistentState?.systemScheme {
            
            self.systemScheme = FontScheme(persistentSystemScheme, true)
            
        } else {
            
            self.systemScheme = systemDefinedSchemes.first(where: {$0.name == FontSchemePreset.standard.name}) ??
                FontScheme("_system_", FontSchemePreset.standard)
        }
        
        super.init(systemDefinedPresets: systemDefinedSchemes, userDefinedPresets: userDefinedSchemes)
    }
    
    func applyScheme(named name: String) -> FontScheme? {
        
        if let scheme = preset(named: name) {
            return applyScheme(scheme)
        }
        
        return nil
    }
    
    func applyScheme(_ fontScheme: FontScheme) -> FontScheme {

        systemScheme = FontScheme("_system_", true, fontScheme)
        return systemScheme
    }
    
    // State to be persisted to disk.
    var persistentState: FontSchemesPersistentState {
        
        FontSchemesPersistentState(FontSchemePersistentState(systemScheme),
                                   userDefinedPresets.map {FontSchemePersistentState($0)})
    }
}
