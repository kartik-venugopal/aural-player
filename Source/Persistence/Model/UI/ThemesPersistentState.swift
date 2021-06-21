import Foundation

class ThemesPersistentState: PersistentStateProtocol {
    
    let userThemes: [ThemePersistentState]?
    
    init(_ userThemes: [ThemePersistentState]) {
        self.userThemes = userThemes
    }
    
    required init?(_ map: NSDictionary) {
        self.userThemes = map.persistentObjectArrayValue(forKey: "userThemes", ofType: ThemePersistentState.self)
    }
}

class ThemePersistentState: PersistentStateProtocol {
    
    let name: String
    
    let fontScheme: FontSchemePersistentState?
    let colorScheme: ColorSchemePersistentState?
    let windowAppearance: WindowUIPersistentState?
    
    init(_ theme: Theme) {
        
        self.name = theme.name
        self.fontScheme = FontSchemePersistentState(theme.fontScheme)
        self.colorScheme = ColorSchemePersistentState(theme.colorScheme)
        self.windowAppearance = WindowUIPersistentState(cornerRadius: theme.windowAppearance.cornerRadius)
    }
    
    required init?(_ map: NSDictionary) {
        
        guard let name = map.nonEmptyStringValue(forKey: "name") else {return nil}
        
        self.name = name
        
        self.fontScheme = map.persistentObjectValue(forKey: "fontScheme", ofType: FontSchemePersistentState.self)
        self.colorScheme = map.persistentObjectValue(forKey: "colorScheme", ofType: ColorSchemePersistentState.self)
        self.windowAppearance = map.persistentObjectValue(forKey: "windowAppearance", ofType: WindowUIPersistentState.self)
    }
}

extension Theme: PersistentModelObject {
    
    var persistentState: ThemePersistentState {
        ThemePersistentState(self)
    }
}
