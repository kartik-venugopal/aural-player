//
//  AppMode.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// An enumeration of all application user interface modes.
///
enum AppMode: String, CaseIterable, Codable {
    
    static let defaultMode: AppMode = .modular
    
    case modular
    case unified
    case menuBar
    case widget
    case compact
    
    static func fromLegacyAppMode(_ legacyAppMode: LegacyAppMode?) -> AppMode? {
        
        guard let legacyAppMode = legacyAppMode else {return nil}
        
        switch legacyAppMode {
            
        case .windowed:
            return .modular
            
        case .menuBar:
            return .menuBar
            
        case .widget:
            return .widget
        }
    }
}
