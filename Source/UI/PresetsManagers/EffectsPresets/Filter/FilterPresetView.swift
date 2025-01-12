//
//  FilterPresetView.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Cocoa

class FilterPresetView: NSView {
    
    // ------------------------------------------------------------------------
    
    // MARK: UI fields
    
    @IBOutlet weak var chart: FilterChart!
    
    // ------------------------------------------------------------------------
    
    // MARK: UI initialization / life-cycle
    
    func initialize(stateFunction: @escaping EffectsUnitStateFunction,
                    bandsDataFunction: @escaping () -> [FilterBand]) {
        
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
    
    // ------------------------------------------------------------------------
    
    // MARK: Theming
    
    func applyFontScheme(_ fontScheme: FontScheme) {
        redrawChart()
    }
}
