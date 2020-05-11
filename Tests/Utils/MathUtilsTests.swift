import XCTest

/*
    Unit tests for MathUtils global functions
 */
class MathUtilsTests: XCTestCase {

    func testRoundedInt_Float() {
        
        XCTAssertEqual(roundedInt(Float(5.5)), 6)
        XCTAssertEqual(roundedInt(Float(5)), 5)
        XCTAssertEqual(roundedInt(Float(5.0000001)), 5)
        XCTAssertEqual(roundedInt(Float(4.99)), 5)
        XCTAssertEqual(roundedInt(Float(4.499999)), 4)
    }
    
    func testRoundedInt_Double() {
        
        XCTAssertEqual(roundedInt(5.5), 6)
        XCTAssertEqual(roundedInt(5.0), 5)
        XCTAssertEqual(roundedInt(5.0000001), 5)
        XCTAssertEqual(roundedInt(4.99), 5)
        XCTAssertEqual(roundedInt(4.499999), 4)
    }
    
    func testFloorInt_Float() {
        
        XCTAssertEqual(floorInt(Float(5.5)), 5)
        XCTAssertEqual(floorInt(Float(5.75)), 5)
        XCTAssertEqual(floorInt(Float(5)), 5)
        XCTAssertEqual(floorInt(Float(5.0000001)), 5)
        XCTAssertEqual(floorInt(Float(4.999999)), 4)
        XCTAssertEqual(floorInt(Float(4.499999)), 4)
    }
    
    func testFloorInt_Double() {
        
        XCTAssertEqual(floorInt(5.5), 5)
        XCTAssertEqual(floorInt(5.75), 5)
        XCTAssertEqual(floorInt(5.0), 5)
        XCTAssertEqual(floorInt(5.0000001), 5)
        XCTAssertEqual(floorInt(4.999999), 4)
        XCTAssertEqual(floorInt(4.499999), 4)
    }
}
