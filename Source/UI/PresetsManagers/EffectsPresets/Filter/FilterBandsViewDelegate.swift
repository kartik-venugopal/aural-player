//
//  FilterBandsViewDelegate.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FilterBandsViewDelegate: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    var preset: FilterPreset?
    
    var allowSelection: Bool = true
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        preset?.bands.count ?? 0
    }
    
    // Returns a view for a single row
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        GenericTableRowView()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        guard let colID = tableColumn?.identifier,
              let band = preset?.bands[row] else {return nil}
        
        var cellText: String
        
        switch colID {
            
        case .cid_filterBandsFreqColumn:
            
            switch band.type {
                
            case .bandPass, .bandStop:
                
                cellText = String(format: "[ %@ - %@ ]", formatFreqNumber(band.minFreq!), formatFreqNumber(band.maxFreq!))
                
            case .lowPass:
                
                cellText = String(format: "< %@", formatFreqNumber(band.maxFreq!))
                
            case .highPass:
                
                cellText = String(format: "> %@", formatFreqNumber(band.minFreq!))
            }
            
        case .cid_filterBandsTypeColumn:
            
            cellText = band.type.description
            
        default: return nil
            
        }
        
        return createCell(tableView, colID, row, cellText)
    }
    
    private func formatFreqNumber(_ freq: Float) -> String {
        
        let num = freq.roundedInt
        if num % 1000 == 0 {
            return String(format: "%d KHz", num / 1000)
        } else {
            return String(format: "%d Hz", num)
        }
    }
    
    private func createCell(_ tableView: NSTableView, _ id: NSUserInterfaceItemIdentifier, _ row: Int, _ text: String) -> BasicTableCellView? {
        
        guard let cell = tableView.makeView(withIdentifier: id, owner: nil) as? BasicTableCellView else {return nil}
        
        cell.text = text
        cell.unselectedTextFont = standardFontSet.mainFont(size: 10)
        cell.selectedTextFont = standardFontSet.mainFont(size: 10)
        cell.rowSelectionStateFunction = {[weak tableView] in tableView?.isRowSelected(row) ?? false}
        
        return cell
    }
    
    // Row selection
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return allowSelection
    }
}

extension NSUserInterfaceItemIdentifier {
    
    // Table view column identifiers
    static let cid_filterBandsFreqColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Frequencies")
    static let cid_filterBandsTypeColumn: NSUserInterfaceItemIdentifier = NSUserInterfaceItemIdentifier("cid_Type")
}
