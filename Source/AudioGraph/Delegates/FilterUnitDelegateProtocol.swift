//
//  FilterUnitDelegateProtocol.swift
//  Aural
//
//  Copyright © 2023 Kartik Venugopal. All rights reserved.
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
    
    subscript(_ index: Int) -> FilterBand {get set}
    
    func addBand() -> (band: FilterBand, index: Int)
    
    func removeBand(at index: Int)
    
    var presets: FilterPresets {get}
}
