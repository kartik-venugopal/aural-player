import XCTest

/*
    Unit tests for StringUtils
 */
class StringUtilsTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
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
    }
    
    func testFormatTrackTimes_percentage_endOfTrack() {
        doTest(3.5, 3.5, .percentage, .percentage, "100%", "- 0%")
    }
    
    private func doTest(_ elapsedTime: Double, _ trackDuration: Double, _ elapsedTimeFormat: TimeElapsedDisplayType, _ remainingTimeFormat: TimeRemainingDisplayType, _ expectedTimeElapsedString: String, _ expectedTimeRemainingString: String) {
        
        let perc = elapsedTime * 100.0 / trackDuration
        let trackTimes = StringUtils.formatTrackTimes(elapsedTime, trackDuration, perc, elapsedTimeFormat, remainingTimeFormat)
        
        XCTAssertEqual(trackTimes.elapsed, expectedTimeElapsedString, String(format: "Expected Elapsed time: '%@', but found: '%@'", expectedTimeElapsedString, trackTimes.elapsed))
        
        XCTAssertEqual(trackTimes.remaining, expectedTimeRemainingString, String(format: "Expected Remaining time: '%@', but found: '%@'", expectedTimeRemainingString, trackTimes.remaining))
    }
}
