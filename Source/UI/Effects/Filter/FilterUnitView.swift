//
//  FilterUnitView.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FilterUnitView: NSView {
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var chart: FilterChart!
    
    @IBOutlet weak var bandsTable: NSTableView!
    
    @IBOutlet weak var btnAdd: NSPopUpButton!
    @IBOutlet weak var btnRemove: NSButton!
    
    // ------------------------------------------------------------------------
    
    // MARK: Services, utilities, helpers, and properties
    
    private static let noTabsShown: ClosedRange<Int> = (-1)...(-1)
    
    var filterUnit: FilterUnitDelegateProtocol = audioGraphDelegate.filterUnit
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    func initialize(stateFunction: @escaping EffectsUnitStateFunction,
                    bandsDataFunction: @escaping () -> [FilterBand]) {
        
        chart.bandsDataFunction = bandsDataFunction
    }
    
    func setBands(_ bands: [FilterBandView]) {
        updateCRUDButtonStates()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: View update
    
    func addBand(_ bandView: FilterBandView, selectNewTab: Bool) {
        
        redrawChart()
        updateCRUDButtonStates()
    }
    
    func removeSelectedBand() {
            
        redrawChart()
        updateCRUDButtonStates()
    }
    
    func stateChanged() {
        redrawChart()
    }
    
    // ------------------------------------------------------------------------
    
    // MARK: Helper functions
    
    private let maxNumBands: Int = 31
    
    private func updateCRUDButtonStates() {
        
        let numberOfBands = filterUnit.numberOfBands
        
        btnAdd.isEnabled = numberOfBands < maxNumBands
        btnRemove.isEnabled = numberOfBands > 0
    }
    
    func redrawChart() {
        chart.redraw()
    }
}
