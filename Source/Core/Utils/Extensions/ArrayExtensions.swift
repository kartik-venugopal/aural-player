//
//  ArrayExtensions.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation
import OrderedCollections

extension Collection {
    
    var isNonEmpty: Bool {count > 0}
    
    var lastIndex: Int {count - 1}
}

extension Array {
    
    @inlinable
    @inline(__always)
    func categorizeOneToManyBy<C>(_ categorizingFunction: (Element) -> C) -> [C: [Element]] where C: Hashable {
        
        var map: [C: [Element]] = [:]
        
        for item in self {
            
            let category: C = categorizingFunction(item)
            map[category, default: []].append(item)
        }
        
        return map
    }
    
    func categorizeOneToOneBy<C>(_ categorizingFunction: (Element) -> C) -> [C: Element] where C: Hashable {
        
        var map: [C: Element] = [:]
        
        for item in self {
            map[categorizingFunction(item)] = item
        }
        
        return map
    }
}

// TODO: Replace Range / ClosedRange with IndexSet

extension Array where Element: Hashable {
    
    mutating func addItems(_ items: OrderedSet<Element>) -> ClosedRange<Int> {
        
        let firstIndex: Int = self.count
        self.append(contentsOf: items)
        
        return firstIndex...self.lastIndex
    }
}

extension Array where Element: Equatable {
    
    mutating func removeItem(_ item: Element) -> Int? {
        
        if let index = self.firstIndex(of: item) {
            
            self.remove(at: index)
            return index
        }
        
        return nil
    }
    
    mutating func removeItems(_ items: [Element]) -> IndexSet {

        // Collect and sort indices before removing items
        let indices: [Int] = items.compactMap {self.firstIndex(of: ($0))}
                                    .sortedDescending()
        
        indices.forEach {self.remove(at: $0)}
        
        return IndexSet(indices)
    }
    
    mutating func moveItemsUp(_ items: [Element]) -> [Int: Int] {
        return moveItemsUp(from: IndexSet(items.compactMap {self.firstIndex(of: $0)}))
    }

    mutating func moveItemsDown(_ items: [Element]) -> [Int: Int] {
        return moveItemsDown(from: IndexSet(items.compactMap {self.firstIndex(of: $0)}))
    }
    
    mutating func moveItemsToTop(_ items: [Element]) -> [Int: Int] {
        return moveItemsToTop(from: IndexSet(items.compactMap {self.firstIndex(of: $0)}))
    }
    
    mutating func moveItemsToBottom(_ items: [Element]) -> [Int: Int] {
        return moveItemsToBottom(from: IndexSet(items.compactMap {self.firstIndex(of: $0)}))
    }
}

extension Array {
    
    func item(at index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

    mutating func addItem(_ item: Element) -> Int {
        
        self.append(item)
        return lastIndex
    }
    
    mutating func addItems(_ items: [Element]) -> ClosedRange<Int> {
        
        let firstIndex: Int = self.count
        self.append(contentsOf: items)
        
        return firstIndex...self.lastIndex
    }
    
    mutating func removeItem(at index: Int) -> Element? {
        return indices.contains(index) ? self.remove(at: index) : nil
    }
    
    @discardableResult mutating func removeItems(at indices: IndexSet) -> [Element] {
        
        return indices.sortedDescending()
            .compactMap {self.indices.contains($0) ? self.remove(at: $0) : nil}
    }
    
    mutating func removeAndInsertItem(_ sourceIndex: Int, _ destinationIndex: Int) {
        self.insert(self.remove(at: sourceIndex), at: destinationIndex)
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
    
    /*
       In response to a array reordering by drag and drop, and given source indices, a destination index, and the drop operation (on/above), determines which destination indices the source indexs will occupy.
    */
    mutating func dragAndDropItems(_ sourceIndices: IndexSet, _ dropIndex: Int) -> [Int: Int] {
        
        // The destination indices will depend on whether there are more source items above/below the drop index
        // Find out how many source items are above the dropIndex and how many below
        let dropsAboveDropIndex: Int = sourceIndices.count(in: 0..<dropIndex)
        let dropsBelowDropIndex: Int = sourceIndices.count - dropsAboveDropIndex
        let destinationIndices = [Int]((dropIndex - dropsAboveDropIndex)...(dropIndex + dropsBelowDropIndex - 1))
        
        // Make sure that the source indices are iterated in descending order, because tracks need to be removed from the bottom up.
        // Collect all the tracks into an array for re-insertion later.
        let sourceItems: [Element] = sourceIndices.sortedDescending().compactMap {self.removeItem(at: $0)}
        
        // Reverse the source items collection to match the order of the destination indices.
        // For each destination index, copy over a source item into the corresponding destination hole.
        for (sourceItem, destinationIndex) in zip(sourceItems.reversed(), destinationIndices) {
            self.insert(sourceItem, at: destinationIndex)
        }
        
        return Dictionary(uniqueKeysWithValues: zip(sourceIndices.sortedAscending(), destinationIndices))
    }
}

extension Sequence {
    
    func firstNonNilMappedValue<R>(_ mapFunc: (Element) -> R?) ->R? {

        for elm in self {

            if let result = mapFunc(elm) {
                return result
            }
        }

        return nil
    }
}

extension Sequence where Element: Equatable {
    
    func containsOneOf(_ options: Element?...) -> Bool {
        self.contains(where: {options.contains($0)})
    }
}

extension IndexSet {
    
    func sortedAscending() -> [Int] {
        sorted(by: <)
    }
    
    func sortedDescending() -> [Int] {
        sorted(by: >)
    }
}

extension Array where Element: Comparable {
    
    func sortedAscending() -> Self {
        sorted(by: <)
    }
    
    func sortedDescending() -> Self {
        sorted(by: >)
    }
}

extension Equatable {
    
    func equalsOneOf(_ array: Self?...) -> Bool {
        array.contains(self)
    }
}

func permute<S: Sequence, T: Sequence>(_ seq1: S, _ seq2: T) -> [(S.Element, T.Element)] {
    
    var permutations: [(S.Element, T.Element)] = []
    
    for elm1 in seq1 {
        
        for elm2 in seq2 {
            permutations.append((elm1, elm2))
        }
    }
    
    return permutations
}
