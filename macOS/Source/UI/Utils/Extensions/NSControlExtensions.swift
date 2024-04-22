//
//  NSControlExtensions.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

extension NSControl {
    
    var isDisabled: Bool {!isEnabled}
    
    @objc func enable() {
        self.isEnabled = true
    }
    
    @objc func disable() {
        self.isEnabled = false
    }
    
    @objc func enableIf(_ condition: Bool) {
        self.isEnabled = condition
    }
    
    @objc func disableIf(_ condition: Bool) {
        self.isEnabled = !condition
    }
}
