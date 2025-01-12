//
//  EffectsUnitState.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// An enumeration of all possible states an effects unit can be in.
///
@objc enum EffectsUnitState: Int, CaseIterable, Codable {
    
    // Master unit on, and effects unit on
    case active
    
    // Effects unit off
    case bypassed
    
    // Master unit off, and effects unit on
    case suppressed
    
    static func fromLegacyState(_ legacyState: LegacyEffectsUnitState?) -> EffectsUnitState? {
        
        guard let legacyState = legacyState else {return nil}
        
        switch legacyState {
            
        case .active:
            return .active
            
        case .bypassed:
            return .bypassed
            
        case .suppressed:
            return .suppressed
        }
    }
}

typealias EffectsUnitStateFunction = () -> EffectsUnitState

typealias EffectsUnitStateChangeHandler = (EffectsUnitState) -> Void
