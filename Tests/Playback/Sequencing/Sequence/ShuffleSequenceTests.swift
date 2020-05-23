import XCTest

/*
    Unit tests for ShuffleSequence.
 */
class ShuffleSequenceTests: AuralTestCase {
    
    //    override var runLongRunningTests: Bool {return true}
    
    private var sequence: ShuffleSequence = ShuffleSequence()
    
    private var sequenceArray: [Int] {
        return sequence.sequence
    }
    
    private var sequenceArrayCount: Int {
        return sequenceArray.count
    }
    
    override func setUp() {
        
        // Start with a fresh object before each test
        sequence = ShuffleSequence()
    }
    
    // Check that in a sequence of size n, all the numbers from 0 to n-1 are present exactly once.
    private func checkSequenceRangeAndUniqueness() {
        
        var numberCounts: [Int: Int] = [:]
        
        for num in sequenceArray {
            
            if numberCounts[num] == nil {
                numberCounts[num] = 1
                
            } else if let curCountOfNum = numberCounts[num] {
                numberCounts[num] = curCountOfNum + 1
            }
        }
        
        // Ensure that the dictionary contains exactly as many elements as the sequence array
        // (this implies that there are n unique elements in the array).
        XCTAssertEqual(numberCounts.count, sequenceArrayCount)
        
        // Finally, check that the numbers in the sequence are 0, 1, 2, ..., n - 1
        for num in 0..<sequenceArrayCount {
            XCTAssertEqual(numberCounts[num], 1)
        }
    }
    
    // MARK: size tests --------------------------------------------------------------------------------------------------------------
    
    func testSize_upTo100Elements_startFromEmptySequence() {
        doTestSize(1...100, true)
    }
    
    // Long running test: ~ 1 minute
    func testSize_100To1000Elements_startFromEmptySequence_longRunning() {
        doTestSize(101...1000, true)
    }
    
    // Long running test: ~ 1 minute
    func testSize_moreThan1000Elements_startFromEmptySequence_longRunning() {
        doTestSize(1001...10000, true)
    }
    
    func testSize_upTo100Elements() {
        doTestSize(1...100, false)
    }
    
    // Long running test: ~ 1 minute
    func testSize_100To1000Elements_longRunning() {
        doTestSize(101...1000, false)
    }
    
    // Long running test: ~ 1 minute
    func testSize_moreThan1000Elements_longRunning() {
        doTestSize(1001...10000, false)
    }
    
    private func doTestSize(_ sizes: ClosedRange<Int>, _ clearSequenceBeforeTest: Bool) {
        
        for size in sizes {
            
            if clearSequenceBeforeTest {
                sequence.clear()
            }
            
            sequence.resizeAndReshuffle(size: size)
            
            XCTAssertEqual(sequenceArrayCount, size)
            XCTAssertEqual(sequence.size, size)
        }
    }
    
    func testResizeAndReshuffle_upTo100Elements() {
        doTestResizeAndReshuffle_sizeRange(1...100, nil, false)
    }
    
    // Long running test: ~ 2 minutes
    func testResizeAndReshuffle_100To1000Elements_longRunning() {
        doTestResizeAndReshuffle_sizeRange(101...1000, 50, false)
    }
    
    // Long running test: ~ 20 minutes
    func testResizeAndReshuffle_moreThan1000Elements_longRunning() {
        doTestResizeAndReshuffle_sizeRange(1001...10000, 50, false)
    }
    
    func testResizeAndReshuffle_upTo100Elements_startWithEmptySequence() {
        doTestResizeAndReshuffle_sizeRange(1...100, nil, true)
    }
    
    // Long running test: ~ 2 minutes
    func testResizeAndReshuffle_100To1000Elements_startWithEmptySequence_longRunning() {
        doTestResizeAndReshuffle_sizeRange(101...1000, 50, true)
    }
    
    // Long running test: ~ 20 minutes
    func testResizeAndReshuffle_moreThan1000Elements_startWithEmptySequence_longRunning() {
        doTestResizeAndReshuffle_sizeRange(1001...10000, 50, true)
    }
    
