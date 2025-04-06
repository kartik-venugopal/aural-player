////
////  FilterUnitDelegate.swift
////  Aural
////
////  Copyright © 2025 Kartik Venugopal. All rights reserved.
////
////  This software is licensed under the MIT software license.
////  See the file "LICENSE" in the project root directory for license terms.
////
//import AVFoundation
//
/////
///// A delegate representing the Filter effects unit.
/////
///// Acts as a middleman between the Effects UI and the Filter effects unit,
///// providing a simplified interface / facade for the UI layer to control the Filter effects unit.
/////
///// - SeeAlso: `FilterUnit`
///// - SeeAlso: `FilterUnitDelegateProtocol`
/////
//class FilterUnitDelegate: EffectsUnitDelegate<FilterUnit>, FilterUnitDelegateProtocol {
//
//    var presets: FilterPresets {unit.presets}
//    
//    var bands: [FilterBand] {
//        
//        get {unit.bands}
//        set {unit.bands = newValue}
//    }
//    
//    var numberOfBands: Int {
//        unit.bands.count
//    }
//    
//    var maximumNumberOfBands: Int {31}
//    
//    var numberOfActiveBands: Int {
//        unit.bands.filter {!$0.bypass}.count
//    }
//    
//    func addBand(ofType bandType: FilterBandType) -> (band: FilterBand, index: Int) {
//        unit.addBand(ofType: bandType)
//    }
//    
//    subscript(_ index: Int) -> FilterBand {
//        
//        get {unit[index]}
//        set(newBand) {
//            unit[index] = newBand
//        }
//    }
//    
//    func removeBands(atIndices indices: IndexSet) {
//        unit.removeBands(at: indices)
//    }
//}
