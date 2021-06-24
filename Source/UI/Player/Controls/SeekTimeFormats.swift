//
//  SeekTimeFormats.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
// Enumeration of all possible formats in which the elapsed seek time is displayed.
public enum TimeElapsedDisplayType: String {

    // Displayed as hh:mm:ss
    case formatted
    
    // Displayed as "xyz sec"
    case seconds
    
    // Displayed as "xyz %"
    case percentage

    func toggle() -> TimeElapsedDisplayType {

        switch self {

        case .formatted:    return .seconds

        case .seconds:      return .percentage

        case .percentage:   return .formatted

        }
    }
}

// Enumeration of all possible formats in which the remaining seek time is displayed.
public enum TimeRemainingDisplayType: String {

    // Remaining seek time is displayed as "- hh:mm:ss"
    case formatted

    // Track duration is displayed as hh:mm:ss
    case duration_formatted
    
    // Track duration is displayed as "xyz sec"
    case duration_seconds
    
    // Remaining seek time is displayed as "- xyz sec"
    case seconds
    
    // Remaining seek time is displayed as "- xyz %"
    case percentage

    func toggle() -> TimeRemainingDisplayType {

        switch self {

        case .formatted:    return .seconds

        case .seconds:      return .percentage

        case .percentage:   return .duration_formatted

        case .duration_formatted:     return .duration_seconds

        case .duration_seconds:     return .formatted

        }
    }
}
