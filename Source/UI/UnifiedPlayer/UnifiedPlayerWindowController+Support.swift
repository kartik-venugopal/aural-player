//
//  UnifiedPlayerWindowController+Support.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import AppKit

extension NSTabView {
    
    func addAndAnchorSubView(forController controller: NSViewController) {
        
        let item = NSTabViewItem()
        addTabViewItem(item)
        item.view?.addSubview(controller.view)
        
        controller.view.anchorToSuperview()
    }
}

extension NSSplitView {
    
    func addAndAnchorSubView(_ subView: NSView, underArrangedSubviewAt index: Int) {
        
        arrangedSubviews[index].addSubview(subView)
        subView.anchorToSuperview()
    }
}

class UnifiedPlayerSplitView: NSSplitView {
    
    override func resetCursorRects() {
        // Do nothing
    }
}
