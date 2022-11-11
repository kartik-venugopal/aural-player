//
//  MasterUnitDelegateProtocol.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

///
/// A functional contract for a delegate representing the Master effects unit.
///
/// Acts as a middleman between the Effects UI and the Master effects unit,
/// providing a simplified interface / facade for the UI layer to control the Master effects unit.
///
/// - SeeAlso: `MasterUnit`
///
protocol MasterUnitDelegateProtocol: EffectsUnitDelegateProtocol {
    
    var presets: MasterPresets {get}
    
    func applyPreset(_ preset: MasterPreset)
}
