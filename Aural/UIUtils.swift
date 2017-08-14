/*
    Utilities for manipulating UI elements
 */

import Cocoa

class UIUtils {
    
    // Positions a window relative to the desired location on screen, e.g Top left or Bottom center, etc.
    static func positionWindowRelativeToScreen(_ window: NSWindow, _ locationOnScreen: WindowLocations) {
        
        let screen = NSScreen.main()!
        let screenWidth = screen.frame.width
        let screenHeight = screen.frame.height
        
        let windowWidth = window.frame.width
        let windowHeight = window.frame.height
        
        var x: CGFloat, y: CGFloat
        
        switch locationOnScreen {
            
        case .center:   x = (screenWidth / 2) - (windowWidth / 2)
        y = (screenHeight / 2) - (windowHeight / 2)
            
        case .topLeft:  x = 0
        y = screenHeight - windowHeight
            
        case .topCenter:    x = (screenWidth / 2) - (windowWidth / 2)
        y = screenHeight - windowHeight
            
        case .topRight: x = screenWidth - windowWidth
        y = screenHeight - windowHeight
            
        case .leftCenter:   x = 0
        y = (screenHeight / 2) - (windowHeight / 2)
            
        case .rightCenter:  x = screenWidth - windowWidth
        y = (screenHeight / 2) - (windowHeight / 2)
            
        case .bottomLeft:   x = 0
        y = 0
            
        case .bottomCenter: x = (screenWidth / 2) - (windowWidth / 2)
        y = 0
            
        case .bottomRight:  x = screenWidth - windowWidth
        y = 0
        }
        
        window.setFrameOrigin(NSPoint(x: x, y: y))
    }
}
