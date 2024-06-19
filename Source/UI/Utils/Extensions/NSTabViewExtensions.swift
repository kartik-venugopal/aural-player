//
//  NSTabViewExtensions.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

extension NSTabView {
    
    var selectedIndex: Int {
        
        if let selectedItem = selectedTabViewItem {
            return indexOfTabViewItem(selectedItem)
        }
        
        return 0
    }
    
    func previousTab(_ sender: Any) {
        
        let selIndex = selectedIndex
        
        if selIndex >= 1 {
            selectPreviousTabViewItem(sender)
        } else {
            selectLastTabViewItem(sender)
        }
    }
    
    func nextTab(_ sender: Any) {
        
        let selIndex = selectedIndex
        
        if selIndex < tabViewItems.count - 1 {
            selectNextTabViewItem(sender)
        } else {
            selectFirstTabViewItem(sender)
        }
    }
}

extension NSDragOperation {
    
    // Signifies an invalid drag/drop operation
    static let invalidDragOperation: NSDragOperation = []
}
