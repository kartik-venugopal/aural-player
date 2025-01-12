//
//  NSTableColumnExtensions.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

extension NSTableColumn {
    
    var isShown: Bool {!isHidden}
    
    func show() {
        isHidden = false
    }
    
    func hide() {
        isHidden = true
    }
    
    func toggleShowOrHide() {
        isHidden.toggle()
    }
}
