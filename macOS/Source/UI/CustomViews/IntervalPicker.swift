//
//  IntervalPicker.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

@IBDesignable
class IntervalPicker: NSDatePicker {
    
    @IBInspectable var maxInterval: Double = 86400 {
        
        didSet {
            
            if let minDate = self.minDate {
                maxDate = minDate.addingTimeInterval(maxInterval)
            }
        }
    }
    
    var interval: Double {
        
        if let minDate = self.minDate {
            return dateValue.timeIntervalSince(minDate)
        } else {
            return 0
        }
    }
    
    func setInterval(_ interval: Double) {
        
        if let minDate = self.minDate {
            dateValue = minDate.addingTimeInterval(interval)
        }
    }
    
    func reset() {
        
        if let minDate = self.minDate {
            dateValue = minDate
        }
    }

    override func awakeFromNib() {

        self.datePickerStyle = .textFieldAndStepper
        self.datePickerElements = .hourMinuteSecond
        self.font = standardFontSet.mainFont(size: 11)
        
        // 24 hour clock (don't want AM/PM)
        self.locale = Locale(identifier: "en_US")
        
        let startOfDay = Date().startOfDay
        
        self.minDate = startOfDay
        self.maxDate = startOfDay.addingTimeInterval(maxInterval)
        self.dateValue = startOfDay
    }
}