    private func doTestResizeAndReshuffle_sizeRange(_ sizeRange: ClosedRange<Int>, _ numberOfStartValues: Int?, _ clearSequenceBeforeEachTest: Bool) {
        
        for size in sizeRange {
            
            doTestResizeAndReshuffle(size, nil, clearSequenceBeforeEachTest)
            
            var testStartValues: [Int]
            
            if let startValuesCount = numberOfStartValues {
                
                // Test with random start values, limit count to the number specified.
                // Generate random numbers and use them as starting values in the tests.
                // Also test with the first and last elements
                testStartValues = [0, size - 1]
                
                for _ in 1...startValuesCount {
                    testStartValues.append(Int.random(in: 1..<(size - 1)))
                }
                
            } else {
                
                // Test with all values from 0 to size - 1 as the start value.
                testStartValues = Array(0..<size)
            }
            
            for startValue in testStartValues {
                doTestResizeAndReshuffle(size, startValue, clearSequenceBeforeEachTest)
            }
        }
    }
    
    private func doTestResizeAndReshuffle(_ size: Int, _ desiredStartValue: Int?, _ clearSequenceBeforeTest: Bool) {
        
        if clearSequenceBeforeTest {
            sequence.clear()
        }
        
        sequence.resizeAndReshuffle(size: size, startWith: desiredStartValue)
        
        // Ensure that the sequence is pointing to either the first element or no element (i.e. nil),
        // depending on whether desiredStartValue is nil or not (i.e. iteration).
        XCTAssertEqual(desiredStartValue, sequence.currentValue)
        
        // Verify the sequence size property
        XCTAssertEqual(sequence.size, size)
        
        // Match the actual array count with the expected size.
        XCTAssertEqual(sequenceArrayCount, size)
        
        checkSequenceRangeAndUniqueness()
        
        // Ensure that the start value matches the desired value.
        if let startValue = desiredStartValue {
            
            XCTAssertEqual(sequenceArray.first, startValue)
            
            // If a start value has been selected, calling peekNext() should produce the 2nd value in the sequence, i.e. with index=1.
            if size > 1 {
                XCTAssertEqual(sequenceArray[1], sequence.peekNext())
            }
            
        } else {
            
            // If no start value is given, calling peekNext() should produce the first value in the sequence.
            XCTAssertEqual(sequenceArray.first, sequence.peekNext())
        }
    }
    
    func testResizeAndReshuffle_size0_withStartIndex() {
        
        sequence.resizeAndReshuffle(size: 10, startWith: 5)
        XCTAssertEqual(sequence.size, 10)
        XCTAssertEqual(sequence.currentValue, 5)
        
        sequence.resizeAndReshuffle(size: 0, startWith: 7)
        XCTAssertEqual(sequence.size, 0)
        XCTAssertEqual(sequence.currentValue, nil)
    }
    
    func testResizeAndReshuffle_size0_noStartIndex() {
        
        sequence.resizeAndReshuffle(size: 10)
        XCTAssertEqual(sequence.size, 10)
        XCTAssertEqual(sequence.currentValue, nil)
        
        sequence.resizeAndReshuffle(size: 0)
        XCTAssertEqual(sequence.size, 0)
        XCTAssertEqual(sequence.currentValue, nil)
    }
    
    func testResizeAndReshuffle_consecutiveSequenceUniqueness() {
        
        doTestResizeAndReshuffle_consecutiveSequenceUniqueness(3, 100, 33)
        doTestResizeAndReshuffle_consecutiveSequenceUniqueness(5, 100, 5)
        doTestResizeAndReshuffle_consecutiveSequenceUniqueness(10, 100, 2)
        doTestResizeAndReshuffle_consecutiveSequenceUniqueness(100, 100, 1)
        doTestResizeAndReshuffle_consecutiveSequenceUniqueness(500, 1000, 1)
        doTestResizeAndReshuffle_consecutiveSequenceUniqueness(1000, 1000, 1)
        doTestResizeAndReshuffle_consecutiveSequenceUniqueness(10000, 1000, 1)
    }
    
