//
//  ValueFormatter.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Utilities for formatting numerical values into user-friendly displayable representations with units (e.g. "20 Hz" for frequency values).
///
class ValueFormatter {
    
    private static var numberFormatter = { () -> NumberFormatter in
        
       let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.minimumIntegerDigits = 1
        
        return formatter
    }()
    
    // Time values in seconds
    static let oneMin = 60
    static let oneHour = 60 * oneMin
    
    // Given the elapsed time, in seconds, for a playing track, and its duration (also in seconds), returns 2 formatted strings: 1 - Formatted elapsed time, and 2 - Formatted time remaining. See formatSecondsToHMS()
    static func formatPlaybackPosition(elapsedSeconds: Double, duration: Double, percentageElapsed: Double, playbackPositionDisplayType: PlaybackPositionDisplayType) -> String {
        
        switch playbackPositionDisplayType {
         
        case .elapsed:

            return formatSecondsToHMS(elapsedSeconds)

        case .remaining:
            
            let elapsedSecondsInt = elapsedSeconds.roundedInt
            let durationInt = duration.roundedInt
            
            return formatSecondsToHMS(durationInt - elapsedSecondsInt, true)

        case .duration:

            return formatSecondsToHMS(duration)
        }
    }
    
    // Given the elapsed time, in seconds, for a playing track, and its duration (also in seconds), returns 2 formatted strings: 1 - Formatted elapsed time, and 2 - Formatted time remaining. See formatSecondsToHMS()
    static func formatPlaybackPositions(_ elapsedSeconds: Double, _ duration: Double, _ percentageElapsed: Double) -> (elapsed: String, remaining: String) {
        
        var remainingString: String
        
        let elapsedString = formatSecondsToHMS(elapsedSeconds)

        let elapsedSecondsInt = elapsedSeconds.roundedInt
            let durationInt = duration.roundedInt
        
        remainingString = formatSecondsToHMS(durationInt - elapsedSecondsInt, true)
         
        return (elapsedString, remainingString)
    }
    
    /* Formats a duration (time interval) from seconds to a displayable string showing hours, minutes, and seconds. For example, 500 seconds becomes "8:20", and 3675 seconds becomes "1:01:15".
     
        The "includeMinusPrefix" indicates whether or not to include a prefix of "-" in the formatted string returned.
    */
    static func formatSecondsToHMS(_ timeSecondsDouble: Double, _ includeMinusPrefix: Bool = false) -> String {
        return formatSecondsToHMS(timeSecondsDouble.roundedInt)
    }
    
    static func formatSecondsToHMS(_ timeSeconds: Int, _ includeMinusPrefix: Bool = false) -> String {
        
        let secs = timeSeconds % oneMin
        let mins = (timeSeconds / oneMin) % oneMin
        let hrs = timeSeconds / oneHour
        
        return hrs > 0 ? String(format: "%@%d:%02d:%02d", includeMinusPrefix ? "- " : "", hrs, mins, secs) : String(format: "%@%d:%02d", includeMinusPrefix ? "- " : "", mins, secs)
    }
    
    // Formats a duration (time interval) from seconds to a displayable string showing minutes, and seconds. For example, 500 seconds becomes "8 min 20 sec", 120 seconds becomes "2 min", and 36 seconds becomes "36 sec"
    static func formatSecondsToHMS_hrMinSec(_ duration: Int) -> String {
        
        let hrs = duration / oneHour
        let mins = (duration - (hrs * oneHour)) / oneMin
        let secs = duration % oneMin
        
        var hrsStr = ""
        
        if hrs > 0 {
            hrsStr = String(format: "%d hr ", hrs)
        }
        
        var secsStr = "0 sec"
        
        if secs > 0 {
            secsStr = String(format: "%d sec", secs)
        } else {
            secsStr = ""
        }
        
        var minsStr = ""
        
        if mins > 0 {
            minsStr = String(format: "%d min ", mins)
        } else {
            minsStr = hrs > 0 ? (secs > 0 ?  "0 min " : "") : ""
        }
        
        let fStr = String(format: "%@%@%@", hrsStr, minsStr, secsStr)
        
        return fStr
    }
    
    static func formatVolume(_ value: Float) -> String {
        return String(format: "%d%%", value.roundedInt)
    }
    
    static func formatPan(_ value: Float) -> String {
        
        let panVal = value.roundedInt
        let absVal = abs(panVal)
        
        if panVal < 0 {
            
            // Left of center
            return absVal < 100 ? "\(absVal)%  Left" : "Left"
            
        } else if panVal > 0 {
            
            // Right of center
            return absVal < 100 ? "\(absVal)%  Right" : "Right"
            
        } else {
            
            // Center
            return "Center"
        }
    }
    
