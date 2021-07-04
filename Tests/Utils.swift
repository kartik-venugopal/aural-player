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
    randomNillableValue {randomUnitState()}
}

func randomNillableValue<T>(_ producer: @escaping () -> T) -> T? where T: Any {
    
    if Float.random(in: 0...1) < 0.5 {
        return producer()
    } else {
        return nil
    }
}

extension Float {
    
    static func approxEquals(_ op1: Float?, _ op2: Float?, accuracy: Float) -> Bool {
        
        if op1 == nil {return op2 == nil}
        if op2 == nil {return false}
        
        guard let theOp1 = op1, let theOp2 = op2 else {return false}
        
        return theOp1.approxEquals(theOp2, accuracy: accuracy)
    }
    
    func approxEquals(_ other: Float, accuracy: Float) -> Bool {
        fabsf(self - other) <= accuracy
    }
}

extension Array where Element == Float {
    
    func approxEquals(_ other: [Float], accuracy: Float) -> Bool {
        
        if count != other.count {return false}
        
        if count == 0 {return true}
        
        for index in indices {
            
            if !self[index].approxEquals(other[index], accuracy: accuracy) {
                return false
            }
        }
        
        return true
    }
}

extension Double {
    
    func approxEquals(_ other: Double, accuracy: Double) -> Bool {
        fabs(self - other) <= accuracy
    }
    
    static func approxEquals(_ op1: Double?, _ op2: Double?, accuracy: Double) -> Bool {
        
        if op1 == nil {return op2 == nil}
        if op2 == nil {return false}
        
        guard let theOp1 = op1, let theOp2 = op2 else {return false}
        
        return theOp1.approxEquals(theOp2, accuracy: accuracy)
    }
}
