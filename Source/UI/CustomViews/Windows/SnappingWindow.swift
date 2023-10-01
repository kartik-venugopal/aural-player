//
//  SnappingWindow.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

fileprivate let preferences: ViewPreferences = objectGraph.preferences.viewPreferences

@IBDesignable
class SnappingWindow: NoTitleBarWindow {
    
    var snapped: Bool = false
    var snapLocation: NSPoint?
    
    @IBInspectable var snapLevel: Int = 0
    
    var userMovingWindow: Bool = false
    
    private static let snapProximity: CGFloat = 20
    
    private var snapProximity: CGFloat {Self.snapProximity}
    
    private lazy var theDelegate: SnappingWindowDelegate = SnappingWindowDelegate(window: self)
    
    override func awakeFromNib() {
        self.delegate = theDelegate
    }

    override func mouseUp(with event: NSEvent) {

        // Mark Bool flag to indicate that user-initiated movement has ended
        userMovingWindow = false

        // Snap window to its pre-determined snap location
        if snapped, let theSnapLocation = self.snapLocation {

            self.setFrameOrigin(theSnapLocation)

            snapped = false
            snapLocation = nil
        }

        super.mouseUp(with: event)
    }

    // Mark Bool flag to indicate that window movement is user-initiated
    override func mouseDown(with event: NSEvent) {

        userMovingWindow = true
        super.mouseDown(with: event)
    }
    
    func checkForSnap(to mate: NSWindow) -> Bool {
        
        let gap = preferences.windowGap
        
        var snap: SnapToWindowType = checkForSnap_bottom(to: mate)
        
        if snap.isValidSnap() {
            
            self.snapLocation = snap.getLocation(self, mate, gap)
            self.snapped = true
            return true
        }
        
        snap = checkForSnap_top(to: mate)
        
        if snap.isValidSnap() {
            
            self.snapLocation = snap.getLocation(self, mate, gap)
            self.snapped = true
            return true
        }
            
        snap = checkForSnap_right(to: mate)
        
        if snap.isValidSnap() {
            
            self.snapLocation = snap.getLocation(self, mate, gap)
            self.snapped = true
            return true
        }
        
        snap = checkForSnap_left(to: mate)
        
        if snap.isValidSnap() {
            
            self.snapLocation = snap.getLocation(self, mate, gap)
            self.snapped = true
            return true
        }
        
        return false
    }
    
    // Top edge of Effects vs Bottom edge of main (i.e. below main window)
    private func checkForSnap_bottom(to mate: NSWindow) -> SnapToWindowType {
        
        // Left edges
        var snapMinX = mate.x - snapProximity
        var snapMaxX = mate.x + snapProximity
        let rangeX_leftEdges = snapMinX...snapMaxX
        
        let snapMinY = mate.y - snapProximity
        let snapMaxY = mate.y + snapProximity
        let rangeY = snapMinY...snapMaxY
        
        if rangeX_leftEdges.contains(x) && rangeY.contains(maxY) {
            return .bottom_leftEdges
        }
        
        // Right edges
        snapMinX = mate.maxX - snapProximity
        snapMaxX = mate.maxX + snapProximity
        let rangeX_rightEdges = snapMinX...snapMaxX
        
        if rangeX_rightEdges.contains(maxX) && rangeY.contains(maxY) {
            return .bottom_rightEdges
        }
        
        return .none
    }
    
    // Top edge of Effects vs Bottom edge of main (i.e. below main window)
    private func checkForSnap_top(to mate: NSWindow) -> SnapToWindowType {
        
        // Left edges
        var snapMinX = mate.x - snapProximity
        var snapMaxX = mate.x + snapProximity
        let rangeX_leftEdges = snapMinX...snapMaxX
        
        let snapMinY = mate.maxY - snapProximity
        let snapMaxY = mate.maxY + snapProximity
        let rangeY = snapMinY...snapMaxY
        
        if rangeX_leftEdges.contains(x) && rangeY.contains(y) {
            return .top_leftEdges
        }
        
        // Right edges
        snapMinX = mate.maxX - snapProximity
        snapMaxX = mate.maxX + snapProximity
        let rangeX_rightEdges = snapMinX...snapMaxX
        
        if rangeX_rightEdges.contains(maxX) && rangeY.contains(y) {
            return .top_rightEdges
        }
        
        return .none
    }
    
