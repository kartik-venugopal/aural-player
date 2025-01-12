//
//  AuralTabView.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

/* 
    A custom tab view that makes it easier to use custom buttons to switch tabs
 
    NOTE: In order to set up an AuralTabView in Interface Builder, perform the following steps:
 
        - Set up the desired number of tab view items, as instances of AuralTabViewItem
        - Create the custom buttons, one for each tab
        - Set the button tag values to correspond to their respective tab indexes
        - Connect outlets from each tab view item's tabButton property to the corresponding button
 */
class AuralTabView: NSTabView {
    
    private var indexedViews: [NSView: Int] = [NSView: Int]()
    
    private var curIndex: Int = 0
    
    // The tab view items cast to AuralTabViewItem
    var items: [AuralTabViewItem] {
        return self.tabViewItems as! [AuralTabViewItem]
    }
    
    // One time setup
    override func awakeFromNib() {
    
        // Set button actions to switch to the appropriate tab when clicked
        for item in items {
            
            item.tabButton.action = #selector(self.selectTab(_:))
            item.tabButton.target = self
        }
    }
    
    // Adds a set of views, one under each tab's view, in the given order
    func addViewsForTabs(_ views: [NSView]) {
        
        for i in 0..<views.count {
            self.tabViewItem(at: i).view?.addSubview(views[i])
            indexedViews[views[i]] = i
        }
    }
    
    // Action function for custom tab buttons. The button's tag value is interpreted as the index of the tab to be selected.
    @objc func selectTab(_ sender: NSButton) {
        self.selectTabViewItem(at: sender.tag)
    }
    
    func showView(_ view: NSView) {
        selectTabViewItem(at: indexedViews[view]!)
    }
    
    // Updates tab button states
    override func selectTabViewItem(at index: Int) {
        
        super.selectTabViewItem(at: index)
        
        items.forEach {$0.tabButton.off()}
        (self.tabViewItem(at: index) as? AuralTabViewItem)?.tabButton.on()
        
        curIndex = index
    }
    
    func previousTab() {
        
        if curIndex >= 1 {
            selectTabViewItem(at: curIndex - 1)
        } else {
            selectTabViewItem(at: items.count - 1)
        }
    }
    
    func nextTab() {
        
        if curIndex < items.count - 1 {
            selectTabViewItem(at: curIndex + 1)
        } else {
            selectTabViewItem(at: 0)
        }
    }
}

// A custom tab view item that has an associated tab button. Instances of this class are intended to be used with an AuralTabView.
class AuralTabViewItem: NSTabViewItem {
    @IBOutlet weak var tabButton: NSButton!
}
