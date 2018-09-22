/*
    Utilities for manipulating UI elements or performing computations
 */

import Cocoa

private var visibleFrame: NSRect = {
    return NSScreen.main()!.visibleFrame
}()

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
    
    // Centers a dialog with respect to the main app window
    private static func centerDialog(_ dialog: NSWindow) {
        
        let window = WindowState.mainWindow!
        
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
    
    static func checkForSnap(_ child: SnappingWindow, _ parent: NSWindow) -> Bool {
        
        var snap: SnapToWindowType = checkForBottomSnap(child, parent)
        
        if (snap.isValidSnap()) {
            
            // Snap on the bottom
            child.snapLocation = snap.getLocation(child, parent)
            
        } else {
            
            snap = checkForRightSnap(child, parent)
            
            if (snap.isValidSnap()) {
            
                // Snap on the right
                child.snapLocation = snap.getLocation(child, parent)
                
            } else {
                
                snap = checkForLeftSnap(child, parent)
                
                if (snap.isValidSnap()) {
                    
                    // Snap on the left
                    child.snapLocation = snap.getLocation(child, parent)
                }
            }
        }
        
        child.snapped = snap.isValidSnap()
        return snap.isValidSnap()
    }
    
    // Top edge of FX vs Bottom edge of main (i.e. below main window)
    private static func checkForBottomSnap(_ child: SnappingWindow, _ parent: NSWindow) -> SnapToWindowType {
        
        // Left edges
        var snapMinX = parent.x - Dimensions.snapProximity
        var snapMaxX = parent.x + Dimensions.snapProximity
        let rangeX_leftEdges = snapMinX...snapMaxX
        
        let snapMinY = parent.y - child.height - Dimensions.snapProximity
        let snapMaxY = parent.y - child.height + Dimensions.snapProximity
        let rangeY = snapMinY...snapMaxY
        
        if rangeX_leftEdges.contains(child.x) && rangeY.contains(child.y) {
            return SnapToWindowType.bottom_leftEdges
        }
        
        // Right edges
        snapMinX = parent.maxX - Dimensions.snapProximity
        snapMaxX = parent.maxX + Dimensions.snapProximity
        let rangeX_rightEdges = snapMinX...snapMaxX
        
        if rangeX_rightEdges.contains(child.maxX) && rangeY.contains(child.y) {
            return SnapToWindowType.bottom_rightEdges
        }
        
        return SnapToWindowType.none
    }
    
    // Left edge of FX vs Right edge of main (i.e. to the right of the main window)
    private static func checkForRightSnap(_ child: SnappingWindow, _ parent: NSWindow) -> SnapToWindowType {
        
        let snapMinX = parent.maxX - Dimensions.snapProximity
        let snapMaxX = parent.maxX + Dimensions.snapProximity
        let rangeX = snapMinX...snapMaxX
        
        // Bottom edges
        var snapMinY = parent.y - Dimensions.snapProximity
        var snapMaxY = parent.y + Dimensions.snapProximity
        let rangeY_bottomEdges = snapMinY...snapMaxY
        
        if rangeX.contains(child.x) && rangeY_bottomEdges.contains(child.y) {
            return SnapToWindowType.right_bottomEdges
        }
        
        // Top edges
        snapMinY = parent.maxY - Dimensions.snapProximity
        snapMaxY = parent.maxY + Dimensions.snapProximity
        let rangeY_topEdges = snapMinY...snapMaxY
        
        if rangeX.contains(child.x) && rangeY_topEdges.contains(child.maxY) {
            return SnapToWindowType.right_topEdges
        }
        
        return SnapToWindowType.none
    }
    
    // Right edge of FX vs Left edge of main (i.e. to the left of the main window)
    private static func checkForLeftSnap(_ child: SnappingWindow, _ parent: NSWindow) -> SnapToWindowType {
        
        let snapMinX = parent.x - child.width - Dimensions.snapProximity
        let snapMaxX = parent.x - child.width + Dimensions.snapProximity
        let rangeX = snapMinX...snapMaxX
        
        // Bottom edges
        var snapMinY = parent.y - Dimensions.snapProximity
        var snapMaxY = parent.y + Dimensions.snapProximity
        let rangeY_bottomEdges = snapMinY...snapMaxY
        
        if rangeX.contains(child.x) && rangeY_bottomEdges.contains(child.y) {
            return SnapToWindowType.left_bottomEdges
        }
        
        // Top edges
        snapMinY = parent.maxY - Dimensions.snapProximity
        snapMaxY = parent.maxY + Dimensions.snapProximity
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
        let snapMaxX = visibleFrame.minX + Dimensions.snapProximity
        let rangeX = snapMinX...snapMaxX
        
        let snapMinY = visibleFrame.maxY - Dimensions.snapProximity
        let snapMaxY = visibleFrame.maxY
        let rangeY = snapMinY...snapMaxY
        
        if rangeX.contains(window.x) && rangeY.contains(window.maxY) {
            return SnapToVisibleFrameType.topLeftCorner
        }
        
        return SnapToVisibleFrameType.none
    }
    
    private static func checkForSnapToVisibleFrame_topRightCorner(_ window: SnappingWindow) -> SnapToVisibleFrameType {
        
        let snapMinX = visibleFrame.maxX - Dimensions.snapProximity
        let snapMaxX = visibleFrame.maxX
        let rangeX = snapMinX...snapMaxX
        
        let snapMinY = visibleFrame.maxY - Dimensions.snapProximity
        let snapMaxY = visibleFrame.maxY
        let rangeY = snapMinY...snapMaxY
        
        if rangeX.contains(window.maxX) && rangeY.contains(window.maxY) {
            return SnapToVisibleFrameType.topRightCorner
        }
        
        return SnapToVisibleFrameType.none
    }
    
    private static func checkForSnapToVisibleFrame_bottomRightCorner(_ window: SnappingWindow) -> SnapToVisibleFrameType {
        
        let snapMinX = visibleFrame.maxX - Dimensions.snapProximity
        let snapMaxX = visibleFrame.maxX
        let rangeX = snapMinX...snapMaxX
        
        let snapMinY = visibleFrame.minY
        let snapMaxY = visibleFrame.minY + Dimensions.snapProximity
        let rangeY = snapMinY...snapMaxY
        
        if rangeX.contains(window.maxX) && rangeY.contains(window.y) {
            return SnapToVisibleFrameType.bottomRightCorner
        }
        
        return SnapToVisibleFrameType.none
    }
    
    private static func checkForSnapToVisibleFrame_bottomLeftCorner(_ window: SnappingWindow) -> SnapToVisibleFrameType {
        
        let snapMinX = visibleFrame.minX
        let snapMaxX = visibleFrame.minX + Dimensions.snapProximity
        let rangeX = snapMinX...snapMaxX
        
        let snapMinY = visibleFrame.minY
        let snapMaxY = visibleFrame.minY + Dimensions.snapProximity
        let rangeY = snapMinY...snapMaxY
        
        if rangeX.contains(window.x) && rangeY.contains(window.y) {
            return SnapToVisibleFrameType.bottomLeftCorner
        }
        
        return SnapToVisibleFrameType.none
    }
    
    private static func checkForSnapToVisibleFrame_leftEdge(_ window: SnappingWindow) -> SnapToVisibleFrameType {
        
        let snapMinX = visibleFrame.minX
        let snapMaxX = visibleFrame.minX + Dimensions.snapProximity
        let rangeX = snapMinX...snapMaxX
        
        if rangeX.contains(window.x) {
            return SnapToVisibleFrameType.leftEdge
        }
        
        return SnapToVisibleFrameType.none
    }
    
    private static func checkForSnapToVisibleFrame_topEdge(_ window: SnappingWindow) -> SnapToVisibleFrameType {
        
        let snapMinY = visibleFrame.maxY - Dimensions.snapProximity
        let snapMaxY = visibleFrame.maxY
        let rangeY = snapMinY...snapMaxY
        
        if rangeY.contains(window.maxY) {
            return SnapToVisibleFrameType.topEdge
        }
        
        return SnapToVisibleFrameType.none
    }
    
    private static func checkForSnapToVisibleFrame_rightEdge(_ window: SnappingWindow) -> SnapToVisibleFrameType {
        
        let snapMinX = visibleFrame.maxX - Dimensions.snapProximity
        let snapMaxX = visibleFrame.maxX
        let rangeX = snapMinX...snapMaxX
        
        if rangeX.contains(window.maxX) {
            return SnapToVisibleFrameType.rightEdge
        }
        
        return SnapToVisibleFrameType.none
    }
    
    private static func checkForSnapToVisibleFrame_bottomEdge(_ window: SnappingWindow) -> SnapToVisibleFrameType {
        
        let snapMinY = visibleFrame.minY
        let snapMaxY = visibleFrame.minY + Dimensions.snapProximity
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
    
    case right_bottomEdges
    case right_topEdges
    
    case left_bottomEdges
    case left_topEdges
    
    // TODO: Add top edge snapping
    
    func isValidSnap() -> Bool {
        return self != .none
    }
    
    func getLocation(_ child: NSWindow, _ parent: NSWindow) -> NSPoint {
        
        switch self {
         
        case .bottom_leftEdges:
            
            return parent.origin.applying(CGAffineTransform.init(translationX: 0, y: -child.height))
            
        case .bottom_rightEdges:
            
            return parent.origin.applying(CGAffineTransform.init(translationX: parent.width - child.width, y: -child.height))
            
        case .right_bottomEdges:
            
            return parent.origin.applying(CGAffineTransform.init(translationX: parent.width, y: 0))
            
        case .right_topEdges:
            
            return parent.origin.applying(CGAffineTransform.init(translationX: parent.width, y: parent.height - child.height))
            
        case .left_bottomEdges:
            
            return parent.origin.applying(CGAffineTransform.init(translationX: -child.width, y: 0))
            
        case .left_topEdges:
            
            return parent.origin.applying(CGAffineTransform.init(translationX: -child.width, y: parent.height - child.height))
            
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
