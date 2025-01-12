//
//  IndexSetExtensions.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

extension IndexSet {

    // Convenience function to convert an IndexSet to an array
    func toArray() -> [Int] {map {$0}}
}
