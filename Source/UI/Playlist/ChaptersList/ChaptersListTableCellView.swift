//
//  ChaptersListTableCellView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  
import Cocoa

class ChaptersListTableCellView: BasicTableCellView {
    
    private lazy var textFieldConstraintsManager = LayoutConstraintsManager(for: textField!)
    
    // Constraints
    func realignText(yOffset: CGFloat) {

        textFieldConstraintsManager.removeAll(withAttributes: [.bottom])
        textFieldConstraintsManager.setBottom(relatedToBottomOf: self, offset: yOffset)
    }
}
