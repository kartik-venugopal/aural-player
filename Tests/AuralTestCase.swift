import XCTest

class AuralTestCase: XCTestCase {

    var runLongRunningTests: Bool {return false}
    
    var numSkippedTests: Int = 0
    
    override func perform(_ run: XCTestRun) {
        
        if run.test.name.contains("longRunning") && !runLongRunningTests {
            
            print(String(format: "\tSkipped long running test: %@...", run.test.name))
            numSkippedTests.increment()
            return
        }
        
        super.perform(run)
    }
}

extension XCTestCase {
    
    func XCTAssertAllNil(_ expressions: Any?...) {
        expressions.forEach({XCTAssertNil($0)})
    }
}
