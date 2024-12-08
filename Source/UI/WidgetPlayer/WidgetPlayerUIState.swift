//
//  WidgetPlayerUIState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class WidgetPlayerUIState {
    
    var windowFrame: NSRect?
    static let windowWidthRange: ClosedRange<CGFloat> = 610...10000
    static let windowHeight: CGFloat = 50
    
    static let defaultCornerRadius: CGFloat = 3
    static let cornerRadiusRange: ClosedRange<CGFloat> = 0...20
    var cornerRadius: CGFloat
    
    var trackInfoScrollingEnabled: Bool
    
    var showPlaybackPosition: Bool
    
    init(persistentState: WidgetPlayerUIPersistentState?) {
        
        windowFrame = persistentState?.windowFrame
        cornerRadius = persistentState?.cornerRadius ?? Self.defaultCornerRadius
        
        trackInfoScrollingEnabled = persistentState?.trackInfoScrollingEnabled ?? true
        
        showPlaybackPosition = persistentState?.showPlaybackPosition ?? true
    }
    
    var persistentState: WidgetPlayerUIPersistentState {
        
        WidgetPlayerUIPersistentState(windowFrame: self.windowFrame,
                                      cornerRadius: cornerRadius,
                                      trackInfoScrollingEnabled: trackInfoScrollingEnabled,
                                      showPlaybackPosition: showPlaybackPosition)
    }
}
