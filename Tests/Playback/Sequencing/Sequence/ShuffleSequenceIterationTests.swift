//
//  ShuffleSequenceIterationTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class ShuffleSequenceIterationTests: AuralTestCase {
    
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
