/*
    Utilities for manipulating UI elements or performing computations
 */

import Cocoa

private var screen: NSRect = {
    return NSScreen.main!.frame
}()

private var visibleFrame: NSRect = {
    return NSScreen.main!.visibleFrame
}()

class UIUtils {
    
    private init() {}
    
    private static var preferences: ViewPreferences!
    
    private static let snapProximity: CGFloat = 15
    
    static func initialize(_ preferences: ViewPreferences) {
        UIUtils.preferences = preferences
    }
    
    // Dismisses the given dialog
    static func dismissDialog(_ dialog: NSWindow) {
        dialog.close()
    }
    
    // Centers a dialog with respect to the main app window, and shows it
    static func showDialog(_ dialog: NSWindow) {
        
        centerDialogWRTScreen(dialog)
        dialog.makeKeyAndOrderFront(dialog)
    }
    
    // Centers an alert with respect to the main app window, and shows it. Returns the modal response from the alert.
    static func showAlert(_ alert: NSAlert) -> NSApplication.ModalResponse {
        
        centerDialogWRTScreen(alert.window)
        return alert.runModal()
    }
    
    static func showAlert_nonModal(_ alert: NSAlert) {
        
        centerDialogWRTScreen(alert.window)
        alert.showsHelp = false
        alert.showsSuppressionButton = false
        alert.window.makeKeyAndOrderFront(alert)
    }
    
    // Centers a dialog with respect to the screen
    static func centerDialogWRTScreen(_ dialog: NSWindow) {
        
        let xPadding = (screen.width - dialog.width) / 2
        let yPadding = (screen.height - dialog.height) / 2
        
        dialog.setFrameOrigin(NSPoint(x: xPadding, y: yPadding))
        dialog.setIsVisible(true)
    }
    
    // Centers a dialog with respect to the main window
    static func centerDialogWRTMainWindow(_ dialog: NSWindow) {
        centerDialogWRTWindow(dialog, WindowManager.instance.mainWindow)
    }
    
