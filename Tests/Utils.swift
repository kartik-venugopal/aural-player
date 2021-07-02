//
//  Utils.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

func executionTimeFor(_ task: () -> Void) -> Double {
    
    let startTime = CFAbsoluteTimeGetCurrent()
    task()
    return CFAbsoluteTimeGetCurrent() - startTime
}

func randomString(length: Int) -> String {
    
    let letters: NSString = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    let len = UInt32(letters.length)

    var randomString: String = ""

    for _ in 0 ..< length {
        
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }

    return randomString
}

extension CaseIterable where Self: RawRepresentable, AllCases == [Self] {
    
    static func randomCase() -> Self {
        return allCases[Int.random(in: allCases.indices)]
    }
}

func randomUnitState() -> EffectsUnitState {EffectsUnitState.randomCase()}

func randomNillableUnitState() -> EffectsUnitState? {
    
    if Float.random(in: 0...1) < 0.5 {
        return randomUnitState()
    } else {
        return nil
    }
}
