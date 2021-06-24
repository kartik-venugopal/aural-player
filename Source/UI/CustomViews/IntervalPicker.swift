//
//  IntervalPicker.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
                self.maxDate = minDate.addingTimeInterval(maxInterval)
            }
        }
    }
    
    var interval: Double {
        
        if let minDate = self.minDate {
            return self.dateValue.timeIntervalSince(minDate)
        } else {
            return 0
        }
    }
    
    func setInterval(_ interval: Double) {
        self.dateValue = self.minDate!.addingTimeInterval(interval)
    }
    
    func reset() {
        self.dateValue = self.minDate!
    }

    override func awakeFromNib() {

        self.datePickerStyle = .textFieldAndStepper
        self.datePickerElements = .hourMinuteSecond
        self.font = Fonts.Standard.mainFont_11
        
        // 24 hour clock (don't want AM/PM)
        self.locale = Locale(identifier: "en_GB")
        
        let startOfDay = Date().startOfDay
        
        self.minDate = startOfDay
        self.maxDate = startOfDay.addingTimeInterval(maxInterval)
        self.dateValue = startOfDay
    }
}

@IBDesignable
class FormattedIntervalLabel: NSTextField {
    
    @IBInspectable var interval: Double = 0 {
        
        didSet {
            self.stringValue = interval != 0 ? ValueFormatter.formatSecondsToHMS_hrMinSec(Int(round(interval))) : "0 sec"
        }
    }
    
    override func awakeFromNib() {
        
        self.alignment = .left
        self.font = Fonts.Standard.mainFont_11
        self.isBordered = false
        self.drawsBackground = false
        self.textColor = Colors.defaultLightTextColor
    }
}
