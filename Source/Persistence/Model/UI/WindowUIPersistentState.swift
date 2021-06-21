import Foundation

class WindowUIPersistentState: PersistentStateProtocol {
    
    var cornerRadius: CGFloat?
    
    init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
    }
    
    required init?(_ map: NSDictionary) {
        self.cornerRadius = map.cgFloatValue(forKey: "cornerRadius")
    }
}

extension WindowAppearanceState {
    
    static func initialize(_ persistentState: WindowUIPersistentState?) {
        Self.cornerRadius = persistentState?.cornerRadius ?? WindowAppearanceStateDefaults.cornerRadius
    }
    
    static var persistentState: WindowUIPersistentState {
        WindowUIPersistentState(cornerRadius: cornerRadius)
    }
}
