//
//  OrderedDictionaryExtensions.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation
import OrderedCollections

extension OrderedDictionary {
    
    var indices: Range<Int> {
        0..<count
    }
    
    var lastIndex: Int {
        count - 1
    }
    
    @inlinable
    @inline(__always)
    mutating func insertItem(_ item: Value, forKey key: Key, at index: Int) {
        updateValue(item, forKey: key, insertingAt: index)
    }
    
    @discardableResult mutating func addMappings(_ mappings: [(key: Key, value: Value)]) -> IndexSet {
        
        let firstIndex: Int = count
        
        for (key, value) in mappings {
            self[key] = value
        }
        
        return IndexSet(firstIndex..<count)
    }
    
    mutating func moveItemUp(from index: Int) -> Int {

        swapAt(index, index - 1)
        return index - 1
    }
    
    mutating func moveItemDown(from index: Int) -> Int {

        swapAt(index, index + 1)
        return index + 1
    }

    mutating func moveItemsUp(from indices: IndexSet) -> [Int: Int] {
        
        // Indices need to be in ascending order, because items need to be moved up, one by one, from top to bottom of the array
        // Determine if there is a contiguous block of items at the top of the array, that cannot be moved. If there is, determine its size.
        let ascendingOldIndices = indices.sortedAscending()
        let unmovableBlockSize: Int = self.indices.first(where: {!ascendingOldIndices.contains($0)}) ?? 0
        
        guard areAscendingIndicesValid(ascendingOldIndices) && unmovableBlockSize < ascendingOldIndices.count else {return [:]}
        
        let oldIndices = (unmovableBlockSize..<ascendingOldIndices.count).map({ascendingOldIndices[$0]})
        return Dictionary(uniqueKeysWithValues: zip(oldIndices, oldIndices.map {moveItemUp(from: $0)}))
    }
    
    mutating func moveItemsDown(from indices: IndexSet) -> [Int: Int] {
        
        // Indices need to be in descending order, because items need to be moved down, one by one, from bottom to top of the array
        let descendingOldIndices = indices.sortedDescending()
        
        // Determine if there is a contiguous block of items at the bottom of the array, that cannot be moved. If there is, determine its size.
        let indicesReversed = self.indices.reversed()
        let unmovableBlockSize = self.lastIndex - (indicesReversed.first(where: {!descendingOldIndices.contains($0)}) ?? 0)
        
        guard areDescendingIndicesValid(descendingOldIndices) && unmovableBlockSize < descendingOldIndices.count else {return [:]}
        
        let oldIndices = (unmovableBlockSize..<descendingOldIndices.count).map({descendingOldIndices[$0]})
        return Dictionary(uniqueKeysWithValues: zip(oldIndices, oldIndices.map {moveItemDown(from: $0)}))
    }
    
    private func areAscendingIndicesValid(_ indices: [Int]) -> Bool {
        return !indices.isEmpty && indices.first! >= 0 && indices.last! < self.count && indices.count < self.count
    }
    
    private func areDescendingIndicesValid(_ indices: [Int]) -> Bool {
        return !indices.isEmpty && indices.first! < self.count && indices.last! >= 0 && indices.count < self.count
    }
    
    mutating func removeAndInsertItem(_ sourceIndex: Int, _ destinationIndex: Int) {

        let mapping = self.remove(at: sourceIndex)
        insertItem(mapping.value, forKey: mapping.key, at: destinationIndex)
    }
    
    mutating func moveItemsToTop(from indices: IndexSet) -> [Int: Int] {
        
        let sortedIndices = indices.sortedAscending()
        guard areAscendingIndicesValid(sortedIndices) else {return [:]}

        var results: [Int: Int] = [:]
        
        // Remove from original location and insert at the top, one after another, below the previous one
        // No need to move the item if the original location is the same as the destination
        for (newIndex, oldIndex) in sortedIndices.enumerated().filter({$0.0 != $0.1}) {
            
            self.removeAndInsertItem(oldIndex, newIndex)
            results[oldIndex] = newIndex
        }
        
        return results
    }
    
    mutating func moveItemsToBottom(from indices: IndexSet) -> [Int: Int] {
        
        let sortedIndices = indices.sortedDescending()
        guard areDescendingIndicesValid(sortedIndices) else {return [:]}
        
        var results: [Int: Int] = [:]

        // Remove from original location and insert at the bottom, one after another, above the previous one
        // No need to move the item if the original location is the same as the destination
        for (newIndex, oldIndex) in sortedIndices.enumerated().map({(self.lastIndex - $0, $1)}).filter({$0.0 != $0.1}) {
            
            self.removeAndInsertItem(oldIndex, newIndex)
            results[oldIndex] = newIndex
        }
        
        return results
    }
    
    @discardableResult mutating func removeItems(at indices: IndexSet) -> [Value] {
        indices.sortedDescending().map {remove(at: $0).value}
    }
    
    @discardableResult mutating func removeMappings(at indices: [Int]) -> [(key: Key, value: Value)] {
        indices.sortedDescending().map {remove(at: $0)}
    }
    
    mutating func dragAndDropItems(_ sourceIndices: IndexSet, _ dropIndex: Int) -> [Int: Int] {
        
        // The destination indices will depend on whether there are more source items above/below the drop index
        // Find out how many source items are above the dropIndex and how many below
        let dropsAboveDropIndex: Int = sourceIndices.count(in: 0..<dropIndex)
        let dropsBelowDropIndex: Int = sourceIndices.count - dropsAboveDropIndex
        let destinationIndices = [Int]((dropIndex - dropsAboveDropIndex)...(dropIndex + dropsBelowDropIndex - 1))
        
        // Make sure that the source indices are iterated in descending order, because tracks need to be removed from the bottom up.
        // Collect all the tracks into an array for re-insertion later.
        let sourceMappings: [(key: Key, value: Value)] = removeMappings(at: sourceIndices.sortedDescending())
        
        // Reverse the source items collection to match the order of the destination indices.
        // For each destination index, copy over a source item into the corresponding destination hole.
        for (sourceMapping, destinationIndex) in zip(sourceMappings.reversed(), destinationIndices) {
            insertItem(sourceMapping.value, forKey: sourceMapping.key, at: destinationIndex)
        }
        
        return Dictionary(uniqueKeysWithValues: zip(sourceIndices.sortedAscending(), destinationIndices))
    }
    
    mutating func sortValues(by comparator: (Value, Value) -> Bool) {
        
        self.sort(by: {kv1, kv2 in
            comparator(kv1.value, kv2.value)
        })
    }
}
