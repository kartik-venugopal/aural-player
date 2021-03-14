import Cocoa

class KeyCodeConstants {
    
    // TODO: Are these system-independent ???
    static let UP_ARROW: UInt16 = 126
    static let DOWN_ARROW: UInt16 = 125
    
    static let LEFT_ARROW: UInt16 = 123
    static let RIGHT_ARROW: UInt16 = 124
    
    static let TAB: UInt16 = 48
    
    static let arrows = [UP_ARROW, DOWN_ARROW, LEFT_ARROW, RIGHT_ARROW]
    static let verticalArrows = [UP_ARROW, DOWN_ARROW]
    static let horizontalArrows = [LEFT_ARROW, RIGHT_ARROW]
}
