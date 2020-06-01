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
    
    func executeAfter(_ timeSeconds: Double, _ work: (@escaping () -> Void)) {
        
        let theExpectation = expectation(description: "some expectation")
        
        DispatchQueue.global(qos: .userInteractive).asyncAfter(deadline: .now() + timeSeconds) {
            
            work()
            theExpectation.fulfill()
        }
        
        wait(for: [theExpectation], timeout: timeSeconds + 1)
    }
}

extension XCTestCase {
    
    func XCTAssertAllNil(_ expressions: Any?...) {
        expressions.forEach({XCTAssertNil($0)})
    }
}
