//
//  DebuggingUtils.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Measures the execution time of a code block, in seconds.
/// Useful for estimating performance of a function or code block.
///
/// - Parameter task: The code block whose execution time is to be measured.
///
func measureExecutionTime(_ task: () -> Void) -> Double {
    
    let startTime = CFAbsoluteTimeGetCurrent()
    task()
    return CFAbsoluteTimeGetCurrent() - startTime
}

func measureTimeTry(_ task: () throws -> Void) throws -> Double {
    
    let startTime = CFAbsoluteTimeGetCurrent()
    try task()
    return CFAbsoluteTimeGetCurrent() - startTime
}
