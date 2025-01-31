//
//  EnumExtensions.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

extension CaseIterable where Self: RawRepresentable, AllCases == [Self], RawValue: Equatable {
    
    // Iterates through the allCases ordered collection, returning the next case
    // in the collection, looping around to the first case when the end of
    // the collection is reached.
    //
    // This is useful when switching from one case to the next.
    //
    func toggleCase() -> Self {
        
        let cases = Self.allCases
        guard let myIndex = cases.firstIndex(where: {$0 == self}) else {return self}
        
        var nextIndex = myIndex + 1
        
        if nextIndex > cases.lastIndex {
            nextIndex = 0
        }
        
        return cases[nextIndex]
    }
}