    // Left edge of Effects vs Right edge of main (i.e. to the right of the main window)
    private func checkForSnap_right(to mate: NSWindow) -> SnapToWindowType {
        
        let snapMinX = mate.maxX - snapProximity
        let snapMaxX = mate.maxX + snapProximity
        let rangeX = snapMinX...snapMaxX
        
        // Bottom edges
        var snapMinY = mate.y - snapProximity
        var snapMaxY = mate.y + snapProximity
        let rangeY_bottomEdges = snapMinY...snapMaxY
        
        if rangeX.contains(x) && rangeY_bottomEdges.contains(y) {
            return .right_bottomEdges
        }
        
        // Top edges
        snapMinY = mate.maxY - snapProximity
        snapMaxY = mate.maxY + snapProximity
        let rangeY_topEdges = snapMinY...snapMaxY
        
        if rangeX.contains(x) && rangeY_topEdges.contains(maxY) {
            return .right_topEdges
        }
        
        return .none
    }
    
    // Right edge of Effects vs Left edge of main (i.e. to the left of the main window)
    private func checkForSnap_left(to mate: NSWindow) -> SnapToWindowType {
        
        let snapMinX = mate.x - width - snapProximity
        let snapMaxX = mate.x - width + snapProximity
        let rangeX = snapMinX...snapMaxX
        
        // Bottom edges
        var snapMinY = mate.y - snapProximity
        var snapMaxY = mate.y + snapProximity
        let rangeY_bottomEdges = snapMinY...snapMaxY
        
        if rangeX.contains(x) && rangeY_bottomEdges.contains(y) {
            return .left_bottomEdges
        }
        
        // Top edges
        snapMinY = mate.maxY - snapProximity
        snapMaxY = mate.maxY + snapProximity
        let rangeY_topEdges = snapMinY...snapMaxY
        
        if rangeX.contains(x) && rangeY_topEdges.contains(maxY) {
            return .left_topEdges
        }
        
        return .none
    }
    
    func checkForSnapToVisibleFrame() {
        
        var snap: SnapToVisibleFrameType = checkForSnapToVisibleFrame_topLeftCorner()
        
        if snap.isValidSnap() {
            
            snapLocation = snap.getLocation(self)
            snapped = true
            return
        }
        
        snap = checkForSnapToVisibleFrame_topRightCorner()
        
        if snap.isValidSnap() {
            
            snapLocation = snap.getLocation(self)
            snapped = true
            return
        }
        
        snap = checkForSnapToVisibleFrame_bottomRightCorner()
        
        if snap.isValidSnap() {
            
            // Snap on the right
            snapLocation = snap.getLocation(self)
            snapped = true
            return
        }
        
        snap = checkForSnapToVisibleFrame_bottomLeftCorner()
        
        if snap.isValidSnap() {
            
            // Snap on the right
            snapLocation = snap.getLocation(self)
            snapped = true
            return
        }
        
        snap = checkForSnapToVisibleFrame_leftEdge()
        
        if snap.isValidSnap() {
            
            snapLocation = snap.getLocation(self)
            snapped = true
            return
        }
        
        snap = checkForSnapToVisibleFrame_rightEdge()
        
        if snap.isValidSnap() {
            
            snapLocation = snap.getLocation(self)
            snapped = true
            return
        }
        
        snap = checkForSnapToVisibleFrame_topEdge()
        
        if snap.isValidSnap() {
            
            snapLocation = snap.getLocation(self)
            snapped = true
            return
        }
        
        snap = checkForSnapToVisibleFrame_bottomEdge()
        
        if snap.isValidSnap() {
            
            snapLocation = snap.getLocation(self)
            snapped = true
            return
        }
    }
    
    private func checkForSnapToVisibleFrame_topLeftCorner() -> SnapToVisibleFrameType {
        
        let visibleFrame = computedVisibleFrame
        
        let snapMinX = visibleFrame.minX
        let snapMaxX = visibleFrame.minX + snapProximity
        let rangeX = snapMinX...snapMaxX
        
        let snapMinY = visibleFrame.maxY - snapProximity
        let snapMaxY = visibleFrame.maxY
        let rangeY = snapMinY...snapMaxY
        
        if rangeX.contains(x) && rangeY.contains(maxY) {
            return .topLeftCorner
        }
        
        return .none
    }
    
    private func checkForSnapToVisibleFrame_topRightCorner() -> SnapToVisibleFrameType {
        
        let visibleFrame = computedVisibleFrame
        
        let snapMinX = visibleFrame.maxX - snapProximity
        let snapMaxX = visibleFrame.maxX
        let rangeX = snapMinX...snapMaxX
        
        let snapMinY = visibleFrame.maxY - snapProximity
        let snapMaxY = visibleFrame.maxY
        let rangeY = snapMinY...snapMaxY
        
        if rangeX.contains(maxX) && rangeY.contains(maxY) {
            return .topRightCorner
        }
        
        return .none
    }
    
    private func checkForSnapToVisibleFrame_bottomRightCorner() -> SnapToVisibleFrameType {
        
        let visibleFrame = computedVisibleFrame
        
        let snapMinX = visibleFrame.maxX - snapProximity
        let snapMaxX = visibleFrame.maxX
        let rangeX = snapMinX...snapMaxX
        
        let snapMinY = visibleFrame.minY
        let snapMaxY = visibleFrame.minY + snapProximity
        let rangeY = snapMinY...snapMaxY
        
        if rangeX.contains(maxX) && rangeY.contains(y) {
            return .bottomRightCorner
        }
        
        return .none
    }
    
