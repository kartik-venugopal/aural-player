//
//  IntExtensions.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

extension Int {
    
    static let ascendingIntComparator: (Int, Int) -> Bool = {$0 < $1}
    static let descendingIntComparator: (Int, Int) -> Bool = {$0 > $1}
    
    var signedString: String {
        self > 0 ? "+\(self)" : "\(self)"
    }
}

extension SignedInteger {
    
    mutating func increment() {
        self += 1
    }
    
    mutating func incrementAndGet() -> Self {
        
        self += 1
        return self
    }
    
    mutating func getAndIncrement() -> Self {
        
        let returnValue = self
        self += 1
        return returnValue
    }
    
    mutating func decrement() {
        self -= 1
    }
    
    mutating func decrementAndGet() -> Self {
        
        self -= 1
        return self
    }
    
    mutating func clamp(minValue: Self, maxValue: Self) {
        
        if self < minValue {
            self = minValue
            
        } else if self > maxValue {
            self = maxValue
        }
    }
    
    func clampedTo(minValue: Self, maxValue: Self) -> Self {
        
        if self < minValue {
            return minValue
            
        } else if self > maxValue {
            return maxValue
        }
        
        return self
    }
    
    mutating func clamp(minValue: Self) {
        
        if self < minValue {
            self = minValue
        }
    }
    
    mutating func clamp(maxValue: Self) {
        
        if self > maxValue {
            self = maxValue
        }
    }
}