    static func formatPitch(_ value: Float) -> String {
        PitchShift(fromCents: value).formattedString
    }
    
    static func formatTimeStretchRate(_ value: Float) -> String {
        return ValueFormatter.formatValueWithUnits(NSNumber(value: value), 2, Units.timeStretchRate, false)
    }
    
    static func formatReverbAmount(_ value: Float) -> String {
        
        if value == 0 {
            return String(format: "100%% %@", Units.reverbDryAmount)
            
        } else if value == 100 {
            return String(format: "100%% %@", Units.reverbWetAmount)
            
        } else {
            
            let dry = value.roundedInt
            let wet = 100 - dry
            return String(format:"%d / %d", dry, wet)
        }
    }
    
    static func formatDelayTime(_ value: Double) -> String {
        return ValueFormatter.formatValueWithUnits(NSNumber(value: value), 2, Units.delayTimeSecs, false)
    }
    
    static func formatDelayAmount(_ value: Float) -> String {
        return ValueFormatter.formatValue(NSNumber(value: value), 0)
    }
    
    static func formatDelayFeedback(_ value: Float) -> String {
        return ValueFormatter.formatValueWithUnits(NSNumber(value: value), 0, Units.delayFeedbackPerc, false)
    }
    
    static func formatDelayLowPassCutoff(_ value: Float) -> String {
        return formatFrequency(value)
    }
    
    static func formatFilterFrequencyRange(_ value1: Double, _ value2: Double) -> String {
        return String(format: "[ %d %@ - %d %@ ]", Int(value1), Units.frequencyHz, Int(value2), Units.frequencyHz)
    }
    
    static func formatFilterFrequencyRange(_ value1: Float, _ value2: Float) -> String {
        return String(format: "[ %d %@ - %d %@ ]", Int(value1), Units.frequencyHz, Int(value2), Units.frequencyHz)
    }
    
    static func formatFrequency(_ value: Float) -> String {
        return String(format: "%d %@", Int(value), Units.frequencyHz)
    }
    
    static func formatValueWithUnits(_ value: NSNumber, _ decimalDigits: Int, _ unit: String, _ includeSpace: Bool) -> String {
        
        numberFormatter.maximumFractionDigits = decimalDigits
        
        var numStr = numberFormatter.string(from: value)!
        
        if (numStr == "-0") {
            numStr = "0"
        }
        
        return includeSpace ? String(format: "%@ %@", numStr, unit) : String(format: "%@%@", numStr, unit)
    }
    
    static func formatValue(_ value: NSNumber, _ decimalDigits: Int) -> String {
        
        numberFormatter.locale = Locale(identifier: "en_US_POSIX")
        numberFormatter.maximumFractionDigits = decimalDigits
        numberFormatter.minimumIntegerDigits = 1
        
        return numberFormatter.string(from: value)!
    }
    
    static func formatPixels(_ value: Float) -> String {
        
        return formatValueWithUnits(NSNumber(value: value), 0, Units.screenRealEstatePixel, false)
    }
    
    // Provides a comma separated String representation of an integer, that is easy to read. For ex, 15700900 -> "15,700,900"
    static func readableLongInteger(_ num: Int64) -> String {
        
        let numString = String(num)
        var readableNumString: String = ""
        
        // Last index of numString
        let numDigits: Int = numString.count - 1
        
        var c = 0
        for eachCharacter in numString {
            readableNumString.append(eachCharacter)
            if (c < numDigits && (numDigits - c) % 3 == 0) {
                readableNumString.append(",")
            }
            c.increment()
        }
        
        return readableNumString
    }
    
    static func commaSeparatedInt(_ num: Int) -> String {
        
        let numString = String(num)
        var readableNumString: String = ""
        
        // Last index of numString
        let numDigits: Int = numString.count - 1
        
        var c = 0
        for eachCharacter in numString {
            readableNumString.append(eachCharacter)
            if (c < numDigits && (numDigits - c) % 3 == 0) {
                readableNumString.append(",")
            }
            c.increment()
        }
        
        return readableNumString
    }
    
    struct Units {

        // Units for different effects parameters
        
        static let pitchOctaves: String = "8ve"
        static let pitchCents: String = "cents"
        static let timeStretchRate: String = "x"
        static let reverbWetAmount: String = "wet"
        static let reverbDryAmount: String = "dry"
        static let delayTimeSecs: String = "s"
        static let delayFeedbackPerc: String = "%"
        static let frequencyHz: String = "Hz"
        static let screenRealEstatePixel: String = "px"
    }
}
