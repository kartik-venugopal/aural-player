//
//  ControlBarPlayerUIPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

fileprivate var screenVisibleFrame: NSRect {
    return NSScreen.main!.visibleFrame
}

class ControlBarPlayerUIPersistenceTests: PersistenceTestCase {
    
    func testPersistence_typicalSettings() {
        
        let visibleFrame = screenVisibleFrame
        let windowFrame = NSRectPersistentState(rect: NSMakeRect(visibleFrame.minX, visibleFrame.maxY - 40,
                                                                 610, 40))
        
        let state = ControlBarPlayerUIPersistentState(windowFrame: windowFrame,
                                                      cornerRadius: 4,
                                                      trackInfoScrollingEnabled: true,
                                                      showSeekPosition: true,
                                                      seekPositionDisplayType: .timeElapsed)
        
        doTestPersistence(serializedState: state)
    }
    
    func testPersistence() {
        
        for _ in 1...1000 {
            
            let state = ControlBarPlayerUIPersistentState(windowFrame: NSRectPersistentState(rect: randomWindowFrame()),
                                                          cornerRadius: CGFloat.random(in: 0...20),
                                                          trackInfoScrollingEnabled: Bool.random(),
                                                          showSeekPosition: Bool.random(),
                                                          seekPositionDisplayType: .randomCase())
            
            doTestPersistence(serializedState: state)
        }
    }
    
    private func randomWindowFrame() -> NSRect {
        
        let visibleFrame = screenVisibleFrame
        return visibleFrame.randomContainedRect(width: CGFloat.random(in: 600...visibleFrame.width),
                                                height: 40)
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension ControlBarPlayerUIPersistentState: Equatable {
    
    static func == (lhs: ControlBarPlayerUIPersistentState, rhs: ControlBarPlayerUIPersistentState) -> Bool {
        
        CGFloat.approxEquals(lhs.cornerRadius, rhs.cornerRadius, accuracy: 0.001) &&
            lhs.seekPositionDisplayType == rhs.seekPositionDisplayType &&
            lhs.showSeekPosition == rhs.showSeekPosition &&
            lhs.trackInfoScrollingEnabled == rhs.trackInfoScrollingEnabled &&
            lhs.windowFrame == rhs.windowFrame
    }
}