    static func centerDialogWRTWindow(_ dialog: NSWindow, _ parent: NSWindow) {
        
        let windowX = parent.frame.origin.x
        let windowY = parent.frame.origin.y
        
        let windowWidth = parent.frame.width
        let windowHeight = parent.frame.height
        
        let dialogWidth = dialog.frame.width
        let dialogHeight = dialog.frame.height
        
        let posX = windowX + ((windowWidth - dialogWidth) / 2)
        let posY = windowY + ((windowHeight - dialogHeight) / 2)
        
        dialog.setFrameOrigin(NSPoint(x: posX, y: posY))
        dialog.setIsVisible(true)
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
    
    static func checkForSnapToWindow(_ child: SnappingWindow, _ parent: NSWindow) -> Bool {
        
        let gap = preferences.windowGap
        
        var snap: SnapToWindowType = checkForSnapToWindow_bottom(child, parent)
        
        if (snap.isValidSnap()) {
            
            child.snapLocation = snap.getLocation(child, parent, gap)
            child.snapped = true
            return true
        }
        
        snap = checkForSnapToWindow_top(child, parent)
        
        if (snap.isValidSnap()) {
            
            child.snapLocation = snap.getLocation(child, parent, gap)
            child.snapped = true
            return true
        }
            
        snap = checkForSnapToWindow_right(child, parent)
        
        if (snap.isValidSnap()) {
            
            child.snapLocation = snap.getLocation(child, parent, gap)
            child.snapped = true
            return true
        }
        
        snap = checkForSnapToWindow_left(child, parent)
        
        if (snap.isValidSnap()) {
            
            child.snapLocation = snap.getLocation(child, parent, gap)
            child.snapped = true
            return true
        }
        
        return false
    }
    
    // Top edge of FX vs Bottom edge of main (i.e. below main window)
    private static func checkForSnapToWindow_bottom(_ child: SnappingWindow, _ parent: NSWindow) -> SnapToWindowType {
        
        // Left edges
        var snapMinX = parent.x - Self.snapProximity
        var snapMaxX = parent.x + Self.snapProximity
        let rangeX_leftEdges = snapMinX...snapMaxX
        
        let snapMinY = parent.y - Self.snapProximity
        let snapMaxY = parent.y + Self.snapProximity
        let rangeY = snapMinY...snapMaxY
        
        if rangeX_leftEdges.contains(child.x) && rangeY.contains(child.maxY) {
            return SnapToWindowType.bottom_leftEdges
        }
        
        // Right edges
        snapMinX = parent.maxX - Self.snapProximity
        snapMaxX = parent.maxX + Self.snapProximity
        let rangeX_rightEdges = snapMinX...snapMaxX
        
        if rangeX_rightEdges.contains(child.maxX) && rangeY.contains(child.maxY) {
            return SnapToWindowType.bottom_rightEdges
        }
        
        return SnapToWindowType.none
    }
    
    // Top edge of FX vs Bottom edge of main (i.e. below main window)
    private static func checkForSnapToWindow_top(_ child: SnappingWindow, _ parent: NSWindow) -> SnapToWindowType {
        
        // Left edges
        var snapMinX = parent.x - Self.snapProximity
        var snapMaxX = parent.x + Self.snapProximity
        let rangeX_leftEdges = snapMinX...snapMaxX
        
        let snapMinY = parent.maxY - Self.snapProximity
        let snapMaxY = parent.maxY + Self.snapProximity
        let rangeY = snapMinY...snapMaxY
        
        if rangeX_leftEdges.contains(child.x) && rangeY.contains(child.y) {
            return SnapToWindowType.top_leftEdges
        }
        
        // Right edges
        snapMinX = parent.maxX - Self.snapProximity
        snapMaxX = parent.maxX + Self.snapProximity
        let rangeX_rightEdges = snapMinX...snapMaxX
        
        if rangeX_rightEdges.contains(child.maxX) && rangeY.contains(child.y) {
            return SnapToWindowType.top_rightEdges
        }
        
        return SnapToWindowType.none
    }
    
    // Left edge of FX vs Right edge of main (i.e. to the right of the main window)
    private static func checkForSnapToWindow_right(_ child: SnappingWindow, _ parent: NSWindow) -> SnapToWindowType {
        
        let snapMinX = parent.maxX - Self.snapProximity
        let snapMaxX = parent.maxX + Self.snapProximity
        let rangeX = snapMinX...snapMaxX
        
        // Bottom edges
        var snapMinY = parent.y - Self.snapProximity
        var snapMaxY = parent.y + Self.snapProximity
        let rangeY_bottomEdges = snapMinY...snapMaxY
        
        if rangeX.contains(child.x) && rangeY_bottomEdges.contains(child.y) {
            return SnapToWindowType.right_bottomEdges
        }
        
        // Top edges
        snapMinY = parent.maxY - Self.snapProximity
        snapMaxY = parent.maxY + Self.snapProximity
        let rangeY_topEdges = snapMinY...snapMaxY
        
        if rangeX.contains(child.x) && rangeY_topEdges.contains(child.maxY) {
            return SnapToWindowType.right_topEdges
        }
        
        return SnapToWindowType.none
    }
    
    // Right edge of FX vs Left edge of main (i.e. to the left of the main window)
    private static func checkForSnapToWindow_left(_ child: SnappingWindow, _ parent: NSWindow) -> SnapToWindowType {
        
        let snapMinX = parent.x - child.width - Self.snapProximity
        let snapMaxX = parent.x - child.width + Self.snapProximity
        let rangeX = snapMinX...snapMaxX
        
        // Bottom edges
        var snapMinY = parent.y - Self.snapProximity
        var snapMaxY = parent.y + Self.snapProximity
        let rangeY_bottomEdges = snapMinY...snapMaxY
        
        if rangeX.contains(child.x) && rangeY_bottomEdges.contains(child.y) {
            return SnapToWindowType.left_bottomEdges
        }
        
        // Top edges
        snapMinY = parent.maxY - Self.snapProximity
        snapMaxY = parent.maxY + Self.snapProximity
        let rangeY_topEdges = snapMinY...snapMaxY
        
        if rangeX.contains(child.x) && rangeY_topEdges.contains(child.maxY) {
            return SnapToWindowType.left_topEdges
        }
        
        return SnapToWindowType.none
    }
    
    static func checkForSnapToVisibleFrame(_ window: SnappingWindow) {
        
        var snap: SnapToVisibleFrameType = checkForSnapToVisibleFrame_topLeftCorner(window)
        
        if (snap.isValidSnap()) {
            
            window.snapLocation = snap.getLocation(window)
            window.snapped = true
            return
        }
        
        snap = checkForSnapToVisibleFrame_topRightCorner(window)
        
        if (snap.isValidSnap()) {
            
            window.snapLocation = snap.getLocation(window)
            window.snapped = true
            return
        }
        
        snap = checkForSnapToVisibleFrame_bottomRightCorner(window)
        
        if (snap.isValidSnap()) {
            
            // Snap on the right
            window.snapLocation = snap.getLocation(window)
            window.snapped = true
            return
        }
        
        snap = checkForSnapToVisibleFrame_bottomLeftCorner(window)
        
        if (snap.isValidSnap()) {
            
            // Snap on the right
            window.snapLocation = snap.getLocation(window)
            window.snapped = true
            return
        }
        
        snap = checkForSnapToVisibleFrame_leftEdge(window)
        
        if (snap.isValidSnap()) {
            
            window.snapLocation = snap.getLocation(window)
            window.snapped = true
            return
        }
        
        snap = checkForSnapToVisibleFrame_rightEdge(window)
        
        if (snap.isValidSnap()) {
            
            window.snapLocation = snap.getLocation(window)
            window.snapped = true
            return
        }
        
        snap = checkForSnapToVisibleFrame_topEdge(window)
        
        if (snap.isValidSnap()) {
            
            window.snapLocation = snap.getLocation(window)
            window.snapped = true
            return
        }
        
        snap = checkForSnapToVisibleFrame_bottomEdge(window)
        
        if (snap.isValidSnap()) {
            
            window.snapLocation = snap.getLocation(window)
            window.snapped = true
            return
        }
    }
    
    private static func checkForSnapToVisibleFrame_topLeftCorner(_ window: SnappingWindow) -> SnapToVisibleFrameType {
        
        let snapMinX = visibleFrame.minX
        let snapMaxX = visibleFrame.minX + Self.snapProximity
        let rangeX = snapMinX...snapMaxX
        
        let snapMinY = visibleFrame.maxY - Self.snapProximity
        let snapMaxY = visibleFrame.maxY
        let rangeY = snapMinY...snapMaxY
        
        if rangeX.contains(window.x) && rangeY.contains(window.maxY) {
            return SnapToVisibleFrameType.topLeftCorner
        }
        
        return SnapToVisibleFrameType.none
    }
    
    private static func checkForSnapToVisibleFrame_topRightCorner(_ window: SnappingWindow) -> SnapToVisibleFrameType {
        
        let snapMinX = visibleFrame.maxX - Self.snapProximity
        let snapMaxX = visibleFrame.maxX
        let rangeX = snapMinX...snapMaxX
        
        let snapMinY = visibleFrame.maxY - Self.snapProximity
        let snapMaxY = visibleFrame.maxY
        let rangeY = snapMinY...snapMaxY
        
        if rangeX.contains(window.maxX) && rangeY.contains(window.maxY) {
            return SnapToVisibleFrameType.topRightCorner
        }
        
        return SnapToVisibleFrameType.none
    }
    
    private static func checkForSnapToVisibleFrame_bottomRightCorner(_ window: SnappingWindow) -> SnapToVisibleFrameType {
        
        let snapMinX = visibleFrame.maxX - Self.snapProximity
        let snapMaxX = visibleFrame.maxX
        let rangeX = snapMinX...snapMaxX
        
        let snapMinY = visibleFrame.minY
        let snapMaxY = visibleFrame.minY + Self.snapProximity
        let rangeY = snapMinY...snapMaxY
        
        if rangeX.contains(window.maxX) && rangeY.contains(window.y) {
            return SnapToVisibleFrameType.bottomRightCorner
        }
        
        return SnapToVisibleFrameType.none
    }
    
    private static func checkForSnapToVisibleFrame_bottomLeftCorner(_ window: SnappingWindow) -> SnapToVisibleFrameType {
        
        let snapMinX = visibleFrame.minX
        let snapMaxX = visibleFrame.minX + Self.snapProximity
        let rangeX = snapMinX...snapMaxX
        
        let snapMinY = visibleFrame.minY
        let snapMaxY = visibleFrame.minY + Self.snapProximity
        let rangeY = snapMinY...snapMaxY
        
        if rangeX.contains(window.x) && rangeY.contains(window.y) {
            return SnapToVisibleFrameType.bottomLeftCorner
        }
        
        return SnapToVisibleFrameType.none
    }
    
    private static func checkForSnapToVisibleFrame_leftEdge(_ window: SnappingWindow) -> SnapToVisibleFrameType {
        
        let snapMinX = visibleFrame.minX
        let snapMaxX = visibleFrame.minX + Self.snapProximity
        let rangeX = snapMinX...snapMaxX
        
        if rangeX.contains(window.x) {
            return SnapToVisibleFrameType.leftEdge
        }
        
        return SnapToVisibleFrameType.none
    }
    
    private static func checkForSnapToVisibleFrame_topEdge(_ window: SnappingWindow) -> SnapToVisibleFrameType {
        
        let snapMinY = visibleFrame.maxY - Self.snapProximity
        let snapMaxY = visibleFrame.maxY
        let rangeY = snapMinY...snapMaxY
        
        if rangeY.contains(window.maxY) {
            return SnapToVisibleFrameType.topEdge
        }
        
        return SnapToVisibleFrameType.none
    }
    
    private static func checkForSnapToVisibleFrame_rightEdge(_ window: SnappingWindow) -> SnapToVisibleFrameType {
        
        let snapMinX = visibleFrame.maxX - Self.snapProximity
        let snapMaxX = visibleFrame.maxX
        let rangeX = snapMinX...snapMaxX
        
        if rangeX.contains(window.maxX) {
            return SnapToVisibleFrameType.rightEdge
        }
        
        return SnapToVisibleFrameType.none
    }
    
    private static func checkForSnapToVisibleFrame_bottomEdge(_ window: SnappingWindow) -> SnapToVisibleFrameType {
        
        let snapMinY = visibleFrame.minY
        let snapMaxY = visibleFrame.minY + Self.snapProximity
        let rangeY = snapMinY...snapMaxY
        
        if rangeY.contains(window.y) {
            return SnapToVisibleFrameType.bottomEdge
        }
        
        return SnapToVisibleFrameType.none
    }
}

enum SnapToWindowType {
    
