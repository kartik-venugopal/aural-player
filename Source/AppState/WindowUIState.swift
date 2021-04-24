import Foundation

class WindowUIState: PersistentStateProtocol {
    
    var cornerRadius: Float?
    
    init(cornerRadius: Float) {
        self.cornerRadius = cornerRadius
    }
    
    required init?(_ map: NSDictionary) {
        self.cornerRadius = map.floatValue(forKey: "cornerRadius")
    }
}

extension WindowAppearanceState {
    
    static func initialize(_ persistentState: WindowUIState) {
        
        if let cornerRadius = persistentState.cornerRadius {
            Self.cornerRadius = CGFloat(cornerRadius)
        } else {
            Self.cornerRadius = WindowAppearanceStateDefaults.cornerRadius
        }
    }
    
    static var persistentState: WindowUIState {
        WindowUIState(cornerRadius: Float(cornerRadius))
    }
}
