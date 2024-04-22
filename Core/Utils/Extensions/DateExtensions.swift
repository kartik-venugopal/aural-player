//
//  DateExtensions.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
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
    
    // Returns a String suitable for serialization as a timestamp, in the format: YYYY_MM_DD_hh_mm_ss
    var serializableStringAsHMS: String {
        String(format: "%d_%d_%d_%d_%d_%d", year, month, day, hour, minute, second)
    }
    
    // Returns this date with time set to 00:00:00
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var second: Int {
        Calendar.current.component(.second, from: self)
    }
    
    // Returns the minute component of this Date
    var minute: Int {
        Calendar.current.component(.minute, from: self)
    }

    // Returns the hour component of this Date
    var hour: Int {
        Calendar.current.component(.hour, from: self)
    }

    // Returns the day component of this Date
    var day: Int {
        Calendar.current.component(.day, from: self)
    }

    // Returns the month component of this Date
    var month: Int {
        Calendar.current.component(.month, from: self)
    }

    // Returns the year component of this Date
    var year: Int {
        Calendar.current.component(.year, from: self)
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
    
    private static let timestampFormatter = DateFormatter(format: "H:mm:ss.SSS")
    private static let hmsFormatter = DateFormatter(format: "dd-MM-yyyy H:mm:ss")
    
    var hmsString: String {
        Self.hmsFormatter.string(from: self)
    }
    
    static var nowTimestampString: String {
        timestampFormatter.string(from: Date())
    }
    
    static var nowEpochTime: Int {
        Int(NSDate().timeIntervalSince1970)
    }
    
    var epochTime: Int {
        Int(timeIntervalSince1970)
    }
}

extension DateFormatter {
    
    convenience init(format: String) {
        
        self.init()
        self.dateFormat = format
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
