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

#if os(iOS)
import UIKit
#endif

///
/// Persistent state for the Control Bar app mode's UI.
///
/// - SeeAlso: `WidgetPlayerUIState`
///
struct WidgetPlayerUIPersistentState: Codable {
    
    let windowFrame: NSRectPersistentState?
    let cornerRadius: CGFloat?
    
    let trackInfoScrollingEnabled: Bool?
    let showPlaybackPosition: Bool?
    
    init(windowFrame: NSRectPersistentState?, cornerRadius: CGFloat?, trackInfoScrollingEnabled: Bool?, showPlaybackPosition: Bool?) {
        self.windowFrame = windowFrame
        self.cornerRadius = cornerRadius
        self.trackInfoScrollingEnabled = trackInfoScrollingEnabled
        self.showPlaybackPosition = showPlaybackPosition
    }
    
    init(legacyPersistentState: LegacyControlBarPlayerUIPersistentState?) {
        
        if let windowOrigin = legacyPersistentState?.windowFrame?.origin, let windowWidth = legacyPersistentState?.windowFrame?.size?.width,
           let windowX = windowOrigin.x, let windowY = windowOrigin.y {
            
            self.windowFrame = NSRectPersistentState(rect: NSMakeRect(windowX, windowY,
                                                                      windowWidth.clamped(to: WidgetPlayerUIState.windowWidthRange),
                                                                      WidgetPlayerUIState.windowHeight))
            
        } else {
            
            self.windowFrame = nil
        }
        
        self.cornerRadius = legacyPersistentState?.cornerRadius?.clamped(to: WidgetPlayerUIState.cornerRadiusRange)
        
        self.trackInfoScrollingEnabled = legacyPersistentState?.trackInfoScrollingEnabled
        self.showPlaybackPosition = legacyPersistentState?.showSeekPosition
    }
}
