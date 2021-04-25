import Foundation

class ThemesState: PersistentStateProtocol {
    
    let userThemes: [ThemeState]?
    
    init(_ userThemes: [ThemeState]) {
        self.userThemes = userThemes
    }
    
    required init?(_ map: NSDictionary) {
        self.userThemes = map.arrayValue(forKey: "userThemes", ofType: ThemeState.self)
    }
}

class ThemeState: PersistentStateProtocol {
    
    let name: String
    
    let fontScheme: FontSchemeState?
    let colorScheme: ColorSchemeState?
    let windowAppearance: WindowUIState?
    
    init(_ theme: Theme) {
        
        self.name = theme.name
        self.fontScheme = FontSchemeState(theme.fontScheme)
        self.colorScheme = ColorSchemeState(theme.colorScheme)
        self.windowAppearance = WindowUIState(cornerRadius: theme.windowAppearance.cornerRadius)
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let name = map.nonEmptyStringValue(forKey: "name") else {return nil}
        
        self.name = name
        
        self.fontScheme = map.objectValue(forKey: "fontScheme", ofType: FontSchemeState.self)
        self.colorScheme = map.objectValue(forKey: "colorScheme", ofType: ColorSchemeState.self)
        self.windowAppearance = map.objectValue(forKey: "windowAppearance", ofType: WindowUIState.self)
    }
}

extension Theme: PersistentModelObject {
    
    var persistentState: ThemeState {
        ThemeState(self)
    }
}
