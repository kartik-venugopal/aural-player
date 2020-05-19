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
    
    // MARK: size tests --------------------------------------------------------------------------------------------------------------
    
    func testSize_upTo100Elements_startFromEmptySequence() {
        
        for size in 1...100 {
            
            sequence.clear()
            sequence.resizeAndReshuffle(size: size)
            
            XCTAssertEqual(sequenceArrayCount, size)
            XCTAssertEqual(sequence.size, size)
        }
    }
    
    // Long running test: ~ 1 minute
    func testSize_100To1000Elements_startFromEmptySequence_longRunning() {
        
        for size in 101...1000 {
            
            sequence.clear()
            sequence.resizeAndReshuffle(size: size)
            
            XCTAssertEqual(sequenceArrayCount, size)
            XCTAssertEqual(sequence.size, size)
        }
    }
    
    // Long running test: ~ 1 minute
    func testSize_moreThan1000Elements_startFromEmptySequence_longRunning() {
        
        for size in 1001...10000 {
            
            sequence.clear()
            sequence.resizeAndReshuffle(size: size)
            
            XCTAssertEqual(sequenceArrayCount, size)
            XCTAssertEqual(sequence.size, size)
        }
    }
    
    func testSize_upTo100Elements() {
        
        for size in 1...100 {
            
            sequence.resizeAndReshuffle(size: size)
            
            XCTAssertEqual(sequenceArrayCount, size)
            XCTAssertEqual(sequence.size, size)
        }
    }
    
    // Long running test: ~ 1 minute
    func testSize_100To1000Elements_longRunning() {
        
        for size in 101...1000 {
            
            sequence.resizeAndReshuffle(size: size)
            
            XCTAssertEqual(sequenceArrayCount, size)
            XCTAssertEqual(sequence.size, size)
        }
    }
    
    // Long running test: ~ 1 minute
    func testSize_moreThan1000Elements_longRunning() {
        
        for size in 1001...10000 {
            
            sequence.resizeAndReshuffle(size: size)
            
            XCTAssertEqual(sequenceArrayCount, size)
            XCTAssertEqual(sequence.size, size)
        }
    }

    func testResizeAndReshuffle_upTo100Elements() {
        
        for size in 1...100 {
            
            doTestResizeAndReshuffle(size)
            
            for startValue in 0..<size {
                doTestResizeAndReshuffle(size, startValue)
            }
        }
    }
    
    // Long running test: ~ 1 minute
    func testResizeAndReshuffle_100To1000Elements_longRunning() {
        
        for size in 101...1000 {
            
            doTestResizeAndReshuffle(size)
            
            // Generate random numbers and use them as starting values in the tests.
            // Also test with the first and last elements
            var testStartValues: [Int] = [0, size - 1]
            for _ in 1...50 {
                testStartValues.append(Int.random(in: 1..<(size - 1)))
            }
            
            for startValue in testStartValues {
                doTestResizeAndReshuffle(size, startValue)
            }
        }
    }
    
    // Long running test: ~ 20 minutes
    func testResizeAndReshuffle_moreThan1000Elements_longRunning() {
        
        for size in 1001...10000 {
            
            doTestResizeAndReshuffle(size)
            
            // Generate random numbers and use them as starting values in the tests.
            // Also test with the first and last elements
            var testStartValues: [Int] = [0, size - 1]
            for _ in 1...50 {
                testStartValues.append(Int.random(in: 1..<(size - 1)))
            }
            
            for startValue in testStartValues {
                doTestResizeAndReshuffle(size, startValue)
            }
        }
    }
    
    private func doTestResizeAndReshuffle(_ size: Int, _ desiredStartValue: Int? = nil) {
        
        sequence.clear()
        sequence.resizeAndReshuffle(size: size, startWith: desiredStartValue)
        
        // Ensure that the sequence is pointing to either the first element or no element (i.e. nil),
        // depending on whether desiredStartValue is nil or not (i.e. iteration).
        XCTAssertEqual(desiredStartValue, sequence.currentValue)
        
        // Verify the sequence size property
        XCTAssertEqual(sequence.size, size)
        
        // Match the actual array count with the expected size.
        XCTAssertEqual(sequenceArrayCount, size)
        
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
        
        for size in 1...100 {
            
            sequence.clear()
            sequence.resizeAndReshuffle(size: size)
            
            for dontStartWith in 0..<size {
                doTestReshuffle(size, dontStartWith)
            }
        }
    }
    
    // Long running test: ~ 1 minute
    func testReshuffle_100To1000Elements_longRunning() {
        
        for size in 101...1000 {
            
            sequence.clear()
            sequence.resizeAndReshuffle(size: size)
            
            // Generate random numbers and use them as starting values in the tests.
            // Also test with the first and last elements
            var testDontStartWithValues: [Int] = [0, size - 1]
            for _ in 1...50 {
                testDontStartWithValues.append(Int.random(in: 1..<(size - 1)))
            }
            
            for dontStartWith in testDontStartWithValues {
                doTestReshuffle(size, dontStartWith)
            }
        }
    }
    
    // Long running test: ~ 10 minutes
    func testReshuffle_moreThan1000Elements_longRunning() {
        
        for size in 1001...10000 {
            
            sequence.clear()
            sequence.resizeAndReshuffle(size: size)
            
            // Generate random numbers and use them as starting values in the tests.
            // Also test with the first and last elements
            var testDontStartWithValues: [Int] = [0, size - 1]
            for _ in 1...25 {
                testDontStartWithValues.append(Int.random(in: 1..<(size - 1)))
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
    
    func testPrevious_noSequence() {
        
        // Ensure that the sequence is not pointing to any element.
        XCTAssertNil(sequence.currentValue)

        // previous() should produce nil when there is no sequence.
        // Calling previous() multiple times here should always produce the same result.
        
        for _ in 1...5 {
        
            XCTAssertNil(sequence.previous())
            
            // Ensure that the sequence is still not pointing to any element (i.e. no iteration).
            XCTAssertNil(sequence.currentValue)
        }
    }
    
    func testPrevious_sequenceNotStarted() {
        
        // Create but don't start the sequence.
        sequence.resizeAndReshuffle(size: 10)
        
        // Ensure that the sequence is not pointing to any element.
        XCTAssertNil(sequence.currentValue)
        
        // Calling previous() multiple times here should always produce the same result.
        for _ in 1...5 {
            
            // No previous element available when sequence has not started.
            XCTAssertNil(sequence.previous())
            
            // Also verify that no iteration was performed (i.e. still not pointing to any element).
            XCTAssertNil(sequence.currentValue)
        }
    }
    
    func testPrevious_atFirstElement() {
        
        // Create and start the sequence.
        sequence.resizeAndReshuffle(size: 10, startWith: 5)
        
        // Ensure that the sequence points to the first element).
        XCTAssertEqual(sequenceArray.first, sequence.currentValue)
        
        // Calling previous() multiple times here should always produce the same result.
        for _ in 1...5 {
            
            XCTAssertNil(sequence.previous())
            
            // Ensure that the calls to previous() did not result in any iteration (i.e. it still points to the first element).
            XCTAssertEqual(sequenceArray.first, sequence.currentValue)
        }
    }
    
    func testPrevious_atSecondElement() {
        
        sequence.resizeAndReshuffle(size: 10)
        
        // Iterate to the 2nd element.
        XCTAssertEqual(sequence.next(repeatMode: .off), sequenceArray[0])
        XCTAssertEqual(sequence.next(repeatMode: .off), sequenceArray[1])
        
        // Ensure sequence is pointing to the second element.
        XCTAssertEqual(sequenceArray[1], sequence.currentValue)
        
        // Perform the test.
        let previous = sequence.previous()
        XCTAssertNotNil(previous)
        
        // Previous value should equal the first element.
        XCTAssertEqual(previous, sequenceArray.first)
        
        // Ensure that the call to previous() resulted in iteration to the first element.
        XCTAssertEqual(sequenceArray.first, sequence.currentValue)
        
        // Any further calls should result in nil
        for _ in 1...5 {
            
            XCTAssertNil(sequence.previous())
            
            // Ensure sequence is still pointing to the first element (i.e. no iteration).
            XCTAssertEqual(sequenceArray.first, sequence.currentValue)
        }
    }
    
    func testPrevious_iterateBackwardsFromTheEnd() {
        
        sequence.resizeAndReshuffle(size: 1000)
        
        // Iterate to the last element.
        for _ in 0..<sequenceArray.count {
            _ = sequence.next(repeatMode: .off)
        }
        
        // Ensure sequence is pointing to the last element.
        XCTAssertEqual(sequenceArray.last, sequence.currentValue)
        
        // Iterate backwards, invoking previous()
        var cursor: Int = sequenceArray.count - 1
        while cursor > 0 {
        
            let previous = sequence.previous()
            XCTAssertNotNil(previous)
            XCTAssertEqual(previous, sequenceArray[cursor - 1])
            
            // Ensure sequence is now pointing to the element at index = cursor - 1 (i.e. iteration).
            XCTAssertEqual(sequenceArray[cursor - 1], sequence.currentValue)
            
            cursor.decrement()
        }
    }
    
    // MARK: next() tests ----------------------------------------------------------------------------------------------------
    
    func testNext_noSequence() {
        
        for repeatMode in RepeatMode.allCases {
            
            sequence.clear()
            
            // next() should produce nil, regardless of repeat mode.
            XCTAssertNil(sequence.next(repeatMode: repeatMode))
        }
    }
    
    func testNext_sequenceNotStarted() {
        
        for repeatMode in RepeatMode.allCases {
            
            sequence.clear()

            // Create but don't start the sequence.
            sequence.resizeAndReshuffle(size: 10)
            
            // Ensure sequence is not pointing to any element (i.e. no iteration), because it has not been started.
            XCTAssertNil(sequence.currentValue)
            
            // next() should produce the first element, regardless of repeat mode.
            XCTAssertEqual(sequenceArray.first, sequence.next(repeatMode: repeatMode))
            
            // Ensure sequence is now pointing to the first element (i.e. iteration).
            XCTAssertEqual(sequenceArray.first, sequence.currentValue)
        }
    }
    
    func testNext_atFirstElement() {
        
        for repeatMode in RepeatMode.allCases {
            
            sequence.clear()

            // Create and start the sequence.
            sequence.resizeAndReshuffle(size: 10, startWith: 5)
            
            // Ensure sequence is now pointing to the first element.
            XCTAssertEqual(sequenceArray.first, sequence.currentValue)
            
            // next() should produce the second element, regardless of repeat mode.
            XCTAssertEqual(sequenceArray[1], sequence.next(repeatMode: repeatMode))
            
            // Ensure sequence is now pointing to the second element (i.e. iteration).
            XCTAssertEqual(sequenceArray[1], sequence.currentValue)
        }
    }
    
    func testNext_atSecondLastElement() {
        
        for repeatMode in RepeatMode.allCases {
            
            sequence.clear()

            // Create but don't start the sequence.
            sequence.resizeAndReshuffle(size: 1000)
            
            // Ensure sequence is not pointing to any element (i.e. no iteration).
            XCTAssertNil(sequence.currentValue)
            
            // Iterate to the second-last element.
            for index in 0..<(sequenceArrayCount - 1) {
                XCTAssertEqual(sequence.next(repeatMode: repeatMode), sequenceArray[index])
            }
            
            // Ensure sequence is now pointing to the second-last element (i.e. iteration).
            XCTAssertEqual(sequenceArray[sequenceArrayCount - 2], sequence.currentValue)
            
            // next() should produce the last element, regardless of repeat mode.
            XCTAssertEqual(sequenceArray.last, sequence.next(repeatMode: repeatMode))
            
            // Ensure sequence is now pointing to the last element (i.e. iteration).
            XCTAssertEqual(sequenceArray.last, sequence.currentValue)
        }
    }
    
    func testNext_atLastElement_repeatOff() {
        
        // Create but don't start the sequence.
        sequence.resizeAndReshuffle(size: 1000)
        
        // Iterate to the last element.
        for index in 0..<sequenceArrayCount {
            XCTAssertEqual(sequence.next(repeatMode: .off), sequenceArray[index])
        }
        
        // Ensure sequence is now pointing to the last element (i.e. iteration).
        XCTAssertEqual(sequenceArray.last, sequence.currentValue)
            
        // next() should produce nil when not repeating the sequence.
        XCTAssertNil(sequence.next(repeatMode: .off))
        
        // Ensure sequence is still pointing to the last element (i.e. no iteration).
        XCTAssertEqual(sequenceArray.last, sequence.currentValue)
    }
    
    func testNext_atLastElement_repeatOne() {
        
        // Create but don't start the sequence.
        sequence.resizeAndReshuffle(size: 1000)
        
        // Iterate to the last element.
        for index in 0..<sequenceArrayCount {
            XCTAssertEqual(sequence.next(repeatMode: .one), sequenceArray[index])
        }
        
        // Ensure sequence is now pointing to the last element (i.e. iteration).
        XCTAssertEqual(sequenceArray.last, sequence.currentValue)
            
        // next() should produce nil when not repeating the sequence.
        XCTAssertNil(sequence.next(repeatMode: .one))
        
        // Ensure sequence is still pointing to the last element (i.e. iteration).
        XCTAssertEqual(sequenceArray.last, sequence.currentValue)
    }
    
    func testNext_atLastElement_repeatAll() {
        
        // Create but don't start the sequence.
        sequence.resizeAndReshuffle(size: 1000)
        let seqArrayBeforeReshuffle: [Int] = Array(sequenceArray)
        
        // Iterate to the last element.
        for index in 0..<sequenceArrayCount {
            XCTAssertEqual(sequence.next(repeatMode: .all), sequenceArray[index])
        }
        
        // Ensure sequence is now pointing to the last element (i.e. iteration).
        XCTAssertEqual(sequenceArray.last, sequence.currentValue)
        
        let lastElementBeforeReshuffle = sequenceArray.last!
            
        // next() should cause the sequence to be reshuffled, and a value to be produced, so the value should be non-nil.
        let next = sequence.next(repeatMode: .all)
        XCTAssertNotNil(next)
        
        let seqArrayAfterReshuffle: [Int] = Array(sequenceArray)
        let firstElementAfterReshuffle = seqArrayAfterReshuffle.first!
        
        // Check that next() produced the first element in the new sequence
        XCTAssertEqual(next, firstElementAfterReshuffle)
        
        // Ensure the order of the sequence elements changed (i.e. new sequence), and that the last element
        // in the old sequence is not equal the first element in the new sequence.
        // (so that no track plays twice in a row)
        XCTAssertFalse(seqArrayBeforeReshuffle.elementsEqual(seqArrayAfterReshuffle))
        XCTAssertNotEqual(lastElementBeforeReshuffle, firstElementAfterReshuffle)
        
        // Ensure sequence is now pointing to the first element of the new sequence (i.e. iteration).
        XCTAssertEqual(sequenceArray.first, sequence.currentValue)
    }
    
    // MARK: peekPrevious() tests ---------------------------------------------------------------------------------------
    
    func testPeekPrevious_noSequence() {
        
        // Ensure that the sequence is not pointing to any element.
        XCTAssertNil(sequence.currentValue)

        // peekPrevious() should produce nil when there is no sequence.
        // Calling peekPrevious() multiple times here should always produce the same result.
        
        for _ in 1...5 {
        
            XCTAssertNil(sequence.peekPrevious())
            
            // Ensure that the sequence is still not pointing to any element (i.e. no iteration).
            XCTAssertNil(sequence.currentValue)
        }
    }
    
    func testPeekPrevious_sequenceNotStarted() {
        
        // Create but don't start the sequence.
        sequence.resizeAndReshuffle(size: 10)
        
        // Ensure that the sequence is not pointing to any element.
        XCTAssertNil(sequence.currentValue)
        
        // Calling peekPrevious() multiple times here should always produce the same result.
        for _ in 1...5 {
            
            XCTAssertNil(sequence.peekPrevious())
            
            // Also verify that no iteration was performed (i.e. still not pointing to any element).
            XCTAssertNil(sequence.currentValue)
        }
    }
    
    func testPeekPrevious_atFirstElement() {
        
        // Create and start the sequence.
        sequence.resizeAndReshuffle(size: 10, startWith: 5)
        
        // Ensure that the sequence points to the first element).
        XCTAssertEqual(sequenceArray.first, sequence.currentValue)
        
        // Calling peekPrevious() multiple times here should always produce the same result.
        for _ in 1...5 {
            
            // When pointing to the first element, the previous element should be nil.
            XCTAssertNil(sequence.peekPrevious())
            
            // Ensure that the calls to peekPrevious() did not result in any iteration (i.e. it still points to the first element).
            XCTAssertEqual(sequenceArray.first, sequence.currentValue)
        }
    }
    
    func testPeekPrevious_atSecondElement() {
        
        sequence.resizeAndReshuffle(size: 10)
        
        // Iterate to the 2nd element.
        XCTAssertEqual(sequence.next(repeatMode: .off), sequenceArray[0])
        XCTAssertEqual(sequence.next(repeatMode: .off), sequenceArray[1])
        
        // Ensure sequence is pointing to the second element.
        XCTAssertEqual(sequenceArray[1], sequence.currentValue)
        
        // Perform the test.
        let previous = sequence.peekPrevious()
        XCTAssertNotNil(previous)
        
        // Previous value should equal the first element.
        XCTAssertEqual(previous, sequenceArray.first)
        
        // Ensure that the call to peekPrevious() resulted in no iteration (i.e. still pointing to the 2nd element)
        XCTAssertEqual(sequenceArray[1], sequence.currentValue)
        
        // Any further calls should result in the same value being produced (i.e. first element).
        for _ in 1...5 {
            
            XCTAssertEqual(previous, sequenceArray.first)
            
            // Ensure sequence is still pointing to the second element (i.e. no iteration).
            XCTAssertEqual(sequenceArray[1], sequence.currentValue)
        }
    }
    
    func testPeekPrevious_iterateBackwardsFromTheEnd() {
        
        sequence.resizeAndReshuffle(size: 1000)
        
        // Iterate to the last element.
        for _ in 0..<sequenceArray.count {
            _ = sequence.next(repeatMode: .off)
        }
        
        // Ensure sequence is pointing to the last element.
        XCTAssertEqual(sequenceArray.last, sequence.currentValue)
        
        // Iterate backwards
        var cursor: Int = sequenceArray.count - 1
        while cursor > 0 {
            
            // Ensure sequence is pointing to the element at index = cursor.
            XCTAssertEqual(sequenceArray[cursor], sequence.currentValue)
            
            // Then test peekPrevious().
            let previous = sequence.peekPrevious()
            XCTAssertNotNil(previous)
            XCTAssertEqual(previous, sequenceArray[cursor - 1])
            
            // Call previous() to actually iterate one element back.
            _ = sequence.previous()
            cursor.decrement()
        }
    }
    
    // MARK: peekNext() tests ---------------------------------------------------------------------------------------
    
    func testPeekNext_noSequence() {
        
        // Ensure sequence is not pointing to any element.
        XCTAssertNil(sequence.currentValue)
        
        // peekNext() should produce nil, even with repeated calls
        // No iteration should take place.
        for _ in 1...5 {
            XCTAssertNil(sequence.peekNext())
            XCTAssertNil(sequence.currentValue)
        }
    }
    
    func testPeekNext_sequenceNotStarted() {
        
        // Create but don't start the sequence.
        sequence.resizeAndReshuffle(size: 10)
        
        // Ensure sequence is not pointing to any element (i.e. no iteration), because it has not been started.
        XCTAssertNil(sequence.currentValue)
        
        // peekNext() should produce the first element, even with repeated calls.
        for _ in 1...5 {
            
            XCTAssertEqual(sequenceArray.first, sequence.peekNext())
            
            // Ensure sequence is still not pointing to any element (i.e. no iteration).
            XCTAssertNil(sequence.currentValue)
        }
    }
    
    func testPeekNext_atFirstElement() {
        
        // Create and start the sequence.
        sequence.resizeAndReshuffle(size: 10, startWith: 5)
        
        // Ensure sequence is now pointing to the first element.
        XCTAssertEqual(sequenceArray.first, sequence.currentValue)
        
        for _ in 1...5 {
            
            // peekNext() should produce the second element, even with repeated calls.
            XCTAssertEqual(sequenceArray[1], sequence.peekNext())
            
            // Ensure sequence is still pointing to the first element (i.e. no iteration).
            XCTAssertEqual(sequenceArray.first, sequence.currentValue)
        }
    }
    
    func testPeekNext_atSecondLastElement() {
        
        // Create but don't start the sequence.
        sequence.resizeAndReshuffle(size: 1000)
        
        // Ensure sequence is not pointing to any element (i.e. no iteration).
        XCTAssertNil(sequence.currentValue)
        
        // Iterate to the second-last element.
        for index in 0..<(sequenceArrayCount - 1) {
            XCTAssertEqual(sequence.next(repeatMode: .off), sequenceArray[index])
        }
        
        // Ensure sequence is now pointing to the second-last element (i.e. iteration).
        XCTAssertEqual(sequenceArray[sequenceArrayCount - 2], sequence.currentValue)
        
        // peekNext() should produce the last element, even with repeated calls.
        for _ in 1...5 {
            
            XCTAssertEqual(sequenceArray.last, sequence.peekNext())
            
            // Ensure sequence is still pointing to the second-last element (i.e. no iteration).
            XCTAssertEqual(sequenceArray[sequenceArrayCount - 2], sequence.currentValue)
        }
    }
    
    func testPeekNext_atLastElement() {
        
        // Create but don't start the sequence.
        sequence.resizeAndReshuffle(size: 1000)
        
        // Iterate to the last element.
        for index in 0..<sequenceArrayCount {
            XCTAssertEqual(sequence.next(repeatMode: .off), sequenceArray[index])
        }
        
        // Ensure sequence is now pointing to the last element (i.e. iteration).
        XCTAssertEqual(sequenceArray.last, sequence.currentValue)
            
        // peekNext() should always produce nil, even with repeated calls.
        for _ in 1...5 {
            
            XCTAssertNil(sequence.peekNext())
            
            // Ensure sequence is still pointing to the last element (i.e. no iteration).
            XCTAssertEqual(sequenceArray.last, sequence.currentValue)
        }
    }
    
    // MARK: hasPrevious tests ---------------------------------------------------------------------------------------
    
    func testHasPrevious_noSequence() {
        
        // Ensure that the sequence is not pointing to any element.
        XCTAssertNil(sequence.currentValue)

        // hasPrevious should produce false when there is no sequence.
        // Calling hasPrevious multiple times here should always produce the same result.
        for _ in 1...5 {
        
            XCTAssertFalse(sequence.hasPrevious)
            
            // Ensure that the sequence is still not pointing to any element (i.e. no iteration).
            XCTAssertNil(sequence.currentValue)
        }
    }
    
    func testHasPrevious_sequenceNotStarted() {
        
        // Create but don't start the sequence.
        sequence.resizeAndReshuffle(size: 10)
        
        // Ensure that the sequence is not pointing to any element.
        XCTAssertNil(sequence.currentValue)
        
        // Calling hasPrevious multiple times here should always produce the same result.
        for _ in 1...5 {
            
            // No previous element available when sequence has not started.
            XCTAssertFalse(sequence.hasPrevious)
            
            // Also verify that no iteration was performed (i.e. still not pointing to any element).
            XCTAssertNil(sequence.currentValue)
        }
    }
    
    func testHasPrevious_atFirstElement() {
        
        // Create and start the sequence.
        sequence.resizeAndReshuffle(size: 10, startWith: 5)
        
        // Ensure that the sequence points to the first element).
        XCTAssertEqual(sequenceArray.first, sequence.currentValue)
        
        // Calling hasPrevious multiple times here should always produce the same result.
        for _ in 1...5 {
            
            // When pointing to the first element, there should be no previous element.
            XCTAssertFalse(sequence.hasPrevious)
            
            // Ensure that the calls to hasPrevious did not result in any iteration (i.e. it still points to the first element).
            XCTAssertEqual(sequenceArray.first, sequence.currentValue)
        }
    }
    
    func testHasPrevious_atSecondElement() {
        
        sequence.resizeAndReshuffle(size: 10)
        
        // Iterate to the 2nd element.
        XCTAssertEqual(sequence.next(repeatMode: .off), sequenceArray[0])
        XCTAssertEqual(sequence.next(repeatMode: .off), sequenceArray[1])
        
        // Ensure sequence is pointing to the second element.
        XCTAssertEqual(sequenceArray[1], sequence.currentValue)
        
        // Any further calls should result in the same value being produced (i.e. true).
        for _ in 1...5 {
            
            XCTAssertTrue(sequence.hasPrevious)
            
            // Ensure sequence is still pointing to the second element (i.e. no iteration).
            XCTAssertEqual(sequenceArray[1], sequence.currentValue)
        }
    }
    
    func testHasPrevious_iterateBackwardsFromTheEnd() {
        
        sequence.resizeAndReshuffle(size: 1000)
        
        // Iterate to the last element.
        for _ in 0..<sequenceArray.count {
            _ = sequence.next(repeatMode: .off)
        }
        
        // Ensure sequence is pointing to the last element.
        XCTAssertEqual(sequenceArray.last, sequence.currentValue)
        
        // Iterate backwards
        var cursor: Int = sequenceArray.count - 1
        while cursor > 0 {
            
            // Ensure sequence is pointing to the element at index = cursor.
            XCTAssertEqual(sequenceArray[cursor], sequence.currentValue)
            
            // Then test hasPrevious.
            XCTAssertTrue(sequence.hasPrevious)
            
            // Call previous() to actually iterate one element back.
            _ = sequence.previous()
            cursor.decrement()
        }
    }
    
    // MARK: hasNext tests ---------------------------------------------------------------------------------------
    
    func testHasNext_noSequence() {
        
        // Ensure sequence is not pointing to any element.
        XCTAssertNil(sequence.currentValue)
        
        // hasNext should produce false, even with repeated calls
        // No iteration should take place.
        for _ in 1...5 {
            
            XCTAssertFalse(sequence.hasNext)
            XCTAssertNil(sequence.currentValue)
        }
    }
    
    func testHasNext_sequenceNotStarted() {
        
        // Create but don't start the sequence.
        sequence.resizeAndReshuffle(size: 10)
        
        // Ensure sequence is not pointing to any element (i.e. no iteration), because it has not been started.
        XCTAssertNil(sequence.currentValue)
        
        // hasNext should return true when sequence has not started, even with repeated calls.
        for _ in 1...5 {
            
            XCTAssertTrue(sequence.hasNext)
            
            // Ensure sequence is still not pointing to any element (i.e. no iteration).
            XCTAssertNil(sequence.currentValue)
        }
    }
    
    func testHasNext_atFirstElement() {
        
        // Create and start the sequence.
        sequence.resizeAndReshuffle(size: 10, startWith: 5)
        
        // Ensure sequence is now pointing to the first element.
        XCTAssertEqual(sequenceArray.first, sequence.currentValue)
        
        for _ in 1...5 {
            
            // hasNext should produce true, even with repeated calls.
            XCTAssertTrue(sequence.hasNext)
            
            // Ensure sequence is still pointing to the first element (i.e. no iteration).
            XCTAssertEqual(sequenceArray.first, sequence.currentValue)
        }
    }
    
    func testHasNext_atSecondLastElement() {
        
        // Create but don't start the sequence.
        sequence.resizeAndReshuffle(size: 1000)
        
        // Ensure sequence is not pointing to any element (i.e. no iteration).
        XCTAssertNil(sequence.currentValue)
        
        // Iterate to the second-last element.
        for index in 0..<(sequenceArrayCount - 1) {
            XCTAssertEqual(sequence.next(repeatMode: .off), sequenceArray[index])
        }
        
        // Ensure sequence is now pointing to the second-last element (i.e. iteration).
        XCTAssertEqual(sequenceArray[sequenceArrayCount - 2], sequence.currentValue)
        
        // hasNext should produce true, even with repeated calls.
        for _ in 1...5 {
            
            XCTAssertTrue(sequence.hasNext)
            
            // Ensure sequence is still pointing to the second-last element (i.e. no iteration).
            XCTAssertEqual(sequenceArray[sequenceArrayCount - 2], sequence.currentValue)
        }
    }
    
    func testHasNext_atLastElement() {
        
        // Create but don't start the sequence.
        sequence.resizeAndReshuffle(size: 1000)
        
        // Iterate to the last element.
        for index in 0..<sequenceArrayCount {
            XCTAssertEqual(sequence.next(repeatMode: .off), sequenceArray[index])
        }
        
        // Ensure sequence is now pointing to the last element (i.e. iteration).
        XCTAssertEqual(sequenceArray.last, sequence.currentValue)
            
        // hasNext should always produce false, even with repeated calls.
        for _ in 1...5 {
            
            XCTAssertFalse(sequence.hasNext)
            
            // Ensure sequence is still pointing to the last element (i.e. no iteration).
            XCTAssertEqual(sequenceArray.last, sequence.currentValue)
        }
    }
    
    // MARK: hasEnded tests ---------------------------------------------------------------------------------------
    
    func testHasEnded_noSequence() {
        
        // An empty sequence is never considered to have started or ended.
        XCTAssertFalse(sequence.hasEnded)
    }
    
    func testHasEnded_sequenceNotStarted() {
        
        // Create but don't start the sequence.
        sequence.resizeAndReshuffle(size: 10)
        
        // Ensure sequence is not pointing to any element (i.e. no iteration), because it has not been started.
        XCTAssertNil(sequence.currentValue)
        
        // hasEnded should return false when sequence has not started, even with repeated calls.
        for _ in 1...5 {
            
            XCTAssertFalse(sequence.hasEnded)
            
            // Ensure sequence is still not pointing to any element (i.e. no iteration).
            XCTAssertNil(sequence.currentValue)
        }
    }
    
    func testHasEnded_atFirstElement() {
        
        // Create and start the sequence.
        sequence.resizeAndReshuffle(size: 10, startWith: 5)
        
        // Ensure sequence is now pointing to the first element.
        XCTAssertEqual(sequenceArray.first, sequence.currentValue)
        
        for _ in 1...5 {
            
            // hasEnded should produce false, even with repeated calls.
            XCTAssertFalse(sequence.hasEnded)
            
            // Ensure sequence is still pointing to the first element (i.e. no iteration).
            XCTAssertEqual(sequenceArray.first, sequence.currentValue)
        }
    }
    
    func testHasEnded_atSecondLastElement() {
        
        // Create but don't start the sequence.
        sequence.resizeAndReshuffle(size: 1000)
        
        // Ensure sequence is not pointing to any element (i.e. no iteration).
        XCTAssertNil(sequence.currentValue)
        
        // Iterate to the second-last element.
        for index in 0..<(sequenceArrayCount - 1) {
            
            XCTAssertEqual(sequence.next(repeatMode: .off), sequenceArray[index])
            
            // hasEnded should produce false, throughout the loop.
            XCTAssertFalse(sequence.hasEnded)
        }
        
        // Ensure sequence is now pointing to the second-last element (i.e. iteration).
        XCTAssertEqual(sequenceArray[sequenceArrayCount - 2], sequence.currentValue)
        
        // hasEnded should still produce false, even with repeated calls.
        for _ in 1...5 {
            
            XCTAssertFalse(sequence.hasEnded)
            
            // Ensure sequence is still pointing to the second-last element (i.e. no iteration).
            XCTAssertEqual(sequenceArray[sequenceArrayCount - 2], sequence.currentValue)
        }
    }
    
    func testHasEnded_atLastElement() {
        
        // Create but don't start the sequence.
        sequence.resizeAndReshuffle(size: 1000)
        
        // Iterate to the last element.
        for index in 0..<sequenceArrayCount {
            
            // hasEnded should produce false, throughout the loop.
            XCTAssertFalse(sequence.hasEnded)
            
            XCTAssertEqual(sequence.next(repeatMode: .off), sequenceArray[index])
        }
        
        // Ensure sequence is now pointing to the last element (i.e. iteration).
        XCTAssertEqual(sequenceArray.last, sequence.currentValue)
            
        // hasEnded should now produce true, even with repeated calls, because sequence is now pointing to the last element.
        for _ in 1...5 {
            
            XCTAssertTrue(sequence.hasEnded)
            
            // Ensure sequence is still pointing to the last element (i.e. no iteration).
            XCTAssertEqual(sequenceArray.last, sequence.currentValue)
        }
    }
    
    func testHasEnded_atLastElement_afterReshuffle() {
        
        // Create but don't start the sequence.
        sequence.resizeAndReshuffle(size: 1000)
        
        // Iterate to the last element.
        for index in 0..<sequenceArrayCount {
            
            // hasEnded should produce false, throughout the loop.
            XCTAssertFalse(sequence.hasEnded)
            
            XCTAssertEqual(sequence.next(repeatMode: .off), sequenceArray[index])
        }
        
        // Ensure sequence is now pointing to the last element (i.e. iteration).
        XCTAssertEqual(sequenceArray.last, sequence.currentValue)
        
        // hasEnded should now produce true, even with repeated calls, because sequence is now pointing to the last element.
        for _ in 1...5 {
            
            XCTAssertTrue(sequence.hasEnded)
            
            // Ensure sequence is still pointing to the last element (i.e. no iteration).
            XCTAssertEqual(sequenceArray.last, sequence.currentValue)
        }
        
        // Trigger a sequence reshuffle by calling next() with repeatMode = .all (this will cause the creation of a new sequence)
        XCTAssertNotNil(sequence.next(repeatMode: .all))
        
        // Ensure sequence is pointing to the first element of the new sequence (i.e. iteration).
        XCTAssertEqual(sequenceArray.first, sequence.currentValue)
        
        // Now, hasEnded should produce false, as a new sequence has been created.
        for _ in 1...5 {
            
            XCTAssertFalse(sequence.hasEnded)
            
            // Ensure sequence is still pointing to the first element of the new sequence (i.e. no iteration).
            XCTAssertEqual(sequenceArray.first, sequence.currentValue)
        }
    }
}
