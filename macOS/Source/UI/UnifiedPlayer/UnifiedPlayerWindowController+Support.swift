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
    
    func addAndHorizontallyCenterSubView(forController controller: NSViewController) {
        
        let item = NSTabViewItem()
        addTabViewItem(item)
        item.view?.addSubview(controller.view)
        
        let cons = LayoutConstraintsManager(for: controller.view)
        
        cons.setWidth(480)
        cons.setHeight(200)
        cons.centerHorizontallyInSuperview()
        cons.setTop(relatedToTopOf: controller.view.superview!, offset: 0)
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
