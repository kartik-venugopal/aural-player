//
//  TimeIntervalFormatter.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

///
/// A utility used to format time intervals into a human-readable (user-friendly) format.
///
/// Example:
///
/// `3798.9345 seconds -> "01:03:19"`
///
class TimeIntervalFormatter: Formatter {
    
    var minValue: Double = 0
    var maxValue: Double = .greatestFiniteMagnitude
    
    // Used to get the stepper value
    var valueFunction: (() -> String)?
    
    // Used to set the stepper value
    var updateFunction: ((Double) -> Void)?

    override func isPartialStringValid(_ partialString: String,
                                       newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?,
                                       errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        if partialString.isEmpty, let updateFunction = updateFunction {

            updateFunction(0)
            return true
        }
        
        if let num = Double(partialString) {
            
            let numInRange = (minValue...maxValue).contains(num)
            
            if numInRange, let updateFunction = self.updateFunction {
                updateFunction(num)
            }
            
            return numInRange
            
        } else {
            
            return false
        }
    }
    
    override func string(for obj: Any?) -> String? {
        valueFunction?() ?? "0"
    }
    
    override func editingString(for obj: Any) -> String? {
        valueFunction?() ?? "0"
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
                                 for string: String,
                                 errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {true}
}
