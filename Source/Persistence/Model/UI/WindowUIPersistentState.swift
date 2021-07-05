//
//  WindowUIPersistentState.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

struct WindowUIPersistentState: Codable {
    
    var cornerRadius: CGFloat?
    
    init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
    }
}

extension WindowAppearanceState {
    
    static func initialize(_ persistentState: WindowUIPersistentState?) {
        Self.cornerRadius = persistentState?.cornerRadius ?? WindowAppearanceState.defaultCornerRadius
    }
    
    static var persistentState: WindowUIPersistentState {
        WindowUIPersistentState(cornerRadius: cornerRadius)
    }
}
