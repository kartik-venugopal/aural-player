//
//  FilterUnitProtocol.swift
//  Aural
//
//  Copyright © 2025 Kartik Venugopal. All rights reserved.
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
    
    var numberOfBands: Int {get}
    
    var maximumNumberOfBands: Int {get}
    
    var numberOfActiveBands: Int {get}
    
    subscript(_ index: Int) -> FilterBand {get set}
    
    func addBand(ofType bandType: FilterBandType) -> (band: FilterBand, index: Int)
    
    func removeBands(at indices: IndexSet)
    
    var presets: FilterPresets {get}
}
