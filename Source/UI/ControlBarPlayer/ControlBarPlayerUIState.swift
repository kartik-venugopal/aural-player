//
//  ControlBarPlayerUIState.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class ControlBarPlayerUIState {
    
    var windowFrame: NSRect?
    
    static let defaultCornerRadius: CGFloat = 3
    var cornerRadius: CGFloat
    
    var trackInfoScrollingEnabled: Bool
    
    var showSeekPosition: Bool
    var seekPositionDisplayType: ControlBarSeekPositionDisplayType
    
    init(persistentState: ControlBarPlayerUIPersistentState?) {
        
        windowFrame = persistentState?.windowFrame?.toNSRect()
        cornerRadius = persistentState?.cornerRadius ?? Self.defaultCornerRadius
        
        trackInfoScrollingEnabled = persistentState?.trackInfoScrollingEnabled ?? true
        
        showSeekPosition = persistentState?.showSeekPosition ?? true
        seekPositionDisplayType = persistentState?.seekPositionDisplayType ?? .timeElapsed
    }
    
    var persistentState: ControlBarPlayerUIPersistentState {
        
        var windowFrame: NSRectPersistentState? = nil
        
        if let frame = self.windowFrame {
            windowFrame = NSRectPersistentState(rect: frame)
        }
        
        return ControlBarPlayerUIPersistentState(windowFrame: windowFrame,
                                                 cornerRadius: cornerRadius,
                                                 trackInfoScrollingEnabled: trackInfoScrollingEnabled,
                                                 showSeekPosition: showSeekPosition,
                                                 seekPositionDisplayType: seekPositionDisplayType)
    }
}
