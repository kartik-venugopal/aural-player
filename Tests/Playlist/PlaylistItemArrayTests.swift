//
//  PlaylistItemArrayTests.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import XCTest

class PlaylistItemArrayTests: AuralTestCase {
    
    // TODO: Tests with large arrays (~ 10,000 elements) and arbitrary indices.
    
    var arr: [Int] = []
    
    // MARK: moveItemsUp() tests --------------------------------------------------------------------------------

    func testMoveItemsUp_emptyArray() {
        
        arr = []
        
        let results = arr.moveItemsUp(IndexSet([0, 3]))
        
        XCTAssertEqual(results, [:])
        XCTAssertTrue(arr.elementsEqual([]))
    }
    
    func testMoveItemsUp_invalidIndices() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsUp(IndexSet([3, 5, 10, 15]))
        
        XCTAssertEqual(results, [:])
        XCTAssertTrue(arr.elementsEqual(Array(0..<10)))
    }
    
    func testMoveItemsUp_moveSingleItem_unmovable() {
        
        arr = [0]
        
        let results = arr.moveItemsUp(IndexSet([0]))
        
        XCTAssertEqual(results, [:])
        XCTAssertTrue(arr.elementsEqual([0]))
    }
    
    func testMoveItemsUp_moveSingleItem_movable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsUp(IndexSet([5]))
        
        XCTAssertEqual(results, [5: 4])
        XCTAssertTrue(arr.elementsEqual([0, 1, 2, 3, 5, 4, 6, 7, 8, 9]))
    }
    
    func testMoveItemsUp_moveAllItems_allUnmovable() {
        
        arr = [0, 1]
        
        let results = arr.moveItemsUp(IndexSet([0, 1]))
        
        XCTAssertEqual(results, [:])
        XCTAssertTrue(arr.elementsEqual([0, 1]))
    }
    
    func testMoveItemsUp_moveMultipleItems_someUnmovable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsUp(IndexSet([1, 0, 3]))
        
        XCTAssertEqual(results, [3: 2])
        XCTAssertTrue(arr.elementsEqual([0, 1, 3, 2, 4, 5, 6, 7, 8, 9]))
    }
    
    func testMoveItemsUp_moveMultipleItems_allMovable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsUp(IndexSet([5, 7, 9]))
        
        XCTAssertEqual(results, [5: 4, 7: 6, 9: 8])
        XCTAssertTrue(arr.elementsEqual([0, 1, 2, 3, 5, 4, 7, 6, 9, 8]))
    }
    
    func testMoveItemsUp_moveContiguousItems_unmovable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsUp(IndexSet([0, 2, 1]))
        
        XCTAssertEqual(results, [:])
        XCTAssertTrue(arr.elementsEqual(Array(0..<10)))
    }
    
    func testMoveItemsUp_moveContiguousItems_movable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsUp(IndexSet([5, 6, 7]))
        
        XCTAssertEqual(results, [5: 4, 6: 5, 7: 6])
        XCTAssertTrue(arr.elementsEqual([0, 1, 2, 3, 5, 6, 7, 4, 8, 9]))
    }
    
    func testMoveItemsUp_moveAllButOneItem_movable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsUp(IndexSet(1..<10))
        XCTAssertEqual(9, results.count)
        
        for oldIndex in 1..<10 {
            XCTAssertEqual(results[oldIndex], oldIndex - 1)
        }

        XCTAssertTrue(arr.elementsEqual([1, 2, 3, 4, 5, 6, 7, 8, 9, 0]))
    }
    
    // MARK: moveItemsDown() tests --------------------------------------------------------------------------------
    
    func testMoveItemsDown_emptyArray() {
        
        arr = []
        
        let results = arr.moveItemsDown(IndexSet([0, 3]))
        
        XCTAssertEqual(results, [:])
        XCTAssertTrue(arr.elementsEqual([]))
    }
    
    func testMoveItemsDown_invalidIndices() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsDown(IndexSet([3, 5, 10, 15]))
        
        XCTAssertEqual(results, [:])
        XCTAssertTrue(arr.elementsEqual(Array(0..<10)))
    }
    
    func testMoveItemsDown_singleElement_unmovable() {
        
        arr = [0]
        
        let results = arr.moveItemsDown(IndexSet([0]))
        
        XCTAssertEqual(results, [:])
        XCTAssertTrue(arr.elementsEqual([0]))
    }
    
    func testMoveItemsDown_moveSingleItem_movable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsDown(IndexSet([5]))
        
        XCTAssertEqual(results, [5: 6])
        XCTAssertTrue(arr.elementsEqual([0, 1, 2, 3, 4, 6, 5, 7, 8, 9]))
    }
    
    func testMoveItemsDown_moveAllItems_allUnmovable() {
        
        arr = [0, 1]
        
        let results = arr.moveItemsDown(IndexSet([0, 1]))
        
        XCTAssertEqual(results, [:])
        XCTAssertTrue(arr.elementsEqual([0, 1]))
    }
    
    func testMoveItemsDown_moveMultipleItems_someUnmovable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsDown(IndexSet([8, 9, 3]))
        
        XCTAssertEqual(results, [3: 4])
        XCTAssertTrue(arr.elementsEqual([0, 1, 2, 4, 3, 5, 6, 7, 8, 9]))
    }
    
    func testMoveItemsDown_moveMultipleItems_allMovable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsDown(IndexSet([5, 7, 3]))
        
        XCTAssertEqual(results, [5: 6, 7: 8, 3: 4])
        XCTAssertTrue(arr.elementsEqual([0, 1, 2, 4, 3, 6, 5, 8, 7, 9]))
    }
    
    func testMoveItemsDown_moveContiguousItems_unmovable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsDown(IndexSet([7, 9, 8]))
        
        XCTAssertEqual(results, [:])
        XCTAssertTrue(arr.elementsEqual(Array(0..<10)))
    }
    
    func testMoveItemsDown_moveContiguousItems_movable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsDown(IndexSet([5, 6, 7]))
        
        XCTAssertEqual(results, [5: 6, 6: 7, 7: 8])
        XCTAssertTrue(arr.elementsEqual([0, 1, 2, 3, 4, 8, 5, 6, 7, 9]))
    }
    
    func testMoveItemsDown_moveAllButOneItem_movable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsDown(IndexSet(0...8))
        XCTAssertEqual(9, results.count)
        
        for oldIndex in 0...8 {
            XCTAssertEqual(results[oldIndex], oldIndex + 1)
        }

        XCTAssertTrue(arr.elementsEqual([9, 0, 1, 2, 3, 4, 5, 6, 7, 8]))
    }
    
    // MARK: moveItemsToTop() tests --------------------------------------------------------------------------------

    func testMoveItemsToTop_emptyArray() {
        
        arr = []
        
        let results = arr.moveItemsToTop(IndexSet([0, 3]))
        
        XCTAssertEqual(results, [:])
        XCTAssertTrue(arr.elementsEqual([]))
    }
    
    func testMoveItemsToTop_invalidIndices() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsToTop(IndexSet([3, 5, 10, 15]))
        
        XCTAssertEqual(results, [:])
        XCTAssertTrue(arr.elementsEqual(Array(0..<10)))
    }
    
    func testMoveItemsToTop_singleElement_unmovable() {
        
        arr = [0]
        
        let results = arr.moveItemsToTop(IndexSet([0]))
        
        XCTAssertEqual(results, [:])
        XCTAssertTrue(arr.elementsEqual([0]))
    }
    
    func testMoveItemsToTop_moveSingleItem_movable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsToTop(IndexSet([5]))
        
        XCTAssertEqual(results, [5: 0])
        XCTAssertTrue(arr.elementsEqual([5, 0, 1, 2, 3, 4, 6, 7, 8, 9]))
    }
    
    func testMoveItemsToTop_moveAllItems_allUnmovable() {
        
        arr = [0, 1]
        
        let results = arr.moveItemsToTop(IndexSet([0, 1]))
        
        XCTAssertEqual(results, [:])
        XCTAssertTrue(arr.elementsEqual([0, 1]))
    }
    
    func testMoveItemsToTop_moveMultipleItems_someUnmovable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsToTop(IndexSet([1, 0, 3]))
        
        XCTAssertEqual(results, [3: 2])
        XCTAssertTrue(arr.elementsEqual([0, 1, 3, 2, 4, 5, 6, 7, 8, 9]))
    }
    
    func testMoveItemsToTop_moveMultipleItems_allMovable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsToTop(IndexSet([5, 7, 9]))
        
        XCTAssertEqual(results, [5: 0, 7: 1, 9: 2])
        XCTAssertTrue(arr.elementsEqual([5, 7, 9, 0, 1, 2, 3, 4, 6, 8]))
    }
    
    func testMoveItemsToTop_moveContiguousItems_unmovable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsToTop(IndexSet([0, 2, 1]))
        
        XCTAssertEqual(results, [:])
        XCTAssertTrue(arr.elementsEqual(Array(0..<10)))
    }
    
    func testMoveItemsToTop_moveContiguousItems_movable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsToTop(IndexSet([5, 6, 7]))
        
        XCTAssertEqual(results, [5: 0, 6: 1, 7: 2])
        XCTAssertTrue(arr.elementsEqual([5, 6, 7, 0, 1, 2, 3, 4, 8, 9]))
    }
    
    func testMoveItemsToTop_moveAllButOneItem_movable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsToTop(IndexSet(1..<10))
        XCTAssertEqual(9, results.count)
        
        for oldIndex in 1..<10 {
            XCTAssertEqual(results[oldIndex], oldIndex - 1)
        }

        XCTAssertTrue(arr.elementsEqual([1, 2, 3, 4, 5, 6, 7, 8, 9, 0]))
    }
    
    // MARK: moveItemsToBottom() tests --------------------------------------------------------------------------------
    
    func testMoveItemsToBottom_emptyArray() {
        
        arr = []
        
        let results = arr.moveItemsToBottom(IndexSet([0, 3]))
        
        XCTAssertEqual(results, [:])
        XCTAssertTrue(arr.elementsEqual([]))
    }
    
    func testMoveItemsToBottom_invalidIndices() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsToBottom(IndexSet([3, 5, 10, 15]))
        
        XCTAssertEqual(results, [:])
        XCTAssertTrue(arr.elementsEqual(Array(0..<10)))
    }
    
    func testMoveItemsToBottom_singleElement_unmovable() {
        
        arr = [0]
        
        let results = arr.moveItemsToBottom(IndexSet([0]))
        
        XCTAssertEqual(results, [:])
        XCTAssertTrue(arr.elementsEqual([0]))
    }
    
    func testMoveItemsToBottom_moveSingleItem_movable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsToBottom(IndexSet([5]))
        
        XCTAssertEqual(results, [5: arr.lastIndex])
        XCTAssertTrue(arr.elementsEqual([0, 1, 2, 3, 4, 6, 7, 8, 9, 5]))
    }
    
    func testMoveItemsToBottom_moveAllItems_allUnmovable() {
        
        arr = [0, 1]
        
        let results = arr.moveItemsToBottom(IndexSet([0, 1]))
        
        XCTAssertEqual(results, [:])
        XCTAssertTrue(arr.elementsEqual([0, 1]))
    }
    
    func testMoveItemsToBottom_moveMultipleItems_someUnmovable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsToBottom(IndexSet([8, 9, 3]))
        
        XCTAssertEqual(results, [3: 7])
        XCTAssertTrue(arr.elementsEqual([0, 1, 2, 4, 5, 6, 7, 3, 8, 9]))
    }
    
    func testMoveItemsToBottom_moveMultipleItems_allMovable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsToBottom(IndexSet([5, 7, 3]))
        
        XCTAssertEqual(results, [5: 8, 7: 9, 3: 7])
        XCTAssertTrue(arr.elementsEqual([0, 1, 2, 4, 6, 8, 9, 3, 5, 7]))
    }
    
    func testMoveItemsToBottom_moveContiguousItems_unmovable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsToBottom(IndexSet([7, 9, 8]))
        
        XCTAssertEqual(results, [:])
        XCTAssertTrue(arr.elementsEqual(Array(0..<10)))
    }
    
    func testMoveItemsToBottom_moveContiguousItems_movable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsToBottom(IndexSet([5, 6, 7]))
        
        XCTAssertEqual(results, [5: 7, 6: 8, 7: 9])
        XCTAssertTrue(arr.elementsEqual([0, 1, 2, 3, 4, 8, 9, 5, 6, 7]))
    }
    
    func testMoveItemsToBottom_moveAllButOneItem_movable() {
        
        arr = Array(0..<10)
        
        let results = arr.moveItemsToBottom(IndexSet(0...8))
        XCTAssertEqual(9, results.count)
        
        for oldIndex in 0...8 {
            XCTAssertEqual(results[oldIndex], oldIndex + 1)
        }

        XCTAssertTrue(arr.elementsEqual([9, 0, 1, 2, 3, 4, 5, 6, 7, 8]))
    }
}
