/*
    Utilities for manipulating UI elements
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
        
        return NSPoint(x: x, y: y)
    }
}
