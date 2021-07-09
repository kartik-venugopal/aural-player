//
//  WindowAppearanceState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

// Convenient accessor for information about the current appearance settings for the app's main windows.
class WindowAppearanceState {
    
    static let defaultCornerRadius: CGFloat = 3
    static var cornerRadius: CGFloat = defaultCornerRadius
    
    static func initialize(_ persistentState: WindowUIPersistentState?) {
        Self.cornerRadius = persistentState?.cornerRadius ?? WindowAppearanceState.defaultCornerRadius
    }
    
    static var persistentState: WindowUIPersistentState {
        WindowUIPersistentState(cornerRadius: cornerRadius)
    }
}

// A snapshot of WindowAppearanceState
struct WindowAppearance {
    let cornerRadius: CGFloat
}
