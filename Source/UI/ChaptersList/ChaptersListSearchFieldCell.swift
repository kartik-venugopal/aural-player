//
//  ChaptersListSearchFieldCell.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

class ChaptersListSearchIconCell: NSButtonCell {
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        self.image?.filledWithColor(systemColorScheme.primaryTextColor).draw(in: cellFrame)
    }
}
