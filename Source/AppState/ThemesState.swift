import Foundation

class ThemesState: PersistentState {
    
    var userThemes: [ThemeState] = []
    
    init() {}
    
    init(_ userThemes: [ThemeState]) {
        self.userThemes = userThemes
    }
    
    static func deserialize(_ map: NSDictionary) -> ThemesState {
        
        let state = ThemesState()
        
        if let userThemesArr = map["userThemes"] as? [NSDictionary] {
            state.userThemes = userThemesArr.map {ThemeState.deserialize($0)}
        }
        
        return state
    }
}

class ThemeState: PersistentState {
    
    var name: String = ""
    
    var fontScheme: FontSchemeState = FontSchemeState()
    var colorScheme: ColorSchemeState = ColorSchemeState()
    var windowAppearance: WindowUIState = WindowUIState()
    
    init() {}
    
    init(_ theme: Theme) {
        
        self.name = theme.name
        self.fontScheme = FontSchemeState(theme.fontScheme)
        self.colorScheme = ColorSchemeState(theme.colorScheme)
        self.windowAppearance.cornerRadius = Float(theme.windowAppearance.cornerRadius)
    }
    
    static func deserialize(_ map: NSDictionary) -> ThemeState {
        
        let state = ThemeState()
        
        state.name = map["name"] as? String ?? ""
        
        if let fontSchemeDict = map["fontScheme"] as? NSDictionary {
            state.fontScheme = FontSchemeState.deserialize(fontSchemeDict)
        }
        
        if let colorSchemeDict = map["colorScheme"] as? NSDictionary {
            state.colorScheme = ColorSchemeState.deserialize(colorSchemeDict)
        }
        
        if let windowAppearanceDict = map["windowAppearance"] as? NSDictionary {
            state.windowAppearance = WindowUIState.deserialize(windowAppearanceDict)
        }
        
        return state
    }
}

extension Theme: PersistentModelObject {
    
    var persistentState: ThemeState {
        
        let state = ThemeState()
        
        state.name = self.name
        state.fontScheme = FontSchemeState(self.fontScheme)
        state.colorScheme = ColorSchemeState(self.colorScheme)
        state.windowAppearance.cornerRadius = Float(self.windowAppearance.cornerRadius)
        
        return state
    }
}
