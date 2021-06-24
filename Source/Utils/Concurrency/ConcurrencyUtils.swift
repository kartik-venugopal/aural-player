//
//  ConcurrencyUtils.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class ConcurrencyUtils {
    
    static func executeSynchronized(_ lock: Any, closure: () -> Void) {
        
        objc_sync_enter(lock)
        closure()
        objc_sync_exit(lock)
    }
}