    case none
    
    case bottom_leftEdges
    case bottom_rightEdges
    
    case top_leftEdges
    case top_rightEdges
    
    case right_bottomEdges
    case right_topEdges
    
    case left_bottomEdges
    case left_topEdges
    
    func isValidSnap() -> Bool {
        return self != .none
    }
    
    func getLocation(_ child: NSWindow, _ parent: NSWindow, _ gapFloat: Float) -> NSPoint {
        
        let gap = CGFloat(gapFloat)
        
        switch self {
         
        case .bottom_leftEdges:
            
            return parent.origin.applying(CGAffineTransform.init(translationX: 0, y: -(child.height + gap)))
            
        case .bottom_rightEdges:
            
            return parent.origin.applying(CGAffineTransform.init(translationX: parent.width - child.width, y: -(child.height + gap)))
            
        case .top_leftEdges:
            
            return parent.origin.applying(CGAffineTransform.init(translationX: 0, y: parent.height + gap))
            
        case .top_rightEdges:
            
            return parent.origin.applying(CGAffineTransform.init(translationX: parent.width - child.width, y: parent.height + gap))
            
        case .right_bottomEdges:
            
            return parent.origin.applying(CGAffineTransform.init(translationX: parent.width + gap, y: 0))
            
        case .right_topEdges:
            
            return parent.origin.applying(CGAffineTransform.init(translationX: parent.width + gap, y: parent.height - child.height))
            
        case .left_bottomEdges:
            
            return parent.origin.applying(CGAffineTransform.init(translationX: -(child.width + gap), y: 0))
            
        case .left_topEdges:
            
            return parent.origin.applying(CGAffineTransform.init(translationX: -(child.width + gap), y: parent.height - child.height))
            
        default:    return NSPoint.zero     // Impossible
            
        }
    }
}

enum SnapToVisibleFrameType {
    
