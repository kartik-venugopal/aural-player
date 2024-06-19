//
//  TimeUtils.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// Some utilities related to time and timing.
///

///
/// Measures the execution time of a code block, in milliseconds.
/// Useful for estimating performance of a function or code block.
///
/// - Parameter task: The code block whose execution time is to be measured.
///
func measureExecutionTime(_ task: () -> Void) -> Double {
    
    let startTime = nowCFTime()
    task()
    return (nowCFTime() - startTime) * 1000
}

func measureTimeTry(_ task: () throws -> Void) throws -> Double {
    
    let startTime = nowCFTime()
    try task()
    return (nowCFTime() - startTime) * 1000
}

func nowCFTime() -> Double {CFAbsoluteTimeGetCurrent()}
