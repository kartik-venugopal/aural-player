//
//  FilterUnitView.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FilterUnitView: NSView {
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var chart: FilterChart!
    @IBOutlet weak var bandsView: NSTabView!
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    func initialize(stateFunction: @escaping EffectsUnitStateFunction,
                    bandsDataFunction: @escaping () -> [FilterBand]) {
        
        chart.filterUnitStateFunction = stateFunction
        chart.bandsDataFunction = bandsDataFunction
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View update
    
    func refresh() {
        redrawChart()
    }
    
    func redrawChart() {
        chart.redraw()
    }
    
    func addBandView(_ view: NSView) {
        
        let numItems = bandsView.numberOfTabViewItems
        let title = "Band \(numItems)"
        
        let newItem = NSTabViewItem(identifier: title)
        newItem.label = title
        
        bandsView.addTabViewItem(newItem)
        newItem.view?.addSubview(view)
    }
    
    func selectTab(at index: Int) {
        bandsView.selectTabViewItem(at: index)
    }
    
    func removeTab(at index: Int) {
        bandsView.removeTabViewItem(bandsView.tabViewItem(at: index))
    }
    
    func removeAllTabs() {
        bandsView.tabViewItems.removeAll()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        redrawChart()
    }
}
