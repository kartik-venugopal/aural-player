//
//  FilterUnitProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for an effects unit that eliminates certain frequencies from the input audio signal.
///
protocol FilterUnitProtocol: EffectsUnitProtocol {
    
    var bands: [FilterBand] {get set}
    
    subscript(_ index: Int) -> FilterBand {get set}
    
    func addBand(_ band: FilterBand) -> Int
    
    func removeBands(_ indexSet: IndexSet)
    
    func removeAllBands()
}
