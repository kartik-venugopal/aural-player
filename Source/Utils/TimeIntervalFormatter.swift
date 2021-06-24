//
//  TimeIntervalFormatter.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class TimeIntervalFormatter: Formatter {
    
    var minValue: Double = 0
    var maxValue: Double = Double.greatestFiniteMagnitude
    
    // Used to get the stepper value
    var valueFunction: (() -> String)?
    
    // Used to set the stepper value
    var updateFunction: ((Double) -> Void)?

    override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
        
        if partialString.isEmpty {
            
            if updateFunction != nil {
                updateFunction!(0)
            }
            
            return true
        }
        
        if let num = Double(partialString) {
            
            if num >= minValue && num <= maxValue && updateFunction != nil {
                updateFunction!(num)
            }
            
            return num >= minValue && num <= maxValue
            
        } else {
            
            return false
        }
    }
    
    override func string(for obj: Any?) -> String? {
        return valueFunction != nil ? valueFunction!() : "0"
    }
    
    override func editingString(for obj: Any) -> String? {
        return valueFunction != nil ? valueFunction!() : "0"
    }
    
    override func getObjectValue(_ obj: AutoreleasingUnsafeMutablePointer<AnyObject?>?, for string: String, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {true}
}
