//
//  FilterUnitDelegate.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import AVFoundation

class FilterUnitDelegate: EffectsUnitDelegate<FilterUnit>, FilterUnitDelegateProtocol {

    var presets: FilterPresets {return unit.presets}
    
    var bands: [FilterBand] {
        
        get {unit.bands}
        set {unit.bands = newValue}
    }
    
    func addBand(_ band: FilterBand) -> Int {
        return unit.addBand(band)
    }
    
    func updateBand(_ index: Int, _ band: FilterBand) {
        unit.updateBand(index, band)
    }
    
    func removeBands(_ indexSet: IndexSet) {
        unit.removeBands(indexSet)
    }
    
    func removeAllBands() {
        unit.removeAllBands()
    }
    
    func getBand(_ index: Int) -> FilterBand {
        return unit.getBand(index)
    }
}
