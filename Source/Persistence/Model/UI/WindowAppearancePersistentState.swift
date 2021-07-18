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

///
/// Persistent state for window appearance settings.
///
/// - SeeAlso: `WindowAppearanceState`
///
struct WindowAppearancePersistentState: Codable {
    
    let cornerRadius: CGFloat?
}
