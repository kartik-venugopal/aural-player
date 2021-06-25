//
//  NSControlExtensions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

extension NSControl {
    
    var isDisabled: Bool {!isEnabled}
    
    // TODO: Why not just set the flag to true/false here ???
    // Is there an overriden function somewhere in a subview ?
    @objc func enable() {
        self.isEnabled = true
    }
    
    // TODO: Why not just set the flag to true/false here ???
    // Is there an overriden function somewhere in a subview ?
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
