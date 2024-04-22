//
//  FilterBandsViewDelegate.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FilterPresetBandsTableViewDelegate: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    var preset: FilterPreset?
    
//    override func numberOfRows(in tableView: NSTableView) -> Int {
//        preset?.bands.count ?? 0
//    }
//
//    override func bandAtRow(_ row: Int) -> FilterBand? {
//        preset?.bands[row]
//    }
}

extension NSUserInterfaceItemIdentifier {
    
    // Table view column identifiers
    static let cid_filterBandsFreqColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Frequencies")
    static let cid_filterBandsTypeColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Type")
}
