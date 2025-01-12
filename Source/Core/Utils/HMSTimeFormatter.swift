//
//  HMSTimeFormatter.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

///
/// A utility used to format time intervals into a human-readable (user-friendly) format.
///
/// Example:
///
/// `3798.9345 seconds -> "01:03:19"`
///
class HMSTimeFormatter: Formatter {
    
    var minValue: Double = 0
    var maxValue: Double = 1000 * 60 * 60    // 100 hours
    
    // Used to get the stepper value
    var valueFunction: (() -> String)?
    
    // Used to set the stepper value
    var updateFunction: ((Double) -> Void)?
    
    override func isPartialStringValid(_ partialString: String,
                                       newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?,
                                       errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        if partialString.isEmpty {

            updateFunction?(0)
            return true
        }
        
        let hmsComponents = partialString.split(separator: ":")
        let numComponents = hmsComponents.count
        
        var hours = 0
        var minutes = 0
        var seconds = 0
        var totalSeconds: Double = 0
        
        switch numComponents {
            
        case 3:
            
            hours = Int(hmsComponents[0]) ?? 0
            minutes = Int(hmsComponents[1]) ?? 0
            seconds = Int(hmsComponents[2]) ?? 0
            
        case 2:
            
            minutes = Int(hmsComponents[0]) ?? 0
            seconds = Int(hmsComponents[1]) ?? 0
            
        case 1:
            
            seconds = Int(hmsComponents[0]) ?? 0
            
        default:
            
            break
        }
        
        guard (0...1000).contains(hours), (0...59).contains(minutes), (0...59).contains(seconds) else {return false}
        
        totalSeconds = Double((hours * 3600) + (minutes * 60) + seconds)
        
        if totalSeconds > maxValue {return false}
        
        updateFunction?(Double(totalSeconds))
        return true
    }
    
    override func string(for obj: Any?) -> String? {
        valueFunction?() ?? "00:00:00"
    }
    
    override func editingString(for obj: Any) -> String? {
        valueFunction?() ?? "00:00:00"
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
                                 for string: String,
                                 errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {true}
}
