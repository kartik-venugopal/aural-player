//
//  AppMode.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// An enumeration of all application user interface modes.
///
enum AppMode: String, CaseIterable, Codable {
    
    static let defaultMode: AppMode = .windowed
    
    case windowed
    case menuBar
    case controlBar
}
