/*
    Utilities for manipulating UI elements or performing computations
 */

import Cocoa

class UIUtils {
    
    // Dismisses the currently displayed modal dialog
    static func dismissModalDialog() {
        NSApp.stopModal()
    }
    
    // Centers a modal dialog with respect to the main app window, and shows it
    static func showModalDialog(_ dialog: NSWindow) {
        
        centerDialog(dialog)
        
        NSApp.runModal(for: dialog)
        dialog.close()
    }
    
    // Centers an alert with respect to the main app window, and shows it. Returns the modal response from the alert.
    static func showAlert(_ alert: NSAlert) -> NSModalResponse {
        
        centerDialog(alert.window)
        return alert.runModal()
    }
    
    static func createRoundedCorners(_ window: NSWindow) {
        
        window.styleMask.insert(NSTitledWindowMask)
        window.styleMask = window.styleMask.union(NSFullSizeContentViewWindowMask)
        window.isMovableByWindowBackground	=	true
        window.titlebarAppearsTransparent 	= 	true
        window.titleVisibility				=	.hidden
        window.showsToolbarButton			=	false
        window.standardWindowButton(NSWindowButton.fullScreenButton)?.isHidden	=	true
        window.standardWindowButton(NSWindowButton.miniaturizeButton)?.isHidden	=	true
        window.standardWindowButton(NSWindowButton.closeButton)?.isHidden		=	true
        window.standardWindowButton(NSWindowButton.zoomButton)?.isHidden			=	true
    }
    
    // Centers a dialog with respect to the main app window
    private static func centerDialog(_ dialog: NSWindow) {
        
        let window = WindowState.window!
        
        let windowX = window.frame.origin.x
        let windowY = window.frame.origin.y
        
        let windowWidth = window.frame.width
        let windowHeight = window.frame.height
        
        let dialogWidth = dialog.frame.width
        let dialogHeight = dialog.frame.height
        
        let posX = windowX + ((windowWidth - dialogWidth) / 2)
        let posY = windowY + ((windowHeight - dialogHeight) / 2)
        
        dialog.setFrameOrigin(NSPoint(x: posX, y: posY))
        dialog.setIsVisible(true)
    }
    
    // Computes a window position relative to the desired location on screen, e.g Top left or Bottom center, etc.
    static func windowPositionRelativeToScreen(_ windowWidth: CGFloat, _ windowHeight: CGFloat, _ locationOnScreen: WindowLocations) -> NSPoint {
        
        let screen = NSScreen.main()!
        
        let screenWidth = screen.frame.width
        let screenHeight = screen.frame.height
        
        let minX = screen.visibleFrame.minX
        let maxX = screen.visibleFrame.maxX
        
        let minY = screen.visibleFrame.minY
        let maxY = screen.visibleFrame.maxY
        
        var x: CGFloat, y: CGFloat
        
        switch locationOnScreen {
            
        case .center:
            
            x = (screenWidth / 2) - (windowWidth / 2)
            y = (screenHeight / 2) - (windowHeight / 2)
            
        case .topLeft:
            
            x = minX
            y = maxY - windowHeight
            
        case .topCenter:
            
            x = (screenWidth / 2) - (windowWidth / 2)
            y = maxY - windowHeight
            
        case .topRight:
            
            x = screenWidth - windowWidth
            y = maxY - windowHeight
            
        case .leftCenter:
            
            x = minX
            y = (screenHeight / 2) - (windowHeight / 2)
            
        case .rightCenter:
            
            x = maxX - windowWidth
            y = (screenHeight / 2) - (windowHeight / 2)
            
        case .bottomLeft:
            
            x = minX
            y = minY
            
        case .bottomCenter:
            
            x = (screenWidth / 2) - (windowWidth / 2)
            y = minY
            
        case .bottomRight:
            
            x = maxX - windowWidth
            y = minY
            
        }
        
        return NSPoint(x: x, y: y)
    }
    
    // Calculates the direction of a swipe gesture
    static func determineSwipeDirection(_ event: NSEvent) -> GestureDirection? {
        
        if (event.type != .swipe) {
            return nil
        }
        
        // Offset
        let deltaX = event.deltaX, deltaY = event.deltaY
        
        // No offset data, no direction
        if (deltaX == 0 && deltaY == 0) {
            return nil
        }
        
        // Determine absolute offset values along both axes
        let absX = abs(deltaX), absY = abs(deltaY)
        
        // Check along which axis greater movement occurred
        if (absX > absY) {
            
            // This is a horizontal swipe (left/right)
            return deltaX < 0 ? .right : .left
            
        } else {
            
            // This is a vertical swipe (up/down)
            return deltaY < 0 ? .down : .up
        }
    }
    
    // Calculates the direction and magnitude of a scroll gesture
    static func determineScrollVector(_ event: NSEvent) -> (direction: GestureDirection, movement: CGFloat)? {
        
        if (event.type != .scrollWheel) {
            return nil
        }
        
        // Offset
        let deltaX = event.deltaX, deltaY = event.deltaY
        
        // No offset data, no direction
        if (deltaX == 0 && deltaY == 0) {
            return nil
        }
        
        // Determine absolute offset values along both axes
        let absX = abs(deltaX), absY = abs(deltaY)
        
        var direction: GestureDirection
        var movement: CGFloat
        
        // Check along which axis greater movement occurred
        if (absX > absY) {
            
            // This is a horizontal swipe (left/right)
            direction = deltaX < 0 ? .right : .left
            movement = absX
            
        } else {
            
            // This is a vertical swipe (up/down)
            direction = deltaY < 0 ? .down : .up
            movement = absY
        }
        
        return (direction, movement)
    }
}
