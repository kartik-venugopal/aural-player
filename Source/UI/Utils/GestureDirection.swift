//
//  GestureDirection.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// Enumerates all possible directions of a trackpad/MagicMouse swipe/scroll gesture
///
enum GestureDirection: String {
    
    case left
    case right
    case down
    case up
    
    var isHorizontal: Bool {
        self.equalsOneOf(.left, .right)
    }
    
    var isVertical: Bool {
        self.equalsOneOf(.up, .down)
    }
}