    // Any 2 consecutive sequences generated by resizeAndReshuffle() should be unique.
    private func doTestResizeAndReshuffle_consecutiveSequenceUniqueness(_ size: Int, _ repetitionCount: Int, _ maxNumberOfFailures: Int) {
        
        sequence.clear()
        sequence.resizeAndReshuffle(size: size)
        
        var sequenceBeforeReshuffle: [Int] = Array(sequenceArray)
        var sequenceAfterReshuffle: [Int]
        
        var failures: Int = 0
        
        for _ in 1...repetitionCount {
            
            sequence.resizeAndReshuffle(size: size)
            sequenceAfterReshuffle = Array(sequenceArray)
            
            // Size of the sequence should have remained the same.
            XCTAssertEqual(sequenceArrayCount, size)
            
            // Verify the sequence size property
            XCTAssertEqual(sequence.size, size)
            
            checkSequenceRangeAndUniqueness()
            
            if sequenceBeforeReshuffle.elementsEqual(sequenceAfterReshuffle) {
                failures.increment()
            }
            
            sequenceBeforeReshuffle = sequenceAfterReshuffle
        }
        
        XCTAssertLessThan(failures, maxNumberOfFailures)
    }
    
    func testResizeAndReshuffle_performance() {
        
        doTestResizeAndReshuffle_performance(100, 2)
        doTestResizeAndReshuffle_performance(500, 5)
        doTestResizeAndReshuffle_performance(1000, 10)
        doTestResizeAndReshuffle_performance(5000, 50)
        doTestResizeAndReshuffle_performance(10000, 100)
    }
    
    private func doTestResizeAndReshuffle_performance(_ size: Int, _ maxExecTime_msec: Double) {
        
        var totalExecTime: Double = 0
        let numRepetitions: Int = 5
        
        // Repeat a few times to get an accurate average execution time.
        for _ in 1...numRepetitions {
            
            // This is important. Must start with an empty sequence to force the sequence to actually allocate a new array each time.
            sequence.clear()
            XCTAssertEqual(sequence.size, 0)
            
            totalExecTime += executionTimeFor {
                sequence.resizeAndReshuffle(size: size, startWith: size / 2)
            }
            
            // Verify the sequence size property
            XCTAssertEqual(sequence.size, size)
        }
        
        let avgExecTime: Double = totalExecTime / Double(numRepetitions)
        XCTAssertLessThan(avgExecTime, maxExecTime_msec / 1000.0)
    }
    
    func testReshuffle_upTo100Elements() {
        doTestReshuffle_sizeRange(1...100, nil, false)
    }
    
    // Long running test: ~ 1 minute
    func testReshuffle_100To1000Elements_longRunning() {
        doTestReshuffle_sizeRange(101...1000, 50, false)
    }
    
    // Long running test: ~ 10 minutes
    func testReshuffle_moreThan1000Elements_longRunning() {
        doTestReshuffle_sizeRange(1001...10000, 50, false)
    }
    
    func testReshuffle_upTo100Elements_startWithEmptySequence() {
        doTestReshuffle_sizeRange(1...100, nil, true)
    }
    
    // Long running test: ~ 1 minute
    func testReshuffle_100To1000Elements_startWithEmptySequence_longRunning() {
        doTestReshuffle_sizeRange(101...1000, 50, true)
    }
    
    // Long running test: ~ 10 minutes
    func testReshuffle_moreThan1000Elements_startWithEmptySequence_longRunning() {
        doTestReshuffle_sizeRange(1001...10000, 50, true)
    }
    
    private func doTestReshuffle_sizeRange(_ sizeRange: ClosedRange<Int>, _ numberOfDontStartWithValues: Int?, _ clearSequenceBeforeEachTest: Bool) {
        
        for size in sizeRange {
            
            if clearSequenceBeforeEachTest {
                sequence.clear()
            }
            
            sequence.resizeAndReshuffle(size: size)
            
            var testDontStartWithValues: [Int]
            
            if let dontStartWithValuesCount = numberOfDontStartWithValues {
                
                // Test with random start values, limit count to the number specified.
                // Generate random numbers and use them as starting values in the tests.
                // Also test with the first and last elements
                testDontStartWithValues = [0, size - 1]
                
                for _ in 1...dontStartWithValuesCount {
                    testDontStartWithValues.append(Int.random(in: 1..<(size - 1)))
                }
                
            } else {
                
                // Test with all values from 0 to size - 1 as the start value.
                testDontStartWithValues = Array(0..<size)
            }
            
            for dontStartWith in testDontStartWithValues {
                doTestReshuffle(size, dontStartWith)
            }
        }
    }
    
