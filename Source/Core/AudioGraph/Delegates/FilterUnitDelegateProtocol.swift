//
//  FilterUnitDelegateProtocol.swift
//  Aural
//
//  Copyright © 2024 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

///
/// A functional contract for a delegate representing the Filter effects unit.
///
/// Acts as a middleman between the Effects UI and the Filter effects unit,
/// providing a simplified interface / facade for the UI layer to control the Filter effects unit.
///
/// - SeeAlso: `FilterUnit`
///
protocol FilterUnitDelegateProtocol: EffectsUnitDelegateProtocol {

    var bands: [FilterBand] {get set}
    
    var numberOfBands: Int {get}
    
    var maximumNumberOfBands: Int {get}
    
    var numberOfActiveBands: Int {get}
    
    subscript(_ index: Int) -> FilterBand {get set}
    
    func addBand(ofType bandType: FilterBandType) -> (band: FilterBand, index: Int)
    
    func removeBands(atIndices indices: IndexSet)
    
    var presets: FilterPresets {get}
}
