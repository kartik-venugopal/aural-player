//
//  VariableRateNode.swift
//  Aural
//
//  Copyright © 2022 Kartik Venugopal. All rights reserved.
//
//  This software is licensed under the MIT software license.
//  See the file "LICENSE" in the project root directory for license terms.
//
import Foundation
import AVFoundation

///
/// Custom audio graph node that encapsulates all logic for variable playback rate.
///
/// The node offers 2 variable rate modes:
///
/// - Variable rate without pitch shift (i.e. playback rate is altered, without change in pitch)
/// - Variable rate with pitch shift (i.e. both playback rate and pitch are altered simultaneously and in sync)
///
class VariableRateNode {
 
    let timePitchNode: AVAudioUnitTimePitch
    let varispeedNode: AVAudioUnitVarispeed
    
    var avNodes: [AVAudioNode] {[timePitchNode, varispeedNode]}
    
    private static let octavesToCents: Float = 1200
    
    init() {
        
        timePitchNode = AVAudioUnitTimePitch()
        varispeedNode = AVAudioUnitVarispeed()
        
        bypass = AudioGraphDefaults.timeStretchState != .active
        rate = AudioGraphDefaults.timeStretchRate
        shiftPitch = AudioGraphDefaults.timeStretchShiftPitch
        overlap = AudioGraphDefaults.timeStretchOverlap
    }
    
    var bypass: Bool {
        
        didSet {
            
            if self.bypass {
                
                [timePitchNode, varispeedNode].forEach {$0.bypass = true}
                
            } else {
                
                timePitchNode.bypass = shiftPitch
                varispeedNode.bypass = !shiftPitch
            }
        }
    }
    
    var rate: Float {
        
        didSet {
            
            timePitchNode.rate = rate
            varispeedNode.rate = rate
        }
    }
    
    var shiftPitch: Bool {
        
        didSet {
            
            if !self.bypass {
                
                timePitchNode.bypass = shiftPitch
                varispeedNode.bypass = !shiftPitch
            }
        }
    }
    
    var pitch: Float {
        shiftPitch ? Self.octavesToCents * log2(rate) : 0
    }
    
    var overlap: Float {
        didSet {timePitchNode.overlap = overlap}
    }
}