    private func doTestReshuffle(_ size: Int, _ dontStartWith: Int) {
        
        sequence.reShuffle(dontStartWith: dontStartWith)
        
        // Ensure that the sequence is not pointing to any element (i.e. no iteration).
        XCTAssertNil(sequence.currentValue)
        
        // Size of the sequence should have remained the same.
        XCTAssertEqual(sequenceArrayCount, size)
        
        // Verify the sequence size property
        XCTAssertEqual(sequence.size, size)
        
        checkSequenceRangeAndUniqueness()
        
        // The first element should not equal dontStartWith
        if size > 1 {
            XCTAssertNotEqual(sequenceArray.first, dontStartWith)
        }
        
        // dontStartWith should be contained in the sequence.
        XCTAssertTrue(sequenceArray.contains(dontStartWith))
        
        // peekNext() should produce the first value, i.e. sequence should not have started yet.
        XCTAssertEqual(sequenceArray.first, sequence.peekNext())
    }
    
    func testReshuffle_consecutiveSequenceUniqueness() {
        
        // The larger the size of the sequence, the lesser the expected failure rate should be.
        
        doTestReshuffle_consecutiveSequenceUniqueness(3, 100, 50)
        doTestReshuffle_consecutiveSequenceUniqueness(5, 100, 5)
        doTestReshuffle_consecutiveSequenceUniqueness(10, 100, 2)
        doTestReshuffle_consecutiveSequenceUniqueness(100, 100, 1)
        doTestReshuffle_consecutiveSequenceUniqueness(1000, 1000, 1)
        doTestReshuffle_consecutiveSequenceUniqueness(10000, 1000, 1)
    }
    
    // Any 2 consecutive sequences generated by resizeAndReshuffle() should be unique, with a certain acceptable failure rate.
    private func doTestReshuffle_consecutiveSequenceUniqueness(_ size: Int, _ repetitionCount: Int, _ maxNumberOfFailures: Int) {
        
        sequence.resizeAndReshuffle(size: size)
        
        sequence.reShuffle(dontStartWith: 0)
        
        var sequenceBeforeReshuffle: [Int] = Array(sequenceArray)
        var sequenceAfterReshuffle: [Int]
        
        var failures: Int = 0
        
        for _ in 1...repetitionCount {
            
            sequence.reShuffle(dontStartWith: 0)
            sequenceAfterReshuffle = Array(sequenceArray)
            
            // Size of the sequence should have remained the same.
            XCTAssertEqual(sequenceArrayCount, size)
            
            // Verify the sequence size property
            XCTAssertEqual(sequence.size, size)
            
            if sequenceBeforeReshuffle.elementsEqual(sequenceAfterReshuffle) {
                failures.increment()
            }
            
            sequenceBeforeReshuffle = sequenceAfterReshuffle
        }
        
        XCTAssertLessThan(failures, maxNumberOfFailures)
    }
    
    func testReshuffle_performance() {
        
        doTestReshuffle_performance(100, 1)
        doTestReshuffle_performance(1000, 2)
        doTestReshuffle_performance(5000, 10)
        doTestReshuffle_performance(10000, 20)
    }
    
    private func doTestReshuffle_performance(_ size: Int, _ maxExecTime_msec: Double) {
        
        sequence.resizeAndReshuffle(size: size)
        
        var totalExecTime: Double = 0
        let numRepetitions: Int = 5
        
        // Repeat a few times to get an accurate average execution time.
        for _ in 1...numRepetitions {
            
            totalExecTime += executionTimeFor {
                sequence.reShuffle(dontStartWith: 0)
            }
            
            // Verify the sequence size property
            XCTAssertEqual(sequence.size, size)
        }
        
        let avgExecTime: Double = totalExecTime / Double(numRepetitions)
        
        XCTAssertLessThan(avgExecTime, maxExecTime_msec / 1000.0)
    }
    
    func testClear() {
        
        for size in [1, 2, 3, 5, 10, 100, 1000, 5000, 10000] {
            doTestClear(size)
        }
    }
    
    private func doTestClear(_ size: Int) {
        
        sequence.resizeAndReshuffle(size: size)
        XCTAssertEqual(sequenceArrayCount, size)
        
        sequence.clear()
        XCTAssertEqual(sequenceArrayCount, 0)
        XCTAssertEqual(sequence.size, 0)
        XCTAssertFalse(sequence.hasNext)
        
        // Ensure that the sequence is not pointing to any element.
        XCTAssertNil(sequence.currentValue)
    }
}
