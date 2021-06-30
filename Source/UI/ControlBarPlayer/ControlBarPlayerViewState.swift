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
    static var seekPositionDisplayType: SeekPositionDisplayType = .timeElapsed
    static var trackInfoScrollingEnabled: Bool = true
}
