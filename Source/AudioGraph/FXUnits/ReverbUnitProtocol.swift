//
//  ReverbUnitProtocol.swift
//  Aural
//
//  Copyright © 2021 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation

///
/// A functional contract for an effects unit that applies a "reverb" effect, i.e. reverberation. The result
/// is that the output audio is perceived as being more roomy, as if it has traveled a distance, bounced
/// off walls and other barriers, i.e. that the sound has "reverberated".
///
protocol ReverbUnitProtocol: EffectsUnitProtocol {
    
    var space: ReverbSpaces {get set}
    
    var amount: Float {get set}
}
