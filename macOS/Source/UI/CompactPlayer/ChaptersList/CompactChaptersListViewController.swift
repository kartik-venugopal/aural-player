//
//  CompactChaptersListViewController.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class CompactChaptersListViewController: ChaptersListViewController {
    
    override var nibName: NSNib.Name? {"CompactChaptersList"}
    
    override var shouldRespondToTrackChange: Bool {
        true
    }
    
    override func createTitleCell(_ tableView: NSTableView, _ text: String, _ row: Int) -> ChaptersListTableCellView? {
        
        let cell = super.createTitleCell(tableView, text, row)
        
        if let textField = cell?.textField, textField.isTruncatingText {
            textField.toolTip = textField.stringValue
        }
        
        return cell
    }
}
