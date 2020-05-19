import XCTest

class AuralTestCase: XCTestCase {

    var runLongRunningTests: Bool {return false}
    
    override func perform(_ run: XCTestRun) {
        
        if run.test.name.contains("longRunning") && !runLongRunningTests {
            
            print(String(format: "\tSkipped long running test: %@...", run.test.name))
            return
        }
        
        super.perform(run)
    }
}
