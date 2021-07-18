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
    var cornerRadius: CGFloat = defaultCornerRadius
    
    init(persistentState: WindowAppearancePersistentState?) {
        cornerRadius = persistentState?.cornerRadius ?? WindowAppearanceState.defaultCornerRadius
    }
    
    var persistentState: WindowAppearancePersistentState {
        WindowAppearancePersistentState(cornerRadius: cornerRadius)
    }
}

// A snapshot of WindowAppearanceState
struct WindowAppearance {
    let cornerRadius: CGFloat
}
