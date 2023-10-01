//
//  SeekTimeFormats.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
// Enumeration of all possible formats in which the elapsed seek time is displayed.
public enum TimeElapsedDisplayType: String, CaseIterable, Codable {

    // Displayed as hh:mm:ss
    case formatted
    
    // Displayed as "xyz sec"
    case seconds
    
    // Displayed as "xyz %"
    case percentage
}

// Enumeration of all possible formats in which the remaining seek time is displayed.
public enum TimeRemainingDisplayType: String, CaseIterable, Codable {

    // Remaining seek time is displayed as "- hh:mm:ss"
    case formatted

    // Remaining seek time is displayed as "- xyz sec"
    case seconds
    
    // Remaining seek time is displayed as "- xyz %"
    case percentage
    
    // Track duration is displayed as hh:mm:ss
    case duration_formatted
    
    // Track duration is displayed as "xyz sec"
    case duration_seconds
}
