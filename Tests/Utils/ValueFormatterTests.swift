//
//  ValueFormatterTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

/*
    Unit tests for ValueFormatter
 */
class ValueFormatterTests: XCTestCase {
    
    func testFormatTrackTimes_formatted_startOfTrack() {
        
        doTest(0, 3, .formatted, .formatted, "0:00", "- 0:03")
        doTest(0, 3.1, .formatted, .formatted, "0:00", "- 0:03")
        doTest(0, 3.4999, .formatted, .formatted, "0:00", "- 0:03")
        
        doTest(0.1, 3, .formatted, .formatted, "0:00", "- 0:03")
        doTest(0.4999, 3, .formatted, .formatted, "0:00", "- 0:03")
        
        doTest(0, 3.5, .formatted, .formatted, "0:00", "- 0:04")
        doTest(0, 3.99, .formatted, .formatted, "0:00", "- 0:04")
    }

    func testFormatTrackTimes_formatted_endOfTrack() {
        
        doTest(2.49999, 3, .formatted, .formatted, "0:02", "- 0:01")
        doTest(2.5, 3, .formatted, .formatted, "0:03", "- 0:00")
        doTest(2.999, 3, .formatted, .formatted, "0:03", "- 0:00")
        doTest(3.5, 3.5, .formatted, .formatted, "0:04", "- 0:00")
    }
    
    func testFormatTrackTimes_seconds_startOfTrack() {
        doTest(0, 3.5, .seconds, .seconds, "0 sec", "- 4 sec")
    }
    
    func testFormatTrackTimes_seconds_endOfTrack() {
        doTest(3.5, 3.5, .seconds, .seconds, "4 sec", "- 0 sec")
    }
    
    func testFormatTrackTimes_percentage_startOfTrack() {
        
        doTest(0, 3.5, .percentage, .percentage, "0%", "- 100%")
        
        doTest(3, 300, .percentage, .percentage, "1%", "- 99%")
        doTest(2.9999, 300, .percentage, .percentage, "0%", "- 100%")
        
        doTest(150, 300, .percentage, .percentage, "50%", "- 50%")
        doTest(149, 300, .percentage, .percentage, "49%", "- 51%")
        doTest(153, 300, .percentage, .percentage, "51%", "- 49%")
        
        doTest(1.5, 300, .percentage, .percentage, "0%", "- 100%")
        doTest(1, 300, .percentage, .percentage, "0%", "- 100%")
        doTest(0, 300, .percentage, .percentage, "0%", "- 100%")
    }
    
    func testFormatTrackTimes_percentage_endOfTrack() {
        
        doTest(3.5, 3.5, .percentage, .percentage, "100%", "- 0%")
        
        doTest(297, 300, .percentage, .percentage, "99%", "- 1%")
        doTest(298.4999, 300, .percentage, .percentage, "99%", "- 1%")
        
        doTest(298.5, 300, .percentage, .percentage, "99%", "- 1%")
        doTest(299, 300, .percentage, .percentage, "99%", "- 1%")
        doTest(300, 300, .percentage, .percentage, "100%", "- 0%")
    }
    
    private func doTest(_ elapsedTime: Double, _ trackDuration: Double, _ elapsedTimeFormat: TimeElapsedDisplayType, _ remainingTimeFormat: TimeRemainingDisplayType, _ expectedTimeElapsedString: String, _ expectedTimeRemainingString: String) {
        
        let perc = elapsedTime * 100.0 / trackDuration
        let trackTimes = ValueFormatter.formatTrackTimes(elapsedTime, trackDuration, perc, elapsedTimeFormat, remainingTimeFormat)
        
        XCTAssertEqual(trackTimes.elapsed, expectedTimeElapsedString, String(format: "Expected Elapsed time: '%@', but found: '%@'", expectedTimeElapsedString, trackTimes.elapsed))
        
        XCTAssertEqual(trackTimes.remaining, expectedTimeRemainingString, String(format: "Expected Remaining time: '%@', but found: '%@'", expectedTimeRemainingString, trackTimes.remaining))
    }
}
