//
//  ExclusiveAccessSemaphore.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Foundation

///
/// A specialized semaphore that provides exclusive (serial) access to a block of code by
/// utilizing a **DispatchSemaphore** with a value of 1.
///
/// Use of this class reduces repetition of boilerplate code.
///
class ExclusiveAccessSemaphore {
    
    ///
    /// The underlying semaphore used to provide exclusive access to a block of code.
    ///
    private let semaphore: DispatchSemaphore = DispatchSemaphore(value: 1)
    
    ///
    /// Executes a block of code after waiting till the semaphore allows access to the block.
    ///
    /// - Parameter task:   The block of code to execute.
    ///
    func executeAfterWait(_ task: () -> Void) {
        
        semaphore.wait()
        defer {semaphore.signal()}
        
        task()
    }
    
    ///
    /// Executes a block of code that returns (produces) a value, after waiting till the semaphore
    /// allows access to the block.
    ///
    /// - Parameter task:   The block of code to execute.
    ///
    func produceValueAfterWait<T>(_ task: () -> T) -> T where T: Any {
        
        semaphore.wait()
        defer {semaphore.signal()}
        
        return task()
    }
}
