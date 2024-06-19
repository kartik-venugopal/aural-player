//
//  SortOrderMenuItemView.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Cocoa

class SortOrderMenuItemView: NSView {
    
    @IBOutlet weak var btnAscending: NSButton!
    @IBOutlet weak var btnDescending: NSButton!
    
    var sortOrder: SortOrder {
        btnAscending.isOn ? .ascending : .descending
    }
    
    // Radio button group
    @IBAction func changeSortOrderAction(_ sender: NSButton) {}
}
