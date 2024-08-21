//
//  ReplayGainUnitDelegateProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//  

import Foundation

protocol ReplayGainUnitDelegateProtocol: EffectsUnitDelegateProtocol {
    
    var mode: ReplayGainMode {get set}
    
    // NOTE - Replay gain values will be set upon track change (values derived from metadata).
    
    // TODO: Maybe allow the user to specify whether to reset the pre-amp when no replay gain metadata is available ???
    
    var preAmp: Float {get set}
    
    var preventClipping: Bool {get set}
    
    func applyGain(_ replayGain: ReplayGain?)
    
    var appliedGain: Float {get}
    
    var dataSource: ReplayGainDataSource {get set}
    
    var maxPeakLevel: ReplayGainMaxPeakLevel {get set}
    
    var hasAppliedGain: Bool {get}
    
    var effectiveGain: Float {get}
    
    func initiateScan(forFile file: URL)
    
    var isScanning: Bool {get}
}