    private func checkForSnapToVisibleFrame_bottomLeftCorner() -> SnapToVisibleFrameType {
        
        let visibleFrame = computedVisibleFrame
        
        let snapMinX = visibleFrame.minX
        let snapMaxX = visibleFrame.minX + snapProximity
        let rangeX = snapMinX...snapMaxX
        
        let snapMinY = visibleFrame.minY
        let snapMaxY = visibleFrame.minY + snapProximity
        let rangeY = snapMinY...snapMaxY
        
        if rangeX.contains(x) && rangeY.contains(y) {
            return .bottomLeftCorner
        }
        
        return .none
    }
    
    private func checkForSnapToVisibleFrame_leftEdge() -> SnapToVisibleFrameType {
        
        let visibleFrame = computedVisibleFrame
        
        let snapMinX = visibleFrame.minX
        let snapMaxX = visibleFrame.minX + snapProximity
        let rangeX = snapMinX...snapMaxX
        
        if rangeX.contains(x) {
            return .leftEdge
        }
        
        return .none
    }
    
    private func checkForSnapToVisibleFrame_topEdge() -> SnapToVisibleFrameType {
        
        let visibleFrame = computedVisibleFrame
        
        let snapMinY = visibleFrame.maxY - snapProximity
        let snapMaxY = visibleFrame.maxY
        let rangeY = snapMinY...snapMaxY
        
        if rangeY.contains(maxY) {
            return .topEdge
        }
        
        return .none
    }
    
    private func checkForSnapToVisibleFrame_rightEdge() -> SnapToVisibleFrameType {
        
        let visibleFrame = computedVisibleFrame
        
        let snapMinX = visibleFrame.maxX - snapProximity
        let snapMaxX = visibleFrame.maxX
        let rangeX = snapMinX...snapMaxX
        
        if rangeX.contains(maxX) {
            return .rightEdge
        }
        
        return .none
    }
    
    private func checkForSnapToVisibleFrame_bottomEdge() -> SnapToVisibleFrameType {
        
        let visibleFrame = computedVisibleFrame
        
        let snapMinY = visibleFrame.minY
        let snapMaxY = visibleFrame.minY + snapProximity
        let rangeY = snapMinY...snapMaxY
        
        if rangeY.contains(y) {
            return .bottomEdge
        }
        
        return .none
    }
    
    func ensureOnScreen() {
        
        let myFrame = self.frame
        let visibleFrame = computedVisibleFrame
        
        if !visibleFrame.contains(myFrame) {
            
            // Determine if it is partially contained.
            if myFrame.corners.contains(where: {visibleFrame.contains($0)}) {
                return
            }
            
            // Not partially contained, fully off screen.
            var x: CGFloat = myFrame.minX
            var y: CGFloat = myFrame.minY
            
            if myFrame.minX > visibleFrame.maxX {
                x = visibleFrame.maxX - width
            }
            
            if myFrame.minY > visibleFrame.maxY {
                y = visibleFrame.maxY - height
            }
            
            setFrameOrigin(NSMakePoint(x, y))
        }
    }
}

class SnappingNonKeyWindow: SnappingWindow {
    
    override var canBecomeKey: Bool {false}
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
    
    func getLocation(_ movingWindow: NSWindow, _ mate: NSWindow, _ gapFloat: Float) -> NSPoint {
        
        let gap = CGFloat(gapFloat)
        let mateLoc = mate.origin
        
        switch self {
         
        case .bottom_leftEdges:
            
            return mateLoc.translating(0, -(movingWindow.height + gap))
            
        case .bottom_rightEdges:
            
            return mateLoc.translating(mate.width - movingWindow.width, -(movingWindow.height + gap))
            
        case .top_leftEdges:
            
            return mateLoc.translating(0, mate.height + gap)
            
        case .top_rightEdges:
            
            return mateLoc.translating(mate.width - movingWindow.width, mate.height + gap)
            
        case .right_bottomEdges:
            
            return mateLoc.translating(mate.width + gap, 0)
            
        case .right_topEdges:
            
            return mateLoc.translating(mate.width + gap, mate.height - movingWindow.height)
            
        case .left_bottomEdges:
            
            return mateLoc.translating(-(movingWindow.width + gap), 0)
            
        case .left_topEdges:
            
            return mateLoc.translating(-(movingWindow.width + gap), mate.height - movingWindow.height)
            
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
        
        let visibleFrame = computedVisibleFrame
        
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

fileprivate var computedVisibleFrame: NSRect {NSScreen.main!.visibleFrame}
