//
//  VisualizerUIPersistenceTests.swift
//  Tests
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class VisualizerUIPersistenceTests: PersistenceTestCase {
    
    func testPersistence() {
        
        for _ in 1...100 {
            
            let options = VisualizerOptionsPersistentState(lowAmplitudeColor: randomColor(),
                                                           highAmplitudeColor: randomColor())
            
            let state = VisualizerUIPersistentState(type: .randomCase(),
                                                    options: options)
            
            doTestPersistence(serializedState: state)
        }
    }
}

// MARK: Equality comparison for model objects -----------------------------

extension VisualizerUIPersistentState: Equatable {
    
    static func == (lhs: VisualizerUIPersistentState, rhs: VisualizerUIPersistentState) -> Bool {
        lhs.type == rhs.type && lhs.options == rhs.options
    }
}

extension VisualizerOptionsPersistentState: Equatable {
    
    static func == (lhs: VisualizerOptionsPersistentState, rhs: VisualizerOptionsPersistentState) -> Bool {
        
        lhs.lowAmplitudeColor == rhs.lowAmplitudeColor &&
            lhs.highAmplitudeColor == rhs.highAmplitudeColor
    }
}

extension ColorPersistentState: Equatable {
    
    static func == (lhs: ColorPersistentState, rhs: ColorPersistentState) -> Bool {
        
        lhs.colorSpace == rhs.colorSpace &&
            CGFloat.approxEquals(lhs.alpha, rhs.alpha, accuracy: 0.001) &&
            CGFloat.approxEquals(lhs.black, rhs.black, accuracy: 0.001) &&
            CGFloat.approxEquals(lhs.blue, rhs.blue, accuracy: 0.001) &&
            CGFloat.approxEquals(lhs.cyan, rhs.cyan, accuracy: 0.001) &&
            CGFloat.approxEquals(lhs.green, rhs.green, accuracy: 0.001) &&
            CGFloat.approxEquals(lhs.magenta, rhs.magenta, accuracy: 0.001) &&
            CGFloat.approxEquals(lhs.red, rhs.red, accuracy: 0.001) &&
            CGFloat.approxEquals(lhs.white, rhs.white, accuracy: 0.001) &&
            CGFloat.approxEquals(lhs.yellow, rhs.yellow, accuracy: 0.001)
    }
}
