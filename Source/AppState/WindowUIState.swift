import Foundation

class WindowUIState: PersistentStateProtocol {
    
    var cornerRadius: Float = Float(AppDefaults.windowCornerRadius)
    
    required init?(_ map: NSDictionary) -> WindowUIState {
        
        let state = WindowUIState()
        
        if let cornerRadius = (map["cornerRadius"] as? NSNumber)?.floatValue {
            state.cornerRadius = cornerRadius
        }
        
        return state
    }
}

extension WindowAppearanceState {
    
    static func initialize(_ persistentState: WindowUIState) {
        cornerRadius = CGFloat(persistentState.cornerRadius)
    }
    
    static var persistentState: WindowUIState {
        
        let state = WindowUIState()
        state.cornerRadius = Float(cornerRadius)
        
        return state
    }
}
