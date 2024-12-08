//
//  WidgetPlayerUIPersistentState.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

///
/// Persistent state for the Control Bar app mode's UI.
///
/// - SeeAlso: `WidgetPlayerUIState`
///
struct WidgetPlayerUIPersistentState: Codable {
        
    let windowFrame: NSRect?
    let cornerRadius: CGFloat?
    
    let trackInfoScrollingEnabled: Bool?
    let showPlaybackPosition: Bool?
    
    init(windowFrame: NSRect?, cornerRadius: CGFloat?, trackInfoScrollingEnabled: Bool?, showPlaybackPosition: Bool?) {
        self.windowFrame = windowFrame
        self.cornerRadius = cornerRadius
        self.trackInfoScrollingEnabled = trackInfoScrollingEnabled
        self.showPlaybackPosition = showPlaybackPosition
    }
    
    init(legacyPersistentState: LegacyControlBarPlayerUIPersistentState?) {
        
        if let windowOrigin = legacyPersistentState?.windowFrame?.origin, 
            let windowWidth = legacyPersistentState?.windowFrame?.width {
            
            self.windowFrame = NSMakeRect(windowOrigin.x, windowOrigin.y,
                                          windowWidth.clamped(to: WidgetPlayerUIState.windowWidthRange),
                                          WidgetPlayerUIState.windowHeight)
            
        } else {
            
            self.windowFrame = nil
        }
        
        self.cornerRadius = legacyPersistentState?.cornerRadius?.clamped(to: WidgetPlayerUIState.cornerRadiusRange)
        
        self.trackInfoScrollingEnabled = legacyPersistentState?.trackInfoScrollingEnabled
        self.showPlaybackPosition = legacyPersistentState?.showSeekPosition
    }
}
