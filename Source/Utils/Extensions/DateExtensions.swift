//
//  DateExtensions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

// Constants representing different time intervals (in seconds)

fileprivate let oneHour: TimeInterval = 3600
fileprivate let oneDay: TimeInterval = 24 * oneHour
fileprivate let oneWeek: TimeInterval = 7 * oneDay
fileprivate let thirtyDays: TimeInterval = 30 * oneDay

// Convenience utility functions
extension Date {
    
    // Returns this date with time set to 00:00:00
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    // Returns a String suitable for serialization as a timestamp, in the format: YYYY_MM_DD_hh_mm
    func serializableString() -> String {
        
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        
        return String(format: "%d_%d_%d_%d_%d", year, month, day, hour, minute)
    }
    
    // Returns a String suitable for serialization as a timestamp, in the format: YYYY_MM_DD_hh_mm_ss
    func serializableString_hms() -> String {
        
        let calendar = Calendar.current
        
        let year = calendar.component(.year, from: self)
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        let hour = calendar.component(.hour, from: self)
        let minute = calendar.component(.minute, from: self)
        let second = calendar.component(.second, from: self)
        
        return String(format: "%d_%d_%d_%d_%d_%d", year, month, day, hour, minute, second)
    }
    
    // Constructs a Date from a String of the format: YYYY_MM_DD_hh_mm (created by the serializableString() function)
    static func fromString(_ string: String) -> Date {
        
        // Parse the String into individual date components
        let dateStringComponents = string.components(separatedBy: "_")
        
        let year = Int(dateStringComponents[0])!
        let month = Int(dateStringComponents[1])!
        let day = Int(dateStringComponents[2])!
        let hour = Int(dateStringComponents[3])!
        let minute = Int(dateStringComponents[4])!
        
        let components = DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: 0)
        
        return Calendar(identifier: .gregorian).date(from: components)!
    }
    
    // Returns the minute component of this Date
    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }
    
    // Returns the hour component of this Date
    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }
    
    // Returns the day component of this Date
    var day: Int {
        return Calendar.current.component(.day, from: self)
    }
    
    // Returns the month component of this Date
    var month: Int {
        return Calendar.current.component(.month, from: self)
    }
    
    // Returns the year component of this Date
    var year: Int {
        return Calendar.current.component(.year, from: self)
    }
    
    // Computes a time category (see TimeElapsed) representing the time elapsed since a given date (until now)
    static func timeElapsedSince(_ date: Date) -> TimeElapsed {
        
        // Convert a TimeInterval to a TimeElapsed
        
        let timeElapsed = Date().timeIntervalSince(date)
        
        if timeElapsed > thirtyDays {
            return .olderThan30Days
        }
        
        if timeElapsed > oneWeek {
            return .past30Days
        }
        
        if timeElapsed > oneDay {
            return .past7Days
        }
        
        if timeElapsed > oneHour {
            return .past24Hours
        }
        
        return .pastHour
    }
}

// Enumerates time categories that can be used to group historical data, describing when an event occurred, based on its timestamp. For example, an item that was played 10 minutes ago falls into the category "Past hour".
enum TimeElapsed: String {
    
    case pastHour = "Past hour"
    
    case past24Hours = "Past 24 hours"
    
    case past7Days = "Past 7 days"
    
    case past30Days = "Past 30 days"
    
    case olderThan30Days = "Older than 30 days"
}
