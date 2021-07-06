//
//  ControlBarSeekPositionDisplayType.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

enum ControlBarSeekPositionDisplayType: String, CaseIterable, Codable {
    
    case timeElapsed
    case timeRemaining
    case duration
    
    func toggle() -> ControlBarSeekPositionDisplayType {
        
        switch self {
        
        case .timeElapsed:  return .timeRemaining
            
        case .timeRemaining:    return .duration
            
        case .duration:     return .timeElapsed
            
        }
    }
}
