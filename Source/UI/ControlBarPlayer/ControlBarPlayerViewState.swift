//
//  ControlBarPlayerViewState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class ControlBarPlayerViewState {
    
    static var windowFrame: NSRect?
    
    static let defaultCornerRadius: CGFloat = 3
    static var cornerRadius: CGFloat = defaultCornerRadius
    
    static var showSeekPosition: Bool = true
    static var seekPositionDisplayType: ControlBarSeekPositionDisplayType = .timeElapsed
    static var trackInfoScrollingEnabled: Bool = true
    
    static func initialize(_ persistentState: ControlBarPlayerUIPersistentState?) {
        
        windowFrame = persistentState?.windowFrame?.toNSRect()
        cornerRadius = persistentState?.cornerRadius ?? defaultCornerRadius
        
        trackInfoScrollingEnabled = persistentState?.trackInfoScrollingEnabled ?? true
        
        showSeekPosition = persistentState?.showSeekPosition ?? true
        seekPositionDisplayType = persistentState?.seekPositionDisplayType ?? .timeElapsed
    }
    
    static var persistentState: ControlBarPlayerUIPersistentState {
        
        var windowFrame: NSRectPersistentState? = nil
        
        if let frame = Self.windowFrame {
            windowFrame = NSRectPersistentState(rect: frame)
        }
        
        return ControlBarPlayerUIPersistentState(windowFrame: windowFrame,
                                                 cornerRadius: cornerRadius,
                                                 trackInfoScrollingEnabled: trackInfoScrollingEnabled,
                                                 showSeekPosition: showSeekPosition,
                                                 seekPositionDisplayType: seekPositionDisplayType)
    }
}