    case none
    
    case leftEdge
    case topLeftCorner
    case topEdge
    case topRightCorner
    case rightEdge
    case bottomRightCorner
    case bottomEdge
    case bottomLeftCorner
    
    func isValidSnap() -> Bool {
        return self != .none
    }
    
    func getLocation(_ window: NSWindow) -> NSPoint {
        
        switch self {
            
        case .leftEdge:
            
            return NSPoint(x: visibleFrame.minX, y: window.y)
            
        case .topLeftCorner:
            
            return NSPoint(x: visibleFrame.minX, y: visibleFrame.maxY - window.height)
            
        case .topEdge:
            
            return NSPoint(x: window.x, y: visibleFrame.maxY - window.height)
            
        case .topRightCorner:
            
            return NSPoint(x: visibleFrame.maxX - window.width, y: visibleFrame.maxY - window.height)
            
        case .rightEdge:
            
            return NSPoint(x: visibleFrame.maxX - window.width, y: window.y)
            
        case .bottomRightCorner:
            
            return NSPoint(x: visibleFrame.maxX - window.width, y: visibleFrame.minY)
            
        case .bottomEdge:
            
            return NSPoint(x: window.x, y: visibleFrame.minY)
            
        case .bottomLeftCorner:
            
            return NSPoint(x: visibleFrame.minX, y: visibleFrame.minY)
            
        default:    return NSPoint.zero     // Impossible
            
        }
    }
}
