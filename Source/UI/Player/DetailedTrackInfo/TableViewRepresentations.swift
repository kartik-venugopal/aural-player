//
//  TableViewRepresentations.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

extension NSTableView {
    
    var jsonObject: NSDictionary {
        
        var dict: [NSString: AnyObject] = [:]
        
        for index in allRowIndices {
            
            if let keyCell = view(atColumn: 0, row: index, makeIfNecessary: true) as? NSTableCellView,
               let key = keyCell.text,
               let valueCell = view(atColumn: 1, row: index, makeIfNecessary: true) as? NSTableCellView,
               let value = valueCell.text {
                
                dict[key.prefix(key.count - 1) as NSString] = value as AnyObject
            }
        }
        
        return dict as NSDictionary
    }
    
    var htmlTable: [[HTMLText]] {
        
        var grid: [[HTMLText]] = [[]]
        
        for index in allRowIndices {
            
            if let keyCell = view(atColumn: 0, row: index, makeIfNecessary: true) as? NSTableCellView,
               let key = keyCell.text,
               let valueCell = view(atColumn: 1, row: index, makeIfNecessary: true) as? NSTableCellView,
               let value = valueCell.text {
                
                let keyCol = HTMLText(text: String(key.prefix(key.count - 1)), underlined: true, bold: false, italic: false, width: 300)
                let valueCol = HTMLText(text: value, underlined: false, bold: false, italic: false, width: nil)
                
                grid.append([keyCol, valueCol])
            }
        }
        
        return grid
    }
}
