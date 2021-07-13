//
//  NSTableColumnExtensions.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

extension NSTableColumn {
    
    var isShown: Bool {!self.isHidden}
    
    func show() {
        self.isHidden = false
    }
    
    func hide() {
        self.isHidden = true
    }
    
    func toggleShowOrHide() {
        self.isHidden.toggle()
    }
}
