//
//  LegacyHistoryPersistentState.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

struct LegacyHistoryPersistentState: Codable {
    
    let recentlyAdded: [LegacyHistoryItemPersistentState]?
    let recentlyPlayed: [LegacyHistoryItemPersistentState]?
    let lastPlaybackPosition: Double?
}

struct LegacyHistoryItemPersistentState: Codable {
    
    let file: URLPath?
    let name: String?
    let time: DateString?
    
    var dateFromTimestamp: Date? {
        
        guard let dateString = self.time else {return nil}
        return Date.fromString(dateString)
    }
}

fileprivate extension Date {
    
    // Constructs a Date from a String of the format: YYYY_MM_DD_hh_mm (created by the serializableString() function).
    static func fromString(_ string: DateString) -> Date? {
        
        // Parse the String into individual date components.
        let dateStringComponents = string.components(separatedBy: "_")
        
        guard dateStringComponents.count == 5,
              let year = Int(dateStringComponents[0]),
              let month = Int(dateStringComponents[1]),
              let day = Int(dateStringComponents[2]),
              let hour = Int(dateStringComponents[3]),
              let minute = Int(dateStringComponents[4]) else {return nil}
        
        let components = DateComponents(year: year, month: month, day: day,
                                        hour: hour, minute: minute, second: 0)
        
        return Calendar(identifier: .gregorian).date(from: components)
    }
}
