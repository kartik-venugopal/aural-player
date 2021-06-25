//
//  FilterUnitDelegateProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
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
    
    func addBand(_ band: FilterBand) -> Int
    
    func removeBands(_ indexSet: IndexSet)
    
    func removeAllBands()
    
    var presets: FilterPresets {get}
}
